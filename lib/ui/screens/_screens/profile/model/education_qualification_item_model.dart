

class EducationalQualificationItem {
  final String degree;
  final String fieldOfStudy;
  final String institutionName;
  final String startYear;
  final String endYear;
  final String uuid;

  EducationalQualificationItem({
    required this.degree,
    required this.fieldOfStudy,
    required this.institutionName,
    required this.startYear,
    required this.endYear,
    required this.uuid,
  });

  factory EducationalQualificationItem.fromJson(Map<String, dynamic> json) {
    return EducationalQualificationItem(
      degree: json['degree'] ?? '',
      fieldOfStudy: json['fieldOfStudy'] ?? '',
      institutionName: json['institutionName'] ?? '',
      startYear: json['startYear'] ?? '',
      endYear: json['endYear'] ?? '',
      uuid: json['uuid'] ?? '',
    );
  }
}