import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/services/http_service.dart';
import 'package:karmayogi_mobile/models/_api/user_action_model.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import 'dart:convert';
import 'dart:async';
import '../../models/_models/blended_program_enroll_response_model.dart';
import '../../models/_models/blended_program_unenroll_response_model.dart';
import '../../ui/pages/_pages/search/utils/search_helper.dart';
import './../../constants/index.dart';

class LearnService {
  final String coursesUrl = ApiUrl.baseUrl + ApiUrl.getTrendingCourses;
  final String coursesUrlV4 = ApiUrl.baseUrl + ApiUrl.getTrendingCoursesV4;

  final String myLearningEnrollment =
      ApiUrl.baseUrl + ApiUrl.getMyLearningEnrolmentlist;
  final String courseDetailsUrl = ApiUrl.baseUrl + ApiUrl.getCourseDetails;
  final String courseDataUrl = ApiUrl.baseUrl + ApiUrl.getCourse;
  final String courseLearnersUrl = ApiUrl.baseUrl + ApiUrl.getCourseLearners;
  final String courseAuthorsUrl = ApiUrl.baseUrl + ApiUrl.getCourseAuthors;

  final String getAllTopics = ApiUrl.baseUrl + ApiUrl.getAllTopics;
  final String courseProgressUrl = ApiUrl.baseUrl + ApiUrl.getCourseProgress;
  final String updateContentProgressUrl =
      ApiUrl.baseUrl + ApiUrl.updateContentProgress;
  final String readContentProgressUrl =
      ApiUrl.baseUrl + ApiUrl.readContentProgress;
  final String getBatchListUrl = ApiUrl.baseUrl + ApiUrl.getBatchList;
  final String autoEnrollBatchUrl = ApiUrl.baseUrl + ApiUrl.autoEnrollBatch;
  final String enrolProgramBatchUrl =
      ApiUrl.baseUrl + ApiUrl.enrollProgramBatch;
  final String requestBlendedProgramEnrollUrl =
      ApiUrl.baseUrl + ApiUrl.requestBlendedProgramEnrollUrl;
  final String requestBlendedProgramUnenroll =
      ApiUrl.baseUrl + ApiUrl.requestBlendedProgramUnenroll;
  final String getEnrollDetailsUrl = ApiUrl.baseUrl + ApiUrl.getEnrollDetails;
  final String getListOfCompetenciesUrl =
      ApiUrl.fracBaseUrl + ApiUrl.getListOfCompetencies;
  final String getAllCompetenciesUrl =
      ApiUrl.baseUrl + ApiUrl.getAllCompetencies;
  final String getAllCompetenciesUrlV6 =
      ApiUrl.baseUrl + ApiUrl.getAllCompetenciesV6;

  final String getCoursesByCompetenciesURL =
      ApiUrl.baseUrl + ApiUrl.getTrendingCourses;
  final String getAllProvidersUrl = ApiUrl.baseUrl + ApiUrl.getAllProviders;
  final String getTrendingSearchUrl = ApiUrl.baseUrl + ApiUrl.getTrendingSearch;
  final String playListSearchUrl = ApiUrl.baseUrl + ApiUrl.playListSearchUrl;
  final String playListReadUrl = ApiUrl.baseUrl + ApiUrl.playListReadUrl;
  final String exteranlCoursesUrl = ApiUrl.baseUrl + ApiUrl.getExternalCourses;
  final String getExteranlCourseContentsUrl =
      ApiUrl.baseUrl + ApiUrl.getExteranlCourseContentsUrl;
  final String getExtCourseListByUserIdUrl =
      ApiUrl.baseUrl + ApiUrl.getExtCourseListByUserId;
  final String getUserDataOnExtCourseUrl =
      ApiUrl.baseUrl + ApiUrl.getUserDataOnExtCourse;
  final String enrollExtCourseUrl = ApiUrl.baseUrl + ApiUrl.enrollExtCourse;

  static final _storage = FlutterSecureStorage();

  Future<dynamic> getListOfCompetencies() async {
    String? token = await _storage.read(key: Storage.authToken);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
    };

    Response response = await get(
        Uri.parse(AppConfiguration().useCompetencyv6
            ? getAllCompetenciesUrlV6
            : getAllCompetenciesUrl),
        headers: headers);

