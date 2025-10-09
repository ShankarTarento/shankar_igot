import 'dart:convert';

import 'package:karmayogi_mobile/models/_models/creator_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_models/tag_user_data_model.dart';

class CommentDataModel {
  final String? commentId;
  CommentData? commentData;
  String? status;
  final String? createdDate;
  String? lastUpdatedDate;
  final List<CommentDataModel>? children;
  bool? isLiked = false;

  CommentDataModel({
    this.commentId,
    this.commentData,
    this.status,
    this.createdDate,
    this.lastUpdatedDate,
    this.children,
    this.isLiked,
  });

  factory CommentDataModel.fromJson(Map<String, dynamic> json) {
    return CommentDataModel(
      commentId: json['commentId'] ?? '',
      commentData: json['commentData'] != null
          ? CommentData.fromJson(json['commentData'] as Map<String, dynamic>)
          : null,
      status: json['status'] ?? '',
      createdDate: json['createdDate'] ?? '',
      lastUpdatedDate: json['lastUpdatedDate'] ?? '',
      children: (json['children'] != null) ? (json['children'] as List<dynamic>?)
          ?.map((e) => CommentDataModel.fromJson(e as Map<String, dynamic>))
          .toList() : [],
      isLiked: json['isLiked'] ?? false,
    );
  }
}

class CommentData {
  final List<String>? file;
  String? comment;
  final CommentSource? commentSource;
  final String? commentResolved;
  int ?like;
  int ?disLike;
  final List<String>? taggedUsers;
  List<TagUserDataModel>? mentionedUsers;

  CommentData({
    this.file,
    this.comment,
    this.commentSource,
    this.commentResolved,
    this.like,
    this.disLike,
    this.taggedUsers,
    this.mentionedUsers,
  });

  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
      file: (json['file'] as List<dynamic>?)?.map((e) => e as String).toList(),
      comment: json['comment'] ?? '',
      commentSource: json['commentSource'] != null
          ? CommentSource.fromJson(json['commentSource'] as Map<String, dynamic>)
          : null,
      commentResolved: json['commentResolved'] ?? '',
      like: json['like'] ?? 0,
      disLike: json['disLike'] ?? 0,
      taggedUsers: (json['taggedUsers'] as List<dynamic>?)?.map((e) => e as String).toList(),
      mentionedUsers: (json['mentionedUsers'] as List<dynamic>?)
          ?.map((x) => TagUserDataModel.fromJson(x as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class CommentSource {
  final String? userId;
  final String? userPic;
  final String? userName;
  final String? userRole;
  final String? designation;
  final String? profileStatus;

  CommentSource({
    this.userId,
    this.userPic,
    this.userName,
    this.userRole,
    this.designation,
    this.profileStatus,
  });

  factory CommentSource.fromJson(Map<String, dynamic> json) {
    return CommentSource(
      userId: json['userId'] ?? '',
      userPic: json['userPic'] ?? '',
      userName: json['userName'] ?? '',
      userRole: json['userRole'] ?? '',
      designation: json['designation'] ?? '',
      profileStatus: json['profileStatus'] ?? '',
    );
  }
}

class CourseDetails {
  List<CreatorModel> authors;
  List<CreatorModel> curators;

  CourseDetails({
    required this.authors,
    required this.curators,
  });

  factory CourseDetails.fromJson(Map<String, dynamic> json) {
    return CourseDetails(
      authors: json['creatorDetails'] != null &&
          json['creatorDetails'].isNotEmpty
          ? List<CreatorModel>.from(jsonDecode(json['creatorDetails'])
          .map((x) => CreatorModel.fromJson(x)))
          : [],
      curators: json['creatorContacts'] != null && json['creatorContacts'].isNotEmpty
          ? List<CreatorModel>.from(jsonDecode(json['creatorContacts'])
          .map((x) => CreatorModel.fromJson(x)))
          : [],
    );
  }
}
