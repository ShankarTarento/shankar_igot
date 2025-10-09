class MicroSitesTrainingCalenderDataModel {
  int? count;
  List<EventDataModel>? Event;

  MicroSitesTrainingCalenderDataModel({this.count, this.Event});

  MicroSitesTrainingCalenderDataModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['Event'] != null) {
      Event = <EventDataModel>[];
      json['Event'].forEach((v) {
        Event!.add(EventDataModel.fromJson(v));
      });
    }
  }
}

class EventDataModel {
  String? venue;
  String? code;
  String? endDate;
  String? channel;
  String? description;
  String? mimeType;
  String? locale;
  String? createdOn;
  String? objectType;
  String? registrationEndDate;
  String? lastUpdatedOn;
  String? startTime;
  String? contentType;
  String? identifier;
  String? visibility;
  String? eventType;
  String? registrationLink;
  String? createdBy;
  String? name;
  String? location;
  String? sourceName;
  String? endTime;
  String? category;
  String? startDate;
  String? resourceType;
  String? status;

  EventDataModel({
    this.venue,
    this.code,
    this.endDate,
    this.channel,
    this.description,
    this.mimeType,
    this.locale,
    this.createdOn,
    this.objectType,
    this.registrationEndDate,
    this.lastUpdatedOn,
    this.startTime,
    this.contentType,
    this.identifier,
    this.visibility,
    this.eventType,
    this.registrationLink,
    this.createdBy,
    this.name,
    this.location,
    this.sourceName,
    this.endTime,
    this.category,
    this.startDate,
    this.resourceType,
    this.status,
  });

  factory EventDataModel.fromJson(Map<String, dynamic> json) {
    return EventDataModel(
      venue: json['venue'],
      code: json['code'] as String,
      endDate: json['endDate'] as String,
      channel: json['channel'] as String,
      description: json['description'] as String,
      mimeType: json['mimeType'] as String,
      locale: json['locale'] as String,
      createdOn: json['createdOn'] as String,
      objectType: json['objectType'] as String,
      registrationEndDate: json['registrationEndDate'] as String,
      lastUpdatedOn: json['lastUpdatedOn'] as String,
      startTime: json['startTime'] as String,
      contentType: json['contentType'] as String,
      identifier: json['identifier'] as String,
      visibility: json['visibility'] as String,
      eventType: json['eventType'] as String,
      registrationLink: json['registrationLink'] as String,
      createdBy: json['createdBy'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      sourceName: json['sourceName'] as String,
      endTime: json['endTime'] as String,
      category: json['category'] as String,
      startDate: json['startDate'] as String,
      resourceType: json['resourceType'] as String,
      status: json['status'] as String,
    );
  }
}

class MicroSitesTrainingCalenderItems {
  String? dayOfMonth;
  String? dateOfMonth;
  String? month;
  String? formattedDateOfMonth;
  List<EventDataModel>? events;

  MicroSitesTrainingCalenderItems(
      {this.dayOfMonth,
      this.dateOfMonth,
      this.month,
      this.formattedDateOfMonth,
      this.events});

  MicroSitesTrainingCalenderItems.fromJson(Map<String, dynamic> json) {
    dayOfMonth = json['dayOfMonth'];
    dateOfMonth = json['dateOfMonth'];
    month = json['month'];
    formattedDateOfMonth = json['formattedDateOfMonth'];
    if (json['events'] != null) {
      events = <EventDataModel>[];
      json['events'].forEach((v) {
        events!.add(EventDataModel.fromJson(v));
      });
    }
  }
}

class MicroSitesTrainingCalenderMonthData {
  String? monthName;
  String? yearOfMonth;
  String? startDate;
  String? endDate;

  MicroSitesTrainingCalenderMonthData({
    this.monthName,
    this.yearOfMonth,
    this.startDate,
    this.endDate,
  });

  MicroSitesTrainingCalenderMonthData.fromJson(Map<String, dynamic> json) {
    monthName = json['monthName'];
    yearOfMonth = json['yearOfMonth'];
    startDate = json['startDate'];
    endDate = json['endDate'];
  }
}
