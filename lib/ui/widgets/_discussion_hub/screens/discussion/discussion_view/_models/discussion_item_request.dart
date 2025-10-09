

import 'dart:ui';

import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/discussion_model.dart';

class DiscussionItemRequest {
  final DiscussionItemData discussionItemData;
  final String userName;
  final String userId;
  final String profileImageUrl;
  final String userRole;
  final String designation;
  final String profileStatus;
  final int answerPostCount;
  final bool enableLike;
  final bool enableBookmark;
  final bool enableReport;
  final bool enableReply;
  final bool enableEdit;
  final bool enableDelete;
  final bool enableAction;
  final bool isReply;
  final bool isAnswerPostReply;
  final bool enableTag;
  final String parentId;
  final String postType;
  final Color cardBackgroundColor;
  final Color replyCardBackgroundColor;

  final Function(String) updateChildCallback;
  final Function deleteCommentCallback;
  final DiscussionType discussionType;

  DiscussionItemRequest({
    required this.discussionItemData,
    required this.userName,
    required this.userId,
    required this.profileImageUrl,
    required this.userRole,
    required this.designation,
    required this.profileStatus,
    required this.answerPostCount,
    required this.enableLike,
    required this.enableBookmark,
    required this.enableReport,
    required this.enableReply,
    required this.enableEdit,
    required this.enableDelete,
    required this.updateChildCallback,
    required this.deleteCommentCallback,
    required this.enableAction,
    this.isReply = false,
    this.isAnswerPostReply = false,
    this.enableTag = false,
    required this.parentId,
    required this.discussionType,
    required this.postType,
    required this.cardBackgroundColor,
    required this.replyCardBackgroundColor
  });
}
