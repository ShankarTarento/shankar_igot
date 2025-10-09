class EventEnrollModel {
  final List<EventEnrollData>? events;

  EventEnrollModel({this.events});

  factory EventEnrollModel.fromJson(Map<String, dynamic> json) {
    return EventEnrollModel(
      events: (json['events'] as List)
          .map((eventJson) => EventEnrollData.fromJson(eventJson))
          .toList(),
    );
  }
}

class EventEnrollData {
  final int? dateTime;
  final String? eventId;
  final int? lastReadContentStatus;
  final int? enrolledDate;
  final String? addedBy;
  final bool? active;
  final String? batchId;
  final String? userId;
  final double? completionPercentage;
  final List<dynamic>? issuedCertificates;
  final List<dynamic>? certificates;
  final int? completedOn;
  final int? progress;
  final int? status;

  EventEnrollData({
    this.dateTime,
    this.eventId,
    this.lastReadContentStatus,
    this.enrolledDate,
    this.addedBy,
    this.active,
    this.batchId,
    this.userId,
    this.completionPercentage,
    this.issuedCertificates,
    this.certificates,
    this.completedOn,
    this.progress,
    this.status,
  });

  factory EventEnrollData.fromJson(Map<String, dynamic> json) {
    return EventEnrollData(
      dateTime: json['dateTime'],
      eventId: json['eventid'],
      lastReadContentStatus: json['lastReadContentStatus'],
      enrolledDate: json['enrolledDate'],
      addedBy: json['addedBy'],
      active: json['active'],
      batchId: json['batchId'],
      userId: json['userId'],
      completionPercentage:  json['completionPercentage'] != null
          ? (json['completionPercentage'] is double
          ? json['completionPercentage']
          : (json['completionPercentage'] is int ? json['duration'].toDouble() : null))
          : null,
      issuedCertificates: json['issuedCertificates'] ?? [],
      certificates: json['certificates'] ?? [],
      completedOn: json['completedOn'],
      progress: json['progress'],
      status: json['status'],
    );
  }
}
