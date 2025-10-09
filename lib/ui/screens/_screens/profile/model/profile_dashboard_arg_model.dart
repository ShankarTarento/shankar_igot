class ProfileDashboardArgModel {
  final String? userId;
  final String type;
  final profileParentAction;
  final bool showMyActivity;

  const ProfileDashboardArgModel({
    this.userId,
    this.profileParentAction,
    required this.type,
    this.showMyActivity = false
  });

  /// From JSON
  factory ProfileDashboardArgModel.fromJson(Map<String, dynamic> json) {
    return ProfileDashboardArgModel(
        userId: json['userId'],
        profileParentAction: json['profileParentAction'],
        type: json['type'],
        showMyActivity: json['showMyActivity']);
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profileParentAction': profileParentAction,
      'type': type,
      'showMyActivity': showMyActivity
    };
  }
}
