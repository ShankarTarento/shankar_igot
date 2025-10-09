class UserEnrollmentInfo {
  UserCourseEnrolmentInfo userCourseEnrolmentInfo;
  UserExternalCourseEnrolmentInfo userExternalCourseEnrolmentInfo;

  UserEnrollmentInfo({
    required this.userCourseEnrolmentInfo,
    required this.userExternalCourseEnrolmentInfo,
  });

  factory UserEnrollmentInfo.fromJson(Map<String, dynamic> json) =>
      UserEnrollmentInfo(
        userCourseEnrolmentInfo:
            UserCourseEnrolmentInfo.fromJson(json['userCourseEnrolmentInfo']),
        userExternalCourseEnrolmentInfo:
            UserExternalCourseEnrolmentInfo.fromJson(
                json['userExternalCourseEnrolmentInfo']),
      );
}

class UserCourseEnrolmentInfo {
  int karmaPoints;
  int timeSpentOnCompletedCourses;
  int certificatesIssued;
  int coursesInProgress;
  int? claimedNonAcbpCourseKarmaQuota;
  String? formattedMonth;

  UserCourseEnrolmentInfo(
      {required this.karmaPoints,
      required this.timeSpentOnCompletedCourses,
      required this.certificatesIssued,
      required this.coursesInProgress,
      this.claimedNonAcbpCourseKarmaQuota,
      this.formattedMonth});

  factory UserCourseEnrolmentInfo.fromJson(Map<String, dynamic> json) =>
      UserCourseEnrolmentInfo(
          karmaPoints: json['karmaPoints'] ?? 0,
          timeSpentOnCompletedCourses: json['timeSpentOnCompletedCourses'] ?? 0,
          certificatesIssued: json['certificatesIssued'] ?? 0,
          coursesInProgress: json['coursesInProgress'] ?? 0,
          claimedNonAcbpCourseKarmaQuota: json['addinfo'] != null &&
                  json['addinfo']['claimedNonACBPCourseKarmaQuota'] != null
              ? json['addinfo']['claimedNonACBPCourseKarmaQuota']
              : null,
          formattedMonth: json['addinfo'] != null &&
                  json['addinfo']['formattedMonth'] != null
              ? json['addinfo']['formattedMonth']
              : null);
}

class UserExternalCourseEnrolmentInfo {
  int timeSpentOnCompletedCourses;
  int certificatesIssued;
  int coursesInProgress;

  UserExternalCourseEnrolmentInfo({
    required this.timeSpentOnCompletedCourses,
    required this.certificatesIssued,
    required this.coursesInProgress,
  });

  factory UserExternalCourseEnrolmentInfo.fromJson(Map<String, dynamic> json) =>
      UserExternalCourseEnrolmentInfo(
        timeSpentOnCompletedCourses: json['timeSpentOnCompletedCourses'] ?? 0,
        certificatesIssued: json['certificatesIssued'] ?? 0,
        coursesInProgress: json['coursesInProgress'] ?? 0,
      );
}
