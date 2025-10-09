import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/services/http_service.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import '../../env/env.dart';
import './../../constants/index.dart';

class ProfileService {
  static final _storage = FlutterSecureStorage();

  Future<dynamic> getProfileDetails() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    String profileDetailsUrl = ApiUrl.baseUrl + ApiUrl.getProfileDetails;
    Response response = await get(Uri.parse(profileDetailsUrl),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  Future<dynamic> getProfileDetailsById(String? id) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    String userId = ((id != '' && id != null)
        ? id
        : (wid != '' && wid != null)
            ? wid
            : '');
    // dont call api if userId is not present
    if (userId == '') return;

    String profileDetailsUrl =
        ApiUrl.baseUrl + ApiUrl.getProfileDetailsByUserId;

    Response response = await HttpService.get(
        ttl: ApiTtl.getProfileDetails,
        apiUri: Uri.parse(profileDetailsUrl + userId),
        headers:
            NetworkHelper.getHeaders(token ?? '', wid ?? '', rootOrgId ?? ''));
    return response;
  }

  Future<dynamic> updateProfileDetails(Map profileDetails) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    // var _profileDetails = json.encode(profileDetails);
    Map data = {
      "request": {"userId": "$wid", "profileDetails": profileDetails}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.updateProfileDetails;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    return jsonDecode(response.body);
  }

  Future<dynamic> updateGetStarted({bool isSkipped = false}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map getStartedObj = {"visited": true, "skipped": isSkipped};
    Map profileDetails = {'get_started_tour': getStartedObj};
    Map data = {
      "request": {"userId": "$wid", "profileDetails": profileDetails}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.updateProfileDetails;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    return jsonDecode(response.body);
  }

  Future<dynamic> getInReviewFields(
      {bool isRejected = false,
      bool isApproved = false,
      bool forceUpdate = false}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "serviceName": "profile",
      "applicationStatus": isRejected
          ? "REJECTED"
          : isApproved
              ? 'APPROVED'
              : "SEND_FOR_APPROVAL"
    };

    Response response = await HttpService.post(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getInReviewFields),
        ttl: ApiTtl.getInReviewFields,
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: data,
        forceUpdate: forceUpdate);

