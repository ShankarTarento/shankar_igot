import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/localization/index.dart';

import '../../services/index.dart';

class IgotAIRepository extends ChangeNotifier {
  final IgotAIService igotAIService = IgotAIService();

  Future<String> generateRecommendation() async {
    var _data;
    try {
      final response = await igotAIService.generateRecommendation();
      _data = response;
    } catch (_) {
      return '';
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);

      return contents['id'];
    } else {
      return '';
    }
  }

  Future<Map<String, dynamic>> getAIRecommentationWithFeedbackDoId(
      {required String id}) async {
    var _data;
    try {
      final response =
          await igotAIService.getAIRecommentationWithFeedbackDoId(id: id);
      _data = response;
    } catch (_) {
      return {
        'doIdList': [],
        'relevantDoIdList': [],
        'nonRelevantDoIdList': []
      };
    }
    if (_data!.statusCode == 200) {
      var contents = jsonDecode(_data!.body);
      if (contents['recommended_courses'] != null &&
          contents['recommended_courses'].isNotEmpty) {
        List<String> doIdList = filterDoIds(contents['recommended_courses']);
        List<String> relevantDoIdList =
            filterReleventDoIds(contents['feedbacks'], 1);
        List<String> nonRelevantDoIdList =
            filterReleventDoIds(contents['feedbacks'], 0);
        return {
          'doIdList': doIdList,
          'relevantDoIdList': relevantDoIdList,
          'nonRelevantDoIdList': nonRelevantDoIdList
        };
      }
      return {
        'doIdList': [],
        'relevantDoIdList': [],
        'nonRelevantDoIdList': []
      };
    } else {
      return {
        'doIdList': [],
        'relevantDoIdList': [],
        'nonRelevantDoIdList': []
      };
    }
  }

  Future<String> saveFeedback(
      {required String courseId,
      required String recommendationId,
      required int rating,
      String? feedback}) async {
    var _data;
    try {
      final response = await igotAIService.saveFeedback(
          courseId: courseId,
          recommendationId: recommendationId,
          feedback: feedback,
          rating: rating);
      _data = response;
    } catch (e) {
      if (e == EnglishLang.feedbackSubmitMessage) {
        return EnglishLang.success;
      } else {
        return EnglishLang.failed;
      }
    }
    if ((_data!.statusCode == 200 || _data!.statusCode == 201) &&
        jsonDecode(_data.body)['message'] ==
            EnglishLang.feedbackSubmitMessage) {
      return EnglishLang.success;
    } else {
      return EnglishLang.failed;
    }
  }

  List<String> filterDoIds(List<dynamic> list) {
    List<String> doIdList = [];
    list.forEach((data) => doIdList.add(data['course_id']));
    return doIdList;
  }

  List<String> filterReleventDoIds(List<dynamic> list, int rating) {
    List<String> doIdList = [];
    list.forEach((data) {
      if (data['rating'] == rating) {
        doIdList.add(data['course_id']);
      }
    });
    return doIdList;
  }
}
