import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/_models/competency_data_model.dart';
import 'package:karmayogi_mobile/models/_models/review_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/util/app_config.dart';

import '../../constants/index.dart';
import '../../services/_services/smartech_service.dart';
import '../../ui/pages/_pages/mdo_channels/model/mdo_channel_data_model.dart';
import '../../ui/pages/_pages/search/models/composite_search_model.dart';
import '../../ui/pages/_pages/toc/model/content_state_model.dart';
// import 'dart:developer' as developer;

class LearnRepository extends ChangeNotifier {
  final LearnService learnService = LearnService();
  List<BrowseCompetencyCardModel> browseCompetencyCard = [];
  List<ProviderCardModel> providerCardModel = [];
  List<Course> courses = [];
  String _errorMessage = '';
  Response? _data;
  final _storage = FlutterSecureStorage();
  dynamic trendingCourseDeptList;
  dynamic _topProvidersConfig;
  dynamic _cbplanData;
  List<CompetencyDataModel> _competency = [];
  List<CompetencyTheme> _competencyThemeList = [];
  dynamic _contentRead;
  dynamic _courseRating;
  dynamic _courseHierarchyInfo;
  dynamic _courseRatingAndReview;
  Map<String, dynamic> _languageProgress = {};
  //dynamic _enrollmentInfo;
  OverallRating? _overallRating;
  OverallRating? get overallRating => _overallRating;
  List<Course> _exteranlCourses = [];

  dynamic get topProvidersConfig => _topProvidersConfig;
  dynamic get cbplanData => _cbplanData;
  dynamic get competency => _competency;
  List<CompetencyTheme> get competencyThemeList => _competencyThemeList;
  dynamic get contentRead => _contentRead;
  dynamic get courseRating => _courseRating;
  dynamic get courseHierarchyInfo => _courseHierarchyInfo;
  dynamic get courseRatingAndReview => _courseRatingAndReview;
  // dynamic get enrollmentInfo => _enrollmentInfo;
  List<Course> get exteranlCourses => _exteranlCourses;
  Map<String, dynamic> get languageProgress => _languageProgress;

  /// Netcore config data
  dynamic netcoreConfig;

  // ignore: missing_return
  Future<List<BrowseCompetencyCardModel>> getListOfCompetencies(context) async {
    try {
      final response = await learnService.getListOfCompetencies();
      _data = response;
    } catch (_) {
      return [];
    }

    if (_data!.statusCode == 200) {
      if (AppConfiguration().useCompetencyv6) {
        var contents = jsonDecode(_data!.body);
        List result = contents['result']['content'];
        List<BrowseCompetencyCardModel> browseCompetencyCard = [];
        // result
        //     .map(
        //       (dynamic item) => BrowseCompetencyCardModel.fromJson(item),
        //     )
        //     .toList();
        for (var area in result) {
          for (var theme in area['children']) {
            for (var subTheme in theme['children']) {
              browseCompetencyCard.add(
                BrowseCompetencyCardModel(
                  competencyArea: theme['name'],
                  competencyType: area['name'],
                  name: subTheme['displayName'],
                  count: subTheme['count'],
                  description: subTheme['description'],
                  id: subTheme['identifier'],
                ),
              );
            }
          }
        }
        return browseCompetencyCard;
      } else {
        var contents = jsonDecode(_data!.body);
        List<dynamic> body = contents;
        List<BrowseCompetencyCardModel> browseCompetencyCard = body
            .map(
              (dynamic item) => BrowseCompetencyCardModel.fromJson(item),
            )
            .toList();
        return browseCompetencyCard;
      }
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
      // return Helper.showErrorPopup(context, _data.body);
    }
  }

