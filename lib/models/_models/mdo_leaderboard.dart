class MDOLeaderboardData {
  final String? size;
  String? lastCreditDate;
  final String? orgId;
  final int? totalPoints;
  final int? rowNum;
  final int? totalUsers;
  final String? orgName;

  MDOLeaderboardData({
    this.size,
    this.lastCreditDate,
    this.orgId,
    this.totalPoints,
    this.rowNum,
    this.totalUsers,
    this.orgName,
  });

  factory MDOLeaderboardData.fromJson(Map<String, dynamic> json) {
    return MDOLeaderboardData(
      size: json['size'] as String?,
      lastCreditDate: json['last_credit_date'] as String?,
      orgId: json['org_id'] as String?,
      totalPoints: json['total_points'] as int?,
      rowNum: json['row_num'] as int?,
      totalUsers: json['total_users'] as int?,
      orgName: json['org_name'] as String?,
    );
  }
}
