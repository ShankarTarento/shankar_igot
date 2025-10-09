import 'dart:convert';

CourseTocModel courseTocModelFromJson(String str) => CourseTocModel.fromJson(
      json.decode(str),
    );

String courseTocModelToJson(CourseTocModel data) => json.encode(data.toJson());

class CourseTocModel {
  String courseId;
  bool isFeaturedCourse;
  bool? isBlendedProgram;
  bool isModeratedContent;
  bool? showCourseCompletionMessage;
  String? externalId;
  String? contentType;
  bool isFeedbackPending;
  bool pointToProd;
  String? recommendationId;
  int? initialTabIndex;
  String? tagCommentId;

  CourseTocModel(
      {required this.courseId,
      this.isFeaturedCourse = false,
      this.isBlendedProgram,
      this.isModeratedContent = false,
      this.showCourseCompletionMessage,
      this.externalId = '',
      this.contentType,
      this.isFeedbackPending = false,
      this.pointToProd = false,
      this.recommendationId,
      this.initialTabIndex,
      this.tagCommentId});

  factory CourseTocModel.fromJson(Map<String, dynamic> json) {
    return CourseTocModel(
        courseId: json["courseId"],
        isFeaturedCourse:
            json["isFeaturedCourse"] != null ? json["isFeaturedCourse"] : false,
        isBlendedProgram:
            json["isBlendedProgram"] != null ? json["isBlendedProgram"] : false,
        isModeratedContent: json["isModeratedContent"] != null
            ? json["isModeratedContent"]
            : false,
        showCourseCompletionMessage: json['showCourseCompletionMessage'] != null
            ? json['showCourseCompletionMessage']
            : false,
        isFeedbackPending: json['isFeedbackPending'] ?? false,
        pointToProd: json['pointToProd'] ?? false,
        recommendationId: json['recommendationId'],
        initialTabIndex: json['initialTabIndex'],
        tagCommentId: json['tagCommentId']);
  }
  Map<String, dynamic> toJson() => {
        "courseId": courseId,
        "isFeaturedCourse": isFeaturedCourse,
      };
}