  Future<List<ProviderCardModel>> getListOfProviders() async {
    try {
      final response = await learnService.getListOfProviders();
      _data = response;
    } catch (_) {
      return [];
    }

    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      List<dynamic> body = contents;
      providerCardModel = body
          .map(
            (dynamic item) => ProviderCardModel.fromJson(item),
          )
          .toList();
      return providerCardModel;
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getCourses(int pageNo, String searchText,
      List primaryCategory, List mimeType, List source,
      {bool isCollection = false,
      bool isInviteOnlyStandaloneAssesment = false,
      Duration? ttl,
      bool hasRequestBody = false,
      bool isModerated = false,
      Map<String, dynamic>? requestBody,
      bool checkforCBPEnddate = true,
      List<String>? doIdList}) async {
    try {
      final response = await learnService.getCourses(
          pageNo - 1, searchText, primaryCategory, mimeType, source,
          isCollection: isCollection,
          isInviteOnlyStandaloneAssesment: isInviteOnlyStandaloneAssesment,
          ttl: ttl,
          hasRequestBody: hasRequestBody,
          isModerated: isModerated,
          requestBody: requestBody,
          doIdList: doIdList);
      _data = response;
    } catch (_) {
      print(_);
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));

      List<dynamic> body = contents['result']['content'] != null
          ? contents['result']['content']
          : [];
      if (checkforCBPEnddate) {
        body = await addCBPEnddateToCourse(body);
      }
      try {
        courses = body
            .map(
              (dynamic item) => Course.fromJson(item),
            )
            .toList();
      } catch (e) {
        print(e);
      }
      // Filtering learn under 30 minutes courses (Time is in seconds)
      // if (primaryCategory.isEmpty) {
      //   _shortDurationCourseList = courses
      //       .where((course) =>
      //           (course.duration != null && int.parse(course.duration) < 1800))
      //       .toList();
      //   notifyListeners();
      // }
      notifyListeners();
      return courses;
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<Course> getExternalCourseContents({required String extId}) async {
    try {
      final response =
          await learnService.getExternalCourseContents(extId: extId);
      _data = response;
    } catch (_) {
      throw _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      dynamic body = contents['content'] ?? null;
      Course exteranlCourse = Course.fromJson(body);
      return exteranlCourse;
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getKarmaProgramContents(String primaryCategory,
      {bool hasRequestBody = false,
      required String url,
      Map<String, dynamic>? requestBody}) async {
    String? profileStatus = await _storage.read(key: Storage.profileStatus);
    try {
      final response = await learnService.getKarmaPrograms(primaryCategory,
          hasRequestBody: hasRequestBody,
          requestBody: requestBody,
          apiUrl: url,
          isPlayListRead: true);
      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      List<dynamic> body = contents['result']['content'] != null
          ? contents['result']['content']
          : [];

      courses = body
          .map(
            (dynamic item) => Course.fromJson(item),
          )
          .toList();

      if (profileStatus == UserProfileStatus.notVerified) {
        courses = courses
            .where((element) => (element.isVerifiedKarmayogi == null ||
                element.isVerifiedKarmayogi ==
                    VerifidKarmayogi.verifiedKarmayogiNo))
            .toList();
      }

      notifyListeners();
      return courses;
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<dynamic>> addCBPEnddateToCourse(List<dynamic>? body) async {
    if (body != null && body.isNotEmpty) {
      if (cbplanData == null) {
        await getCbplan();
      }
      if (cbplanData != null &&
          cbplanData.runtimeType != String &&
          cbplanData.isNotEmpty) {
        body.forEach((course) {
          String courseId = '';
          if (course['identifier'] != null) {
            courseId = course['identifier'];
          } else if (course['courseId'] != null) {
            courseId = course['courseId'];
          }
          cbplanData['content'].forEach((cbpCourse) {
            cbpCourse['contentList'].forEach((element) {
              if (element['identifier'] == courseId) {
                course['endDate'] = cbpCourse['endDate'];
              }
            });
          });
        });
      }
    }
    return body ?? [];
  }

  Future<List<Course>> getCoursesByCollection(String identifier) async {
    try {
      final response = await learnService.getCoursesByCollection(identifier);
      _data = response;
    } catch (_) {
      print(_);
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      List<dynamic> body = ((contents['result']['content'] != null &&
                  contents['result']['content']['children'] != null) &&
              contents['result']['content']['children'].length > 0)
          ? contents['result']['content']['children']
          : [];
      if (body.length > 0) {
        courses = body
            .map(
              (dynamic item) => Course.fromJson(item),
            )
            .toList();
      }
      return courses;
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getCoursesByCompetencies(
      competencyName, selectedTypes, selectedProviders) async {
    try {
      final response = await learnService.getCoursesByCompetencies(
          competencyName, selectedTypes, selectedProviders);
      _data = response;
    } catch (_) {
      return [];
    }

    if (_data!.statusCode == 200) {
      courses = [];
      var contents = jsonDecode(_data!.body);
      List<dynamic> body =
          contents['result']['count'] > 0 ? contents['result']['content'] : [];
      if (body.length > 0) {
        courses = body
            .map(
              (dynamic item) => Course.fromJson(item),
            )
            .toList();
      }
      // print('Course test: ' + courses.toString());
      return courses;
    } else {
      // throw 'Can\'t get courses by competencies!';
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Course>> getCoursesByProvider(
      String providerName, List<String> selectedTypes) async {
    try {
      final response =
          await learnService.getCoursesByProvider(providerName, selectedTypes);
      _data = response;
    } catch (_) {
      print(_);
      return [];
    }

    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      List<dynamic> body =
          contents['result']['count'] > 0 ? contents['result']['content'] : [];
      if (body.length > 0) {
        courses = body
            .map(
              (dynamic item) => Course.fromJson(item),
            )
            .toList();
      } else {
        courses = [];
      }
      return courses;
    } else {
      // throw 'Can\'t get courses by competencies!';
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<List<Batch>> getBatchList(courseId) async {
    try {
      final response = await learnService.getBatchList(courseId);

      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);

      List<dynamic> batches = contents['result']['response']['content'];

      List<Batch> courseBatches = batches
          .map(
            (dynamic item) => Batch.fromJson(item),
          )
          .toList();
      return courseBatches;
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<Map?> getSurveyForm(id) async {
    try {
      final response = await learnService.getSurveyForm(id);
      _data = response;

      if (_data!.statusCode == 200) {
        var data = jsonDecode(_data!.body);
        return data['responseData'];
      } else {
        _errorMessage = _data!.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      throw _;
    }
  }

  Future<CbPlanModel?> getCbplan() async {
    _cbplanData = null;
    try {
      final response = await learnService.getCbplan();

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final cbpInfo = data['result'] as Map<String, dynamic>;
        _cbplanData = cbpInfo;
        if (_cbplanData != cbpInfo) {
          notifyListeners();
        }
        final content = cbpInfo['content'];
        if (content != null && content is List && content.isNotEmpty) {
          CbPlanModel data = CbPlanModel.fromJson(cbpInfo);
          return data;
        }
      }
    } catch (e) {
      debugPrint('Error fetching CB Plan: $e');
    }

    return null;
  }

  // Competency search
  Future<dynamic> getCompetencySearchInfo() async {
    var response;
    try {
      // response =
      // `await learnService.getCompetencySearchInfo();
      response = AppConfiguration().useCompetencyv6
          ? await learnService.getListOfCompetencies()
          : await learnService.getCompetencySearchInfo();
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        return contents['result'];
      } else {
        return response.statusCode.toString();
      }
    } catch (_) {
      return response.statusCode.toString();
    }
  }

  // Competency search
  Future<dynamic> getCompetencySearchInfoFilter() async {
    var response;
    try {
      //response = await learnService.getCompetencySearchInfo();
      response = await learnService.getCompetencySearchInfo();
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        return contents['result'];
      } else {
        return response.statusCode.toString();
      }
    } catch (_) {
      return response.statusCode.toString();
    }
  }

  // Competency search
  Future<dynamic> getSearchByProvider() async {
    var response;
    try {
      response = await learnService.getSearchByProvider();
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        return contents;
      } else {
        return response.statusCode.toString();
      }
    } catch (_) {
      return response.statusCode.toString();
    }
  }

  Future<void> getCompetency() async {
    try {
      final response = await learnService.getEnrollmentListByFilter(
          status: EnrollmentAPIFilter.completed, retiredCoursesEnabled: true);
      _data = response;

      if (_data?.statusCode == 200) {
        var body = json.decode(utf8.decode(_data!.bodyBytes));
        var contents = body['result'] as Map<String, dynamic>;
        var competencyList = <CompetencyDataModel>[];
        List<dynamic> data = contents['courses'] as List<dynamic>;
        List<CompetencyPassbook> competencies = [];

        for (var course in data) {
          final String? certificateId =
              (course['issuedCertificates'] as List<dynamic>?)?.isNotEmpty ==
                      true
                  ? (course['issuedCertificates'] as List<dynamic>)
                      .last['identifier']
                  : null;

          final content = course['content'] as Map<String, dynamic>?;

          if (content != null &&
              AppConfiguration().useCompetencyv6 &&
              content['competencies_v6'] != null &&
              (content['competencies_v6'] as List<dynamic>).isNotEmpty) {
            for (var x in content["competencies_v6"]) {
              competencies.add(
                CompetencyPassbook.fromJson(
                    json: x,
                    courseId: content['identifier'],
                    useCompetencyv6: true),
              );
            }
          } else if (content != null &&
              content['competencies_v5'] != null &&
              (content['competencies_v5'] as List<dynamic>).isNotEmpty) {
            for (var x in content["competencies_v5"]) {
              competencies.add(
                CompetencyPassbook.fromJson(
                    json: x,
                    courseId: content['identifier'],
                    useCompetencyv6: false),
              );
            }
          }
          if (content != null && competencies.isNotEmpty) {
            for (var competency in competencies) {
              final courseId = competency.courseId;

              final competencyAreaId = competency.competencyAreaId;
              final competencyAreaName = competency.competencyArea;
              final competencyThemeId = competency.competencyThemeId;
              final competencyThemeName = competency.competencyTheme;
              final competencySubThemeId = competency.competencySubThemeId;
              final competencySubThemeName = competency.competencySubTheme;

              if (competencyAreaName?.toLowerCase() != 'behavioral') {
                CompetencyDataModel? existingCompetencyArea;

                for (var element in competencyList) {
                  if (element.competencyArea?.id == competencyAreaId) {
                    existingCompetencyArea = element;
                    break;
                  }
                }

                if (existingCompetencyArea == null) {
                  try {
                    competencyList.add(CompetencyDataModel.fromJson({
                      'competencyArea': {
                        'id': competencyAreaId,
                        'name': competencyAreaName
                      },
                      'competencyThemes': [
                        {
                          'competencyArea': {
                            'id': competencyAreaId,
                            'name': competencyAreaName
                          },
                          'theme': {
                            'id': competencyThemeId,
                            'name': competencyThemeName
                          },
                          'courses': [
                            {
                              'courseId': courseId,
                              'courseName':
                                  content['name'] ?? course['courseName'],
                              'completedOn': (course['issuedCertificates']
                                              as List<dynamic>?)
                                          ?.isNotEmpty ==
                                      true
                                  ? (course['issuedCertificates']
                                          as List<dynamic>)
                                      .last['lastIssuedOn']
                                  : null,
                              'certificateId': certificateId,
                              'courseCategory': course['primaryCategory'] ??
                                  content['primaryCategory'],
                              'courseSubthemes': [
                                {
                                  'id': competencySubThemeId,
                                  'name': competencySubThemeName
                                }
                              ],
                              'batchId': course['batchId']
                            }
                          ],
                          'competencySubthemes': [
                            {
                              'id': competencySubThemeId,
                              'name': competencySubThemeName
                            }
                          ]
                        }
                      ]
                    }));
                  } catch (e) {
                    print(e);
                  }
                } else {
                  var competencyThemes =
                      existingCompetencyArea.competencyThemes;

                  CompetencyTheme? existingCompetencyTheme;
                  for (var theme in competencyThemes!) {
                    if (theme.theme?.id == competencyThemeId) {
                      existingCompetencyTheme = theme;
                      break;
                    }
                  }

                  if (existingCompetencyTheme == null) {
                    try {
                      competencyThemes.add(CompetencyTheme.fromJson({
                        'competencyArea': {
                          'id': competencyAreaId,
                          'name': competencyAreaName
                        },
                        'theme': {
                          'id': competencyThemeId,
                          'name': competencyThemeName
                        },
                        'courses': [
                          {
                            'courseId': courseId,
                            'courseName':
                                content['name'] ?? course['courseName'],
                            'completedOn':
                                (course['issuedCertificates'] as List<dynamic>?)
                                            ?.isNotEmpty ==
                                        true
                                    ? (course['issuedCertificates']
                                            as List<dynamic>)
                                        .last['lastIssuedOn']
                                    : null,
                            'certificateId': certificateId,
                            'courseCategory': course['primaryCategory'] ??
                                content['primaryCategory'],
                            'courseSubthemes': [
                              {
                                'id': competencySubThemeId,
                                'name': competencySubThemeName
                              }
                            ],
                            'batchId': course['batchId']
                          }
                        ],
                        'competencySubthemes': [
                          {
                            'id': competencySubThemeId,
                            'name': competencySubThemeName
                          }
                        ]
                      }));
                    } catch (e) {
                      print(e);
                    }
                  } else {
                    var existingSubTheme;
                    for (var subTheme
                        in existingCompetencyTheme.competencySubthemes!) {
                      if (subTheme.id == competencySubThemeId) {
                        existingSubTheme = subTheme;
                        break;
                      }
                    }

                    if (existingSubTheme == null) {
                      existingCompetencyTheme.competencySubthemes?.add(
                          Theme.fromJson({
                        'id': competencySubThemeId,
                        'name': competencySubThemeName
                      }));

                      // Find the course associated with the current theme
                      CourseData? course;
                      for (var c in existingCompetencyTheme.courses!) {
                        if (c.courseId == courseId) {
                          course = c;
                          break;
                        }
                      }

                      if (course != null) {
                        course.courseSubthemes!.add(Theme.fromJson({
                          'id': competencySubThemeId,
                          'name': competencySubThemeName
                        }));
                      }
                    }
                    CourseData? existingCourse;
                    for (var course in existingCompetencyTheme.courses!) {
                      if (course.courseId == courseId) {
                        existingCourse = course;
                        break;
                      }
                    }

                    if (existingCourse == null) {
                      try {
                        existingCompetencyTheme.courses!
                            .add(CourseData.fromJson({
                          'courseId': courseId,
                          'courseName': content['name'] ?? course['courseName'],
                          'completedOn': (course['issuedCertificates']
                                          as List<dynamic>?)
                                      ?.isNotEmpty ==
                                  true
                              ? (course['issuedCertificates'] as List<dynamic>)
                                  .last['lastIssuedOn']
                              : null,
                          'certificateId': certificateId,
                          'courseCategory': course['primaryCategory'] ??
                              content['primaryCategory'],
                          'courseSubthemes': [
                            {
                              'id': competencySubThemeId,
                              'name': competencySubThemeName
                            }
                          ],
                          'batchId': course['batchId']
                        }));
                      } catch (e) {
                        print(e);
                      }
                    }
                  }
                }
              }
            }
          }
        }

        competencyList.sort((a, b) =>
            a.competencyArea!.name!.compareTo(b.competencyArea!.name!));

        var competencyThemeList = <CompetencyTheme>[];
        for (var element in competencyList) {
          competencyThemeList.addAll(element.competencyThemes!);
        }

        competencyThemeList.forEach((element) {
          element.courses!.sort((a, b) {
            if (a.completedOn != null && b.completedOn != null) {
              return DateTime.parse(b.completedOn!)
                  .compareTo(DateTime.parse(a.completedOn!));
            } else {
              return -1;
            }
          });
        });

        competencyThemeList.sort((a, b) {
          if (b.courses!.isNotEmpty && a.courses!.isNotEmpty) {
            if (b.courses!.first.completedOn != null &&
                a.courses!.first.completedOn != null) {
              return DateTime.parse(b.courses!.first.completedOn!)
                  .compareTo(DateTime.parse(a.courses!.first.completedOn!));
            }
          }
          return -1;
        });

        _competency = competencyList;
        _competencyThemeList = competencyThemeList;
      } else {
        _competency = [];
        _competencyThemeList = [];
      }
    } catch (e) {
      _competency = [];
      _competencyThemeList = [];
      print(e);
    } finally {
      notifyListeners();
    }
  }

  // Content read
  Future<dynamic> getCourseData(id,
      {bool isFeatured = false,
      bool isResource = false,
      bool pointToProd = false}) async {
    var response;
    try {
      response = await learnService.getCourseData(id,
          isFeatured: isFeatured, pointToProd: pointToProd);
      if (!isResource) {
        _contentRead = response;
      }
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getCourseReviewSummery(
      {required String courseId,
      required String primaryCategory,
      bool forceUpdate = false}) async {
    _courseRating = await learnService.getCourseReviewSummery(
        id: courseId,
        primaryCategory: primaryCategory,
        forceUpdate: forceUpdate);
    try {
      if (_courseRating != null) {
        _overallRating = OverallRating.fromJson(_courseRating);
      } else {
        _overallRating = null;
      }
    } catch (e) {
      print("overall rating error===$e");
    }
  }

  Future<dynamic> getCourseDetails(id,
      {bool isFeatured = false, bool pointToProd = false}) async {
    var response;
    try {
      response = await learnService.getCourseDetails(id,
          isFeatured: isFeatured, pointToProd: pointToProd);

      notifyListeners();
    } catch (e) {
      response = null;
    }
    if (response != null || (_courseHierarchyInfo != response)) {
      _courseHierarchyInfo = response;
      notifyListeners();
    }
    return _courseHierarchyInfo;
  }

  Future<dynamic> getYourReview(
      {required String id,
      required String primaryCategory,
      bool forceUpdate = false}) async {
    _courseRatingAndReview = await learnService.getYourReview(
      id: id,
      primaryCategory: primaryCategory,
      forceUpdate: forceUpdate,
    );
    notifyListeners();
    return _courseRatingAndReview;
  }

  void clearCourseDetails() {
    if (_contentRead != null ||
        _courseRatingAndReview != null ||
        _courseRating != null ||
        _courseHierarchyInfo != null) {
      _contentRead = null;
      _courseRatingAndReview = null;
      _courseRating = null;
      _courseHierarchyInfo = null;
      notifyListeners();
    }
  }

  void clearCbplan() {
    _cbplanData = null;
    notifyListeners();
  }

  /// MicroSite Start

  // getListOfFeaturedProviders
  Future<List<ProviderCardModel>> getListOfFeaturedProviders(String id) async {
    try {
      final _response = await learnService.getListOfFeaturedProviders(id);
      var contents = jsonDecode(_response);
      List<dynamic> body = contents;
      providerCardModel = body
          .map(
            (dynamic item) => ProviderCardModel.fromJson(item),
          )
          .toList();
      return providerCardModel;
    } catch (_) {
      return [];
    }
  }

  // getMicroSiteFormData
  Future<dynamic> getMicroSiteFormData(
      {String? orgId, String? type, String subtype = 'microsite-v2'}) async {
    try {
      final response = await learnService.getMicroSiteFormData(
          orgId: orgId, type: type, subtype: subtype);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));

      return contents['result']['form'];
    } else {
      _errorMessage = _data!.statusCode.toString();

      return null;
    }
  }

  // getLearnerReviews
  Future<dynamic> getLearnerReviews(String id) async {
    var response;
    try {
      response = await learnService.getLearnerReviews(id);
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        if (contents['result'] != null) {
          return contents['result'];
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  // getAllCompetencies
  Future<dynamic> getMicroSiteCompetencies(
      {required String orgId,
      required String competencyArea,
      required List<String> facets}) async {
    try {
      final response = await learnService.getMicroSiteCompetencies(
          orgId: orgId, competencyArea: competencyArea, facets: facets);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));

      return contents['result'];
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  // getInsightData
  Future<dynamic> getInsightData({String? orgId}) async {
    try {
      final response = await learnService.getInsightData(orgId: orgId!);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      return (contents['result']['response']['nudges'][0] != null)
          ? contents['result']['response']['nudges'][0]
          : null;
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  Future<dynamic> getMicroSiteTopCourses(String orgId,
      List<String> selectedTypes, String selectedCoursePills, int limit) async {
    try {
      final response = await learnService.getMicroSiteTopCourses(
          orgId, selectedTypes, selectedCoursePills, limit);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      return (contents['result']['content'] != null)
          ? contents['result']['content']
          : [];
    } else {
      return [];
    }
  }

  Future<dynamic> getMicroSiteFeaturedCourses(String orgId,
      List<String> selectedTypes, String selectedCoursePills) async {
    try {
      final response = await learnService.getMicroSiteFeaturedCourses(
          orgId, selectedTypes, selectedCoursePills);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      return (contents['result']['content'] != null)
          ? contents['result']['content']
          : [];
    } else {
      return [];
    }
  }

  // getLearnerReviews
  Future<dynamic> getMicroSiteCalenderData(
      String id, String startDate, String endDate) async {
    var response;
    try {
      response =
          await learnService.getMicroSiteCalenderData(id, startDate, endDate);
      if (response.statusCode == 200) {
        var contents = jsonDecode(response.body);
        if (contents['result'] != null) {
          return contents['result'];
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// MicroSite End

  /// MDO channel Start

  Future<List<MdoChannelDataModel>> getListOfMdoChannels(
      String orgBookmarkId) async {
    try {
      final response = await learnService.getListOfMdoChannels(orgBookmarkId);
      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      List<dynamic> body = contents['result']['data']['orgList'] != null
          ? contents['result']['data']['orgList']
          : [];
      List<MdoChannelDataModel> channelData = [];
      channelData = body
          .map(
            (dynamic item) => MdoChannelDataModel.fromJson(item),
          )
          .toList();
      return channelData;
    } else {
      _errorMessage = _data!.statusCode.toString();
      return [];
    }
  }

  // getMdoChannelFormData

  Future<dynamic> getMdoChannelFormData({required String orgId}) async {
    try {
      Response response =
          await learnService.getMdoChannelFormData(orgId: orgId);

      if (response.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));
        // TestMdoData().getMdoData();
        return contents['result']['form']['data'];
      } else {
        _errorMessage = response.statusCode.toString();
        throw _errorMessage;
      }
    } catch (_) {
      debugPrint("error in getMdoChannelFormData $_");
      return _;
    }
  }

  // getChannelInsightData
  Future<dynamic> getChannelInsightData({required String orgId}) async {
    try {
      final response = await learnService.getChannelInsightData(orgId: orgId);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      return (contents['result']['response']['nudges'][0] != null)
          ? contents['result']['response']['nudges'][0]
          : null;
    } else {
      _errorMessage = _data!.statusCode.toString();
      return null;
    }
  }

  //getChannelCertificateOfWeek
  Future<dynamic> getMdoCertificateOfWeek(String orgId) async {
    try {
      final response = await learnService.getMdoCertificateOfWeek(orgId);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      return (contents['response']['certifications'] != null)
          ? contents['response']['certifications']
          : [];
    } else {
      return [];
    }
  }

  //getMdoCoursesData
  Future<dynamic> getMdoCoursesData(
      String orgId, String type, String selectedCoursePills) async {
    try {
      final response = await learnService.getMdoCoursesData(
          orgId, type, selectedCoursePills);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      return (contents['result']['content'] != null)
          ? contents['result']['content']
          : [];
    } else {
      return [];
    }
  }

  // getAnnouncementData
  Future<dynamic> getAnnouncementData({required String orgId}) async {
    try {
      final response = await learnService.getAnnouncementData(orgId: orgId);
      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      return (contents['result']['data'] != null)
          ? contents['result']['data']
          : [];
    } else {
      _errorMessage = _data!.statusCode.toString();
      return [];
    }
  }

  // getTopLearnerData for MDO
  Future<dynamic> getMDOTopLearnerData({required String orgId}) async {
    try {
      final response = await learnService.getMDOTopLearnerData(orgId: orgId);
      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      return (contents['result']['result'] != null)
          ? contents['result']['result']
          : [];
    } else {
      _errorMessage = _data!.statusCode.toString();
      return [];
    }
  }

  //getCompetenciesByOrg
  Future<dynamic> getCompetenciesByOrg(String orgId) async {
    try {
      final response = await learnService.getCompetenciesByOrg(orgId);
      _data = response;
    } catch (_) {
      return _;
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(utf8.decode(_data!.bodyBytes));
      return (contents['result'] != null) ? contents['result'] : null;
    } else {
      return null;
    }
  }

  /// MDO channel end

  Future<List<ContentStateModel>> readContentProgress(
      String courseId, String batchId,
      {List contentIds = const [],
      required String language,
      bool forceUpdateOverallProgress = false}) async {
    _languageProgress = {};

    try {
      final response = await learnService.readContentProgress(courseId, batchId,
          contentIds: contentIds, language: language);
      if (response['result']['languageProgress'] != null &&
          response['result']['languageProgress'].isNotEmpty &&
          forceUpdateOverallProgress) {
        _languageProgress = response['result']['languageProgress'];
        notifyListeners();
      }
      List<ContentStateModel> content = response['result']['contentList']
          .map((dynamic item) => ContentStateModel.fromJson(item))
          .toList()
          .cast<ContentStateModel>();
      return content;
    } catch (_) {
      throw 'Unable to fetch content progress';
    }
  }

  void resetLanguageProgress() {
    _languageProgress = {};
    notifyListeners();
  }

  /// read pre requisite content progress
  Future<List<ContentStateModel>> readPreRequisiteContentProgress(
      List<String> contentIds) async {
    try {
      final response =
          await learnService.readPreRequisiteContentProgress(contentIds);
      List<ContentStateModel> content = response['result']['contentList']
          .map((dynamic item) => ContentStateModel.fromJson(item))
          .toList()
          .cast<ContentStateModel>();
      return content;
    } catch (_) {
      throw 'Unable to fetch content progress';
    }
  }

  /// Netcore config data
  Future<bool> isSmartechEventEnabled(
      {required String eventName,
      bool reload = false,
      bool isFunctionality = false}) async {
    try {
      if (!isNetcoreActive || SmartechService.netcoreDisabledAtOrg)
        return false;
      if (reload || netcoreConfig == null) {
        final response = await learnService.getNetcoreConfig();
        netcoreConfig = await response['netcoreConfig'];
      }
      var mobileConfig = netcoreConfig?["netcoreMobileConfig"];
      if (mobileConfig == null) {
        return false;
      }
      bool isActive = mobileConfig["isActive"] ?? false;
      if (isFunctionality) {
        return isActive;
      } else {
        var eventConfig = mobileConfig["events"]?[eventName];
        bool isEventActive =
            eventConfig != null && (eventConfig["isActive"] ?? false);
        return isActive && isEventActive;
      }
    } catch (_) {
      return false;
    }
  }

  //Get recommended Courses with doId
  Future<List<Course>> getRecommendationWithDoId(List doIdList,
      {List<String>? relevantDoId, bool pointToProd = false}) async {
    try {
      final response =
          await learnService.getRecommendationWithDoId(doIdList, pointToProd);
      _data = response;
    } catch (_) {
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      List<Course> courses = [];
      List<dynamic>? body = contents['result']['content'];
      if (body != null) {
        courses = body
            .map(
              (dynamic item) => Course.fromJson(
                item,
              ),
            )
            .toList();
        if (courses.isNotEmpty) {
          courses.sort((a, b) =>
              doIdList.indexOf(a.id).compareTo(doIdList.indexOf(b.id)));
        }
      }
      updateRelevance(relevantDoId, courses);
      return courses;
    } else {
      _errorMessage = _data!.statusCode.toString();
      throw _errorMessage;
    }
  }

  void updateRelevance(List<String>? relevantDoId, List<Course> courses) {
    if ((relevantDoId ?? []).isNotEmpty) {
      relevantDoId!.forEach((doId) {
        int index = courses.indexWhere((course) => course.id == doId);
        if (index >= 0) {
          courses[index].isRelevant = true;
        }
      });
    }
  }

  Future<List<Course>> getCourseEnrollDetailsByIds(
      {required List<String> courseIds,
      bool checkforCBPEnddate = false}) async {
    try {
      final response =
          await learnService.getCourseEnrollDetailsByIds(courseIds: courseIds);
      _data = response;
    } catch (_) {
      print(_);
      return [];
    }
    if (_data!.statusCode == 200) {
      var contents = json.decode(utf8.decode(_data!.bodyBytes));
      List<dynamic> body = contents['result']['courses'] ?? [];

      try {
        if (body.isNotEmpty) {
          if (checkforCBPEnddate) {
            body = await addCBPEnddateToCourse(body);
          }
          List<Course> course =
              body.map((data) => Course.fromJson(data)).toList();
          return course;
        } else {
          return [];
        }
      } catch (e) {
        print(e);
        return [];
      }
    } else {
      return [];
    }
  }

  Future<UserEnrollmentInfo?> getEnrollmentSummary() async {
    try {
      Response response = await learnService.getEnrollmentSummary();

      if (response.statusCode == 200) {
        final contents = json.decode(utf8.decode(response.bodyBytes));
        final body = contents['result'];

        if (body == null) {
          return null;
        }

        return UserEnrollmentInfo.fromJson(body);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching enrollment summary: $e");
      return null;
    }
  }

  Future<List<Course>> getEnrollmentListByFilter(
      {required String status,
      int? limit,
      String? contentType,
      bool retiredCoursesEnabled = true,
      bool checkforCBPEnddate = false}) async {
    try {
      final response = await learnService.getEnrollmentListByFilter(
          status: status,
          limit: limit,
          contentType: contentType,
          retiredCoursesEnabled: retiredCoursesEnabled);
      _data = response;
      if (_data!.statusCode == 200) {
        var contents = json.decode(utf8.decode(_data!.bodyBytes));
        List<dynamic> body = contents['result']['courses'] ?? [];
        if (body.isNotEmpty) {
          if (checkforCBPEnddate) {
            body = await addCBPEnddateToCourse(body);
          }
          List<Course> courses =
              body.map((data) => Course.fromJson(data)).toList();

          courses
            ..sort((a, b) {
              bool aIsCAP = a.courseCategory ==
                  PrimaryCategory.comprehensiveAssessmentProgram;
              bool bIsCAP = b.courseCategory ==
                  PrimaryCategory.comprehensiveAssessmentProgram;

              if (aIsCAP && !bIsCAP) return -1;
              if (!aIsCAP && bIsCAP) return 1;

              return getLastAccessTime(b).compareTo(getLastAccessTime(a));
            });

          return courses;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (_) {
      print(_);
      return [];
    }
  }

  static int getLastAccessTime(Course course) {
    return course.raw['lastContentAccessTime'] ?? 0;
  }

  Future<String> enrollToCuratedProgram(String courseId, String batchId) async {
    try {
      Response res =
          await learnService.enrollToCuratedProgram(courseId, batchId);
      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        return contents['result']['response'];
      } else {
        return jsonDecode(res.body)['params']['errmsg'];
      }
    } catch (e) {
      return EnglishLang.failed;
    }
  }

  Future<String> enrollProgram({
    required String courseId,
    required String programId,
    required String batchId,
  }) async {
    try {
      Response res = await learnService.enrollProgram(
          courseId: courseId, programId: programId, batchId: batchId);
      if (res.statusCode == 200) {
        return EnglishLang.success;
      } else {
        return jsonDecode(res.body)['params']['errmsg'];
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<dynamic> autoEnrollBatch(
      {required String courseId, String? language}) async {
    try {
      Response res = await learnService.autoEnrollBatch(
          courseId: courseId, language: language);
      if (res.statusCode == 200) {
        var contents = jsonDecode(res.body);
        return contents['result']['response']['content'][0];
      } else {
        return jsonDecode(res.body)['params']['errmsg'];
      }
    } catch (e) {
      return 'Unable to auto enroll a batch';
    }
  }

  Future<String?> getCourseCompletionCertificate(String id) async {
    try {
      return await learnService.getCourseCompletionCertificate(id);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getCourseCompletionDynamicCertificate(
      String courseId, String batchId) async {
    try {
      return await learnService.getCourseCompletionDynamicCertificate(
          courseId, batchId);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> downloadCompletionCertificate(String printUri,
      {String? outputType}) async {
    try {
      return await learnService.downloadCompletionCertificate(printUri);
    } catch (e) {
      return null;
    }
  }

  Future<CompositeSearchModel?> getCompositeSearchData(int pageNo,
      String searchText, List primaryCategory, List mimeType, List source,
      {Duration? ttl,
      bool checkforCBPEnddate = true,
      List<String>? facets,
      Map<String, dynamic>? filters,
      Map<String, dynamic>? sortBy,
      int? limit,
      List<String> fields = const []}) async {
    try {
      final response = await learnService.getCompositeSearchData(
          pageNo, searchText, primaryCategory, mimeType, source,
          ttl: ttl,
          facets: facets,
          filters: filters,
          sortBy: sortBy,
          limit: limit,
          fields: fields);
      _data = response;
      if (_data!.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(_data!.bodyBytes));

        Map<String, dynamic> body =
            contents['result'] != null ? contents['result'] : [];
        if (checkforCBPEnddate) {
          body['content'] = await addCBPEnddateToCourse(body['content']);
        }
        CompositeSearchModel data = CompositeSearchModel.fromJson(body);
        return data;
      } else {
        _errorMessage = _data!.statusCode.toString();
        return null;
      }
    } catch (_) {
      print(_);
      return null;
    }
  }
}
