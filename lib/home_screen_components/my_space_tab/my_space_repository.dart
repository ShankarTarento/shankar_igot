import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/common_components/common_service/common_service.dart';
import 'package:karmayogi_mobile/models/_models/cbplan_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';

class MySpaceRepository {
  static final _storage = FlutterSecureStorage();

  static Future<CbPlanModel?> getCbplan({required String apiUrl}) async {
    try {
      Response response =
          await CommonService.getRequest(apiUrl: apiUrl, ttl: ApiTtl.getCbplan);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Map<String, dynamic> cbpInfo = data['result'];

        if (cbpInfo['content'] != null &&
            (cbpInfo['content'] as List).isNotEmpty) {
          return CbPlanModel.fromJson(cbpInfo);
        } else {
          return null;
        }
      } else {
        debugPrint('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching CB Plan: $e');
      return null;
    }
  }

  static Future<List<Course>> addCBPEnddateToCourse(
      {required List<Course> courses,
      required CbPlanModel? cbpPlanData}) async {
    // CbPlanModel? cbpPlanData = await getCbplan(apiUrl: cbpApiUrl);
    if (courses.isNotEmpty) {
      if (cbpPlanData != null) {
        courses.forEach((course) {
          String courseId = course.id;

          cbpPlanData.content!.forEach((cbpCourse) {
            cbpCourse.contentList!.forEach((element) {
              if (element.id == courseId) {
                course.endDate = cbpCourse.endDate;
              }
            });
          });
        });
      }
    }
    return courses;
  }

  static Future<List<Course>> getEnrollmentData({
    required Map enrollmentApi,
    required BuildContext context,
    required CbPlanModel cbpPlanData,
  }) async {
    String? wid = await _storage.read(key: Storage.wid);
    if (wid == null) {
      return [];
    }

    try {
      // Collect course IDs from the cbpPlanData
      List<String> cbpCourseId = cbpPlanData.content!
          .expand((cbpCourse) => cbpCourse.contentList!)
          .map((element) => element.id)
          .toList();

      Map<String, dynamic> request = enrollmentApi['request'];
      request['request']['courseId'] = cbpCourseId;

      // Call the enrollment API
      Response response = await CommonService.postRequest(
        apiUrl: enrollmentApi['url'].replaceAll('userid', wid),
        request: request,
      );

      if (response.statusCode == 200) {
        var contents = json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> body = contents['result']['courses'];

        // Convert the response data into Course objects
        List<Course> enrolledCourseList =
            body.map((e) => Course.fromJson(e)).toList();

        // Add CBP end date information to the courses
        return await addCBPEnddateToCourse(
            cbpPlanData: cbpPlanData, courses: enrolledCourseList);
      }
    } catch (e) {
      debugPrint("Error occurred while fetching enrollment data: $e");
    }

    return [];
  }
}
