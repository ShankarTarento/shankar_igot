import '../../util/date_time_helper.dart';

class Batch {
  final String id;
  final String batchId;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final String enrollmentEndDate;
  final int? status;
  BatchAttribute? batchAttributes;
  final String enrollmentType;
  final List<dynamic> createdFor;
  final String? createdBy;
  final String? startTime;
  final String? endTime;

  Batch(
      {required this.id,
      required this.batchId,
      required this.name,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.enrollmentEndDate,
      required this.status,
      required this.createdFor,
      required this.enrollmentType,
      this.startTime,
      this.endTime,
      this.batchAttributes,
      this.createdBy});

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
        createdFor: json['createdFor'] ?? [],
        id: json['id'] ?? '',
        batchId: json['batchId'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        startDate: json['startDate'] != null
            ? json['startDate'] is int
                ? DateTimeHelper.getDateTimeFormatYYYYMMDD(
                    DateTime.fromMillisecondsSinceEpoch(json['startDate'])
                        .toIso8601String())
                : json['startDate']
            : '',
        endDate: json['endDate'] != null
            ? json['endDate'] is int
                ? DateTimeHelper.getDateTimeFormatYYYYMMDD(
                    DateTime.fromMillisecondsSinceEpoch(json['endDate'])
                        .toIso8601String())
                : json['endDate']
            : '',
        enrollmentEndDate: json['enrollmentEndDate'] != null
            ? json['enrollmentEndDate'] is int
                ? DateTimeHelper.getDateTimeFormatYYYYMMDD(
                    DateTime.fromMillisecondsSinceEpoch(
                            json['enrollmentEndDate'])
                        .toIso8601String())
                : json['enrollmentEndDate']
            : '',
        status: json['status'],
        batchAttributes: json['batchAttributes'] == null
            ? BatchAttribute.fromJson({})
            : BatchAttribute.fromJson(json['batchAttributes']),
        enrollmentType: json['enrollmentType'] ?? '',
        createdBy: json['createdBy'],
        startTime: json['startTime'],
        endTime: json['endTime']);
  }
}

class BatchAttribute {
  final bool? enableQR;
  final String latlong;
  final String? batchLocationDetails;
  final String? currentBatchSize;
  final List<SessionDetailV2> sessionDetailsV2;
  String courseId;
  final Map raw;

  BatchAttribute(
      {this.enableQR,
      required this.latlong,
      this.batchLocationDetails,
      this.currentBatchSize,
      required this.raw,
      required this.sessionDetailsV2,
      required this.courseId});

  factory BatchAttribute.fromJson(Map<String, dynamic> json) {
    bool stringToBool(String str) {
      return str.toLowerCase() == 'true';
    }

    return BatchAttribute(
        enableQR: json['enableQR'] != null
            ? json['enableQR'].runtimeType == String
                ? (stringToBool(json['enableQR']))
                : json['enableQR']
            : null,
        latlong: json['latlong'] ?? '',
        batchLocationDetails: json['batchLocationDetails'],
        currentBatchSize: json['currentBatchSize'],
        courseId: json['courseId'] != null ? json['courseId'] : '',
        sessionDetailsV2: json['sessionDetails_v2'] == null
            ? []
            : List<SessionDetailV2>.from(json['sessionDetails_v2']
                .map((x) => SessionDetailV2.fromJson(x))),
        raw: json);
  }
}

class SessionDetailV2 {
  final List<AttachLink> attachLinks;
  final List<String> facilatorIDs;
  final List<dynamic> sessionHandouts;
  final List<FacilatorDetail> facilatorDetails;
  final String description;
  final String sessionType;
  final String startTime;
  final String sessionId;
  final String endTime;
  final String title;
  final String sessionDuration;
  final String startDate;
  bool sessionAttendanceStatus;
  String? lastCompletedTime;

  SessionDetailV2(
      {required this.attachLinks,
      required this.facilatorIDs,
      required this.sessionHandouts,
      required this.facilatorDetails,
      required this.description,
      required this.sessionType,
      required this.startTime,
      required this.sessionId,
      required this.endTime,
      required this.title,
      required this.sessionDuration,
      required this.startDate,
      required this.sessionAttendanceStatus,
      this.lastCompletedTime});

  factory SessionDetailV2.fromJson(Map<String, dynamic> json) =>
      SessionDetailV2(
          attachLinks: List<AttachLink>.from(
              json['attachLinks'].map((x) => AttachLink.fromJson(x))),
          facilatorIDs: List<String>.from(json['facilatorIDs'].map((x) => x)),
          sessionHandouts:
              List<dynamic>.from(json['sessionHandouts'].map((x) => x)),
          facilatorDetails: List<FacilatorDetail>.from(
              json['facilatorDetails'].map((x) => FacilatorDetail.fromJson(x))),
          description: json['description'],
          sessionType: json['sessionType'],
          startTime: json['startTime'],
          sessionId: json['sessionId'],
          endTime: json['endTime'],
          title: json['title'],
          sessionDuration: json['sessionDuration'],
          startDate: json['startDate'],
          sessionAttendanceStatus: json['sessionAttendanceStatus'] != null
              ? json['sessionAttendanceStatus']
              : false,
          lastCompletedTime: json['lastCompletedTime']);
}

class AttachLink {
  final String? title;
  final String? url;
  final String? logo;

  AttachLink({
    required this.title,
    required this.url,
    this.logo,
  });

  factory AttachLink.fromJson(Map<String, dynamic> json) => AttachLink(
        title: json['title'],
        url: json['url'],
        logo: json['logo'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'logo': logo,
      };
}

class FacilatorDetail {
  final String? name;
  final String? id;
  final String? email;

  FacilatorDetail({
    required this.name,
    required this.id,
    required this.email,
  });

  factory FacilatorDetail.fromJson(Map<String, dynamic> json) =>
      FacilatorDetail(
        name: json['name'],
        id: json['id'],
        email: json['email'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'email': email,
      };
}

class BatchCountStatus {
  String? currentStatus;
  int? statusCount;
  BatchCountStatus({required this.currentStatus, required this.statusCount});
  factory BatchCountStatus.fromJson(Map<String, dynamic> json) {
    return BatchCountStatus(
      currentStatus: json['currentStatus'],
      statusCount: json['statusCount'],
    );
  }
}
