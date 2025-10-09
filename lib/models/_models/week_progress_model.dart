class WeekProgressModel {
  final String? profileImage;
  final String? totalLearningHours;
  final String? lastCreditDate;
  final String? orgId;
  final String? totalPoints;
  final String? count;
  final String? rank;
  final String? fullname;
  final String? designation;
  final String? rowNum;
  final String? userId;

  WeekProgressModel({
    this.profileImage,
    this.totalLearningHours,
    this.lastCreditDate,
    this.orgId,
    this.totalPoints,
    this.count,
    this.rank,
    this.fullname,
    this.designation,
    this.rowNum,
    this.userId,
  });

  factory WeekProgressModel.fromJson(Map<String, dynamic> json) {
    return WeekProgressModel(
      profileImage: json['profile_image'] as String?,
      totalLearningHours: json['total_learning_hours'] as String?,
      lastCreditDate: json['last_credit_date'] as String?,
      orgId: json['org_id'] as String?,
      totalPoints: json['total_points']?.toString(),
      count: json['count']?.toString(),
      rank: json['rank']?.toString(),
      fullname: json['fullname'] as String?,
      designation: json['designation'] as String?,
      rowNum: json['row_num']?.toString(),
      userId: json['userId'] as String?,
    );
  }
}
