import '../index.dart';

class RecommendedLearningModel {
  List<Course> availableCourses;
  List<Course> inprogressCourses;
  List<Course> completedCourses;
  bool showAll;

  RecommendedLearningModel({
    required this.availableCourses,
    required this.inprogressCourses,
    required this.completedCourses,
    required this.showAll,
  });

  factory RecommendedLearningModel.fromJson(Map<String, dynamic> json) =>
      RecommendedLearningModel(
        availableCourses: json['availableCourses'] ?? [],
        inprogressCourses: json['inprogressCourses'] ?? [],
        completedCourses: json['completedCourses'] ?? [],
        showAll: json['showAll'] ?? false,
      );
}
