import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/events_insights_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_hub_insights/event_insights_strip.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_sectiion/event_section.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/view_all_event.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/view_all_event_with_filter/widgets/events_search_bar.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_banner/events_banner.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_hub_skeleton.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';
import 'widgets/browse_events/browse_events_strip.dart';

class EventsHubV2 extends StatefulWidget {
  const EventsHubV2({super.key});

  @override
  State<EventsHubV2> createState() => _EventsHubV2State();
}

class _EventsHubV2State extends State<EventsHubV2> {
  late Future<Map<String, dynamic>?> eventsConfigFuture;

  @override
  void initState() {
    eventsConfigFuture = Future.value(
        Provider.of<EventRepository>(context, listen: false).evenConfigData);
    _generateTelemetryData();
    super.initState();
  }

  final TelemetryRepository _telemetryRepository = TelemetryRepository();

  void _generateTelemetryData() async {
    final eventData = _telemetryRepository.getImpressionTelemetryEvent(
      pageIdentifier: TelemetryPageIdentifier.eventHomePageId,
      telemetryType: TelemetryType.page,
      pageUri: TelemetryPageIdentifier.eventHomePageUri,
      env: TelemetryEnv.events,
    );
    await _telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: eventsConfigFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return EventsHubSkeleton();
          }

          if (snapshot.data == null) return SizedBox();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventsBanner(
                  eventsConfigFuture: snapshot.data,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0).r,
                  child: EventInsightsStrip(
                    eventsConfig: snapshot.data!,
                  ),
                ),
                ...getBody(snapshot.data!),
                SizedBox(
                  height: 200.w,
                ),
              ],
            ),
          );
        });
  }

  List<Widget> getBody(Map eventsConfig) {
    List<Widget> eventBody = [];

    try {
      if (eventsConfig['version2'] != null &&
          eventsConfig['version2']['sectionList'] != null &&
          eventsConfig['version2']['sectionList'].isNotEmpty &&
          eventsConfig['version2']['sectionList'][1] != null &&
          eventsConfig['version2']['sectionList'][1]['data'] != null &&
          eventsConfig['version2']['sectionList'][1]['data']['rightSection'] !=
              null &&
          eventsConfig['version2']['sectionList'][1]['data']['rightSection']
                  ['data'] !=
              null) {
        Map rightConfig = eventsConfig['version2']['sectionList'][1]['data']
            ['rightSection']['data'];
        rightConfig.forEach(
          (key, value) {
            if (key == EventConstants.search) {
              eventBody.add(
                Padding(
                  padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0)
                      .r,
                  child: EventsSearchBar(
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty)
                        Navigator.push(
                            context,
                            FadeRoute(
                                page: ViewAllEvent(
                              query: value,
                            )));
                    },
                  ),
                ),
              );
            }
            if (key == EventConstants.browse) {
              List<EventInsightsModel> browseEventCardData = [];

              try {
                if (value['data'] != null && value['data'] is List) {
                  browseEventCardData = List<EventInsightsModel>.from(
                    value['data'].map((e) => EventInsightsModel.fromJson(e)),
                  );
                }
              } catch (e) {}
              if (browseEventCardData.isNotEmpty)
                eventBody.add(BrowseEventsStrip(
                  browseEventCardData: browseEventCardData,
                ));
            }
            if (key == EventConstants.eventStrips) {
              eventBody.add(EventSection(
                eventsDetails: value,
              ));
            }
          },
        );
      }
    } catch (e) {
      debugPrint("Error in getBody: $e");
    }

    return eventBody;
  }
}
