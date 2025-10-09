class UserDataModel {
  final String? userId;
  final String? firstName;
  final String? userProfileImgUrl;
  final String? designation;
  final String? department;
  final String? userProfileStatus;

  UserDataModel({
    this.userId,
    this.firstName,
    this.userProfileImgUrl,
    this.designation,
    this.department,
    this.userProfileStatus,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      userId: json['user_id'] ?? '',
      firstName: json['first_name'] ?? '',
      userProfileImgUrl: json['user_profile_img_url'] ?? '',
      designation: json['designation'] ?? '',
      department: json['department'] ?? '',
      userProfileStatus: json['userProfileStatus'] ?? '',
    );
  }
}
