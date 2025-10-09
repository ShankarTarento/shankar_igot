import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../models/_models/review_model.dart';

class TocServices extends ChangeNotifier {
  Batch? _batch;
  final LearnService learnService = LearnService();
  OverallRating? _overallRating;
  double? _courseProgress = null;
  bool _isWebWiewPersist = true;

  Batch? get batch => _batch;

  double? get courseProgress => _courseProgress;
  OverallRating? get overallRating => _overallRating;
  bool get isWebWiewPersist => _isWebWiewPersist;

  setBatchDetails({required Batch selectedBatch}) async {
    if (_batch == null ||
        (_batch != null && selectedBatch.batchId != _batch!.batchId)) {
      _batch = selectedBatch;
      notifyListeners();
    }
  }

  DateTime? getBatchStartTime() {
    if (batch != null) {
      return DateTime.parse(batch!.startDate);
    } else
      return null;
  }

  String getButtonTitle({
    required List<Course> enrollmentData,
    required String courseId,
  }) {
    Course? course = enrollmentData
        .cast<Course?>()
        .firstWhere((element) => element!.id == courseId, orElse: () => null);

    if (course != null) {
      if (course.completionPercentage == COURSE_COMPLETION_PERCENTAGE) {
        return 'Start again';
      } else if (course.completionPercentage == 0) {
        return 'Start';
      } else if (course.completionPercentage! > 0 &&
          course.completionPercentage! < COURSE_COMPLETION_PERCENTAGE) {
        return 'Resume';
      }
    } else {
      return 'Enroll';
    }
    return 'Enroll';
  }

  void setInitialBatch(
      {List<Batch>? batches, Course? enrolledCourse, String? courseId}) {
    if (enrolledCourse != null) {
      Batch approvedBatch = batches!
          .firstWhere((element) => element.id == enrolledCourse.batch!.batchId);
      _batch = approvedBatch;
      setBatchDetails(selectedBatch: _batch!);
    } else {
      try {
        DateTime now = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        _batch = batches!.fold(null, (closest, current) {
          if (current.enrollmentEndDate.isEmpty) {
            return closest ?? current;
          }
          DateTime enrollmentEndDate =
              DateTime.parse(current.enrollmentEndDate);
          if (((enrollmentEndDate.isAfter(now)) ||
                  enrollmentEndDate.isAtSameMomentAs(now)) &&
              (closest == null ||
                  enrollmentEndDate
                      .isBefore(DateTime.parse(closest.enrollmentEndDate)))) {
            return current;
          }
          return closest;
        });
        if (_batch != null) {
          setBatchDetails(selectedBatch: _batch!);
        }
      } catch (e) {
        if (_batch != null) {
          _batch = null;
          notifyListeners();
        }
      }
    }
  }

  void setCourseProgress(double progress) {
    if (_courseProgress == null || _courseProgress! < progress) {
      _courseProgress = progress;
      notifyListeners();
    }
  }

  void getCourseRating({required Course courseDetails}) async {
    var rating = null;
    final response = await learnService.getCourseReviewSummery(
        id: courseDetails.id, primaryCategory: courseDetails.courseCategory);

    if (response != null) {
      _overallRating = OverallRating.fromJson(response);
      notifyListeners();
    } else {
      if (_overallRating != rating) {
        notifyListeners();
      }
    }
  }

  void clearCourseProgress() {
    if (_courseProgress != null) {
      _courseProgress = null;
      notifyListeners();
    }
  }

  void destroyWebView() {
    if (_isWebWiewPersist) {
      _isWebWiewPersist = false;
      notifyListeners();
    }
  }

  void setWebView() {
    if (!_isWebWiewPersist) {
      _isWebWiewPersist = true;
      notifyListeners();
    }
  }
}
