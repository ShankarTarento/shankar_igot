import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import '../igot_app.dart';
import '../respositories/_respositories/login_respository.dart';
import './../constants/index.dart';

class NetworkHelper {
  static bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  static void _doLogout() {
    try {
      Provider.of<LoginRespository>(navigatorKey.currentContext!, listen: false)
          .doLogout(navigatorKey.currentContext!);
    } catch (e) {
      debugPrint("Error during logout: $e");
    }
  }

  static Map<String, String> getHeaders(
      String token, String wid, String rootOrgId,
      {bool pointToProd = false}) {
    if (isTokenExpired(token)) {
      _doLogout();
    }
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization':
          'bearer ${pointToProd ? ApiUrl.prodApiKey : ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'x-authenticated-userid': '$wid',
      'rootorg': 'igot',
      'userid': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> getCourseHeaders(
      String token, String wid, String courseId, String rootOrgId) {
    if (isTokenExpired(token)) {
      _doLogout();
    }
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'x-authenticated-userid': '$wid',
      'resourceId': '$courseId',
      'rootOrg': 'igot',
      // 'userid': '$wid',
      'userUUID': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> discussionGetHeaders(String token, String wid) {
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    return headers;
  }

  static Map<String, String> getHeader() {
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    return headers;
  }

  static Map<String, String> formDataHeader() {
    Map<String, String> headers = {
      // 'Content-Type':
      //     'multipart/form-data; boundary=<calculated when request is sent>',
      // 'Accept': '*/*',
      // 'hostpath': ApiUrl.baseUrl,
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    return headers;
  }

  static Map<String, String> knowledgeResourceGetHeaders(String token) {
    Map<String, String> headers = {
      'Authorization': 'bearer $token',
    };
    return headers;
  }

  static Map<String, String> postHeaders(
      String token, String wid, String rootOrgId,
      {bool pointToProd = false}) {
    Map<String, String> headers = {
      'Authorization':
          'bearer ${pointToProd ? ApiUrl.prodApiKey : ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json',
      'hostpath': ApiUrl.baseUrl,
      'locale': 'en',
      'org': 'dopt',
      'rootOrg': 'igot',
      'wid': '$wid',
      'userId': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> postHeader(String token) {
    if (isTokenExpired(token)) {
      _doLogout();
    }
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json'
    };
    return headers;
  }

  static Map<String, String> notificationPostHeaders(
      String token, String wid, String rootOrgId) {
    if (isTokenExpired(token)) {
      _doLogout();
    }
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'x-authenticated-userid': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> profilePostHeaders(
      String token, String wid, String rootOrgId) {
    if (isTokenExpired(token)) {
      _doLogout();
    }
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json',
      'x-authenticated-userid': '$wid',
      'wid': '$wid',
      'userId': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> discussionPostHeaders(
      String token, String wid, String rootOrgId) {
    if (isTokenExpired(token)) {
      _doLogout();
    }
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> postCourseHeaders(
      String token, String wid, String courseId, String rootOrgId,
      {String? language}) {
    if (isTokenExpired(token)) {
      _doLogout();
    }
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json; charset=utf-8',
      'hostpath': ApiUrl.baseUrl,
      'locale': 'en',
      'org': 'dopt',
      'rootOrg': 'igot',
      'courseId': '$courseId',
      'userUUID': '$wid',
      'x-authenticated-userid': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    if (language != null) {
      headers['language'] = language;
    }
    return headers;
  }

  static Map<String, String> curatedProgramPostHeaders(
      String token, String wid, String rootOrgId) {
    if (isTokenExpired(token)) {
      _doLogout();
    }
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
      'Content-Type': 'application/json; charset=utf-8',
      'hostpath': ApiUrl.baseUrl,
      'userUUID': '$wid',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> knowledgeResourcePostHeaders(
      String token, String rootOrgId) {
    Map<String, String> headers = {
      'Authorization': 'bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'x-authenticated-user-orgid': '$rootOrgId'
    };
    return headers;
  }

  static Map<String, String> registerPostHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    return headers;
  }

  static Map<String, String> plainHeader() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    return headers;
  }

  static Map<String, String> registerRequestFieldHeader() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'rootOrg': 'igot',
      'org': 'dopt'
    };
    return headers;
  }

  static Map<String, String> registerParichayUserPostHeaders(token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$token',
    };
    return headers;
  }

  static Map<String, String> signUpPostHeaders() {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    return headers;
  }

  static Map<String, String> insightHeader(String wid, String token) {
    if (isTokenExpired(token)) {
      _doLogout();
    }
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'Content-Type': 'application/json',
      'hostpath': ApiUrl.baseUrl,
      'locale': 'en',
      'org': 'dopt',
      'rootOrg': 'igot',
      'wid': '$wid',
      'x-authenticated-user-token': '$token',
      'x-authenticated-userid': '$wid',
    };
    return headers;
  }

  static Map<String, String> igotAIPostHeader() {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'bearer ${ApiUrl.apiKey}',
    };
    return headers;
  }

  static Map<String, String> subtitleTranscriptionHeader() {
    Map<String, String> headers = {
      'user-agent': 'Dart/3.5 (dart:io)',
      'accept': 'application/json',
      'accept-encoding': 'gzip',
      'authorization': 'bearer ${ApiUrl.apiKey}',
      'content-type': 'application/json',
    };
    return headers;
  }

  static Map<String, String> getDataFromInternetHeader() {
    return {
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-GB,en-US;q=0.9,en;q=0.8',
      'authorization': 'bearer ${ApiUrl.apiKey}',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Content-Type': 'application/json',
    };
  }

  static Map<String, String> publicHeaders({bool pointToProd = false}) {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization':
          'bearer ${pointToProd ? ApiUrl.prodApiKey : ApiUrl.apiKey}',
      'rootorg': 'igot'
    };
    return headers;
  }

  static Map<String, String> igotAiChatbotHeaders(
      {required String wid, required String token, required String rootOrgId}) {
    Map<String, String> headers = {
      'hostpath': ApiUrl.baseUrl,
      'rootorg': 'igot',
      'userid': '$wid',
      'accept-encoding': 'gzip',
      'locale': 'en',
      'authorization': 'bearer ${ApiUrl.apiKey}',
      'Content-Type': 'application/json; charset=utf-8',
      'wid': '$wid',
      'org': 'dopt',
      'x-authenticated-user-orgid': '$rootOrgId',
    };
    return headers;
  }
}
