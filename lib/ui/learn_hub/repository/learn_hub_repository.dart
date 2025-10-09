import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/core/repositories/enrollment_repository.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';

class LearnHubRepository {
  Future<List<Course>> getContinueLearningCourses() async {
    final enrolledCourses = await EnrollmentRepository.getEnrolledCourses(
      type: EnrollmentAPIFilter.all,
    );

    enrolledCourses.sort(
      (a, b) => getLastAccessTime(b).compareTo(getLastAccessTime(a)),
    );

    return enrolledCourses;
  }

  static int getLastAccessTime(Course course) {
    return course.raw['lastContentAccessTime'] ?? 0;
  }
}
