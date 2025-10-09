class Suggestion {
  final String id;
  final String firstName;
  final String lastName;
  final String department;
  final String photo;
  final bool verifiedKarmayogi;
  final String profileImageUrl;
  final String designation;
  final rawDetails;

  Suggestion(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.department,
      required this.photo,
      required this.profileImageUrl,
      required this.rawDetails,
      required this.verifiedKarmayogi,
      required this.designation});

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'] != null
          ? json['id'] as String
          : json['userId'] != null
              ? json['userId']
              : '',
      firstName: (json['personalDetails'] != null &&
              json['personalDetails']['firstname'] != null)
          ? json['personalDetails']['firstname'] as String
          : (json['profileDetails'] != null &&
                  json['profileDetails']['personalDetails'] != null &&
                  json['profileDetails']['personalDetails']['firstname'] !=
                      null)
              ? json['profileDetails']['personalDetails']['firstame'] as String
              : json['firstName'] != null
                  ? json['firstName']
                  : '',
      lastName: json['personalDetails'] != null &&
              json['personalDetails']['surname'] != null
          ? json['personalDetails']['surname']
          : (json['profileDetails'] != null &&
                  json['profileDetails']['personalDetails'] != null &&
                  json['profileDetails']['personalDetails']['surname'] != null)
              ? json['profileDetails']['personalDetails']['surname'] as String
              : '',
      department: (json['employmentDetails'] != null &&
              json['employmentDetails']['departmentName'] != null)
          ? json['employmentDetails']['departmentName'] as String
          : (json['profileDetails'] != null &&
                  json['profileDetails']['employmentDetails'] != null &&
                  json['profileDetails']['employmentDetails']
                          ['departmentName'] !=
                      null)
              ? json['profileDetails']['employmentDetails']['departmentName']
                  as String
              : json['rootOrgName'] != null
                  ? json['rootOrgName']
                  : '',
      photo: json['photo'] != null ? json['photo'] : '',
      verifiedKarmayogi: json['verifiedKarmayogi'] ?? false,
      profileImageUrl: (json['profileDetails'] != null &&
              json['profileDetails']['profileImageUrl'] != null)
          ? json['profileDetails']['profileImageUrl'] as String
          : '',
      designation: (json['profileDetails'] != null &&
              json['profileDetails']['professionalDetails'] != null &&
              json['profileDetails']['professionalDetails'].length > 0 &&
              json['profileDetails']['professionalDetails'][0]['designation'] !=
                  null)
          ? json['profileDetails']['professionalDetails'][0]['designation']
          : '',
      rawDetails: json,
    );
  }
}
