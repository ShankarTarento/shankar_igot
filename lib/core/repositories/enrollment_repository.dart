import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/common_components/common_service/common_service.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';

class EnrollmentRepository {
  static final _storage = FlutterSecureStorage();

  static Future<List<Course>> getEnrolledCoursesByIds(
      {required List courseIds}) async {
    List<Course> courses = [];
    String? wid = await _storage.read(key: Storage.wid);
    if (wid == null) {
      return [];
    }

    try {
      Response response = await CommonService.postRequest(
        apiUrl: ApiUrl.getCourseEnrollDetailsByIds + wid,
        request: {
          "request": {
            "courseId": courseIds,
          }
        },
      );

      if (response.statusCode == 200) {
        var contents = json.decode(utf8.decode(response.bodyBytes));

        if (contents.containsKey('result') &&
            contents['result'].containsKey('courses')) {
          List<dynamic> body = contents['result']['courses'];

          courses = body.map((e) => Course.fromJson(e)).toList();
        }
      } else {
        debugPrint(
            'Error: Failed to load courses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: An error occurred while fetching courses. $e');
    }
    return courses;
  }

  static Future<List<Course>> getEnrolledCourses(
      {String? type, int? limit}) async {
    List<Course> courses = [];
    String? wid = await _storage.read(key: Storage.wid);
    if (wid == null) {
      return [];
    }

    try {
      Response response = await CommonService.postRequest(
        apiUrl: ApiUrl.getEnrollmentListByFilter + wid,
        request: {
          "request": {
            "retiredCoursesEnabled": true,
            "status": type ?? "All",
            "limit": limit
          }
        },
      );

      if (response.statusCode == 200) {
        var contents = json.decode(utf8.decode(response.bodyBytes));

        if (contents.containsKey('result') &&
            contents['result'].containsKey('courses')) {
          List<dynamic> body = contents['result']['courses'];

          courses = body.map((e) => Course.fromJson(e)).toList();
        }
      } else {
        debugPrint(
            'Error: Failed to load courses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: An error occurred while fetching courses. $e');
    }
    return courses;
  }

  static Future<List<Map>> getEnrolledCoursesAsMap(
      {String? type, int? limit}) async {
    try {
      Response response = await LearnService().getMyLearningEnrolmentlist();

      if (response.statusCode == 200) {
        var contents = json.decode(utf8.decode(response.bodyBytes));

        if (contents is Map && contents.containsKey('result')) {
          var result = contents['result'];
          if (result is Map && result.containsKey('courses')) {
            return List<Map>.from(result['courses']);
          }
        } else {
          debugPrint(
              'Error: Failed to load courses. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Error: An error occurred while fetching courses. $e');
    }
    return [];
  }
}
