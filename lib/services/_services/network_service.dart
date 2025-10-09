import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import './../../constants/index.dart';
import './../../services/index.dart';

class NetworkService extends BaseService {
  NetworkService(HttpClient client) : super(client);

  // /// Return list of people as you may know as response
  static Future<dynamic> getPeopleYouMayKnow() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.peopleYouMayKnow),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );
    Map peopleYouMayKnowResponse = json.decode(response.body);
    return peopleYouMayKnowResponse;
  }

  // /// Return list of people as you may know as response
  static Future<dynamic> getConnectionRequests() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.connectionRequest),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );
    if (response.statusCode == 200) {
      Map connectionRequestResponse = json.decode(response.body);

      return connectionRequestResponse;
    } else {
      return null;
    }
  }

  // /// Return list of people as you may know as response
  static Future<dynamic> postConnectionRequest(
      String connectionId, profileDetailsFrom, profileDetailsTo) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'connectionId': connectionId,
      'userIdFrom': wid,
      'userNameFrom': profileDetailsFrom.first.firstName,
      'userDepartmentFrom': profileDetailsFrom.first.department,
      'userIdTo': connectionId,
      'userNameTo': profileDetailsTo.first.firstName,
      'userDepartmentTo': profileDetailsTo.first.department
    };

    String body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.postConnectionReq),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map postCRResponse = json.decode(response.body);

    return postCRResponse;
  }

  // /// request to connect
  static Future<dynamic> createConnectionRequest(
      String connectionId,
      String userNameFrom,
      String userDepartmentFrom,
      String userNameTo,
      String userDepartmentTo) async {
    final _storage = FlutterSecureStorage();
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

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.postConnectionReq),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map postCRResponse = json.decode(response.body);

    return postCRResponse;
  }

  // /// Post connection accept / reject status
  static Future<dynamic> postAcceptReject(
      String status, String connectionId, String connectionDepartment) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? deptName = await _storage.read(key: Storage.deptName);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      'userIdFrom': '$wid',
      'userNameFrom': '$wid',
      'userDepartmentFrom': '$deptName',
      'userIdTo': '$connectionId',
      'userNameTo': '$connectionId',
      'userDepartmentTo': '$connectionDepartment',
      'status': '$status',

      // 'connectionId': '$connectionId',
      // 'status': '$status',
    };

    String body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.connectionRejectAccept),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map postAcceptRejectResponse = json.decode(response.body);

    return postAcceptRejectResponse;
  }

  // /// Return list of people as you may know as response
  static Future<dynamic> getUsersListByIds(List userIds) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map data = {
      "request": {
        "filters": {"userId": userIds}
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

  // /// Return list of connections requested by the user
  static Future<dynamic> getRequestedConnections() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.get(
      Uri.parse(ApiUrl.baseUrl + ApiUrl.getRequestedConnections),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );

    return json.decode(response.body);
  }
}
