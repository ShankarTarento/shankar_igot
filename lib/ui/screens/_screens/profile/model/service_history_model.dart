class ServiceHistoryModel {
  final String orgName;
  final String designation;
  final String orgState;
  final String orgDistrict;
  final String startDate;
  final String endDate;
  final String description;
  final String currentlyWorking;
  final String uuid;
  final String orgLogo;

  ServiceHistoryModel(
      {required this.orgName,
      required this.designation,
      required this.orgState,
      required this.orgDistrict,
      required this.startDate,
      required this.endDate,
      required this.description,
      required this.currentlyWorking,
      required this.uuid,
      required this.orgLogo});

  factory ServiceHistoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceHistoryModel(
        orgName: json['orgName'] ?? '',
        designation: json['designation'] ?? '',
        orgState: json['orgState'] ?? '',
        orgDistrict: json['orgDistrict'] ?? '',
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
        description: json['description'] ?? '',
        currentlyWorking: json['currentlyWorking'] ?? '',
        uuid: json['uuid'] ?? '',
        orgLogo: json['orgLogo'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'orgName': orgName,
      'designation': designation,
      'orgState': orgState,
      'orgDistrict': orgDistrict,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'currentlyWorking': currentlyWorking,
      'uuid': uuid,
      'orgLogo': orgLogo
    };
  }
}
