import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_hub_insights/widget/event_schedule/widgets/events_calendar.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_hub_insights/widget/event_schedule/widgets/events_schedule_card.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/my_events/repository/my_events_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class EventSchedule extends StatefulWidget {
  final String title;

  const EventSchedule({super.key, required this.title});

  @override
  State<EventSchedule> createState() => _EventScheduleState();
}

class _EventScheduleState extends State<EventSchedule> {
  List<Event> selectedDaysEvents = [];
  DateTime selectedDate = DateTime.now();

  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = fetchSelectedMonthEvents();
  }

  DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  Future<List<Event>> fetchSelectedMonthEvents() async {
    try {
      String currentDate = selectedDate.toString();
      DateTime now = DateTime.parse(currentDate);

      DateTime firstDayOfMonth = getFirstDayOfMonth(now);
      DateTime lastDayOfMonth = getLastDayOfMonth(now);

      String eventStartDate = DateTimeHelper.convertDateFormat(
        firstDayOfMonth.toString(),
        inputFormat: IntentType.dateTimeFormat,
        desiredFormat: IntentType.dateFormat4,
      );

      String eventEndDate = DateTimeHelper.convertDateFormat(
        lastDayOfMonth.toString(),
        inputFormat: IntentType.dateTimeFormat,
        desiredFormat: IntentType.dateFormat4,
      );
      List<Event> events = await MyEventsRepository().getCalendarEnrolledEvents(
          eventStartDate: eventStartDate, eventEndDate: eventEndDate);
      return events;
    } catch (e) {
      debugPrint('Error fetching events: $e');
      return [];
    }
  }

  // Function to update events when the date changes
  void updateEventsForNewDate(DateTime newDate) async {
    if (selectedDate.month != newDate.month) {
      selectedDate = newDate;

      _eventsFuture = fetchSelectedMonthEvents();
    } else {
      selectedDate = newDate;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGradientOne,
      appBar: AppBar(
        elevation: 0,
        title: TitleWidget(title: widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0).r,
            child: FutureBuilder<List<Event>>(
                future: _eventsFuture,
                builder: (context, snapshot) {
                  selectedDaysEvents = getEventsForDay(
                      day: selectedDate, events: snapshot.data ?? []);
                  return Column(
                    children: [
                      EventsCalendar(
                        selectedDay: selectedDate,
                        events: snapshot.data ?? [],
                        selectedDate: (date) {
                          updateEventsForNewDate(date);
                        },
                      ),
                      SizedBox(height: 24.w),
                      Container(
                        width: 1.sw,
                        decoration: BoxDecoration(
                            color: AppColors.appBarBackground,
                            borderRadius: BorderRadius.circular(8).r),
                        padding: const EdgeInsets.all(16).r,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleWidget(
                                title: selectedDate.year ==
                                            DateTime.now().year &&
                                        selectedDate.month ==
                                            DateTime.now().month &&
                                        selectedDate.day == DateTime.now().day
                                    ? AppLocalizations.of(context)!.mStaticToday
                                    : DateTimeHelper.convertDateFormat(
                                        selectedDate.toString(),
                                        desiredFormat: IntentType.dateFormat2,
                                        inputFormat: IntentType.dateTimeFormat,
                                      ),
                              ),
                              SizedBox(
                                height: 16.w,
                              ),
                              FutureBuilder(
                                  future: Future.delayed(
                                      Duration(milliseconds: 500)),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return ContainerSkeleton(
                                        width: 1.sw,
                                        height: 120.w,
                                      );
                                    }
                                    return selectedDaysEvents.isNotEmpty
                                        ? Column(
                                            children: List.generate(
                                            selectedDaysEvents.length,
                                            (index) => InkWell(
                                              onTap: () {
                                                _generateInteractTelemetryData(
                                                    clickId: TelemetryIdentifier
                                                        .cardContent,
                                                    subType: TelemetrySubType
                                                        .calendarSection,
                                                    selectedDaysEvents[index]
                                                        .identifier);
                                                Navigator.push(
                                                    context,
                                                    FadeRoute(
                                                        page:
                                                            EventsDetailsScreenv2(
                                                      eventId:
                                                          selectedDaysEvents[
                                                                  index]
                                                              .identifier,
                                                    )));
                                              },
                                              child: EventsScheduleCard(
                                                event:
                                                    selectedDaysEvents[index],
                                                showDivider: index ==
                                                        selectedDaysEvents
                                                                .length -
                                                            1
                                                    ? false
                                                    : true,
                                              ),
                                            ),
                                          ))
                                        : Center(
                                            child: Padding(
                                            padding:
                                                const EdgeInsets.all(24.0).r,
                                            child: Text(
                                                AppLocalizations.of(context)!
                                                    .mNoEventsFound),
                                          ));
                                  })
                            ]),
                      ),
                      SizedBox(
                        height: 50.w,
                      )
                    ],
                  );
                })),
      ),
    );
  }

  List<Event> getEventsForDay({
    required DateTime day,
    required List<Event> events,
  }) {
    final normalizedDay = DateTime(day.year, day.month, day.day);

    final List<Event> liveEvents = [];
    final List<Event> nonLiveEvents = [];

    for (final event in events) {
      try {
        final startDate = DateTime.parse(event.startDate);

        final normalizedStartDate =
            DateTime(startDate.year, startDate.month, startDate.day);
        if (normalizedStartDate != normalizedDay) {
          continue;
        }

        if (Helper.isEventLive(
          startDate: event.startDate,
          endDate: event.endDate,
          startTime: event.startTime,
          endTime: event.endTime,
        )) {
          liveEvents.add(event);
        } else {
          nonLiveEvents.add(event);
        }
      } catch (e) {
        debugPrint('Error processing event: ${event.startDate}, Error: $e');
        continue;
      }
    }

    // Sort both lists
    Helper.sortList(listOfEvents: liveEvents, ascending: true);
    Helper.sortList(listOfEvents: nonLiveEvents, ascending: true);

    // Combine live events first, then non-live events
    return [...liveEvents, ...nonLiveEvents];
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '',
      String? primaryCategory,
      bool isObjectNull = false,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.eventHomePageId,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.events,
        objectType: primaryCategory ?? (isObjectNull ? null : subType),
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
