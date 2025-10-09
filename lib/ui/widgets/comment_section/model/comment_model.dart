
import 'package:karmayogi_mobile/ui/widgets/comment_section/model/user_data_model.dart';

import 'comment_data_model.dart';

class CommentModel {
  final int? commentCount;
  final String? commentTreeId;
  final List<CommentDataModel>? comments;
  final CommentDataModel? comment;
  final List<UserDataModel>? taggedUsers;
  final List<UserDataModel>? users;
  final CourseDetails? courseDetails;

  CommentModel({
    this.commentCount,
    this.commentTreeId,
    this.comments,
    this.comment,
    this.taggedUsers,
    this.users,
    this.courseDetails,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
        commentCount: json['commentCount'],
        commentTreeId: json['commentTreeId'] ?? "",
        comments: (json['comments'] as List<dynamic>?)
            ?.map((item) => CommentDataModel.fromJson(item as Map<String, dynamic>))
            .toList() ?? [],
      comment: json['comment'] != null
          ? CommentDataModel.fromJson(json['comment'] as Map<String, dynamic>)
          : null,
      taggedUsers: (json['taggedUsers'] as List<dynamic>?)
          ?.map((item) => UserDataModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      users: (json['users'] as List<dynamic>?)
          ?.map((item) => UserDataModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      courseDetails: json['courseDetails'] != null
          ? CourseDetails.fromJson(json['courseDetails'] as Map<String, dynamic>)
          : null,
      );
  }
}



