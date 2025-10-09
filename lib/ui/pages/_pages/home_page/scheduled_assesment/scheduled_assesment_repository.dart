import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/core/repositories/enrollment_repository.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';

class ScheduledAssesmentRepository {
  Future<List<Course>> getComprehensiveAssesments() async {
    List<Course> comprehensiveScheduledAssesments = [];
    try {
      final response = await LearnService().compositeSearch(contentType: [
        PrimaryCategory.course,
      ], courseCategories: [
        PrimaryCategory.comprehensiveAssessmentProgram
      ]);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        List content = data['result']['content'] ?? [];
        if (content.isNotEmpty) {
          comprehensiveScheduledAssesments =
              content.map((e) => Course.fromJson(e)).toList();
        }

        return comprehensiveScheduledAssesments;
      } else {
        debugPrint(
            "Error fetching comprehensive scheduled assessments: ${response.statusCode} ");
        return [];
      }
    } catch (error, stackTrace) {
      debugPrint("Error in getComprehensiveScheduledAssesments: $error");
      debugPrint("StackTrace: $stackTrace");
      return [];
    }
  }

  Future<List<Course>> getInProgressAssessments() async {
    final List<Course> resultCourses = [];

    try {
      final enrolledCourses = await EnrollmentRepository.getEnrolledCourses(
        type: WidgetConstants.inProgress,
      );

      for (final course in enrolledCourses) {
        final isInviteOnly =
            course.courseCategory == PrimaryCategory.inviteOnlyAssessment;
        final isComprehensive = course.courseCategory ==
            PrimaryCategory.comprehensiveAssessmentProgram;

        if (isComprehensive) {
          resultCourses.add(course);
        }

        if (isInviteOnly) {
          final batchId = course.batchId ?? '';
          final batchList = course.raw['content']?['batches'] as List<dynamic>?;

          if (batchList != null) {
            AssesmentBatch? matchingBatch;

            for (var e in batchList) {
              final batch = AssesmentBatch.fromJson(e);
              if (batch.batchId == batchId) {
                matchingBatch = batch;
                break;
              }

              if (matchingBatch != null) {
                course.assesmentBatch = matchingBatch;
                resultCourses.add(course);
              }
            }
          }
        }
      }

      return resultCourses;
    } catch (error, stackTrace) {
      debugPrint("Error in getInProgressInviteonlyAssessments: $error");
      debugPrint("StackTrace: $stackTrace");
      return [];
    }
  }

  Future<List<Course>> getCompletedComprehensiveAssessment() async {
    final List<Course> resultCourses = [];

    try {
      final enrolledCourses = await EnrollmentRepository.getEnrolledCourses(
        type: WidgetConstants.myLearningCompleted,
      );

      for (final course in enrolledCourses) {
        final isComprehensive = course.courseCategory ==
            PrimaryCategory.comprehensiveAssessmentProgram;

        if (isComprehensive) {
          resultCourses.add(course);
        }
      }

      return resultCourses;
    } catch (error, stackTrace) {
      debugPrint("Error in getInProgressInviteonlyAssessments: $error");
      debugPrint("StackTrace: $stackTrace");
      return [];
    }
  }

  Future<List<Course>> getCombainedAssessmentData() async {
    try {
      List<Course> inprogressInviteOnlyAssessments =
          await getInProgressAssessments();
      List<Course> comprehensiveAssessments =
          await getComprehensiveAssesments();
      List<Course> completedComprehensiveAssessments =
          await getCompletedComprehensiveAssessment();

      // Combine all courses
      List<Course> allCourses = [
        ...comprehensiveAssessments,
        ...inprogressInviteOnlyAssessments,
      ];

      // Remove duplicates based on ID
      final Map<String, Course> uniqueCourses = {};
      for (var course in allCourses) {
        uniqueCourses[course.id] = course;
      }

      // Create a Set of completed course IDs
      final Set<String> completedIds =
          completedComprehensiveAssessments.map((course) => course.id).toSet();

      final List<Course> finalList = [];

      for (var course in uniqueCourses.values) {
        final startDateStr = _getStartDate(course);
        final endDateStr = _getEndDate(course);

        if (startDateStr != null && endDateStr != null) {
          DateTime endDate = DateTime.parse(endDateStr);
          endDate = endDate.add(Duration(days: 1));
          if (endDate.isAfter(DateTime.now()) &&
              !completedIds.contains(course.id)) {
            finalList.add(course);
          }
        }
      }

      // Sort by start date ascending
      finalList.sort((a, b) {
        final aStart =
            DateTime.tryParse(_getStartDate(a) ?? '') ?? DateTime(1900);
        final bStart =
            DateTime.tryParse(_getStartDate(b) ?? '') ?? DateTime(1900);
        return aStart.compareTo(bStart);
      });

      return finalList;
    } catch (error, stackTrace) {
      debugPrint('Error in getCombainedAssessmentData: $error');
      debugPrint('StackTrace: $stackTrace');
      return [];
    }
  }

  String? _getStartDate(Course course) {
    return course.assesmentBatch?.startDate ??
        course.startDate ??
        course.raw['content']['startDate'];
  }

  String? _getEndDate(Course course) {
    return course.assesmentBatch?.endDate ??
        course.endDate ??
        course.raw['content']['endDate'];
  }
}
