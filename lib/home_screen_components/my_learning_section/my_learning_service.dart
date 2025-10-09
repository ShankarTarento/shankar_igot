import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/common_components/common_service/common_service.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/models/event_enrollment_list_model.dart';

class HomeMyLearningService {
  static final _storage = FlutterSecureStorage();

  static Future<List<Course>> getEnrollmentData(
      {required Map enrollmentApi, required String type}) async {
    String? wid = await _storage.read(key: Storage.wid);
    List<Course> courses = [];

    try {
      enrollmentApi['request']['request']['status'] = type;

      Response response = await CommonService.postRequest(
          request: enrollmentApi['request'],
          apiUrl: enrollmentApi['url'].replaceAll('userId', wid!));

      if (response.statusCode == 200) {
        var contents = json.decode(utf8.decode(response.bodyBytes));

        List<dynamic> body = contents['result']['courses'] ?? [];

        for (var course in body) {
          courses.add(Course.fromJson(course));
        }
        courses.sort((a, b) {
          int aTimestamp = a.raw['lastContentAccessTime'] ?? 0;
          int bTimestamp = b.raw['lastContentAccessTime'] ?? 0;
          return bTimestamp.compareTo(aTimestamp);
        });
      } else {
        throw Exception(
            'Failed to load courses with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred while fetching enrollment data: $e');
      return [];
    }

    return courses;
  }

  static Future<List<EventEnrollmentListModel>> getEventEnrollList({
    required Map<String, dynamic> eventsEnrollmentApi,
    required String type,
  }) async {
    String? wid = await _storage.read(key: Storage.wid);
    List<EventEnrollmentListModel> eventDetails = [];

    try {
      eventsEnrollmentApi['request']['request']['status'] = type;

      Response response = await CommonService.postRequest(
          request: eventsEnrollmentApi['request'],
          apiUrl: eventsEnrollmentApi['url'].replaceAll('userId', wid!));

      if (response.statusCode == 200) {
        var contents = json.decode(utf8.decode(response.bodyBytes));

        List<dynamic> body = contents['result']['events'] ?? [];

        for (var event in body) {
          eventDetails.add(EventEnrollmentListModel.fromJson(event));
        }
      } else {
        throw Exception(
            'Failed to load events with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred while fetching enrollment data: $e');
      return [];
    }

    eventDetails
        .removeWhere((event) => event.event.status == WidgetConstants.retired);

    eventDetails.sort((a, b) {
      int aTimestamp = a.lastContentAccessTime ?? 0;
      int bTimestamp = b.lastContentAccessTime ?? 0;
      return bTimestamp.compareTo(aTimestamp);
    });

    return eventDetails;
  }
}
