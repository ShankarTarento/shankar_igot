import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class IgotAiServices {
  static final _storage = FlutterSecureStorage();

  static Future<http.Response> searchIgotPlatform(String query) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? rootOrgId = await _storage.read(key: Storage.deptId);

    String? userId = await _storage.read(key: Storage.wid);
    String chatId = DateTime.now().millisecondsSinceEpoch.toString();

    String aichatbot = ApiUrl.aiChatBot
        .replaceAll('{uid}', userId ?? '')
        .replaceAll('{cid}', "${userId ?? ''}-${chatId}");

    final url = Uri.parse(ApiUrl.baseUrl + aichatbot);
    Map body = {
      "query": query,
    };

    final response = await http.post(
      url,
      headers: NetworkHelper.igotAiChatbotHeaders(
          token: token!, wid: userId!, rootOrgId: rootOrgId!),
      body: jsonEncode(body),
    );

    return response;
  }

  static Future<http.Response?> fetchChatbotResponse(
      {required String query}) async {
    String? userId = await _storage.read(key: Storage.wid);
    try {
      final url = Uri.parse(ApiUrl.baseUrl + ApiUrl.searchInternet + userId!);

      final body = jsonEncode({
        "query": query,
      });

      final response = await http.post(
        url,
        headers: NetworkHelper.getDataFromInternetHeader(),
        body: body,
      );

      return response;
    } catch (e) {
      debugPrint('Request failed: $e');
      return null;
    }
  }

  static Future<http.Response> submitFeedback(
      {required String feedback,
      required String queryId,
      required bool isLiked,
      required String rating}) async {
    String? token = await _storage.read(key: Storage.authToken);
    String? userId = await _storage.read(key: Storage.wid);

    String chatId = DateTime.now().millisecondsSinceEpoch.toString();

    final url = Uri.parse(ApiUrl.baseUrl +
        ApiUrl.submitFeedback
            .replaceAll('{cid}', "${userId ?? ''}-${chatId}")
            .replaceAll('{uid}', userId!));

    Map body = {
      "query_id": queryId,
      "comments": feedback,
      "is_liked": isLiked,
      "rating": rating,
    };

    try {
      final response = await http.post(
        url,
        headers: NetworkHelper.postHeader(token!),
        body: jsonEncode(body),
      );

      return response;
    } catch (e) {
      debugPrint("$e");
      rethrow;
    }
  }
}