    return response;
  }

  Future<dynamic> getListOfProviders() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.get(
        apiUri: Uri.parse(getAllProvidersUrl),
        ttl: ApiTtl.getListOfProviders,
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!));
    return response;
  }

  Future<dynamic> getCourses(int pageNo, String searchText,
      List primaryCategory, List mimeType, List source,
      {bool isCollection = false,
      bool isInviteOnlyStandaloneAssesment = false,
      Duration? ttl,
      bool hasRequestBody = false,
      bool isModerated = false,
      Map<String, dynamic>? requestBody,
      List<String>? doIdList}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);
    String? profileStatus = await _storage.read(key: Storage.profileStatus);

    Map<String, dynamic> data;
    if (isCollection) {
      final response = await getCuratedHomeConfig();
      data = response['search']['searchReq'];
    } else if (hasRequestBody) {
      data = requestBody!;
    } else if (isModerated) {
      data = {
        "request": {
          "query": "",
          "filters": {
            "courseCategory": [
              PrimaryCategory.moderatedCourses.toLowerCase(),
              PrimaryCategory.moderatedProgram.toLowerCase(),
              PrimaryCategory.moderatedAssessment.toLowerCase()
            ],
            "contentType": [PrimaryCategory.course],
            "status": ["Live"],
            "secureSettings.isVerifiedKarmayogi":
                profileStatus == UserProfileStatus.verified ? null : 'No',
            "secureSettings.organisation": ["$deptId"],
            "identifier": doIdList != null ? doIdList : []
          },
          "sort_by": {"lastUpdatedOn": "desc"},
          "facets": ["mimeType"],
          "limit": 100,
          "offset": 0,
        }
      };
    } else if (isInviteOnlyStandaloneAssesment) {
      data = {
        "request": {
          "filters": {
            "primaryCategory": [PrimaryCategory.standaloneAssessment],
            "courseCategory": PrimaryCategory.inviteOnlyAssessment,
            "mimeType": [],
            "source": source,
            "mediaType": [],
            "contentType": [],
            "identifier": doIdList != null ? doIdList : []
          },
          "status": ["Live"],
          "fields": [],
          "sort_by": {"lastUpdatedOn": "desc"},
          "limit": COURSE_LISTING_PAGE_LIMIT,
          "offset": pageNo,
        }
      };
    } else {
      data = {
        "request": {
          "filters": {
            "primaryCategory": primaryCategory,
            "mimeType": [],
            "source": source,
            "mediaType": [],
            "contentType": [],
            "identifier": doIdList != null ? doIdList : []
          },
          "status": ["Live"],
          "fields": [],
          "query": searchText,
          "sort_by": {"lastUpdatedOn": "desc"},
          "limit": COURSE_LISTING_PAGE_LIMIT,
          "offset": pageNo,
        }
      };
    }

    var response = await HttpService.post(
      apiUri: Uri.parse(isModerated ? coursesUrlV4 : coursesUrl),
      //  / ttl: ttl ?? ApiTtl.compositeSearch,
      body: data,
      headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
    );

    return response;
  }

  Future<dynamic> getExternalCourseListByUser() async {
    String? userId = await _storage.read(key: Storage.wid);
    Response response = await get(
      Uri.parse(getExtCourseListByUserIdUrl + userId!),
      headers: NetworkHelper.getHeader(),
    );
    return response;
  }

  Future<dynamic> getUserDataOnExtCourse({required String courseId}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);
    Response response = await get(
        Uri.parse(getUserDataOnExtCourseUrl.replaceAll('#courseId', courseId)),
        headers:
            NetworkHelper.getCourseHeaders(token!, wid!, courseId, deptId!));
    return response;
  }

  Future<dynamic> enrollExtCourse(
      {required String courseId, required String partnerId}) async {
    String? token = await _storage.read(key: Storage.authToken);
    Map<String, dynamic> data = {
      "courseId": "$courseId",
      "partnerId": "$partnerId"
    };
    Response response = await post(Uri.parse(enrollExtCourseUrl),
        headers: NetworkHelper.postHeader(token!), body: jsonEncode(data));

    try {
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);

        String responseCode = contents['responseCode'] ?? '';
        String errMsg = contents['params']?['err'] ?? '';
        return UserActionModel(responseCode: responseCode, errMsg: errMsg);
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<dynamic> getExternalCourseContents({required String extId}) async {
    Response response = await get(
        Uri.parse(getExteranlCourseContentsUrl + extId),
        headers: NetworkHelper.getHeader());
    return response;
  }

  Future<dynamic> getKarmaPrograms(String primaryCategory,
      {bool hasRequestBody = false,
      Map<String, dynamic>? requestBody,
      bool isPlayListRead = false,
      String? apiUrl}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data;
    if (hasRequestBody) {
      data = requestBody!;
    } else if (isPlayListRead) {
      data = {
        "filterCriteriaMap": {"type": "$primaryCategory"},
        "pageNumber": 0,
        "pageSize": 20,
        "orderBy": "createdOn",
        "orderDirection": "ASC",
        "facets": ["category", "orgId"]
      };
    } else {
      data = {
        "filterCriteriaMap": {"type": "$primaryCategory"},
        "pageNumber": 0,
        "pageSize": 20,
        "orderBy": "createdOn",
        "orderDirection": "ASC",
        "facets": ["category", "orgId"]
      };
    }

    String url =
        isPlayListRead ? (ApiUrl.baseUrl + apiUrl!) : playListSearchUrl;

    var response;
    if (isPlayListRead) {
      response = await HttpService.get(
        apiUri: Uri.parse(url),
        ttl: Duration(hours: 8),
        headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
      );
    } else {
      response = await HttpService.post(
        apiUri: Uri.parse(url),
        ttl: Duration(hours: 8),
        body: data,
        headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
      );
    }

    return response;
  }

  Future<dynamic> getCoursesByCollection(String identifier) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    String coursesByCollectionUrl =
        courseDetailsUrl + identifier + '?mode=minimal';

    Response response = await get(Uri.parse(coursesByCollectionUrl),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  Future<dynamic> getCoursesByCompetencies(String competencyName,
      List<String> selectedTypes, List<String> selectedProviders) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = AppConfiguration().useCompetencyv6
        ? {
            "request": {
              "query": "",
              "filters": {
                "primaryCategory": selectedTypes,
                "status": ["Live"],
                "competencies_v6.competencySubThemeName": [competencyName],
                "source": selectedProviders,
              },
              "sort_by": {"lastUpdatedOn": ""},
              "limit": 100,
            }
          }
        : {
            "request": {
              "query": "",
              "filters": {
                "primaryCategory": selectedTypes,
                "status": ["Live"],
                "competencies_v3.name": [competencyName],
                "source": selectedProviders,
              },
              "sort_by": {"lastUpdatedOn": ""},
              "limit": 100,
            }
          };

    Response response = await HttpService.post(
        ttl: ApiTtl.compositeSearch,
        apiUri: Uri.parse(getCoursesByCompetenciesURL),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: data);

    return response;
  }

  Future<dynamic> getCoursesByProvider(
      String providerName, List<String> selectedTypes) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "filters": {
          "contentType": ["Course"],
          "primaryCategory": selectedTypes,
          "mimeType": [],
          "source": providerName,
          "mediaType": [],
          "status": ["Live"]
        },
        "query": "",
        "sort_by": {"lastUpdatedOn": ""},
        "offset": 0,
        "fields": [],
        "facets": ["contentType", "mimeType", "source"]
      }
    };
    var body = json.encode(data);

    Response response = await post(Uri.parse(getCoursesByCompetenciesURL),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  Future<dynamic> getMyLearningEnrolmentlist() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.get(
        apiUri: Uri.parse(myLearningEnrollment.replaceAll(':wid', wid!)),
        ttl: ApiTtl.getMyLearningEnrolmentlist,
        headers: NetworkHelper.getHeaders(token!, wid, rootOrgId!));
    return response;
  }

  Future<int> getTotalCoursePages(List primaryCategory, List source,
      {bool isModerated = false}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data;

    if (isModerated) {
      data = {
        "request": {
          "secureSettings": true,
          "query": "",
          "filters": {
            "courseCategory": [
              PrimaryCategory.moderatedCourses.toLowerCase(),
              PrimaryCategory.moderatedProgram.toLowerCase(),
              PrimaryCategory.moderatedAssessment.toLowerCase()
            ],
            "contentType": [PrimaryCategory.course],
            "status": ["Live"]
          },
          "sort_by": {"lastUpdatedOn": "desc"},
          "facets": ["mimeType"],
        }
      };
    } else {
      data = {
        "request": {
          "filters": {
            "primaryCategory": primaryCategory,
            "mimeType": [],
            "source": source,
            "mediaType": [],
            "contentType": []
          },
          "status": ["Live"],
          "fields": [],
          "query": '',
          "sort_by": {"lastUpdatedOn": "desc"},
        }
      };
    }

    Response res = await HttpService.post(
        ttl: ApiTtl.compositeSearch,
        apiUri: Uri.parse(coursesUrl),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: data);

    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      int count =
          (contents['result']['count'] / COURSE_LISTING_PAGE_LIMIT).ceil();
      return count;
    } else {
      throw 'Can\'t get courses.';
    }
  }

  Future<dynamic> getCourseDetails(id,
      {bool isFeatured = false, bool pointToProd = false}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = isFeatured
        ? await get(
            Uri.parse(courseDetailsUrl + id + '?hierarchyType=detail'),
          )
        : await get(
            pointToProd
                ? Uri.parse('https://portal.igotkarmayogi.gov.in/' +
                    ApiUrl.getCourseDetails +
                    id +
                    '?hierarchyType=detail')
                : Uri.parse(courseDetailsUrl + id + '?hierarchyType=detail'),
            headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!,
                pointToProd: pointToProd));
    // log('Response: ' + res.body.toString());
    if (res.statusCode == 200) {
      var courseDetails = jsonDecode(res.body);
      return courseDetails['result']['content'];
    } else {
      return null;
    }
  }

  Future<dynamic> getCourseData(id,
      {bool isFeatured = false, bool pointToProd = false}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Response res = isFeatured
        ? await get(
            Uri.parse(courseDataUrl + id),
          )
        : await get(
            pointToProd
                ? Uri.parse('https://portal.igotkarmayogi.gov.in/' +
                    ApiUrl.getCourse +
                    id)
                : Uri.parse(courseDataUrl + id),
            headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!,
                pointToProd: pointToProd));
    if (res.statusCode == 200) {
      var courseDetails = jsonDecode(res.body);
      return courseDetails['result']['content'];
    } else {
      return null;
    }
  }

  Future<dynamic> getCourseDataInEditMode(id) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Response res = await get(Uri.parse(courseDataUrl + id + '?mode=edit'),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    if (res.statusCode == 200) {
      var courseDetails = jsonDecode(res.body);
      return courseDetails['result']['content'];
    } else {
      return res.reasonPhrase;
    }
  }

  Future<Map> updateContentProgress(
      String courseId,
      String batchId,
      String contentId,
      int status,
      String contentType,
      List current,
      var maxSize,
      double completionPercentage,
      {bool isAssessment = false,
      bool? isPreRequisite = false,
      int spentTime = 0,
      required String language}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    List dateTime = DateTime.now().toUtc().toString().split('.');

    Map data;

    if (isPreRequisite ?? false) {
      if (isAssessment) {
        data = {
          "request": {
            "contents": [
              {
                "contentId": contentId,
                "status": status,
                "lastAccessTime": '${dateTime[0]}:00+0000',
                "progressdetails": {"mimeType": contentType},
                "completionPercentage": completionPercentage,
                "language": language.toLowerCase()
              }
            ]
          }
        };
      } else {
        data = {
          "request": {
            "contents": [
              {
                "contentId": contentId,
                "status": status,
                "lastAccessTime": '${dateTime[0]}:00+0000',
                "progressdetails": {
                  "max_size": maxSize,
                  "current": current,
                  "mimeType": contentType
                },
                "completionPercentage": completionPercentage,
                "language": language.toLowerCase()
              }
            ]
          }
        };
      }
    } else {
      if (isAssessment) {
        data = {
          "request": {
            "userId": wid,
            "contents": [
              {
                "contentId": contentId,
                "batchId": batchId,
                "status": status,
                "courseId": courseId,
                "lastAccessTime": '${dateTime[0]}:00+0000',
                "language": language.toLowerCase()
              }
            ]
          }
        };
      } else {
        data = {
          "request": {
            "userId": wid,
            "contents": [
              {
                "contentId": contentId,
                "batchId": batchId,
                "status": status,
                "courseId": courseId,
                "lastAccessTime": '${dateTime[0]}:00+0000',
                "progressdetails": {
                  "max_size": maxSize,
                  "current": current,
                  "mimeType": contentType,
                  "spentTime": spentTime
                },
                "completionPercentage": completionPercentage,
                "language": language.toLowerCase()
              }
            ]
          }
        };
      }
    }

    var body = json.encode(data);
    String url = (isPreRequisite ?? false)
        ? '${ApiUrl.baseUrl + ApiUrl.updatePreRequisiteContentProgress}'
        : updateContentProgressUrl;
    Response res = await patch(Uri.parse(url),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    // print(res.body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Can\'t update content progress';
    }
  }

  Future<Map> readContentProgress(String courseId, String batchId,
      {List contentIds = const [], required String language}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "batchId": batchId,
        "userId": wid,
        "courseId": courseId,
        "contentIds": contentIds,
        "fields": ["progressdetails"],
        "language": language.toLowerCase()
      }
    };
    var body = jsonEncode(data);
    Response res = await post(Uri.parse(readContentProgressUrl),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Unable to fetch content progress';
    }
  }

  /// read pre requisite content progress
  Future<Map> readPreRequisiteContentProgress(List<String> contentIds) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {"contentIds": contentIds, "fields": []}
    };
    var body = jsonEncode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.readPreRequisiteContentProgress),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Unable to fetch content progress';
    }
  }

  Future<Map> markAttendance(String courseId, String batchId, String contentId,
      int status, double completionPercentage) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    List dateTime = DateTime.now().toUtc().toString().split('.');

    Map data;

    data = {
      "request": {
        "userId": wid,
        "contents": [
          {
            "batchId": batchId,
            "completionPercentage": completionPercentage,
            "contentId": contentId,
            "courseId": courseId,
            "status": status,
            "lastAccessTime": '${dateTime[0]}:00+0000',
            "progressdetails": {
              "spentTime": 0,
            },
          }
        ]
      }
    };

    var body = json.encode(data);
    Response res = await patch(Uri.parse(updateContentProgressUrl),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Can\'t update content progress';
    }
  }

  Future<dynamic> getBatchList(
    String courseId,
  ) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'request': {
        'filters': {
          'courseId': courseId,
          "status": ['0', '1', '2']
        },
        'sort_by': {'createdDate': 'desc'}
      }
    };
    Response response = await HttpService.post(
        apiUri: Uri.parse(getBatchListUrl),
        ttl: ApiTtl.getBatchList,
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: data);
    return response;
  }

  Future<dynamic> autoEnrollBatch(
      {required String courseId, String? language}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Uri uri = Uri.parse(autoEnrollBatchUrl).replace(
      queryParameters: {'language': language},
    );

    Response res = await get(
      uri,
      headers:
          NetworkHelper.postCourseHeaders(token!, wid!, courseId, rootOrgId!),
    );
    return res;
  }

  Future<dynamic> enrollProgram({
    required String courseId,
    required String programId,
    required String batchId,
  }) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "userId": "$wid",
        "programId": "$programId",
        "batchId": "$batchId"
      }
    };

    Response res = await post(Uri.parse(enrolProgramBatchUrl),
        headers:
            NetworkHelper.postCourseHeaders(token!, wid!, courseId, rootOrgId!),
        body: jsonEncode(data));
    return res;
  }

  Future<dynamic> enrollToCuratedProgram(
      String courseId, String batchId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Map data = {
      "request": {"userId": wid, "programId": courseId, "batchId": batchId}
    };
    var body = jsonEncode(data);

    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.enrollToCuratedProgram),
        headers:
            NetworkHelper.curatedProgramPostHeaders(token!, wid!, rootOrgId!),
        body: body);
    return res;
  }

  Future<dynamic> requestToEnroll(
      {required String batchId,
      required String courseId,
      required String state,
      required String action}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? deptName = await _storage.read(key: Storage.deptName);
    String? firstName = await _storage.read(key: Storage.firstName);

    Map data = {
      "rootOrgId": rootOrgId,
      "userId": wid,
      "state": state,
      "action": action,
      "actorUserId": wid,
      "applicationId": batchId,
      "serviceName": "blendedprogram",
      "courseId": courseId,
      "deptName": deptName,
      "updateFieldValues": [
        {
          "toValue": {"name": firstName}
        }
      ]
    };

    try {
      Response res = await post(Uri.parse(requestBlendedProgramEnrollUrl),
          headers: NetworkHelper.postCourseHeaders(
              token!, wid!, courseId, rootOrgId!),
          body: json.encode(data));
      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        BlendedProgramEnrollResponseModel enrolList;
        enrolList =
            BlendedProgramEnrollResponseModel.fromJson(contents['result']);
        return enrolList;
      } else {
        return jsonDecode(res.body)['result']['errmsg'];
      }
    } catch (err) {
      throw 'Unable to auto enroll a batch';
    }
  }

  Future<dynamic> requestUnenroll(
      {required String batchId,
      required String courseId,
      required String state,
      required String action,
      required String wfId}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? deptName = await _storage.read(key: Storage.deptName);
    String? firstName = await _storage.read(key: Storage.firstName);

    Map data = {
      "rootOrgId": rootOrgId,
      "userId": wid,
      "state": state,
      "action": action,
      "actorUserId": wid,
      "applicationId": batchId,
      "serviceName": "blendedprogram",
      "courseId": courseId,
      "deptName": deptName,
      "wfId": wfId,
      "updateFieldValues": [
        {
          "toValue": {"name": firstName}
        }
      ]
    };

    try {
      Response res = await post(Uri.parse(requestBlendedProgramUnenroll),
          headers: NetworkHelper.postCourseHeaders(
              token!, wid!, courseId, rootOrgId!),
          body: json.encode(data));
      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        BlendedProgramUnenrollResponseModel enrolList;
        enrolList =
            BlendedProgramUnenrollResponseModel.fromJson(contents['result']);
        return enrolList;
      } else {
        throw 'Unable to unenroll batch';
      }
    } catch (err) {
      throw 'Unable to unenroll batch';
    }
  }

  Future<dynamic> userSearch(courseId, batchId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "applicationIds": batchId,
      "serviceName": "blendedprogram",
      "limit": 100,
      "offset": 0
    };

    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.workflowBlendedProgramSearch),
        headers:
            NetworkHelper.postCourseHeaders(token!, wid!, courseId, rootOrgId!),
        body: json.encode(data));
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['result']['data'];
    } else {
      throw 'Unable to auto enroll a batch';
    }
  }

  Future<dynamic> submitSurveyForm(formId, dataObject, courseId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "formId": formId,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "version": 1,
      "dataObject": dataObject
    };

    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.submitBlendedProgramSurvey),
        headers:
            NetworkHelper.postCourseHeaders(token!, wid!, courseId, rootOrgId!),
        body: json.encode(data));
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['statusInfo'] != null
          ? contents['statusInfo']['statusMessage']
          : null;
    } else {
      throw 'Unable to auto enroll a batch';
    }
  }

  //submitProfileSurveyForm
  Future<String?> submitProfileSurveyForm({
    required String formId,
    required Map dataObject,
    required String courseId,
  }) async {
    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);
      String? rootOrgId = await _storage.read(key: Storage.deptId);

      Map data = {
        "formId": formId,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "version": 1,
        "dataObject": dataObject,
      };

      Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.submitForm),
        headers:
            NetworkHelper.postCourseHeaders(token!, wid!, courseId, rootOrgId!),
        body: json.encode(data),
      );

      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        return contents['statusInfo'] != null
            ? contents['statusInfo']['statusMessage']
            : null;
      } else {
        throw 'Unable to auto enroll a batch: ${res.statusCode} ${res.body}';
      }
    } catch (e) {
      print('Error in submitProfileSurveyForm: $e');
      throw 'Failed to submit profile survey form: $e';
    }
  }

  Future<dynamic> getCourseCompletionCertificate(String id) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Response res = await HttpService.get(
        ttl: Duration(days: 1),
        apiUri: Uri.parse(
            ApiUrl.baseUrl + ApiUrl.getCourseCompletionCertificate + id),
        headers: NetworkHelper.discussionGetHeaders(token!, wid!));

    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);

      return contents['result']['printUri'];
    } else {
      throw 'Can\'t get certificates';
    }
  }

  Future<dynamic> getCourseCompletionDynamicCertificate(
      String courseId, String batchId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "userId": "$wid",
        "courseId": "$courseId",
        "batchId": "$batchId"
      }
    };

    var body = json.encode(data);

    Response res = await post(
        Uri.parse(
            ApiUrl.baseUrl + ApiUrl.getCourseCompletionDynamicCertificate),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);

    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['result']['printUri'];
    } else {
      throw 'Can\'t get certificates';
    }
  }

  Future<dynamic> downloadCompletionCertificate(String printUri,
      {String? outputType}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    Map data = {
      "printUri": printUri,
      "inputFormat": "svg",
      "outputFormat": outputType != null ? outputType : CertificateType.pdf
    };

    var body = json.encode(data);
    Response certRes = await post(
        Uri.parse(
            ApiUrl.baseUrl + ApiUrl.getCourseCompletionCertificateForMobile),
        headers: headers,
        body: body);

    if (certRes.statusCode == 200) {
      final certificateData = certRes.bodyBytes;
      return certificateData;
    }
    throw 'Can\'t get certificates';
  }

  Future<dynamic> getYourReview(
      {required String id,
      required String primaryCategory,
      bool forceUpdate = false}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "activityId": "$id",
        "activityType": "$primaryCategory",
        "userId": [wid],
      }
    };

    //   var body = json.encode(data);
    Response res = await HttpService.post(
        forceUpdate: forceUpdate,
        ttl: ApiTtl.getRatingReviews,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getYourRating),
        body: data,
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    var contents = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return contents['result']['content'];
    } else {
      print(contents['params'] != null
          ? contents['params']['errmsg']
          : contents.toString());
      return null;
    }
  }

  Future<dynamic> getBlendedProgramBatchCount(String batchId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Map data = {
      "serviceName": "blendedprogram",
      "applicationStatus": "",
      "applicationIds": ["$batchId"],
      "limit": 100,
      "offset": 0
    };

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.requestBlendedProgramBatchCountUrl),
        body: body,
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    var contents = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return contents['result']['data'];
    } else {
      print(contents['params'] != null
          ? contents['params']['errmsg']
          : contents.toString());
      return null;
    }
  }

  Future<dynamic> postCourseReview(String courseId, String primaryCategory,
      double rating, String comment) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data;
    if (comment.trim().length > 0) {
      data = {
        "activityId": "$courseId",
        "userId": "$wid",
        "activityType": "$primaryCategory",
        "rating": rating.toInt(),
        "review": "$comment"
      };
    } else {
      data = {
        "activityId": "$courseId",
        "userId": "$wid",
        "activityType": "$primaryCategory",
        "rating": rating.toInt(),
      };
    }

    var body = json.encode(data);
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.postReview),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  Future<dynamic> getCourseReviewSummery(
      {required String id,
      required String primaryCategory,
      bool forceUpdate = false}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = await HttpService.get(
        ttl: ApiTtl.getRatingReviews,
        forceUpdate: forceUpdate,
        apiUri: Uri.parse(ApiUrl.baseUrl +
            ApiUrl.getCourseReviewSummery +
            '$id/$primaryCategory'),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    var contents = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return contents['result']['response'];
    } else {
      print(contents['params']['errmsg']);
      return null;
    }
  }

  Future<dynamic> getCourseReview(
      String courseId, String primaryCategory, int limit) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "activityId": "$courseId",
      "activityType": "$primaryCategory",
      //  "limit": limit,
      "updateOn": ""
    };

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCourseReview),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);

    var contents = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return contents['result']['response'];
    } else {
      return null;
    }
  }

  Future<dynamic> getCourseReviewReply(
      String id, String primaryCategory, List userIds) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "activityId": "$id",
        "activityType": "$primaryCategory",
        "userId": userIds,
      }
    };

    var body = json.encode(data);

    Response res = await post(Uri.parse(ApiUrl.baseUrl + ApiUrl.getYourRating),
        body: body,
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    var contents = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return contents['result']['content'];
    } else {
      print(contents['params'] != null
          ? contents['params']['errmsg']
          : contents.toString());
      return null;
    }
  }

  Future<dynamic> getCuratedHomeConfig() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCuratedHomeConfig),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return jsonDecode(response.body);
  }

  Future<dynamic> getLearnHubConfig() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getLearnHubConfig),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return jsonDecode(response.body);
  }

  Future<dynamic> getHomeConfig() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {};
    Map<String, dynamic> reguestBody = {
      "request": {
        "type": "page",
        "subType": "home",
        "action": "page-configuration",
        "component": "portal",
        "rootOrgId": "*"
      }
    };
    Response formReadResponse = await HttpService.post(
      ttl: ApiTtl.getHomeConfig,
      body: reguestBody,
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteFormData),
      headers: NetworkHelper.insightHeader(wid!, token!),
    );

    if (formReadResponse.statusCode == 200) {
      Map responseData = jsonDecode(formReadResponse.body);
      data = responseData['result']?['form']?['data'] ?? {};
    }

    if (data.isEmpty) {
      Response jsonResponse = await HttpService.get(
          ttl: ApiTtl.getHomeConfig,
          apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getHomeConfig),
          headers: NetworkHelper.getHeaders(token, wid, rootOrgId!));
      data = jsonDecode(jsonResponse.body);
    }

    return data;
  }

  Future<dynamic> getMasterCompetenciesJson() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getMasterCompetencies),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return jsonDecode(response.body);
  }

  Future<dynamic> getSurveyForm(id) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getSurveyForm + id.toString()),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  Future<dynamic> getTrendingSearch(
      {String? category, bool? enableAcrossDept}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? designation = await _storage.read(key: Storage.designation);
    if (enableAcrossDept == null) {
      enableAcrossDept = false;
    }
    Map data = {
      "request": {
        "filters": {
          "contextType": [category],
          "designation": designation,
          "organisation": enableAcrossDept ? "across" : rootOrgId
        },
        "limit": 50
      }
    };
    //   var body = json.encode(data);

    Response response = await HttpService.post(
        ttl: ApiTtl.compositeSearch,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getTrendingSearch),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
        body: data);

    return response;
  }

  Future<dynamic> getCbplan() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.get(
        ttl: ApiTtl.getCbplan,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getCbplan),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  // Competency search
  Future<dynamic> getCompetencySearchInfo() async {
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);
    var body = json.encode({
      "search": {"type": "Competency Area"},
      "filter": {"isDetail": true}
    });
    String url = ApiUrl.baseUrl + ApiUrl.competencySearch;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  //Search by provider
  Future<dynamic> getSearchByProvider() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.searchByProvider),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  /// MicroSite Start

  Future<dynamic> getListOfFeaturedProviders(String id) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Response res = await get(Uri.parse(courseDataUrl + id),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    if (res.statusCode == 200) {
      var courseDetails = jsonDecode(res.body);
      return courseDetails['result']['content']['featuredProviders'];
    } else {
      return [];
    }
  }

  // getMicroSiteFormData
  Future<dynamic> getMicroSiteFormData({
    String? orgId,
    String? type,
    String? subtype,
  }) async {
    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);

      if (token == null || wid == null) {
        throw Exception('Missing authentication token or workspace ID.');
      }

      Map<String, dynamic> data = {
        "request": {
          "type": type ?? 'default-type',
          "subType": subtype ?? 'microsite-v2',
          "action": "page-configuration",
          "component": "portal",
          "rootOrgId": orgId,
        },
      };

      var body = json.encode(data);

      Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteFormData),
        headers: NetworkHelper.insightHeader(wid, token),
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load data===== ${response.statusCode}');
      }

      return response;
    } catch (e) {
      print('Error fetching micro site form data===== $e');
      rethrow;
    }
  }

  // getLearnerReviews
  Future<dynamic> getLearnerReviews(String id) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getLearnerReviews + '$id'),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  // getMicroSiteInsights
  Future<dynamic> getMicroSiteInsights(String id) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteInsights + '$id'),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  // getAllCompetencies
  Future<dynamic> getMicroSiteCompetencies(
      {String? orgId,
      String competencyArea = "",
      required List<String> facets}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Map data;

    if (competencyArea.isEmpty) {
      data = {
        "request": {
          "query": "",
          "filters": {
            "contentType": "Course",
            "createdFor": [orgId],
            "status": ["Live"]
          },
          "sort_by": {"lastUpdatedOn": "desc"},
          "facets": facets,
          "limit": 0,
          "offset": 0,
          "fields": []
        },
        "query": ""
      };
    } else {
      data = AppConfiguration().useCompetencyv6
          ? {
              "request": {
                "query": "",
                "filters": {
                  "contentType": "Course",
                  "createdFor": [orgId],
                  "competencies_v6.competencyAreaName": competencyArea,
                  "status": ["Live"]
                },
                "sort_by": {"lastUpdatedOn": "desc"},
                "facets": facets,
                "limit": 0,
                "offset": 0,
                "fields": []
              },
              "query": ""
            }
          : {
              "request": {
                "query": "",
                "filters": {
                  "contentType": "Course",
                  "createdFor": [orgId],
                  "competencies_v5.competencyArea": competencyArea,
                  "status": ["Live"]
                },
                "sort_by": {"lastUpdatedOn": "desc"},
                "facets": facets,
                "limit": 0,
                "offset": 0,
                "fields": []
              },
              "query": ""
            };
    }

    var body = json.encode(data);
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteCompetencies),
        headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
        body: body);
    return response;
  }

  // getInsightData
  Future<dynamic> getInsightData({String? orgId}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Map data = {
      "request": {
        "filters": {
          "organisations": [orgId]
        }
      }
    };

    var body = json.encode(data);
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getInsightData),
        headers: NetworkHelper.insightHeader(wid!, token!),
        body: body);

    return response;
  }

  // getMicroSiteTrendingCourses
  Future<dynamic> getMicroSiteTopCourses(String orgId,
      List<String> selectedTypes, String selectedCoursePills, int limit) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);
    String _organisation = '$orgId:$selectedCoursePills';

    Map data = {
      "request": {
        "filters": {
          "primaryCategory": selectedTypes,
          "contextType": ["TOP"],
          "organisation": _organisation
        },
        "limit": limit
      }
    };

    var body = json.encode(data);
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteTopCoursesData),
        headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
        body: body);
    return response;
  }

  // getMicroSiteFeaturedCourses
  Future<dynamic> getMicroSiteFeaturedCourses(String orgId,
      List<String> selectedTypes, String selectedCoursePills) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    String _contentType = '';
    if (selectedCoursePills == 'courses') {
      _contentType = 'ORG_FEATURED_COURSES';
    } else if (selectedCoursePills == 'programs') {
      _contentType = 'ORG_FEATURED_PROGRAMS';
    } else if (selectedCoursePills == 'assessments') {
      _contentType = 'ORG_FEATURED_ASSESSMENTS';
    }

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.getMdoCoursesData +
            orgId +
            _contentType +
            '/$orgId'),
        headers: NetworkHelper.postHeaders(token!, wid!, deptId!));
    return response;
  }

  // getCalenderData
  Future<dynamic> getMicroSiteCalenderData(
      String orgId, String startDate, String endDate) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Map data = {
      "locale": ["en"],
      "query": "",
      "request": {
        "query": "",
        "filters": {
          "category": ["Calendar"],
          "status": ["Live", "Retired"],
          "contentType": "Event",
          "startDate": {">=": startDate, "<": endDate},
          "channel": [orgId]
        },
        "sort_by": {"lastUpdatedOn": "desc"}
      }
    };

    var body = json.encode(data);
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteCalenderData),
        headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
        body: body);

    return response;
  }

  /// MicroSite End

  /// MDO channel Start

  //getListOfMdoChannels
  Future<dynamic> getListOfMdoChannels(String orgBookmarkId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getListOfMdoChannels + orgBookmarkId),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!));
    return response;
  }

  // getMdoChannelFormData
  Future<dynamic> getMdoChannelFormData({String? orgId}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Map data = {
      "request": {
        "type": "MDO-channel",
        "subType": "microsite-v2",
        "action": "page-configuration",
        "component": "portal",
        "rootOrgId": orgId
      }
    };

    var body = json.encode(data);
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteFormData),
        headers: NetworkHelper.insightHeader(wid!, token!),
        body: body);

    return response;
  }

  // getChannelInsightData
  Future<dynamic> getChannelInsightData({String? orgId}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Map data = {
      "request": {
        "filters": {
          "requestType": "MDO_INSIGHT",
          "organisations": [orgId]
        }
      }
    };

    var body = json.encode(data);
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getInsightData),
        headers: NetworkHelper.insightHeader(wid!, token!),
        body: body);

    return response;
  }

  // getMdoCertificateOfWeek
  Future<dynamic> getMdoCertificateOfWeek(String orgId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "filters": {
          "contextType": ["certifications"],
          "organisation": orgId
        },
        "limit": 5,
        "responseKey": "certifications",
        "query": ""
      },
    };

    var body = json.encode(data);
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getTrendingSearch),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  // getChannelCoursesData
  Future<dynamic> getMdoCoursesData(
      String orgId, String type, String selectedCoursePills) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    String _contentType = type;
    if (type == 'MDO_FEATURED_COURSES') {
      if (selectedCoursePills == 'course') {
        _contentType = 'MDO_FEATURED_COURSES';
      } else if (selectedCoursePills == 'program') {
        _contentType = 'MDO_FEATURED_PROGRAMS';
      }
    } else {
      if (selectedCoursePills == 'course') {
        _contentType = 'MDO_RECOMMENDED_COURSES';
      } else if (selectedCoursePills == 'program') {
        _contentType = 'MDO_RECOMMENDED_PROGRAMS';
      }
    }

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.getMdoCoursesData +
            orgId +
            _contentType +
            '/$orgId'),
        headers: NetworkHelper.postHeaders(token!, wid!, deptId!));
    return response;
  }

  // getAnnouncementData
  Future<dynamic> getAnnouncementData({required String orgId}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Map data = {
      "filterCriteriaMap": {
        "channel": [orgId]
      },
      "requestedFields": [
        "name",
        "description",
        "createdOn",
        "updatedOn",
        "category"
      ],
      "orderBy": "createdOn",
      "orderDirection": "ASC",
      "facets": ["channel"]
    };

    var body = json.encode(data);
    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getAnnouncementData),
        headers: NetworkHelper.insightHeader(wid!, token!),
        body: body);
    return response;
  }

  //downloadCBPlan
  Future<dynamic> downloadCBPlan(String fileUri) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Response response = await get(Uri.parse(fileUri), headers: headers);

    if (response.statusCode == 200) {
      final certificateData = response.bodyBytes;
      return certificateData;
    }
    throw 'Can\'t get certificates';
  }

  // getMDOTopLearnerData
  Future<dynamic> getMDOTopLearnerData({required String orgId}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getMDOTopLearnerData + orgId),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    return response;
  }

  // getCompetenciesByOrg
  Future<dynamic> getCompetenciesByOrg(String orgId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCompetenciesByOrg + orgId),
        headers: NetworkHelper.postHeaders(token!, wid!, deptId!));
    return response;
  }

  /// MDO channel end

  /// Event hub config
  Future<dynamic> getEventConfig() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {};
    Map<String, dynamic> reguestBody = {
      "request": {
        "type": "page",
        "subType": "events",
        "action": "page-configuration",
        "component": "portal",
        "rootOrgId": "*"
      }
    };

    Response formReadResponse = await HttpService.post(
      ttl: ApiTtl.getHomeConfig,
      body: reguestBody,
      apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteFormData),
      headers: NetworkHelper.insightHeader(wid!, token!),
    );

    if (formReadResponse.statusCode == 200) {
      Map responseData = jsonDecode(formReadResponse.body);
      data = responseData['result']?['form']?['data'] ?? {};
    }

    if (data.isEmpty) {
      Response jsonResponse = await HttpService.get(
          ttl: ApiTtl.getSearchConfig,
          apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getSearchConfig),
          headers: NetworkHelper.getHeaders(token, wid, rootOrgId!));
      data = jsonDecode(jsonResponse.body);
    }

    return data;
  }

  ///get netcore config data
  Future<dynamic> getNetcoreConfig() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {};
    Map<String, dynamic> reguestBody = {
      "request": {
        "type": "page",
        "subType": "netcore",
        "action": "page-configuration",
        "component": "portal",
        "rootOrgId": "*"
      }
    };

    try {
      Response formReadResponse = await HttpService.post(
        ttl: ApiTtl.getHomeConfig,
        body: reguestBody,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteFormData),
        headers: NetworkHelper.insightHeader(wid!, token!),
      );

      if (formReadResponse.statusCode == 200) {
        Map responseData = jsonDecode(formReadResponse.body);
        data = responseData['result']?['form']?['data'] ?? {};
      }
    } catch (e) {}

    if (data.isEmpty) {
      Response jsonResponse = await HttpService.get(
          ttl: ApiTtl.getHomeConfig,
          apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getNetcoreConfig),
          headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
      data = jsonDecode(jsonResponse.body);
    }

    return data;
  }

  static Future<Response> submitForm({
    required int version,
    required String formId,
    required String courseId,
    required Map dataObject,
  }) async {
    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);
      String? rootOrgId = await _storage.read(key: Storage.deptId);

      Map data = {
        "formId": formId,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "version": version,
        "dataObject": dataObject
      };

      var body = json.encode(data);

      Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.submitForm),
        headers:
            NetworkHelper.postCourseHeaders(token!, wid!, courseId, rootOrgId!),
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to submit form. Status Code: ${response.statusCode}');
      }

      return response;
    } catch (e) {
      print('Error in submitForm: $e');

      throw Exception('An error occurred while submitting the form: $e');
    }
  }

  //Get recommended Courses with doId
  Future<dynamic> getRecommendationWithDoId(
      List doIdList, bool pointToProd) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);
    var data = {
      "request": {
        "filters": {
          "identifier": doIdList,
          "status": ["Live"]
        },
        "fields": [],
        "query": "",
        "sort_by": {"lastUpdatedOn": "desc"},
        "limit": 100,
        "offset": 0
      }
    };
    var response = await HttpService.post(
      apiUri: pointToProd
          ? Uri.parse('https://portal.igotkarmayogi.gov.in/' +
              ApiUrl.getTrendingCourses)
          : Uri.parse(coursesUrl),
      ttl: ApiTtl.compositeSearch,
      body: data,
      headers: NetworkHelper.postHeaders(token!, wid!, deptId!,
          pointToProd: pointToProd),
    );
    return response;
  }

  Future<dynamic> getCourseEnrollDetailsByIds(
      {required List<String> courseIds}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    var data = {
      'request': {
        'courseId': courseIds,
        'retiredCoursesEnabled': true,
      }
    };

    Response response = await HttpService.post(
        apiUri: Uri.parse(
            ApiUrl.baseUrl + ApiUrl.getCourseEnrollDetailsByIds + wid!),
        body: data,
        headers: NetworkHelper.getHeaders(token!, wid, rootOrgId!));
    return response;
  }

  Future<dynamic> getEnrollmentSummary() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.get(
        ttl: ApiTtl.userEnrollmentSummaryTtl,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getEnrollmentSummary + wid!),
        headers: NetworkHelper.getHeaders(token!, wid, rootOrgId!));
    return response;
  }

  static Future<Response> getRequest(
      {required String apiUrl, Duration? ttl}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.get(
      ttl: ttl != null ? ttl : null,
      apiUri: Uri.parse(ApiUrl.baseUrl + apiUrl),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );
    return response;
  }

  static Future<Response> postRequest(
      {required String apiUrl,
      Duration? ttl,
      required Map<String, dynamic> request,
      int? offset}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.post(
      body: request,
      ttl: ttl != null ? ttl : null,
      apiUri: Uri.parse(ApiUrl.baseUrl + apiUrl),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );
    return response;
  }

  Future<dynamic> getEnrollmentListByFilter(
      {required String status,
      int? limit,
      String? contentType,
      bool retiredCoursesEnabled = true}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    var data = {
      'request': {
        'retiredCoursesEnabled': retiredCoursesEnabled,
        'status': status,
        'limit': limit,
        'contentType': contentType
      }
    };
    Response response = await HttpService.post(
        apiUri:
            Uri.parse(ApiUrl.baseUrl + ApiUrl.getEnrollmentListByFilter + wid!),
        body: data,
        headers: NetworkHelper.getHeaders(token!, wid, rootOrgId!));
    return response;
  }

  Future<dynamic> getCompositeSearchData(int pageNo, String searchText,
      List primaryCategory, List mimeType, List source,
      {Duration? ttl,
      List<String>? facets,
      Map<String, dynamic>? filters,
      Map<String, dynamic>? sortBy,
      int? limit,
      required List<String> fields}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      'request': {
        'filters': {
          'courseCategory': primaryCategory,
          'mimeType': [],
          'source': source,
          'mediaType': [],
          'contentType': [],
          'identifier': [],
          'status': ['Live'],
        },
        'fields': fields,
        'query': searchText,
        'sort_by': sortBy ?? {'lastUpdatedOn': 'desc'},
        'facets': facets,
        "limit": limit ?? 10,
        'offset': pageNo,
        'fuzzy': false
      }
    };

    if (filters != null) {
      Map<String, dynamic> existingFilters =
          data['request']['filters'] as Map<String, dynamic>;
      Map<String, dynamic> newFilters = {};

      filters.forEach((key, newValues) {
        if (key == SearchFilterFacet.avgRating) {
          // Handle avgRating specially as a Map
          newValues.sort((a, b) => double.parse(a).compareTo(double.parse(b)));
          String rating = newValues.first;
          newFilters[SearchFilterFacet.avgRating] = <String, dynamic>{};
          newFilters[SearchFilterFacet.avgRating]['>='] = rating;
        } else {
          // For new keys (except avgRating which was handled above)
          newFilters[key] = newValues;
        }
      });
      newFilters.keys.forEach((key) {
        existingFilters.remove(key);
      });
      Map<String, dynamic> merged = {
        ...existingFilters,
        ...newFilters,
      };
      data['request']['filters'] = merged;
    }

    var response = await HttpService.post(
      apiUri: Uri.parse(coursesUrlV4),
      ttl: ttl ?? ApiTtl.compositeSearch,
      body: data,
      headers: NetworkHelper.postHeaders(token!, wid!, deptId!),
    );

    return response;
  }

  Future<Response> compositeSearch(
      {required List<String> courseCategories,
      int? limit,
      List<String>? contentType,
      List<String>? facets,
      int? pageNo,
      List<String>? identifiers,
      String? searchQuery}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      'request': {
        'filters': {
          'courseCategory': courseCategories,
          'mimeType': [],
          'source': [],
          'mediaType': [],
          'contentType': contentType,
          'identifier': identifiers ?? [],
          'status': ['Live'],
        },
        'fields': [],
        'query': searchQuery,
        'sort_by': {'lastUpdatedOn': 'desc'},
        'facets': facets,
        "limit": limit,
        'offset': pageNo ?? 0,
      }
    };
    Response response = await HttpService.post(
        body: data,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getTrendingCoursesV4),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    return response;
  }

  static Future<Response> getSubtitleAndTranscriptionData(
      {required String resourceId}) async {
    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getTranscriptionData + resourceId),
        headers: NetworkHelper.subtitleTranscriptionHeader());

    return response;
  }
}
