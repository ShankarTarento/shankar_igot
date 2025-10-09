import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_strip/events_strip.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/my_events/my_events.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventSection extends StatefulWidget {
  final List eventsDetails;
  const EventSection({super.key, required this.eventsDetails});

  @override
  State<EventSection> createState() => _EventSectionState();
}

class _EventSectionState extends State<EventSection> {
  EventRepository eventRepository = EventRepository();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [...getStripWidgets()],
    );
  }

  List<Widget> getStripWidgets() {
    List<Widget> stripWidget = [];

    try {
      if (widget.eventsDetails.isNotEmpty) {
        for (var item in widget.eventsDetails) {
          if (item['strips'] != null &&
              item['strips'].isNotEmpty &&
              item['enabled']) {
            if (item['strips'][0].containsKey('key')) {
              String key = item['strips'][0]['key'];
              MultiLingualText? mTitle = item['strips'] != null &&
                      item['strips'].isNotEmpty &&
                      item['strips'][0]['mTitle'] != null
                  ? MultiLingualText.fromJson(item['strips'][0]['mTitle'])
                  : null;
              String? title = mTitle != null ? mTitle.getText(context) : null;
              if (key == EventConstants.myEvents) {
                stripWidget.addAll([
                  MyEvents(
                    data: item['strips'][0],
                  ),
                  SizedBox(
                    height: 20.w,
                  ),
                ]);
              }
              if (key == EventConstants.trendingEvents) {
                stripWidget.add(
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0).r,
                    child: EventsStrip(
                        telemetrySubtype: TelemetrySubType.trendingEvents,
                        title: title ?? AppLocalizations.of(context)!.mEvents,
                        eventsFuture: eventRepository.getTrendingEvents()),
                  ),
                );
              }
              if (key == EventConstants.featuredEvents) {
                stripWidget.add(
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0).r,
                    child: EventsStrip(
                      telemetrySubtype: TelemetrySubType.featuredEvents,
                      title: title ?? AppLocalizations.of(context)!.mEvents,
                      eventsFuture: eventRepository.getFeaturedEvents(),
                    ),
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error in getStripWidgets: $e");
    }

    return stripWidget;
  }
}
