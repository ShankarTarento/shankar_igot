class CourseStatus {
  final double completionPercentage;
  final String? completionOn;
  final double progress;
  final String courseId;
  final int status;
  final List? issuedCertificates;
  final raw;

  CourseStatus(
      {required this.completionPercentage,
      this.completionOn,
      required this.progress,
      required this.courseId,
      required this.status,
      this.issuedCertificates,
      this.raw});

  factory CourseStatus.fromJson(Map<String, dynamic> json) {
    return CourseStatus(
        courseId: json['courseid'] ?? '',
        completionPercentage:json['completionpercentage']!= null?
            double.parse(json['completionpercentage'].toString()):0,
        completionOn: json['completedon'],
        progress: json['progress']!= null ? double.parse(json['progress'].toString()): 0,
        status: json['status']??0,
        issuedCertificates: json['issued_certificates'],
        raw: json);
  }
}
