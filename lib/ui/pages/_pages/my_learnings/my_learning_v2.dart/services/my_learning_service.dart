import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/common_components/common_service/common_service.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/models/event_enrollment_list_model.dart';

class MyLearningService {
  static final _storage = FlutterSecureStorage();

  static Future<List<Course>> getEnrolledCourses({required String type}) async {
    String? wid = await _storage.read(key: Storage.wid);
    if (wid == null) {
      print('No user id found');
      return [];
    }

    List<Course> courses = [];
    List<Course> retiredCourses = [];
    try {
      Response response = await CommonService.postRequest(
        request: {
          "request": {
            "retiredCoursesEnabled":
                type == WidgetConstants.myLearningCompleted,
            "status": type,
          }
        },
        apiUrl: ApiUrl.getEnrollmentListByFilter + wid,
      );

      if (response.statusCode == 200) {
        var contents = json.decode(utf8.decode(response.bodyBytes));
        List<dynamic> body = contents['result']['courses'] ?? [];

        for (var course in body) {
          var courseModel = Course.fromJson(course);
          if (type == WidgetConstants.myLearningCompleted &&
              courseModel.raw['content']['status'] == WidgetConstants.retired) {
            retiredCourses.add(courseModel);
          } else {
            courses.add(courseModel);
          }
        }

        int compareCourses(Course a, Course b) {
          int timeA = getLastAccessTime(a);
          int timeB = getLastAccessTime(b);

          return timeB.compareTo(timeA);
        }

        courses.sort(compareCourses);
        retiredCourses.sort(compareCourses);

        courses.addAll(retiredCourses);
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

  static int getLastAccessTime(Course course) {
    return course.raw['lastContentAccessTime'] ?? 0;
  }

  static Future<List<EventEnrollmentListModel>> getEventEnrollList({
    required String type,
  }) async {
    String? wid = await _storage.read(key: Storage.wid);
    List<EventEnrollmentListModel> eventDetails = [];
    List<EventEnrollmentListModel> retiredEvents = [];

    try {
      Response response = await CommonService.postRequest(request: {
        "request": {
          "retiredCoursesEnabled": type == WidgetConstants.myLearningCompleted,
          "status": type,
        }
      }, apiUrl: ApiUrl.eventList + wid!);

      if (response.statusCode == 200) {
        var contents = json.decode(utf8.decode(response.bodyBytes));

        List<dynamic> body = contents['result']['events'] ?? [];

        for (var event in body) {
          var eventModel = EventEnrollmentListModel.fromJson(event);
          if (eventModel.event.status == WidgetConstants.retired) {
            retiredEvents.add(eventModel);
          } else {
            eventDetails.add(eventModel);
          }
        }

        eventDetails.sort(compareEvents);
        retiredEvents.sort(compareEvents);

        eventDetails.addAll(retiredEvents);
      } else {
        throw Exception(
            'Failed to load events with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching enrollment data: $e');
      return [];
    }

    return eventDetails;
  }

  static int compareEvents(
      EventEnrollmentListModel a, EventEnrollmentListModel b) {
    int timeA = a.lastContentAccessTime ?? 0;
    int timeB = b.lastContentAccessTime ?? 0;

    return timeB.compareTo(timeA);
  }
}
