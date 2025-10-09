
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_models/tag_user_data_model.dart';

class DiscussionModel {
  List<DiscussionItemData>? data;
  Map<String, dynamic>? facets;
  int? totalCount;

  DiscussionModel({this.data, this.facets, this.totalCount});

  factory DiscussionModel.fromJson(Map<String, dynamic> json) {
    return DiscussionModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => DiscussionItemData.fromJson(item))
          .toList(),
      facets: json['facets'] as Map<String, dynamic>?,
      totalCount: json['totalCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((item) => item.toJson()).toList(),
      'facets': facets,
      'totalCount': totalCount,
    };
  }
}

class DiscussionItemData {
  int? downVoteCount;
  String? description;
  String? type;
  bool? isActive;
  String? createdOn;
  String? updatedOn;
  List<String>? tags;
  List<String>? answerPosts;
  int? answerPostCount;
  int? answerPostRepliesCount;
  CreatedBy? createdBy;
  String? discussionId;
  String? targetTopic;
  String? communityId;
  String? communityName;
  MediaCategory? mediaCategory;
  int? upVoteCount;
  String? status;
  String? parentDiscussionId;
  bool? isLiked = false;
  bool? isBookmarked = false;
  bool? isReported = false;
  List<TagUserDataModel>? mentionedUsers;

  DiscussionItemData({
    this.downVoteCount,
    this.description,
    this.type,
    this.isActive,
    this.createdOn,
    this.updatedOn,
    this.tags,
    this.answerPosts,
    this.answerPostCount,
    this.answerPostRepliesCount,
    this.createdBy,
    this.discussionId,
    this.targetTopic,
    this.communityId,
    this.communityName,
    this.mediaCategory,
    this.upVoteCount,
    this.status,
    this.parentDiscussionId,
    this.isLiked,
    this.isBookmarked,
    this.isReported,
    this.mentionedUsers,
  });

  factory DiscussionItemData.fromJson(Map<String, dynamic> json) {
    return DiscussionItemData(
      downVoteCount: json['downVoteCount'] as int?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      isActive: json['isActive'] as bool?,
      createdOn: json['createdOn'] as String?,
      updatedOn: json['updatedOn'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      answerPosts: (json['answerPosts'] as List<dynamic>?)?.map((e) => e as String).toList(),
      answerPostCount: json['answerPostCount'] ?? 0,
      answerPostRepliesCount: json['answerPostRepliesCount'] ?? 0,
      createdBy: json['createdBy'] != null && json['createdBy'] is Map
          ? CreatedBy.fromJson(json['createdBy'])
          : null,
      discussionId: json['discussionId'] as String?,
      targetTopic: json['targetTopic'] as String?,
      communityId: json['communityId'] ?? '',
      communityName: json['communityName'] ?? '',
      mediaCategory: json['mediaCategory'] != null && json['mediaCategory'] is Map
          ? MediaCategory.fromJson(json['mediaCategory'])
          : null,
      upVoteCount: json['upVoteCount'] as int?,
      status: json['status'] as String?,
      parentDiscussionId: json['parentDiscussionId'] as String?,
      isLiked: json['isLiked'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      isReported: json['isReported'] ?? false,
      mentionedUsers: (json['mentionedUsers'] as List<dynamic>?)
          ?.map((x) => TagUserDataModel.fromJson(x as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'downVoteCount': downVoteCount,
      'description': description,
      'type': type,
      'isActive': isActive,
      'createdOn': createdOn,
      'updatedOn': updatedOn,
      'tags': tags,
      'createdBy': createdBy?.toJson(),
      'discussionId': discussionId,
      'targetTopic': targetTopic,
      'communityId': communityId,
      'communityName': communityName,
      'upVoteCount': upVoteCount,
      'status': status,
      'parentDiscussionId': parentDiscussionId,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'isReported': isReported,
    };
  }
}

class CreatedBy {
  String? userId;
  String? firstName;
  String? userProfileImgUrl;
  String? userProfileStatus;
  String? designation;
  String? department;

  CreatedBy({
    this.userId,
    this.firstName,
    this.userProfileImgUrl,
    this.userProfileStatus,
    this.designation,
    this.department,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      userId: json['user_id'] as String?,
      firstName: json['first_name'] as String?,
      userProfileImgUrl: json['user_profile_img_url'] as String?,
      userProfileStatus: json['userProfileStatus'] as String?,
      designation: json['designation'] as String?,
      department: json['department'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'user_profile_img_url': userProfileImgUrl,
      'userProfileStatus': userProfileStatus,
      'designation': designation,
      'department': department,
    };
  }
}

class MediaCategory {
  List<String>? image;
  List<String>? video;
  List<String>? document;
  List<String>? link;

  MediaCategory({
    this.image,
    this.video,
    this.document,
    this.link,
  });

  factory MediaCategory.fromJson(Map<String, dynamic> json) {
    return MediaCategory(
      image: (json['image'] as List<dynamic>?)?.map((e) => e as String).toList(),
      video: (json['video'] as List<dynamic>?)?.map((e) => e as String).toList(),
      document: (json['document'] as List<dynamic>?)?.map((e) => e as String).toList(),
      link: (json['link'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }
}

class DiscussionEnrichData {
  Map<String, bool>? likes;
  Map<String, bool>? bookmarks;
  Map<String, bool>? reported;

  DiscussionEnrichData({
    this.likes,
    this.bookmarks,
    this.reported,
  });

  factory DiscussionEnrichData.fromJson(Map<String, dynamic> json) {
    return DiscussionEnrichData(
      likes: json['likes'] != null && json['likes'] is Map<String, dynamic>
          ? Map<String, bool>.from(json['likes'])
          : null,
      bookmarks: json['bookmarks'] != null && json['bookmarks'] is Map<String, dynamic>
          ? Map<String, bool>.from(json['bookmarks'])
          : null,
      reported: json['reported'] != null && json['reported'] is Map<String, dynamic>
          ? Map<String, bool>.from(json['reported'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'bookmarks': bookmarks,
      'reported': reported,
    };
  }
}





