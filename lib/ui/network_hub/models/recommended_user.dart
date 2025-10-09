class RecommendedUser {
  final String userId;
  final String id;
  final String? designation;
  final List<String>? role;
  final String? rootOrgId;
  final String? profileImageUrl;
  final String? profileBannerUrl;
  final bool? verifiedKarmayogi;
  final List<ProfessionalDetail>? professionalDetails;
  final EmploymentDetails? employmentDetails;
  final PersonalDetails? personalDetails;

  RecommendedUser({
    required this.userId,
    required this.id,
    this.designation,
    this.role,
    this.rootOrgId,
    this.profileImageUrl,
    this.profileBannerUrl,
    this.verifiedKarmayogi,
    this.professionalDetails,
    this.employmentDetails,
    this.personalDetails,
  });

  factory RecommendedUser.fromJson(Map<String, dynamic> json) {
    return RecommendedUser(
      userId: json['userId'],
      id: json['id'],
      designation: json['designation'],
      role: List<String>.from(json['role'] ?? []),
      rootOrgId: json['rootOrgId'],
      profileImageUrl: json['profileImageUrl'] ?? '',
      profileBannerUrl: json['profileBannerUrl'] ?? '',
      verifiedKarmayogi: json['verifiedKarmayogi'] ?? false,
      professionalDetails: (json['professionalDetails'] as List?)
          ?.map((e) => ProfessionalDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      employmentDetails: json['employmentDetails'] != null
          ? EmploymentDetails.fromJson(
              json['employmentDetails'] as Map<String, dynamic>)
          : null,
      personalDetails: json['personalDetails'] != null
          ? PersonalDetails.fromJson(
              json['personalDetails'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ProfessionalDetail {
  final String? designation;
  final String? group;

  ProfessionalDetail({
    this.designation,
    this.group,
  });

  factory ProfessionalDetail.fromJson(Map<String, dynamic> json) {
    return ProfessionalDetail(
      designation: json['designation'],
      group: json['group'],
    );
  }
}

class EmploymentDetails {
  final String departmentName;

  EmploymentDetails({required this.departmentName});

  factory EmploymentDetails.fromJson(Map<String, dynamic> json) {
    return EmploymentDetails(
      departmentName: json['departmentName'] ?? "",
    );
  }
}

class PersonalDetails {
  final String firstname;
  final String? phoneVerified;
  final String? mobile;
  final String? primaryEmail;

  PersonalDetails({
    required this.firstname,
    this.phoneVerified,
    this.mobile,
    this.primaryEmail,
  });

  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      firstname: json['firstname'] ?? "",
      phoneVerified: json['phoneVerified'] != null
          ? json['phoneVerified'].toString()
          : null,
      mobile: json['mobile'] != null ? json['mobile'].toString() : null,
      primaryEmail: json['primaryEmail'],
    );
  }
}

class Role {
  final String role;

  Role({required this.role});

  factory Role.fromJson(dynamic json) {
    return Role(role: json.toString());
  }
}
