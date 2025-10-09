import 'cadre_request_data_model.dart';

class ProfileOtherPrimaryDetails {
  final String? primaryEmail;
  final String pinCode;
  final String dob;
  final String gender;
  final String category;
  final String? mobile;
  final String? motherTongue;
  final String? employeeId;
  final CadreRequestDataModel? cadreRequestData;
  final String? phoneVerified;

  const ProfileOtherPrimaryDetails(
      {this.primaryEmail,
      required this.pinCode,
      required this.dob,
      required this.gender,
      required this.category,
      this.mobile,
      this.motherTongue,
      this.employeeId,
      this.cadreRequestData,
      this.phoneVerified});
}
