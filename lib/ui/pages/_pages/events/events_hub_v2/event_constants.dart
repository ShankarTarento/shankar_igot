import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/_models/events_filter_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventConstants {
  static const String myEvents = 'myEvents';
  static const String recommendedEvents = 'recommendedEvents';
  static const String trendingEvents = 'trendingEvents';
  static const String featuredEvents = 'featuredEvents';
  static const String eventStrips = 'eventStrips';
  static const String browse = 'browse';
  static const String search = 'search';
  static const String myEngagements = "myEngagements";
  static const String eventsCalendar = "eventsCalendar";
}

class EventFilter {
  static const String karmayogiSaptah = "Karmayogi Saptah";
  static const String karmayogiTalks = "Karmayogi Talks";
  static const String rajyaKarmayogiSaptha = "Rajya Karmayogi Saptah";
  static const String all = "all";

  static const String webinar = "Webinar";
  static const String upcoming = "Upcoming";
  static const String live = "Live";
  static const String past = "Past";
  static const String today = "Today";
  static const String tomorrow = "Tomorrow";
  static const String lessThan1Hr = "Less than 1 hr";
  static const String oneHr2Hr = "1 hr-2 hr";
  static const String twoHr3Hr = "2 hr-3 hr";

  static List<EventFilterModel> getEventDurationFilter(context) => [
        EventFilterModel(
          title: MultiLingualFilterModel(text: "Less than 1 hr", id: ""),
        ),
        EventFilterModel(
          title: MultiLingualFilterModel(text: "1 hr-2 hr", id: "1 hr-2 hr"),
        ),
        EventFilterModel(
            title: MultiLingualFilterModel(text: "2 hr-3 hr", id: "2 hr-3 hr")),
      ];
  static List<EventFilterModel> getEventTypeFilter(BuildContext context) {
    return [
      EventFilterModel(
        title: MultiLingualFilterModel(
            id: karmayogiSaptah,
            text: AppLocalizations.of(context)!.mEventsTabKarmayogiSaptah),
      ),
      EventFilterModel(
        title: MultiLingualFilterModel(
            id: karmayogiTalks,
            text: AppLocalizations.of(context)!.mEventsTabKarmayogiTalks),
      ),
      EventFilterModel(
        title: MultiLingualFilterModel(
            id: webinar,
            text: AppLocalizations.of(context)!.mEventsTypoWebinar),
      ),
    ];
  }

  static List<EventFilterModel> getEventStatusFilter(BuildContext context) {
    return [
      EventFilterModel(
        title: MultiLingualFilterModel(
            id: "Upcoming",
            text: AppLocalizations.of(context)!.mStaticUpcoming),
      ),
      EventFilterModel(
        title: MultiLingualFilterModel(
            id: "Live", text: AppLocalizations.of(context)!.mlive),
      ),
      EventFilterModel(
        title: MultiLingualFilterModel(
            id: "Past", text: AppLocalizations.of(context)!.mStaticPast),
      ),
    ];
  }

  static List<EventFilterModel> getEventDateTimeFilter(BuildContext context) {
    return [
      EventFilterModel(
        title: MultiLingualFilterModel(
            id: today, text: AppLocalizations.of(context)!.mStaticToday),
      ),
      EventFilterModel(
        title: MultiLingualFilterModel(
            id: tomorrow, text: AppLocalizations.of(context)!.mTomorrow),
      ),
    ];
  }
}
