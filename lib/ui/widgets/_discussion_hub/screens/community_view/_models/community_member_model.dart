
class CommunityMemberModel {
  List<MemberDetails>? userDetails;
  final int? totalCount;

  CommunityMemberModel({this.userDetails, this.totalCount});

  factory CommunityMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityMemberModel(
      userDetails: (json['userDetails'] as List<dynamic>?)
          ?.map((item) => MemberDetails.fromJson(item))
          .toList(),
      totalCount: json['usersJoinedCount'] as int?,
    );
  }
}

class MemberDetails {
  final String? userId;
  final String? firstName;
  final String? userProfileImgUrl;
  final String? userProfileStatus;
  final String? department;

  MemberDetails({
    this.userId,
    this.firstName,
    this.userProfileImgUrl,
    this.userProfileStatus,
    this.department,
  });

  factory MemberDetails.fromJson(Map<String, dynamic> json) {
    return MemberDetails(
      userId: json['user_id'] as String?,
      firstName: json['first_name'] as String?,
      userProfileImgUrl: json['user_profile_img_url'] as String?,
      userProfileStatus: json['userProfileStatus'] as String?,
      department: json['department'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'user_profile_img_url': userProfileImgUrl,
      'userProfileStatus': userProfileStatus,
      'department': department,
    };
  }
}

