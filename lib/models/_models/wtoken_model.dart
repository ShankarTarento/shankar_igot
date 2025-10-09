import 'package:equatable/equatable.dart';

class Wtoken extends Equatable {
  final String wid;
  final String userName;
  final String? firstName;
  final String? lastName;
  final String? deptName;
  final String deptId;
  final String? email;
  final String? designation;
  final bool? showGetStarted;
  final String? profileStatus;

  final double? profileCompletionPercentage;
  // final String cookie;

  const Wtoken(
      {required this.wid,
      required this.userName,
      this.firstName,
      this.lastName,
      this.deptName,
      required this.deptId,
      this.email,
      this.designation,
      this.showGetStarted,
      this.profileStatus,
      this.profileCompletionPercentage
      // this.cookie,
      });

  factory Wtoken.fromJson(Map<String, dynamic> json) {
    return Wtoken(
        wid: json['id'],
        userName: json['userName'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        deptName: json['rootOrg']['orgName'],
        deptId: json['rootOrgId'],
        email: json['email'],
        designation: json['profileDetails'] != null
            ? ((json['profileDetails']['professionalDetails'] != null &&
                    (json['profileDetails']['professionalDetails'].length > 0 &&
                        json['profileDetails']['professionalDetails'][0] !=
                            null))
                ? json['profileDetails']['professionalDetails'][0]
                    ['designation']
                : null)
            : null,
        showGetStarted: json['profileDetails'] != null
            ? json['profileDetails']['get_started_tour'] != null
                ? json['profileDetails']['get_started_tour']['visited'] ?? null
                : null
            : null,
        profileStatus: json['profileDetails'] != null
            ? json['profileDetails']['profileStatus']
            : null,
        profileCompletionPercentage: json['profileCompletionPercentage'] != null
            ? json['profileCompletionPercentage']
            : 0);
  }

  @override
  List<Object?> get props => [
        wid,
        userName,
        firstName,
        lastName,
        deptName,
        deptId,
        email,
        designation,
        showGetStarted
      ];
}