    return jsonDecode(response.body);
  }

  Future<dynamic> withdrawProfileField({required String wfId}) async {
    String? wid = await _storage.read(key: Storage.wid);
    String? token = await _storage.read(key: Storage.authToken);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "action": ProfileRequests.withdrawAction,
      "state": ProfileRequests.sendForApprovalState,
      "userId": "$wid",
      "applicationId": "$wid",
      "actorUserId": "$wid",
      "wfId": "$wfId",
      "serviceName": ProfileRequests.profileServiceName,
      "updateFieldValues": [],
      "comment": ""
    };

    var body = json.encode(data);

    String url = ApiUrl.baseUrl + ApiUrl.withdrawRequestUrl;
    Response response = await post(Uri.parse(url),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    if (response.statusCode != 200) {
      throw response.statusCode;
    }
    return response;
  }

  Future<dynamic> getNationalities() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getNationalities),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  Future<dynamic> getLanguages() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getLanguages),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    log(response.body.toString());
    return response;
  }

  Future<dynamic> getDegrees(String type) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(Uri.parse(ApiUrl.baseUrl + ApiUrl.getDegrees),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    // print(res.body);
    return response;
  }

  Future<dynamic> getOrganisations() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getDepartments),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getIndustries() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getIndustries),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getDesignations(int offset, String query) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'filterCriteriaMap': {'status': 'Active'},
      'requestedFields': [],
      'pageNumber': offset,
      'pageSize': 50
    };
    if (query.isNotEmpty && query.length >= 3) {
      data['searchString'] = query;
    }
    var body = json.encode(data);

    Response response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getDesignationsAndGradePay),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  Future<dynamic> getGradePay() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getProfilePageMeta),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    // print(res.body.toString());
    return response;
  }

  // getServicesAndCadre

  Future<dynamic> getServices() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getServicesAndCadre),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getCadre() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Response response = await get(Uri.parse(ApiUrl.baseUrl + ApiUrl.getCadre),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    // print(res.body.toString());
    return response;
  }

  Future<dynamic> getProfilePageMeta() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getProfilePageMeta),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Can\'t get profile page meta.';
    }
  }

  /// Return username
  Future<dynamic> getUserName(String wid) async {
    final _storage = FlutterSecureStorage();

    String? token = await _storage.read(key: Storage.authToken);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.basicUserInfo + wid),
        headers: NetworkHelper.getHeaders(token!, wid, rootOrgId!));
    return response;
  }

  // To send the OTP to mobile number
  Future<dynamic> generateMobileNumberOTP(String mobileNumber) async {
    Map data = {
      "request": {"type": "phone", "key": "$mobileNumber"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.generateOTP;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.signUpPostHeaders(), body: body);
    return jsonDecode(response.body);
  }

  //To verify the OTP
  Future<dynamic> verifyMobileNumberOTP(String mobileNumber, String otp) async {
    Map data = {
      "request": {"type": "phone", "key": "$mobileNumber", "otp": "$otp"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.verifyOTP;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.signUpPostHeaders(), body: body);
    // developer.log(jsonDecode(response.body).toString());
    return jsonDecode(response.body);
  }

  // To send the OTP to email
  Future<dynamic> generatePrimaryEmailOTP(String email) async {
    String? token = await _storage.read(key: Storage.authToken);
    Map data = {
      "request": {
        "type": "email",
        "key": "$email",
        "contextType": "extPatch",
        "contextAttributes": [
          "profileDetails.personalDetails.primaryEmail",
        ]
      }
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.generateOTPv3;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.registerParichayUserPostHeaders(token),
        body: body);
    // log(response.body.toString());
    return jsonDecode(response.body);
  }

  //To verify the OTP of email
  Future<dynamic> verifyPrimaryEmailOTP(String email, String otp) async {
    String? token = await _storage.read(key: Storage.authToken);
    Map data = {
      "request": {"type": "email", "key": "$email", "otp": "$otp"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.verifyOTPv3;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.registerParichayUserPostHeaders(token),
        body: body);
    // log('verify otp: ' + response.body.toString());
    return jsonDecode(response.body);
  }

  Future<dynamic> updateUserPrimaryEmail(
      {required String email, required String contextToken}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Map data = {
      "request": {
        "userId": "$wid",
        "profileDetails": {
          "personalDetails": {"primaryEmail": "$email"}
        },
        "contextToken": "$contextToken"
      }
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.updateProfileDetailsV2;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    // log('update primary email: ' + response.body.toString());
    return jsonDecode(response.body);
  }

  // To send the OTP to email address
  Future<dynamic> generateEmailOTP(String emailAddress) async {
    Map data = {
      "request": {"type": "email", "key": "$emailAddress"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.generateOTP;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.signUpPostHeaders(), body: body);
    return jsonDecode(response.body);
  }

  // To send the OTP to email address which have domain validation
  Future<dynamic> generateEmailExtOTP(String emailAddress) async {
    Map data = {
      "request": {"type": "email", "key": "$emailAddress"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.generateExtOTP;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.signUpPostHeaders(), body: body);
    return jsonDecode(response.body);
  }

  // To verify the Email OTP
  Future<dynamic> verifyEmailOTP(String emailId, String otp) async {
    Map data = {
      "request": {"type": "email", "key": "$emailId", "otp": "$otp"}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.verifyOTP;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.signUpPostHeaders(), body: body);
    // developer.log(jsonDecode(response.body).toString());
    return jsonDecode(response.body);
  }

  // get approved email domains
  Future<dynamic> getApprovedEmailDomains() async {
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);

    final response = await HttpService.get(
        ttl: ApiTtl.approvedDomainTtl,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.approvedDomains),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  //get edit profile configuration
  Future<dynamic> getProfileEditConfig() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getProfileEditConfig),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return jsonDecode(response.body);
  }

  // To get user insights
  Future<dynamic> getUserInsights() async {
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);
    String url = ApiUrl.baseUrl + ApiUrl.getInsights;
    Map data = {
      "request": {
        "filters": {
          "primaryCategory": "programs",
          "organisations": ["across", rootOrgId]
        }
      }
    };
    var body = json.encode(data);
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.insightHeader(wid!, token!), body: body);
    return response;
  }

  // To update profile photo
  Future<dynamic> uploadProfilePhoto(File image) async {
    String url = ApiUrl.baseUrl + ApiUrl.uploadProfilePhoto;

    var formData = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(NetworkHelper.formDataHeader());
    formData.files.add(await MultipartFile.fromPath('file', image.path));
    try {
      final response = await formData.send();
      return response;
    } catch (e) {
      print(e);
    }
  }

  // Read karma points(or get history of karma points)
  Future<dynamic> getKarmaPointHistory({limit, offset}) async {
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);
    Map data = {'limit': limit, 'offset': offset.toString()};
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.karmaPointRead;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  // Get Total karma point info
  Future<dynamic> getTotalKarmaPoint() async {
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);
    var body = json.encode({});
    String url = ApiUrl.baseUrl + ApiUrl.totalKarmaPoint;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  // read karma point for course
  Future<dynamic> getKarmaPointCourseRead(String courseId) async {
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);
    var body = json.encode({
      "request": {
        "filters": {"contextType": "Course", "contextId": courseId}
      }
    });
    String url = ApiUrl.baseUrl + ApiUrl.karmapointCourseRead;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  // Claim karma points
  Future<dynamic> claimKarmaPoints(String courseId) async {
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);
    var body = json.encode({"userId": wid, "courseId": courseId});
    String url = ApiUrl.baseUrl + ApiUrl.claimKarmaPoints;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  /// share course -start
  Future<dynamic> getRecipientList(String query, int limit) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "query": query,
        "filters": {"rootOrgId": rootOrgId, "status": 1},
        "fields": ["firstName", "maskedEmail", "userId", "profileDetails"],
        "limit": limit
      }
    };

    String body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getUsersByEndpoint),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map usersList = json.decode(response.body);

    return usersList;
  }

  Future<dynamic> shareCourse(recipients, courseId, courseName,
      coursePosterImageUrl, courseProvider, primaryCategory) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "courseId": courseId,
        "courseName": courseName,
        "coursePosterImageUrl": coursePosterImageUrl,
        "courseProvider": courseProvider,
        "primaryCategory": primaryCategory,
        "recipients": recipients
      }
    };

    Response res = await post(Uri.parse(ApiUrl.baseUrl + ApiUrl.shareCourse),
        headers:
            NetworkHelper.postCourseHeaders(token!, wid!, courseId, rootOrgId!),
        body: json.encode(data));
    if (res.statusCode == 200) {
      var contents = jsonDecode(res.body);
      return contents['params']['status'];
    } else {
      throw 'Unable to auto enroll a batch';
    }
  }

  ///Share course -end

  /// Learner leaderboard
  Future<dynamic> getLeaderboardData() async {
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);
    String url = ApiUrl.baseUrl + ApiUrl.getLeaderboardData;

    final response = await get(Uri.parse(url),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  Future<dynamic> updateLeaderboardNudgeData(String currentDate) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map profileDetails = {'lastMotivationalMessageTime': '$currentDate'};
    Map data = {
      "request": {"userId": "$wid", "profileDetails": profileDetails}
    };
    var body = json.encode(data);
    String url = ApiUrl.baseUrl + ApiUrl.updateProfileDetails;
    final response = await post(Uri.parse(url),
        headers: NetworkHelper.profilePostHeaders(token!, wid!, rootOrgId!),
        body: body);
    return jsonDecode(response.body);
  }

  /// Learner leaderboard
  Future<dynamic> getCadreConfigData() async {
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? token = await _storage.read(key: Storage.authToken);
    String url = ApiUrl.baseUrl + ApiUrl.getCadreConfigData;

    final response = await get(Uri.parse(url),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  //get edit profile configuration
  Future<dynamic> getRecommendedCourse() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response response = await HttpService.get(
        ttl: ApiTtl.getRecommendedCourse,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.courseRecommended),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return response;
  }

  Future<dynamic> getBasicProfileDetailsById(String id) async {
    String? token = await _storage.read(key: Storage.authToken);

    Response response = await HttpService.get(
        ttl: ApiTtl.getProfileDetails,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.basicProfileRead + id),
        headers: NetworkHelper.postHeader(token ?? ''));
    return response;
  }

  Future<dynamic> getStateList() async {
    String? token = await _storage.read(key: Storage.authToken);

    Response response = await HttpService.get(
        ttl: ApiTtl.stateAndDistrict,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.stateList),
        headers: NetworkHelper.postHeader(token ?? ''));
    return response;
  }

  Future<dynamic> getDistrictList(String state) async {
    String? token = await _storage.read(key: Storage.authToken);

    final response = await HttpService.post(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.districtList),
        headers: NetworkHelper.postHeader(token ?? ''),
        body: {'contextName': state},
        ttl: ApiTtl.stateAndDistrict);
    return response;
  }

  Future<dynamic> saveExtendedProfile(Map<String, dynamic> content) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Map<String, dynamic> data = {'request': {}};
    data['request']['userId'] = wid ?? '';
    data['request'].addAll(content.map((key, value) => MapEntry(key, value)));
    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.saveExtendedProfile),
        headers: NetworkHelper.postHeader(token ?? ''),
        body: body);

    return response;
  }

  Future<dynamic> getExtendedProfile(String? userId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Response response = await http.get(
        Uri.parse(
            ApiUrl.baseUrl + ApiUrl.extendedProfileSummary + (userId ?? wid!)),
        headers: NetworkHelper.postHeader(token ?? ''));
    return response;
  }

  Future<dynamic> getDegreeList() async {
    String? token = await _storage.read(key: Storage.authToken);

    Response response = await HttpService.get(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.degreeList),
        headers: NetworkHelper.postHeader(token ?? ''));
    return response;
  }

  Future<dynamic> getInstitutionList() async {
    String? token = await _storage.read(key: Storage.authToken);

    Response response = await HttpService.get(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.institutionList),
        headers: NetworkHelper.postHeader(token ?? ''));
    return response;
  }

  Future<dynamic> updateExtendedProfile(Map<String, dynamic> content) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Map<String, dynamic> data = {'request': {}};
    data['request']['userId'] = wid ?? '';
    data['request'].addAll(content.map((key, value) => MapEntry(key, value)));
    var body = json.encode(data);

    final response = await http.put(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.updateExtendedProfile),
        headers: NetworkHelper.postHeader(token ?? ''),
        body: body);

    return response;
  }

  Future<dynamic> getExtendedServiceHistory(String? userId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Response response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.extendedProfileServiceHistory +
            (userId ?? wid!)),
        headers: NetworkHelper.postHeader(token ?? ''));
    return response;
  }

  Future<dynamic> getExtendedEducationHistory(String? userId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Response response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.extendedProfileEducation +
            (userId ?? wid!)),
        headers: NetworkHelper.postHeader(token ?? ''));
    return response;
  }

  Future<dynamic> getExtendedAchievements(String? userId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);

    Response response = await http.get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.extendedProfileAchievement +
            (userId ?? wid!)),
        headers: NetworkHelper.postHeader(token ?? ''));
    return response;
  }

  // To update profile banner
  Future<dynamic> uploadProfileBanner(File image) async {
    try {
      var formData = http.MultipartRequest(
          'POST', Uri.parse(ApiUrl.baseUrl + ApiUrl.profileBannerUpload))
        ..headers.addAll(NetworkHelper.formDataHeader());
      formData.files.add(await MultipartFile.fromPath('file', image.path));
      final response = await formData.send();
      return response;
    } catch (e) {
      return e;
    }
  }

  // To update certificate
  Future<dynamic> uploadAchievementCertificate(File image) async {
    try {
      var formData = http.MultipartRequest('POST',
          Uri.parse(ApiUrl.baseUrl + ApiUrl.achievementCertificateUpload))
        ..headers.addAll(NetworkHelper.formDataHeader());
      formData.files.add(await MultipartFile.fromPath('file', image.path));
      final response = await formData.send();
      return response;
    } catch (e) {
      return e;
    }
  }

  // To update degree master list
  Future<dynamic> updateDegreeMasterList(String degree) async {
    String? token = await _storage.read(key: Storage.authToken);

    Map<String, dynamic> data = {'degreeName': degree};
    var body = json.encode(data);

    Response response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.updateDegree),
        headers: NetworkHelper.postHeader(token ?? ''),
        body: body);
    return response;
  }

  // To update institution master list
  Future<dynamic> updateInstitutionMasterList(String institution) async {
    String? token = await _storage.read(key: Storage.authToken);

    Map<String, dynamic> data = {'institutionName': institution};
    var body = json.encode(data);

    Response response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.updateInstitute),
        headers: NetworkHelper.postHeader(token ?? ''),
        body: body);
    return response;
  }

  // To get org master list
  Future<dynamic> getOrgMasterList(
      {int offset = 0, required String query}) async {
    String? token = await _storage.read(key: Storage.authToken);

    Map<String, dynamic> data = {
      'request': {
        'filters': {
          'isTenant': true,
          'status': 1,
          'isMdo': true,
          'isCbp': true
        },
        'fields': ['orgName', 'rootOrgId', 'imgUrl', 'logo'],
        'query': query,
        'limit': 20,
        'offset': offset
      }
    };
    var body = json.encode(data);

    Response response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getListOfProviders),
        headers: NetworkHelper.postHeader(token ?? ''),
        body: body);
    return response;
  }

  // To get org based designation
  Future<dynamic> getOrgBasedDesignationList(
      {int offset = 0,
      required List<String> orgIdList,
      required String query}) async {
    String? token = await _storage.read(key: Storage.authToken);
// Append '_odcs_designation' to each orgId
    List<String> orgList =
        orgIdList.map((id) => '${id}_odcs_designation').toList();

    Map<String, dynamic> data = {
      'request': {
        'filters': {
          'status': 'Live',
          'category': 'designation',
          'categories': orgList,
          'objectType': 'Term'
        },
        'fields': ['name'],
        'query': query,
        'offset': 0,
        'limit': 20,
        'sort_by': {'lastUpdatedOn': 'desc', 'objectType': 'Term'},
        'facets': []
      }
    };
    var body = json.encode(data);

    Response response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getTrendingCoursesV4),
        headers: NetworkHelper.postHeader(token ?? ''),
        body: body);
    return response;
  }

  /// Get profile connection relationship
  Future<dynamic> getConnectionRelationship(String id) async {
    String? token = await _storage.read(key: Storage.authToken);
    Response response = await HttpService.get(
        ttl: ApiTtl.getProfileDetails,
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.connectionRelationship + id),
        headers: NetworkHelper.postHeader(token ?? ''));
    return response;
  }

  Future<dynamic> getNodalUser() async {
    final Response response =
        await get(Uri.parse(Env.baseUrl + ApiUrl.getMdoAdminList));

    Map usersList = json.decode(response.body);

    return usersList;
  }
}
