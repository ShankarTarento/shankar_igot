import 'dart:convert';

class Event {
  final String identifier;
  final String? name;
  final String? description;
  final String? eventIcon;
  final String? source;
  final dynamic creatorDetails;
  final dynamic startDate;
  final dynamic startTime;
  final dynamic endTime;
  final dynamic endDate;
  final String? status;
  final String? instructions;
  final List<dynamic>? createdFor;
  final String? objectType;
  final String? eventType;
  final String? contentType;
  final String? category;
  final dynamic raw;
  final String? lastUpdatedOn;
  final String? createdOn;
  final String? duration;
  double completionPercentage;
  List<dynamic> issuedCertificates;
  List<dynamic> certificates;

  Event(
      {required this.identifier,
      this.name,
      this.description,
      this.eventIcon,
      this.source,
      this.creatorDetails,
      this.startDate,
      this.startTime,
      this.endTime,
      this.endDate,
      this.status,
      this.instructions,
      this.createdFor,
      this.objectType,
      this.eventType,
      this.contentType,
      this.category,
      this.raw,
      this.lastUpdatedOn,
      this.createdOn,
      this.duration,
      required this.completionPercentage,
      required this.issuedCertificates,
      required this.certificates});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        identifier: json['identifier'] ?? '',
        name: json['name'],
        description: json['description'],
        eventIcon: json['appIcon'],
        source: json['sourceName'] ?? "",
        creatorDetails:
            json['creatorDetails'] != null && json['creatorDetails'] != ''
                ? json['creatorDetails'] is String &&
                        json['creatorDetails'].trim().startsWith('{')
                    ? jsonDecode(json['creatorDetails'])
                    : json['creatorDetails']
                : [],
        startDate: json['startDate'],
        startTime: json['startTime'],
        endDate: json['endDate'],
        endTime: json['endTime'],
        status: json['status'],
        instructions: json['instructions'],
        createdFor: json['createdFor'] != null ? json['createdFor'] : [],
        objectType: json['objectType'],
        eventType: json['resourceType'] != null ? json['resourceType'] : '',
        contentType: json['resourceType'] != null ? json['resourceType'] : '',
        category: json['category'] != null ? json['resourceType'] : '',
        raw: json,
        completionPercentage: json['completionPercentage'] ?? 0,
        issuedCertificates: json['issuedCertificates'] != null
            ? List<dynamic>.from(json['issuedCertificates'].map((x) => x))
            : [],
        certificates: json['certificates'] != null
            ? List<dynamic>.from(json['certificates'].map((x) => x))
            : [],
        lastUpdatedOn: json['lastUpdatedOn'],
        createdOn: json['createdOn'],
        duration: json['duration'] != null &&
                (json['duration'] != 0 || json['duration'] != '0')
            ? json['duration'].toString()
            : null);
  }
}
