class NetworkUser {
  final String userId;
  final String? createdAt;
  final String? updatedAt;
  final String fullName;
  final String departmentName;
  final String status;
  final List<ProfessionalDetails> professionalDetails;
  final EmploymentDetails? employmentDetails;
  final String? profileImageUrl;
  final String? profileBannerUrl;
  final String? designation;
  final String? organisationId;
  final List<String>? roles;

  NetworkUser({
    required this.userId,
    this.createdAt,
    this.updatedAt,
    required this.fullName,
    required this.departmentName,
    required this.status,
    required this.professionalDetails,
    this.employmentDetails,
    this.profileImageUrl,
    this.profileBannerUrl,
    this.designation,
    this.organisationId,
    this.roles,
  });

  factory NetworkUser.fromJson(Map<String, dynamic> json) {
    return NetworkUser(
      userId: json['userId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'] != "null" ? json['updatedAt'] : null,
      fullName: json['fullName'] ?? '',
      departmentName: json['departmentName'] ?? '',
      status: json['status'] ?? '',
      professionalDetails: (json['professionalDetails'] as List?)
              ?.map((e) => ProfessionalDetails.fromJson(e))
              .toList() ??
          [],
      employmentDetails: json['employmentDetails'] != null
          ? EmploymentDetails.fromJson(json['employmentDetails'])
          : null,
      profileImageUrl: json['profileImageUrl'],
      profileBannerUrl: json['profileBannerUrl'],
      designation: json['designation'],
      organisationId: json['organisationId'],
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList(),
    );
  }
}

class ProfessionalDetails {
  final String designation;
  final String group;

  ProfessionalDetails({
    required this.designation,
    required this.group,
  });

  factory ProfessionalDetails.fromJson(Map<String, dynamic> json) {
    return ProfessionalDetails(
      designation: json['designation'] ?? '',
      group: json['group'] ?? '',
    );
  }
}

class EmploymentDetails {
  final String? departmentName;

  EmploymentDetails({
    this.departmentName,
  });

  factory EmploymentDetails.fromJson(Map<String, dynamic> json) {
    return EmploymentDetails(
      departmentName: json['departmentName'] ?? '',
    );
  }
}
