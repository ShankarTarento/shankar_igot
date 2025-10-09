import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/services/http_service.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class CustomProfileFieldServices {
  static final _storage = FlutterSecureStorage();

  ///
  ///
  ////
  ///
  ///
  //static String dummyRootOrgId = "0140788510336040962";

  ///
  ///
  ///
  ///
  ///

  static Future<Response> getOrgFrameworkId() async {
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'request': {'organisationId': rootOrgId}
    };

    String url = ApiUrl.baseUrl + ApiUrl.getOrgRead;
    Response response = await HttpService.post(
        ttl: ApiTtl.orgDetails,
        apiUri: Uri.parse(url),
        headers: NetworkHelper.registerPostHeaders(),
        body: data);
    return response;
  }

  static Future<Response> getProfileCustomFields(
      {required List<String> customFieldIds}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "filterCriteriaMap": {
        "organisationId": rootOrgId,
        "isEnabled": true,
        "customFieldId": customFieldIds
      },
      "requestedFields": [],
      "pageNumber": 0,
      "pageSize": 10,
      "facets": []
    };

    String url = ApiUrl.baseUrl + ApiUrl.getCustomProfileField;
    Response response = await HttpService.post(
      apiUri: Uri.parse(url),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
      body: data,
      ttl: ApiTtl.orgDetails,
    );

    return response;
  }

  static Future<Response> getCustomProfileData() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    if (wid == null || wid.isEmpty || rootOrgId == null || rootOrgId.isEmpty) {
      throw Exception("User ID or Root Org ID is not available");
    }

    String url = ApiUrl.baseUrl +
        ApiUrl.getCustomProfileFieldData +
        "/" +
        wid +
        "/" +
        rootOrgId;
    Response response = await get(
      Uri.parse(url),
      headers: NetworkHelper.getHeaders(token!, wid, rootOrgId),
    );

    return response;
  }

  static Future<Response> updateCustomProfileData(
      List<Map<String, dynamic>> customProfileData) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    if (wid == null || wid.isEmpty || rootOrgId == null || rootOrgId.isEmpty) {
      throw Exception("User ID or Root Org ID is not available");
    }

    String url = ApiUrl.baseUrl + ApiUrl.updateCustomProfileFieldData;
    Map<String, dynamic> data = {
      "userId": wid,
      "organisationId": rootOrgId,
      "customFieldValues": customProfileData,
    };

    Response response = await post(
      Uri.parse(url),
      headers: NetworkHelper.getHeaders(token!, wid, rootOrgId),
      body: json.encode(data),
    );

    return response;
  }
}
