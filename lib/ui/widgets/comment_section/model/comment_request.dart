
import 'dart:ui';

class CommentRequest {
  final String entityId;
  final String entityType;
  final String workflow;
  final bool? showHeading;
  final bool enableLike;
  final bool enableReport;
  final bool enableReply;
  final String? userName;
  final String? userId;
  final String? userProfileImage;
  final String? userRole;
  final String? designation;
  final String? profileStatus;
  final bool enableAction;
  final bool enableEdit;
  final bool enableDelete;
  final String? tagCommentId;
  VoidCallback? backToAllCommentsCallback;
  final bool enableUserTagging;

  CommentRequest({
    required this.entityId,
    required this.entityType,
    required this.workflow,
    this.showHeading,
    this.enableLike = false,
    this.enableReport = false,
    this.enableReply = false,
    this.userName,
    this.userId,
    this.userProfileImage,
    this.userRole,
    this.designation,
    this.profileStatus,
    this.enableAction = true,
    this.enableEdit = false,
    this.enableDelete = false,
    this.tagCommentId,
    this.backToAllCommentsCallback,
    this.enableUserTagging = false,
  });

  factory CommentRequest.fromJson(Map<String, dynamic> json) {
    return CommentRequest(
      entityId: json['entityId'],
      entityType: json['entityType'],
      workflow: json['workflow'],
      showHeading: json['showHeading'],
      enableLike: json['enableLike'],
      enableReply: json['enableReply'],
      userName: json['userName'],
      userId: json['userId'],
      userProfileImage: json['userProfileImage'],
      userRole: json['userRole'],
      designation: json['designation'],
      profileStatus: json['profileStatus'],
      );
  }
}

class CommentCreationCallbackRequest {
  final String? comment;
  final List<Map<String, String>>? mentionedUser;

  CommentCreationCallbackRequest({
    this.comment,
    this.mentionedUser,
  });

  factory CommentCreationCallbackRequest.fromJson(Map<String, dynamic> json) {
    return CommentCreationCallbackRequest(
      comment: json['comment'],
      mentionedUser: json['mentionedUser'] != null
          ? List<Map<String, String>>.from(
              (json['mentionedUser'] as List)
                  .map((item) => Map<String, String>.from(item)))
          : null
    );
  }
}



