import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import 'package:http/http.dart';

class NetworkHubServices {
  static final _storage = FlutterSecureStorage();

  static Future<Response> getConnectionRequests() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.connectionRequest),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );
    return response;
  }

  static Future<Response> getRecommendedUsers(
      {required int offset, required int size}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'size': size,
      'offset': offset,
    };

    String body = json.encode(data);

    final response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getRecommendedUsers),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    return response;
  }

  static Future<Response> getMyConnections(
      {required int offset, required int size}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String apiUrl = ApiUrl.baseUrl +
        ApiUrl.getMyConnections +
        "?pageNo=$offset&pageSize=$size";
    final response = await get(
      Uri.parse(apiUrl),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );

    return response;
  }

  static Future<dynamic> getRequestedConnections(
      {required int offset, required int size}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    String apiUrl = ApiUrl.baseUrl +
        ApiUrl.getRequestedConnections +
        "?pageNo=$offset&pageSize=$size";

    final response = await get(
      Uri.parse(apiUrl),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );

    return response;
  }

  static Future<Response> getRecommendedMentors(
      {required int offset, required int size}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "size": size,
      "offset": offset,
    };

    final response = await post(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.getRecommendedMentors),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
      body: json.encode(data),
    );

    return response;
  }

  static Future<Response> updateConnection({
    required String status,
    required String connectionIdTo,
    required String connectionDepartmentTo,
    required String userNameFrom,
    required String deptNameFrom,
    required String userNameTo,
  }) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'userIdFrom': '$wid',
      'userNameFrom': '$userNameFrom',
      'userDepartmentFrom': '$deptNameFrom',
      'userIdTo': '$connectionIdTo',
      'userNameTo': '$userNameTo',
      'userDepartmentTo': '$connectionDepartmentTo',
      'status': '$status',
    };

    String body = json.encode(data);

    final response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.connectionRejectAccept),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);

    return response;
  }

  static Future<Response> createConnectionRequest(
      {required String connectionId,
      required String userNameFrom,
      required String userDepartmentFrom,
      required String userNameTo,
      required String userDepartmentTo}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'connectionId': connectionId,
      'userIdFrom': wid,
      'userNameFrom': userNameFrom,
      'userDepartmentFrom': userDepartmentFrom,
      'userIdTo': connectionId,
      'userNameTo': userNameTo,
      'userDepartmentTo': userDepartmentTo
    };

    String body = json.encode(data);

    final response = await post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.postConnectionReq),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);

    return response;
  }

  static Future<Response> getBlockedUsers(
      {required int offset, required int size}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "size": size,
      "offset": offset,
    };

    final response = await post(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.getBlockedUser),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
      body: json.encode(data),
    );

    return response;
  }

  static Future<Response> getConnectionsCount() async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "filter": {
          "status": ["Approved", "Requested", "Pending", "Blocked"]
        },
        "facets": ["status"]
      }
    };

    final response = await post(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.getConnectionsCount),
      body: json.encode(data),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );

    return response;
  }

  static Future<Response> blockUser(
      {required String connectionId,
      required String userNameFrom,
      required String userDepartmentFrom,
      required String userNameTo,
      required String userDepartmentTo}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'connectionId': connectionId,
      'userIdFrom': wid,
      'userNameFrom': userNameFrom,
      'userDepartmentFrom': userDepartmentFrom,
      'userIdTo': connectionId,
      'userNameTo': userNameTo,
      'userDepartmentTo': userDepartmentTo
    };

    String body = json.encode(data);

    return post(Uri.parse(ApiUrl.baseUrl + ApiUrl.blockUser),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
  }
}
