
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';

class DiscussionRequest {
  final String communityId;
  final bool? showAddDiscussion;
  final bool enableLike;
  final bool enableBookmark;
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
  final bool showSearch;
  final DiscussionType discussionType;

  DiscussionRequest({
    required this.communityId,
    this.showAddDiscussion = false,
    this.enableLike = false,
    this.enableBookmark = false,
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
    this.showSearch = false,
    required this.discussionType,
  });

  factory DiscussionRequest.fromJson(Map<String, dynamic> json) {
    return DiscussionRequest(
      communityId: json['communityId'],
      showAddDiscussion: json['showAddDiscussion'],
      enableLike: json['enableLike'],
      enableBookmark: json['enableBookmark'],
      enableReply: json['enableReply'],
      userName: json['userName'],
      userId: json['userId'],
      userProfileImage: json['userProfileImage'],
      userRole: json['userRole'],
      designation: json['designation'],
      profileStatus: json['profileStatus'],
      showSearch: json['showSearch'],
      discussionType: json['discussionType'],
    );
  }
}



