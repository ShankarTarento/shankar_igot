import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import '../../../../../../../constants/_constants/api_endpoints.dart';
import '../../../../../../../constants/_constants/storage_constants.dart';
import '../../../../../../../services/_services/base_service.dart';

class CommentService extends BaseService {
  CommentService(HttpClient client) : super(client);

  /// get comments tree
  static Future<dynamic> getCommentsTree(String entityId, String entityType, String workflow) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "entityType": entityType,
      "entityId": entityId,
      "workflow": workflow,
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getCommentsTree),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    return responseData;
  }

  /// get comments
  static Future<dynamic> getComments(String commentTreeId, String entityId, String entityType, String workflow, int pageNumber) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "commentTreeId": commentTreeId,
      "entityType": entityType,
      "entityId": entityId,
      "workflow": workflow,
      "limit": 20,
      "offset": pageNumber - 1,
      "overrideCache" : true
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getComments),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    log("TEST_LOG===API=========================>${ApiUrl.baseUrl + ApiUrl.getComments}");
    log("TEST_LOG===body=========================>${body}");
    log("TEST_LOG===Response=========================>${responseData}");
    return responseData;
  }

  /// get comments
  static Future<dynamic> getReply(List<String> commentList) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    var body = json.encode(commentList);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.getReply),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);

    Map responseData = json.decode(utf8.decode(response.bodyBytes));
    log("TEST_LOG===API=========================>${ApiUrl.baseUrl + ApiUrl.getReply}");
    log("TEST_LOG===Response=========================>${responseData}");
    return responseData;
  }

  static Future<dynamic> addFirstComment(String entityType, String entityId, String workflow,
      String comment, String role, String userName, String userPic, String designation, String profileStatus, List<Map<String, String>> mentionedUsers) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? userId = await _storage.read(key: Storage.userId);

    Map<String, dynamic> data = {
      "commentTreeData": {
        "entityType": "$entityType",
        "entityId": "$entityId",
        "workflow": "$workflow"
      },
      "commentData": {
        "comment": "$comment",
        "file": [],
        "commentSource": {
          "userId": "$userId",
          "userPic": "$userPic",
          "userName": "$userName",
          "userRole": "$role",
          "designation": "$designation",
          "profileStatus": "$profileStatus"
        },
        "mentionedUsers": mentionedUsers
      }
    };
    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.addFirstComment),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var contents = jsonDecode(response.body);
    log("TEST_LOG===API=========================>${ApiUrl.baseUrl + ApiUrl.addFirstComment}");
    log("TEST_LOG===Request=========================>${body}");
    log("TEST_LOG===Response=========================>${contents}");
    return contents;
  }

  static Future<dynamic> addNewComment(String commentTreeId, List<String> hierarchyPath, String comment,
      String role, String userName, String userPic, String designation, String profileStatus, List<String> taggedUsers, List<Map<String, String>> mentionedUsers) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? userId = await _storage.read(key: Storage.userId);

    Map<String, dynamic> data = {
      "commentTreeId": "$commentTreeId",
      "hierarchyPath": hierarchyPath,
      "commentData": {
        "comment": "$comment",
        "file": [],
        "commentSource": {
          "userId": "$userId",
          "userPic": "$userPic",
          "userName": "$userName",
          "userRole": "$role",
          "designation": "$designation",
          "profileStatus": "$profileStatus"
        },
        "taggedUsers": taggedUsers,
        "mentionedUsers": mentionedUsers
      }
    };
    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.addNewComment),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var contents = jsonDecode(response.body);

    log("TEST_LOG===API=========================>${ApiUrl.baseUrl + ApiUrl.addNewComment}");
    log("TEST_LOG===Request=========================>${body}");
    log("TEST_LOG===response=========================>${response}");
    return contents;
  }

  static Future<dynamic> likeComment(String commentId, String flag, String courseId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? userId = await _storage.read(key: Storage.userId);

    Map<String, dynamic> data = {
      "commentId": commentId,
      "userId": userId,
      "courseId": courseId,
      "flag": flag
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.likeComment),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = jsonDecode(response.body);
    return responseBody;
  }

  static Future<dynamic> reportComment(String commentId, List<String> reportReasons, String otherComment) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    Map<String, dynamic> data = {
      "commentId": commentId,
      "reportedDueTo": reportReasons,
      "otherReasons": otherComment,
    };

    var body = json.encode(data);

    final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.reportComment),
        headers: NetworkHelper.postHeaders(token!, wid!, rootOrgId!),
        body: body);
    var responseBody = jsonDecode(response.body);

    return responseBody;
  }

  /// get report options
  static Future<dynamic> getReportReasons() async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.reportReason),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    Map responseData = json.decode(utf8.decode(response.bodyBytes));

    return responseData;
  }

  static Future<dynamic> deleteComment(String commentId, String entityType, String entityId, String workflow, String? parentId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    String _url = (parentId != null)
        ? ApiUrl.baseUrl +
            ApiUrl.deleteComment +
            '$commentId' +
            '?entityType=$entityType' +
            '&entityId=$entityId' +
            '&workflow=$workflow' +
            '&parentId=$parentId'
        : ApiUrl.baseUrl +
            ApiUrl.deleteComment +
            '$commentId' +
            '?entityType=$entityType' +
            '&entityId=$entityId' +
            '&workflow=$workflow';
    final response = await http.delete(
      Uri.parse(_url),
      headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!),
    );
    var responseBody = jsonDecode(response.body);
    return responseBody;
  }

  static Future<dynamic> editComment(String commentTreeId, String commentId, String comment,
      String role, String userName, String userPic, String designation, String profileStatus, List<String> taggedUsers, List<Map<String, String>> mentionedUsers) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);
    String? userId = await _storage.read(key: Storage.userId);

    Map<String, dynamic> data = {
      "commentTreeId": "$commentTreeId",
      "commentId": commentId,
      "commentData": {
        "comment": "$comment",
        "file": [],
        "commentSource": {
          "userId": "$userId",
          "userPic": "$userPic",
          "userName": "$userName",
          "userRole": "$role",
          "designation": "$designation",
          "profileStatus": "$profileStatus"
        },
        "taggedUsers": taggedUsers,
        "mentionedUsers": mentionedUsers,
        "commentResolved": "false"
      }
    };
    var body = json.encode(data);

    final response = await http.put(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.editComment),
        headers: NetworkHelper.discussionPostHeaders(token!, wid!, rootOrgId!),
        body: body);
    var contents = jsonDecode(response.body);
    log("TEST_LOG===API=========================>${ApiUrl.baseUrl + ApiUrl.editComment}");
    log("TEST_LOG===Request=========================>${body}");
    log("TEST_LOG===Response=========================>${contents}");
    return contents;
  }

  /// get liked comment
  static Future<dynamic> getLikedComments(String entityId) async {
    final _storage = FlutterSecureStorage();
    String? token = await _storage.read(key: Storage.authToken);
    String? wid = await _storage.read(key: Storage.wid);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    final response = await http.get(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.likedComments + '?courseId=$entityId'),
        headers: NetworkHelper.getHeaders(token!, wid!, rootOrgId!));

    Map responseData = json.decode(response.body);
    return responseData;
  }
}
