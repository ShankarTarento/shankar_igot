import '../../../../models/_models/event_model.dart';

class EventEnrollmentListModel {
  int? dateTime;
  int? lastReadContentStatus;
  String contentId;
  bool active;
  String batchId;
  String userId;
  double completionPercentage;
  List<dynamic> issuedCertificates;
  List<dynamic> certificates;
  int? lastContentAccessTime;
  int? completedOn;
  double progress;
  List<BatchDetail> batchDetails;
  String? lastReadContentId;
  Event event;
  int status;

  EventEnrollmentListModel({
    this.dateTime,
    this.lastReadContentStatus,
    required this.contentId,
    required this.active,
    required this.batchId,
    required this.userId,
    required this.completionPercentage,
    required this.issuedCertificates,
    required this.certificates,
    this.lastContentAccessTime,
    this.completedOn,
    required this.progress,
    required this.batchDetails,
    this.lastReadContentId,
    required this.event,
    required this.status,
  });

  factory EventEnrollmentListModel.fromJson(Map<String, dynamic> json) =>
      EventEnrollmentListModel(
        dateTime: json['dateTime'],
        lastReadContentStatus: json['lastReadContentStatus'],
        contentId: json['contentId'],
        active: json['active'],
        batchId: json['batchId'],
        userId: json['userId'],
        completionPercentage: json['completionPercentage'] ?? 0,
        issuedCertificates: json['issuedCertificates'] != null
            ? List<dynamic>.from(json['issuedCertificates'].map((x) => x))
            : [],
        certificates: json['certificates'] != null
            ? List<dynamic>.from(json['certificates'].map((x) => x))
            : [],
        lastContentAccessTime: json['lastContentAccessTime'],
        completedOn: json['completedOn'],
        progress: json['progress'] != null
            ? double.parse(json['progress'].toString())
            : 0,
        batchDetails: List<BatchDetail>.from(
            json['batchDetails'].map((x) => BatchDetail.fromJson(x))),
        lastReadContentId: json['lastReadContentId'],
        event: Event.fromJson(json['event']),
        status: json['status'] ?? 0,
      );
}

class BatchDetail {
  String eventid;
  int endDate;
  String batchId;
  String batchAttributes;
  List<dynamic> mentors;
  String name;
  String enrollmentType;
  int enrollmentEndDate;
  int startDate;
  int status;

  BatchDetail({
    required this.eventid,
    required this.endDate,
    required this.batchId,
    required this.batchAttributes,
    required this.mentors,
    required this.name,
    required this.enrollmentType,
    required this.enrollmentEndDate,
    required this.startDate,
    required this.status,
  });

  factory BatchDetail.fromJson(Map<String, dynamic> json) => BatchDetail(
        eventid: json['eventid'],
        endDate: json['endDate'],
        batchId: json['batchId'],
        batchAttributes: json['batchAttributes'],
        mentors: json['mentors'] != null
            ? List<dynamic>.from(json['mentors'].map((x) => x))
            : [],
        name: json['name'],
        enrollmentType: json['enrollmentType'],
        enrollmentEndDate: json['enrollmentEndDate'],
        startDate: json['startDate'],
        status: json['status'] ?? 0,
      );
}
