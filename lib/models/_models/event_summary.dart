class EventsSummary {
  UserEventEnrolmentInfo userEventEnrolmentInfo;

  EventsSummary({
    required this.userEventEnrolmentInfo,
  });

  factory EventsSummary.fromJson(Map<String, dynamic> json) => EventsSummary(
        userEventEnrolmentInfo:
            UserEventEnrolmentInfo.fromJson(json["userEventEnrolmentInfo"]),
      );

  Map<String, dynamic> toJson() => {
        "userEventEnrolmentInfo": userEventEnrolmentInfo.toJson(),
      };
}

class UserEventEnrolmentInfo {
  int eventsEnrolled;
  int timeSpentOnEventsInSec;
  int eventsAttended; // events completed by user

  UserEventEnrolmentInfo({
    required this.eventsEnrolled,
    required this.timeSpentOnEventsInSec,
    required this.eventsAttended,
  });

  UserEventEnrolmentInfo.defaultValue()
      : eventsEnrolled = 0,
        timeSpentOnEventsInSec = 0,
        eventsAttended = 0;

  factory UserEventEnrolmentInfo.fromJson(Map<String, dynamic> json) =>
      UserEventEnrolmentInfo(
        eventsEnrolled: json["eventsEnrolled"] ?? 0,
        timeSpentOnEventsInSec: json["hoursSpentOnEvents"] ?? 0,
        eventsAttended: json["eventsAttended"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "eventsEnrolled": eventsEnrolled,
        "hoursSpentOnEvents": timeSpentOnEventsInSec,
        "eventsAttended": eventsAttended,
      };
}
