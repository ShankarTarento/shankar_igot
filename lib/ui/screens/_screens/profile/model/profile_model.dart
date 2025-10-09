class Profile {
  final String firstName;
  final String middleName;
  final String surname;
  final String? id;
  final Map<String, dynamic> personalDetails;
  final String? username;
  final String primaryEmail;
  final dynamic interests;
  final Object? skills;
  final String designation;
  final String department;
  final String? location;
  final String? photo;
  final List? experience;
  final List? education;
  final List? competencies;
  final Map? employmentDetails;
  final List? professionalDetails;
  final List? userRoles;
  final List? selectedTopics;
  final List? desiredTopics;
  final List? desiredCompetencies;
  final List? roles;
  final List? tags;
  final rawDetails;
  final bool? verifiedKarmayogi;
  final String? profileImageUrl;
  final String? profileBannerUrl;
  final bool? phoneVerified;
  final double profileCompletionPercentage;
  final int karmaPoints;
  final int certificateCount;
  final int postCount;
  final String group;
  final String? ehrmsId;
  final String? dateOfRetirement;
  final String? ehrmsSystem;
  final String? lastMotivationalMessageTime;
  final String? profileStatus;
  final bool? isApprovedMsgViewed;
  final dynamic profileStatusUpdatedOn;
  final String? profileGroupStatus;
  final String? profileDesignationStatus;
  final String? dob;
  final Map? cadreDetails;
  final int? profilePreference;

  const Profile({
    required this.firstName,
    required this.middleName,
    required this.surname,
    this.id,
    required this.personalDetails,
    this.username,
    required this.primaryEmail,
    this.interests,
    this.skills,
    required this.designation,
    required this.department,
    this.photo,
    this.location,
    this.experience,
    this.education,
    this.competencies,
    this.employmentDetails,
    this.professionalDetails,
    this.userRoles,
    this.selectedTopics,
    this.desiredTopics,
    this.desiredCompetencies,
    this.roles,
    this.tags,
    required this.rawDetails,
    this.verifiedKarmayogi,
    this.profileImageUrl,
    this.profileBannerUrl,
    this.phoneVerified,
    required this.profileCompletionPercentage,
    required this.karmaPoints,
    required this.certificateCount,
    required this.postCount,
    required this.group,
    this.ehrmsId,
    this.dateOfRetirement,
    this.ehrmsSystem,
    this.lastMotivationalMessageTime,
    this.profileStatus,
    this.isApprovedMsgViewed,
    this.profileStatusUpdatedOn,
    this.profileGroupStatus,
    this.profileDesignationStatus,
    this.dob,
    this.cadreDetails,
    this.profilePreference
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '00000000-0000-0000-0000-000000000000',
      firstName: isPersonalDeatilsAvailable(json) &&
              json['profileDetails']['personalDetails']['firstname'] != null
          ? json['profileDetails']['personalDetails']['firstname'] as String
          : json['firstName'] != null
              ? json['firstName'] as String
              : '',
      middleName: isPersonalDeatilsAvailable(json) &&
              json['profileDetails']['personalDetails']['middlename'] != null
          ? json['profileDetails']['personalDetails']['middlename']
          : '',
      surname: isPersonalDeatilsAvailable(json) &&
              json['profileDetails']['personalDetails']['surname'] != null
          ? json['profileDetails']['personalDetails']['surname']
          : '',
      personalDetails: isPersonalDeatilsAvailable(json)
          ? json['profileDetails']['personalDetails']
          : {},
      username: json['userName'] != null
          ? json['userName']
          : json['username'] != null
              ? json['username']
              : isPersonalDeatilsAvailable(json) &&
                      json['profileDetails']['personalDetails']['username'] !=
                          null
                  ? json['profileDetails']['personalDetails']['username']
                      as String
                  : '',
      primaryEmail: isPersonalDeatilsAvailable(json) &&
              json['profileDetails']['personalDetails']['primaryEmail'] != null
          ? json['profileDetails']['personalDetails']['primaryEmail'] as String
          : '',
      interests: json['profileDetails'] != null &&
              json['profileDetails']['interests'] != null
          ? json['profileDetails']['interests']
          : {},
      skills: json['profileDetails'] != null &&
              json['profileDetails']['skills'] != null
          ? json['profileDetails']['skills']
          : {},
      designation: (isProfessionalDetailsAvailable(json) &&
              json['profileDetails']['professionalDetails'].length > 0 &&
              json['profileDetails']['professionalDetails'][0]['designation'] !=
                  null)
          ? json['profileDetails']['professionalDetails'][0]['designation']
          : '',
      department: isEmploymentDetailsAvailable(json) &&
              json['profileDetails']['employmentDetails']['departmentName'] !=
                  null
          ? json['profileDetails']['employmentDetails']['departmentName']
              as String
          : '',
      photo: isPhotoAvailable(json) ? json['profileDetails']['photo'] : '',
      location: isPersonalDeatilsAvailable(json) &&
              json['profileDetails']['personalDetails']['postalAddress'] != null
          ? json['profileDetails']['personalDetails']['postalAddress']
          : '',
      experience: isProfessionalDetailsAvailable(json)
          ? json['profileDetails']['professionalDetails']
          : [],
      education:
          isAcademicsAvailable(json) ? json['profileDetails']['academics'] : [],
      competencies: isCompetenciesAvailable(json)
          ? json['profileDetails']['competencies']
          : [],
      employmentDetails: isEmploymentDetailsAvailable(json)
          ? json['profileDetails']['employmentDetails']
          : {},
      professionalDetails: isProfessionalDetailsAvailable(json)
          ? json['profileDetails']['professionalDetails']
          : [],
      userRoles:
          isUserRolesAvailable(json) ? json['profileDetails']['userRoles'] : [],
      selectedTopics: isSystemTopicsAvailable(json)
          ? json['profileDetails']['systemTopics']
          : [],
      desiredTopics: isDesiredTopicsAvailable(json)
          ? json['profileDetails']['desiredTopics']
          : [],
      desiredCompetencies: isDesiredCompetenciesAvailable(json)
          ? json['profileDetails']['desiredCompetencies']
          : [],
      roles: json['roles'],
      tags: isAdditionalPropertiesAvailable(json) &&
              json['profileDetails']['additionalProperties']['tag'] != null
          ? json['profileDetails']['additionalProperties']['tag']
          : [],
      rawDetails: json,
      verifiedKarmayogi: json['profileDetails'] != null &&
              json['profileDetails']['verifiedKarmayogi'] != null
          ? json['profileDetails']['verifiedKarmayogi']
          : false,
      profileImageUrl: isProfileImageUrlAvailable(json)
          ? json['profileDetails']['profileImageUrl']
          : '',
      profileBannerUrl: isProfileBannerUrlAvailable(json)
          ? json['profileDetails']['profileBannerUrl']
          : '',
      phoneVerified: json['phoneVerified'] != null
          ? parsePhoneVerified(json['phoneVerified'])
          : isPersonalDeatilsAvailable(json) &&
                  json['profileDetails']['personalDetails']['phoneVerified'] !=
                      null
              ? parsePhoneVerified(
                  json['profileDetails']['personalDetails']['phoneVerified'])
              : false,
      profileCompletionPercentage: json['profileCompletionPercentage'] ?? 0,
      karmaPoints: json['karmaPoints'] != null ? json['karmaPoints'] : 0,
      certificateCount:
          json['certificateCount'] != null ? json['certificateCount'] : 0,
      postCount: json['postCount'] != null ? json['postCount'] : 0,
      group: (isProfessionalDetailsAvailable(json) &&
              json['profileDetails']['professionalDetails'].length > 0 &&
              json['profileDetails']['professionalDetails'][0]['group'] != null)
          ? json['profileDetails']['professionalDetails'][0]['group']
          : '',
      ehrmsId: isAdditionalPropertiesAvailable(json)
          ? json['profileDetails']['additionalProperties']['externalSystemId']
          : null,
      dateOfRetirement: isAdditionalPropertiesAvailable(json)
          ? json['profileDetails']['additionalProperties']['externalSystemDor']
          : null,
      ehrmsSystem: isAdditionalPropertiesAvailable(json)
          ? json['profileDetails']['additionalProperties']['externalSystem']
          : null,
      lastMotivationalMessageTime: isLastMotivationalTimeAvailable(json)
          ? json['profileDetails']['lastMotivationalMessageTime']
          : '',
      profileStatus: json['profileDetails'] != null
          ? json['profileDetails']['profileStatus']
          : null,
      isApprovedMsgViewed: isAdditionalPropertiesAvailable(json)
          ? json['profileDetails']['additionalProperties']
              ['isProfileUpdatedMsgViewed']
          : null,
      profileStatusUpdatedOn: json['profileDetails'] != null
          ? json['profileDetails']['profileStatusUpdatedOn']
          : null,
      profileDesignationStatus: json['profileDetails'] != null
          ? json['profileDetails']['profileDesignationStatus']
          : null,
      profileGroupStatus: json['profileDetails'] != null
          ? json['profileDetails']['profileGroupStatus']
          : null,
      cadreDetails: json['profileDetails'] != null
          ? json['profileDetails']['cadreDetails']
          : null,
      profilePreference: json['profileDetails'] != null
          ? json['profileDetails']['profilePreference'] ?? 0
          : 0,
    );
  }

  static bool isLastMotivationalTimeAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['lastMotivationalMessageTime'] != null;

  static bool isProfileImageUrlAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['profileImageUrl'] != null;

  static bool isAdditionalPropertiesAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['additionalProperties'] != null;

  static bool isDesiredCompetenciesAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['desiredCompetencies'] != null;

  static bool isDesiredTopicsAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['desiredTopics'] != null;

  static bool isSystemTopicsAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['systemTopics'] != null;

  static bool isUserRolesAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['userRoles'] != null;

  static bool isCompetenciesAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['competencies'] != null;

  static bool isAcademicsAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['academics'] != null;

  static bool isPhotoAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null && json['profileDetails']['photo'] != null;

  static bool isEmploymentDetailsAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['employmentDetails'] != null;

  static bool isProfessionalDetailsAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['professionalDetails'] != null;

  static bool isPersonalDeatilsAvailable(Map<String, dynamic> json) {
    return json['profileDetails'] != null &&
        json['profileDetails']['personalDetails'] != null;
  }

  static bool isProfileBannerUrlAvailable(Map<String, dynamic> json) =>
      json['profileDetails'] != null &&
      json['profileDetails']['profileBannerUrl'] != null;

  static bool parsePhoneVerified(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }
}
