import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';

/** Used for the compatibility checks on TOC page or at course level **/
enum CourseCategoryVersion {
  /// courses and their compatibility levels
  course(5),
  moderatedCourse(4),

  /// Programs and their compatibility levels
  curatedProgram(5),
  inviteOnlyProgram(4),
  moderatedProgram(4),
  blendedProgram(5),
  comprehensiveAssessmentProgram(5),

  /// Assessments and their compatibility levels
  inviteOnlyAssessment(4),
  standaloneAssessment(4),
  moderatedAssessment(4),

  ///Case Study and its compatibility level
  caseStudy(4),
  multilingualCourse(5);

  final int version;
  const CourseCategoryVersion(this.version);

  /// Returns the version of the course category based on the primary category. Please add the category on map also
  static Map<String, int> getAllVersions() {
    return {
      PrimaryCategory.course.toLowerCase(): course.version,
      PrimaryCategory.moderatedCourses.toLowerCase(): moderatedCourse.version,
      PrimaryCategory.curatedProgram.toLowerCase(): curatedProgram.version,
      PrimaryCategory.inviteOnlyProgram.toLowerCase(): inviteOnlyProgram.version,
      PrimaryCategory.moderatedProgram.toLowerCase(): moderatedProgram.version,
      PrimaryCategory.blendedProgram.toLowerCase(): blendedProgram.version,
      PrimaryCategory.comprehensiveAssessmentProgram.toLowerCase(): comprehensiveAssessmentProgram.version,
      PrimaryCategory.inviteOnlyAssessment.toLowerCase(): inviteOnlyAssessment.version,
      PrimaryCategory.standaloneAssessment.toLowerCase(): standaloneAssessment.version,
      PrimaryCategory.moderatedAssessment.toLowerCase(): moderatedAssessment.version,
      PrimaryCategory.caseStudy.toLowerCase(): caseStudy.version,
      PrimaryCategory.multilingualCourse.toLowerCase():
          multilingualCourse.version
    };
  }
}

/** Used for the compatibility checks on resource level in navigation item and on resource player  **/
enum ResourceCategoryVersion {
  navigationCompatibility(8),
  contentCompatibility(5);

  final int version;
  const ResourceCategoryVersion(this.version);
}

/** Used for the compatibility checks on assessment level **/
enum AssessmentCompatibility {
  multimediaCompatibility(7),
  dropdownCompatibility(8);

  final int version;
  const AssessmentCompatibility(this.version);
}
