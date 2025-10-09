import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/view_model/course_toc_view_model.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../../services/index.dart';
import '../../../../../util/index.dart';

class TocPlayerViewModel {
  String getEnrolledCourseId(BuildContext context, String id) {
    List<Course> enrolledCourses =
        Provider.of<CourseTocViewModel>(context, listen: false).enrollmentList;

    for (final course in enrolledCourses) {
      final languageEntries = course.languageMap.languages.entries;
      if (course.id == id) {
        return id;
      } else {
        for (final entry in languageEntries) {
          if (entry.value.id == id) {
            return course.id;
          }
        }
      }
    }
    return '';
  }

  Future<void> videoUpdateContentProgress(String contentIdentifier,
      {required String language,
      required String courseId,
      required bool isPreRequisite,
      required String batchId,
      required double currentPosition,
      required double maxSize,
      required int status,
      required double completionPercentage,
      required List<String> current}) async {
      await LearnService().updateContentProgress(
          courseId,
          batchId,
          contentIdentifier,
          status,
          EMimeTypes.mp4,
          current,
          maxSize,
          completionPercentage,
          isPreRequisite: isPreRequisite,
          language: language);
  }

  Future<void> audioUpdateContentProgress(
      {required String contentId,
      required String language,
      required double maxSize,
      required String courseId,
      required bool isPreRequisite,
      required int status,
      required double completionPercentage,
      required List<String> current,
      bool isFeatured = false,
      String? batchId}) async {
    if (batchId != null && !isFeatured) {
      await LearnService().updateContentProgress(courseId, batchId, contentId,
          status, EMimeTypes.mp3, current, maxSize, completionPercentage,
          isPreRequisite: isPreRequisite, language: language);
    }
  }

  Future<void> endTelemetryEvent(
      {String? identifier,
      required String pageIdentifier,
      required int duration,
      required String telemetryType,
      required String pageUri,
      required Map<dynamic, dynamic> rollup,
      required String env,
      String? objectType,
      bool isPublic = false,
      String? l1}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getEndTelemetryEvent(
        pageIdentifier: pageIdentifier,
        duration: duration,
        telemetryType: telemetryType,
        pageUri: pageUri,
        rollup: rollup,
        env: env,
        objectId: identifier,
        objectType: objectType,
        isPublic: isPublic,
        l1: l1);
    await telemetryRepository.insertEvent(
        eventData: eventData, isPublic: isPublic);
  }
}
