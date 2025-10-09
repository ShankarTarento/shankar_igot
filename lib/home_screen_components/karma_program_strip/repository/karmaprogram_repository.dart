import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/common_components/common_service/common_service.dart';
import 'package:karmayogi_mobile/models/_models/playlist_model.dart';
import 'package:http/http.dart';

class KarmaprogramRepository {
  static Future<List<PlayList>> getKarmaProgram({
    required String apiUrl,
    required Map<String, dynamic> request,
  }) async {
    List<PlayList> karmaPrograms = [];
    try {
      Response response = await CommonService.postRequest(
        apiUrl: apiUrl,
        ttl: ApiTtl.compositeSearch,
        request: request,
      );

      if (response.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));

        List<dynamic> body = contents['result']['data'] != null
            ? contents['result']['data']
            : [];

        for (var program in body) {
          karmaPrograms.add(PlayList.fromJson(program));
        }
      } else {
        throw Exception(
            'Failed to load karma programs with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred while fetching karma programs: $e');
      rethrow;
    }

    return karmaPrograms;
  }
}
