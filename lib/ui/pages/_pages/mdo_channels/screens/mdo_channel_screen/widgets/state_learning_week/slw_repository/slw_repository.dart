import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:igot_ui_components/models/microsite_insight_data_model.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/models/_models/mdo_leaderboard.dart';
import 'package:karmayogi_mobile/services/_services/national_learning_week_service.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/model/mdo_learner_data_model.dart';

class SlwRepository {
  static String convertDateFormat(String dateString) {
    DateFormat inputFormat = DateFormat(IntentType.dateFormat);
    DateFormat outputFormat = DateFormat(IntentType.dateFormat4);

    DateTime dateTime = inputFormat.parse(dateString);

    return outputFormat.format(dateTime);
  }

  static bool checkStateLearningWeekStarted(Map<String, dynamic> config) {
    DateFormat format = DateFormat(IntentType.dateFormat4);

    DateTime now = DateTime.now().toLocal();
    now = DateTime(now.year, now.month, now.day);

    if (config['enabled'] != true ||
        config['startDate'] == null ||
        config['endDate'] == null) {
      return false;
    }

    try {
      DateTime startDate = format.parse(convertDateFormat(config['startDate']));
      DateTime endDate = format.parse(convertDateFormat(config['endDate']));

      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      endDate = DateTime(endDate.year, endDate.month, endDate.day);

      return now.isAfter(startDate.subtract(Duration(days: 1))) &&
          now.isBefore(endDate.add(Duration(days: 1)));
    } catch (e) {
      debugPrint('Error parsing dates: $e');
      return false;
    }
  }

  Future<List<MicroSiteInsightsData>> getSlwWeekInsights(
      {required String mdoOrgId}) async {
    List<MicroSiteInsightsData> insightsData = [];

    try {
      Response response = await LearnService.postRequest(
          apiUrl: ApiUrl.slwWeekInsights,
          request: {
            "request": {"mdoId": mdoOrgId}
          });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['result']?['data'] != null) {
          List content = data['result']['data'];
          insightsData =
              content.map((e) => MicroSiteInsightsData.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
    }

    return insightsData;
  }

  Future<List<MDOLeaderboardData>> getMdoLeaderBoardData(
      {required String mdoId}) async {
    List<MDOLeaderboardData> leaderboardData = [];

    try {
      Response response = await LearnService.postRequest(
        apiUrl: ApiUrl.slwMdoLeaderboard,
        request: {
          "request": {"mdoId": mdoId}
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data != null &&
            data['result'] != null &&
            data['result']['mdoLeaderBoard'] != null) {
          List content = data['result']['mdoLeaderBoard'];

          for (var e in content) {
            leaderboardData.add(MDOLeaderboardData.fromJson(e));
          }
        } else {
          debugPrint('Error: Missing expected data in the response.');
        }
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
    }

    return leaderboardData;
  }

  Future<List<MdoLearnerData>> getSlwTopLearner({required String mdoId}) async {
    List<MdoLearnerData> learnerData = [];

    try {
      Response response = await LearnService.getRequest(
        apiUrl: ApiUrl.slwTopLearners + "$mdoId",
      );

      if (response.statusCode == 200) {
        var content = jsonDecode(utf8.decode(response.bodyBytes));

        if (content != null &&
            content['result'] != null &&
            content['result']['result'] != null) {
          List data = content['result']['result'];

          learnerData = data.map((e) => MdoLearnerData.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
    }

    return learnerData;
  }

  Future<List<Course>> getLearningContent(
      {required String type, required String mdoId}) async {
    List<Course> courses = [];

    try {
      Response response = await LearnService.getRequest(
          apiUrl: ApiUrl.getMdoCoursesData + mdoId + type + '/$mdoId');

      if (response.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));

        if (contents != null &&
            contents['result'] != null &&
            contents['result']['content'] != null) {
          List data = contents['result']['content'];

          courses = data.map((e) => Course.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
    }

    return courses;
  }

  Future<List<Event>> getAllEvents({
    String? startDate,
    Map<String, dynamic>? request,
  }) async {
    List<Event> eventsList = [];

    try {
      Response? response = await NationalLearningWeekService().getAllEvents(
        startDate: startDate,
        request: request,
      );

      if (response != null && response.statusCode == 200) {
        var contents = jsonDecode(utf8.decode(response.bodyBytes));

        List<dynamic> events = contents['result']['Event'] ?? [];

        for (var event in events) {
          eventsList.add(Event.fromJson(event));
        }
      }
      eventsList.sort((a, b) {
        try {
          String startA = '${a.startDate} ${formateTime(a.startTime)}';
          String startB = '${b.startDate} ${formateTime(b.startTime)}';

          DateTime dateA = DateTime.parse(startA);
          DateTime dateB = DateTime.parse(startB);

          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });
    } catch (e) {
      debugPrint('An error occurred while fetching events: $e');
    }

    return eventsList;
  }

  String formateTime(String time) {
    return time.length >= 5 ? time.substring(0, 5) : '00:00';
  }
}
