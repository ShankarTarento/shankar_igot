import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/services/http_service.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class ContentStripService {
  static final _storage = FlutterSecureStorage();

  static Future<List<Course>> getCourseData({
    bool addDateFilter = false,
    required ContentStripModel stripData,
    int? offset,
  }) async {
    List<Course> courses = [];
    Map<String, dynamic>? requestBody;

    try {
      final String? token = await _storage.read(key: Storage.authToken);
      final String? wid = await _storage.read(key: Storage.wid);
      final String? deptId = await _storage.read(key: Storage.deptId);

      if (token == null || wid == null || deptId == null) {
        debugPrint("Authentication details are missing");
        return courses;
      }

      requestBody = _prepareRequestBody(
          addDateFilter: addDateFilter,
          stripData: stripData,
          offset: offset,
          deptId: deptId);

      final Uri apiUri = Uri.parse('${ApiUrl.baseUrl}${stripData.apiUrl}');
      final Map<String, String> headers =
          NetworkHelper.postHeaders(token, wid, deptId);
      final Response response;
      if (stripData.requestType == "GET") {
        response = await HttpService.get(
          ttl: ApiTtl.recentlyAddedCourse,
          apiUri: apiUri,
          headers: headers,
        );
      } else {
        response = await HttpService.post(
          ttl: ApiTtl.recentlyAddedCourse,
          apiUri: apiUri,
          body: requestBody,
          headers: headers,
        );
      }
      if (response.statusCode == 200) {
        courses = _parseResponse(response, requestBody);
      } else {
        debugPrint("Failed to fetch courses: HTTP ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    }

    return courses;
  }

  /// Prepare the request body with necessary modifications.
  static Map<String, dynamic> _prepareRequestBody(
      {required bool addDateFilter,
      required ContentStripModel stripData,
      required int? offset,
      required String deptId}) {
    final Map<String, dynamic> requestBody = stripData.request ?? {};

    if (offset != null) {
      requestBody['request'] ??= {};
      requestBody['request']['offset'] = offset;
    }
    if (stripData.filterWithDate) {
      if (requestBody['request']['filters']['batches.enrollmentEndDate'] !=
          null) {
        try {
          requestBody['request']['filters']['batches.enrollmentEndDate'] =
              addDateFilter
                  ? {
                      ">=": DateTimeHelper.getDateTimeInFormat(
                          DateTime.now().toString(),
                          desiredDateFormat: IntentType.dateFormat4)
                    }
                  : {};
        } catch (e) {
          print(e);
        }
      }
    }

    if (requestBody['request']?['filters']?['organisation'] == 'rootOrgId') {
      requestBody['request']['filters']['organisation'] = deptId;
    }

    return requestBody;
  }

  /// Parse the API response and extract courses.
  static List<Course> _parseResponse(
      Response response, Map<String, dynamic> requestBody) {
    List<Course> courses = [];

    try {
      final Map<String, dynamic> contents =
          jsonDecode(utf8.decode(response.bodyBytes));
      List<dynamic> body = [];

      if (contents['result']?['content'] != null) {
        body = contents['result']['content'];
      } else if (contents['response'] != null &&
          requestBody['request']?['filters']?['contextType'] != null &&
          requestBody['request']?['filters']?['contextType'].isNotEmpty) {
        final contextType = requestBody['request']['filters']['contextType'][0];
        body = contents['response'][contextType] ?? [];
      } else {
        debugPrint("Unexpected response structure: $contents");
      }

      for (var data in body) {
        try {
          courses.add(Course.fromJson(data));
        } catch (e) {
          debugPrint("Error parsing course data: $e");
        }
      }
    } catch (e) {
      debugPrint("Error parsing response: $e");
    }

    return courses;
  }

  static Future<List<Course>> getEnrollmentListCourses({
    required ContentStripModel stripData,
  }) async {
    final String? token = await _storage.read(key: Storage.authToken);
    final String? wid = await _storage.read(key: Storage.wid);
    final String? deptId = await _storage.read(key: Storage.deptId);

    if (token == null || wid == null || deptId == null) {
      debugPrint("Authentication details are missing");
      return [];
    }

    try {
      final Uri apiUri = Uri.parse('${ApiUrl.baseUrl}${stripData.apiUrl}$wid');
      final Map<String, String> headers =
          NetworkHelper.postHeaders(token, wid, deptId);

      final Map<String, dynamic>? requestBody = _prepareRequestBody(
        addDateFilter: false,
        stripData: stripData,
        offset: 20,
        deptId: deptId,
      );

      final Response response = await HttpService.post(
        apiUri: apiUri,
        body: requestBody,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> body = decoded['result']['courses'] ?? [];

        List<Course> courses =
            body.map((data) => Course.fromJson(data)).toList();

        courses.sort((a, b) {
          return getLastAccessTime(b).compareTo(getLastAccessTime(a));
        });

        return courses;
      } else {
        debugPrint('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching enrollment list: $e');
      debugPrint('StackTrace: $stackTrace');
    }

    return [];
  }

  static int getLastAccessTime(Course course) {
    return course.raw['lastContentAccessTime'] ?? 0;
  }
}
