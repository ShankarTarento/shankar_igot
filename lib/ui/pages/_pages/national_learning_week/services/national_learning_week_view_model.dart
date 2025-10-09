import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/models/_models/mdo_leaderboard.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/models/_models/week_metrics_model.dart';
import 'package:karmayogi_mobile/models/_models/week_progress_model.dart';
import 'package:karmayogi_mobile/services/_services/national_learning_week_service.dart';

class NationalLearningWeekViewModel {
  Map<String, Map<String, OrganizationContent>> categorizedContent = {
    'NLW5YExp': {},
    'NLW10YExp': {},
    'NLW15YExp': {},
    'NLW20YExp': {},
  };
  List<String> nlwOrgs = [];

  Future<List<Course>> getLearningContent({required String type}) async {
    List<Course> allCourses = [];
    Response? response =
        await NationalLearningWeekService.getExploreLearningContent(type: type);

    if (response != null && response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List courses = data['result']['content'];

      for (var course in courses) {
        try {
          allCourses.add(Course.fromJson(course));
        } catch (e) {
          print("getLearningContent==== $e");
        }
      }
    }
    return allCourses;
  }

  Future<List<MDOLeaderboardData>> getMdoLeaderBoardData() async {
    List<MDOLeaderboardData> _mdoleaderboardData = [];
    Response? response = await NationalLearningWeekService.getMdoLeaderBoard();

    if (response != null && response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      List? leaderboardData = data['result']['mdoLeaderBoard'];
      if (leaderboardData != null && leaderboardData.isNotEmpty) {
        for (var data in leaderboardData) {
          _mdoleaderboardData.add(MDOLeaderboardData.fromJson(data));
        }
      }
    }
    return _mdoleaderboardData;
  }

  Future<List<Course>> getMandatoryCourses() async {
    List<Course> _mandatoryCourses = [];

    try {
      Response? response =
          await NationalLearningWeekService.getMandatoryCourses();

      if (response != null && response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List courses = data['result']['content'];

        for (var course in courses) {
          try {
            _mandatoryCourses.add(Course.fromJson(course));
          } catch (e) {
            debugPrint("Error parsing course: $e");
          }
        }
      } else {
        debugPrint("Error: Response status code ${response?.statusCode}");
      }
    } catch (e) {
      debugPrint("getMandatoryCourses failed: $e");
    }

    return _mandatoryCourses;
  }

  Future<List<Event>> getAllEvents(
      {String? startDate, Map<String, dynamic>? request}) async {
    List<Event> eventsList = [];
    Response? response = await NationalLearningWeekService()
        .getAllEvents(startDate: startDate, request: request);
    if (response != null && response.statusCode == 200) {
      var contents = jsonDecode(response.body);
      List<dynamic> events = contents['result']['Event'] ?? [];

      for (var event in events) {
        eventsList.add(Event.fromJson(event));
      }
    }

    eventsList.sort((a, b) {
      String startA = '${a.startDate} ${formateTime(a.startTime)}';
      String startB = '${b.startDate} ${formateTime(b.startTime)}';

      DateTime dateA = DateTime.parse(startA);
      DateTime dateB = DateTime.parse(startB);

      return dateA.compareTo(dateB);
    });
    return eventsList;
  }

  String formateTime(time) {
    return time.substring(0, 5);
  }

  Future<List<WeekMetrics>> getWeekMetrics() async {
    List<WeekMetrics> metricsData = [];
    Response? response = await NationalLearningWeekService.getWeekMetrics();

    if (response != null && response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      List? metrics = data['result']['data'];
      if (metrics != null && metrics.isNotEmpty) {
        for (var data in metrics) {
          metricsData.add(WeekMetrics.fromJson(data));
        }
      }
    }
    return metricsData;
  }

  Future<WeekProgressModel?> getUserWeekProgress() async {
    Response? response =
        await NationalLearningWeekService().getUserWeekProgress();

    if (response != null && response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      if (data['result']['userLeaderBoard'] != null &&
          data['result']['userLeaderBoard'].isNotEmpty) {
        return WeekProgressModel.fromJson(data['result']['userLeaderBoard']);
      }
    }

    return null;
  }

  void getNLWLearningContent() async {
    Response? response =
        await NationalLearningWeekService().getLearningContent();
    if (response != null && response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      categorizeContent(data['result']['content']);
      getOrganisations(data['result']['facets']);
    }
  }

  Map<String, Map<String, OrganizationContent>> categorizeContent(
      List<dynamic>? contentList) {
    categorizedContent = {
      'NLW5YExp': {},
      'NLW10YExp': {},
      'NLW15YExp': {},
      'NLW20YExp': {},
    };

    if (contentList != null) {
      for (var item in contentList) {
        if (item is Map<String, dynamic> &&
            item['nlwUserExp'] is List &&
            item['nlwOrgs'] is List &&
            item['courseCategory'] is String) {
          for (var userExp in item['nlwUserExp']) {
            if (userExp is String) {
              for (var organization in item['nlwOrgs']) {
                if (organization is String) {
                  String type = item['courseCategory'];

                  Course content = Course.fromJson(item);

                  if (!categorizedContent[userExp]!.containsKey(organization)) {
                    categorizedContent[userExp]![organization] =
                        OrganizationContent(courses: [], curatedPrograms: []);
                  }

                  if (type.toLowerCase() == 'course') {
                    categorizedContent[userExp]![organization]!
                        .courses
                        .add(content);
                  } else if (type.toLowerCase() ==
                          PrimaryCategory.curatedProgram.toLowerCase() ||
                      type.toLowerCase() ==
                          PrimaryCategory.blendedProgram.toLowerCase() ||
                      type.toLowerCase() ==
                          PrimaryCategory.moderatedProgram.toLowerCase()) {
                    categorizedContent[userExp]![organization]!
                        .curatedPrograms
                        .add(content);
                  }
                }
              }
            }
          }
        }
      }
    }

    return categorizedContent;
  }

  List<String> getOrganisations(List<dynamic>? facets) {
    nlwOrgs = [];

    if (facets != null) {
      for (var facet in facets) {
        if (facet is Map<String, dynamic> && facet['name'] == 'nlwOrgs') {
          var values = facet['values'];
          if (values is List) {
            for (var value in values) {
              if (value is Map<String, dynamic> && value['name'] != null) {
                nlwOrgs.add(value['name']);
              }
            }
          }
        }
      }
    }

    return nlwOrgs;
  }
}

class OrganizationContent {
  final List<Course> courses;
  final List<Course> curatedPrograms;

  OrganizationContent({
    required this.courses,
    required this.curatedPrograms,
  });
}
