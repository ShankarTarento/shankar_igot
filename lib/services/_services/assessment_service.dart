import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/_models/guest_data_model.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

import '../../constants/index.dart';
import '../../util/index.dart';

class AssessmentService {
  static final _storage = FlutterSecureStorage();

//Advanced Assessment read
  Future<dynamic> getStandaloneAssessmentInfo(String id,
      {required String parentContextId}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    var res;

    res = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getStandaloneAssessmentInfo + id)
            .replace(queryParameters: {'parentContextId': parentContextId}),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    return res;
  }

// Advanced assessment retake info
  Future<dynamic> getRetakeStandaloneAssessmentInfo(String assessmentId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = await get(
        Uri.parse(ApiUrl.baseUrl +
            ApiUrl.getStandaloneRetakeAssessmentInfo +
            assessmentId),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    return res;
  }

// Advanced assessment question list
  Future<dynamic> getStandaloneAssessmentQuestions(
    String assessmentId,
    List<dynamic> questionIds,
  ) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Map data = {
      'assessmentId': '$assessmentId',
      'request': {
        'search': {'identifier': questionIds}
      }
    };

    var body = json.encode(data);

    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getStandaloneAssessmentQuestions),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    return res;
  }

  // Advanced assessment submit
  Future<dynamic> submitStandaloneAssessment(Map data,
      {bool isFTBDropdown = false}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    var body = json.encode(data);
    String url;
    if (isFTBDropdown) {
      url = ApiUrl.baseUrl + ApiUrl.submitV6StandaloneAssessment;
    } else {
      url = ApiUrl.baseUrl + ApiUrl.submitStandaloneAssessment;
    }
    Response res = await post(Uri.parse(url),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!), body: body);
    return res;
  }

  // Advanced assessment save answered questions
  Future<dynamic> saveAssessmentQuestion(Map data) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.saveAssessmentQuestion),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    return res;
  }

// Basic assessment read
  Future<dynamic> getAssessmentInfo(String id,
      {required String parentContextId}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = await get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getAssessmentInfo + id)
            .replace(queryParameters: {'parentContextId': parentContextId}),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    return res;
  }

// Basic assessment retake info
  Future<dynamic> getRetakeAssessmentInfo(String assessmentId) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Response res = await get(
        Uri.parse(
            ApiUrl.baseUrl + ApiUrl.getRetakeAssessmentInfo + assessmentId),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));
    return res;
  }

// Basic assessment question list
  Future<dynamic> getAssessmentQuestions(
    String assessmentId,
    List<dynamic> questionIds,
  ) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    Map data = {
      'assessmentId': '$assessmentId',
      'request': {
        'search': {'identifier': questionIds}
      }
    };

    var body = json.encode(data);

    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getAssessmentQuestions),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    return res;
  }

// Basic assessment submit
  Future<dynamic> submitAssessmentNew(Map data) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.saveAssessmentNew),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);

    return res;
  }

// Basic assessment result
  Future<dynamic> getAssessmentCompletionStatus(Map data) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getAssessmentCompletionStatus),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      var contents = jsonDecode(res.body);
      return contents['result'];
    } else {
      return jsonDecode(res.body)['params']['errmsg'];
    }
  }

// Assessment read for assessment with artifact URL
  Future<dynamic> getAssessmentData(
    String fileUrl,
  ) async {
    Response res =
        await get(Uri.parse(Helper.convertToPortalUrl(fileUrl)), headers: {});
    return res;
  }

// Assessment with artifact URL submit
  Future<dynamic> submitAssessment(Map data) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    var body = json.encode(data);
    Response res = await post(Uri.parse(ApiUrl.baseUrl + ApiUrl.saveAssessment),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!), body: body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      var contents = jsonDecode(res.body);
      return contents;
    } else {
      throw 'Can\'t submit survey data';
    }
  }

  /// Public assessment read
  Future<dynamic> getPublicAssessmentInfo(
      {
        required String assessmentId,
        required String contextId,
        GuestDataModel? guestUserData
      }) async {
    Map<String, dynamic> data = {
      "assessmentIdentifier": assessmentId,
      "contextId": contextId,
      "name": guestUserData?.name??'',
      "email": guestUserData?.email??''
    };

    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.publicAssessmentV5Read),
        headers: NetworkHelper.publicHeaders(),
        body: body);

    return res;
  }

  /// public assessment question list
  Future<dynamic> getPublicAssessmentQuestions(String assessmentId, String contextId, List<dynamic> questionIds, GuestDataModel? guestUserData) async {
    Map data = {
      'assessmentIdentifier': '$assessmentId',
      'contextId': '$contextId',
      'request': {
        'search': {'identifier': questionIds}
      },
      "name": guestUserData?.name??'',
      "email": guestUserData?.email??''
    };
    var body = json.encode(data);

    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.publicAssessmentQuestionList),
        headers: NetworkHelper.publicHeaders(),
        body: body);

    return res;
  }

  /// public assessment submit
  Future<dynamic> submitPublicAssessment(Map data, {bool isAdvanceAssessment = true}) async {
    var body = json.encode(data);
    String url = isAdvanceAssessment
        ? ApiUrl.baseUrl + ApiUrl.publicAdvanceAssessmentSubmit
        : ApiUrl.baseUrl + ApiUrl.publicBasicAssessmentSubmit;
    Response res = await post(Uri.parse(url),
        headers: NetworkHelper.publicHeaders(), body: body);
    return res;
  }

  /// Public Basic assessment result
  Future<dynamic> getPublicAssessmentCompletionStatus(Map data) async {
    var body = json.encode(data);
    Response res = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getPublicAssessmentCompletionStatus),
        headers: NetworkHelper.publicHeaders(),
        body: body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      var contents = jsonDecode(res.body);
      return contents['result'];
    } else {
      return jsonDecode(res.body)['params']['errmsg'];
    }
  }
}
