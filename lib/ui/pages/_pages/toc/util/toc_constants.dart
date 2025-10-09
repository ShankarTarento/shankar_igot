import '../../../../../constants/index.dart';

class EContextLockingType {
  static const courseAssessmentOnly = 'Course Assessment Only';
}

class ContextLockingCompatibility {
  static const CuratedPgmFinalAssessmentLock = 5;
}

class ContentCompletionPercentage {
  static const video = 99;
  static const youtube = 99;
  static const scorm = 80;
  static const audio = 99;
}

enum TocPublishStatus {
  draft,
  live;

  // Add a helper to convert from string
  static TocPublishStatus? fromString(String? status) {
    if (status == null) return null;
    return TocPublishStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => TocPublishStatus.draft,
    );
  }
}

class TocConstants{
  static const contextLockCategories = {
  PrimaryCategory.curatedProgram,
  PrimaryCategory.comprehensiveAssessmentProgram
};
}
