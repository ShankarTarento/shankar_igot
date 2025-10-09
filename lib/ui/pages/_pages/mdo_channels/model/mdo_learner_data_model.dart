class MdoLearnerDataModel {
  String? title;
  String? titleFontColor;

  MdoLearnerDataModel({
    this.title,
    this.titleFontColor,
  });

  MdoLearnerDataModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    titleFontColor = json['titleFontColor'];
  }
}

class MdoLearnerData {
  final String? profileImage;
  final String? month;
  final String? year;
  final String? orgId;
  final int? totalPoints;
  final int rank;
  final int previousRank;
  final String? fullname;
  final int? rowNum;
  final String? userId;
  final String? designation;
  final String? orgName;

  MdoLearnerData({
    this.profileImage,
    this.month,
    this.year,
    this.orgId,
    this.totalPoints,
    required this.rank,
    required this.previousRank,
    this.fullname,
    this.rowNum,
    this.userId,
    this.designation,
    this.orgName,
  });

  factory MdoLearnerData.fromJson(Map<String, dynamic> json) {
    return MdoLearnerData(
      profileImage: json['profile_image'],
      month: json['month'],
      year: json['year'],
      orgId: json['org_id'],
      totalPoints: json['total_points'],
      rank: json['rank'] ?? 0,
      previousRank: json['previous_rank'] ?? 0,
      fullname: json['fullname'] ?? json['fullName'],
      rowNum: json['row_num'],
      userId: json['userId'],
      designation: json['designation'],
      orgName: json['org_name'] ?? json['orgName'],
    );
  }
}
