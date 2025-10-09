import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/events_hub.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/todays_events.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/widgets/todays_event_skeleton.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeLiveEventsStrip extends StatefulWidget {
  const HomeLiveEventsStrip({super.key});

  @override
  State<HomeLiveEventsStrip> createState() => _HomeLiveEventsStripState();
}

class _HomeLiveEventsStripState extends State<HomeLiveEventsStrip> {
  Future<List<Event>> _getLiveEvents() async {
    String currentDate = DateTimeHelper.getDateTimeInFormat(DateTime.now().toString(),
        desiredDateFormat: IntentType.dateFormat4);

    final events = await Provider.of<EventRepository>(context, listen: false)
        .getAllEvents(startDate: currentDate.toString());
    events.sort((a, b) {
      String startA = '${a.startDate} ${formatTime(a.startTime)}';
      String startB = '${b.startDate} ${formatTime(b.startTime)}';

      DateTime dateA = DateTime.parse(startA);
      DateTime dateB = DateTime.parse(startB);

      return dateA.compareTo(dateB);
    });
    List<Event> liveEvents = events
        .where((event) => isEventCompleted(event: event) == EnglishLang.started)
        .toList();
    return liveEvents;
  }

  String isEventCompleted({required Event event}) {
    int timestampNow = DateTime.now().millisecondsSinceEpoch;
    String start = event.startDate + ' ' + formatTime(event.startTime);
    DateTime startDate = DateTime.parse(start);
    int timestampStartEvent = startDate.microsecondsSinceEpoch;
    double eventStartTime = timestampStartEvent / 1000;
    String expiry = event.endDate + ' ' + formatTime(event.endTime);
    DateTime expireDate = DateTime.parse(expiry);
    int timestampExpireEvent = expireDate.microsecondsSinceEpoch;
    double eventExpireTime = timestampExpireEvent / 1000;
    if (timestampNow > eventExpireTime) {
      return EnglishLang.completed;
    } else if (timestampNow <= eventExpireTime &&
        timestampNow >= eventStartTime) {
      return EnglishLang.started;
    } else
      return EnglishLang.notStarted;
  }

  String formatTime(time) {
    try {
      return time.substring(0, 5);
    } catch (e) {
      debugPrint('formatTime Error: $e');
      return '';
    }
  }

  late Future<List<Event>> _liveEvents;
  @override
  void initState() {
    super.initState();

    _liveEvents = _getLiveEvents();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: _liveEvents,
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: EdgeInsets.only(top: 16).r,
            height: 160.w,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, index) => TodaysEventSkeleton()),
          );
        }
        return TodaysEvents(
          events: snapshot.data ?? [],
          title: AppLocalizations.of(context)!.mEventsLabelLiveEvent,
          showAllCallBack: () {
            Navigator.push(context, FadeRoute(page: EventsHub()));
          },
        );
      },
    );
  }
}
