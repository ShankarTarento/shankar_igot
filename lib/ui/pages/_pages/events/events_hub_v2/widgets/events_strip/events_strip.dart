import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/see_all_events.dart/see_all_event.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/events_card.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class EventsStrip extends StatelessWidget {
  final String title;
  final Future<List<Event>> eventsFuture;
  final String telemetrySubtype;

  const EventsStrip(
      {super.key,
      required this.title,
      required this.eventsFuture,
      required this.telemetrySubtype});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
        future: eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.data!.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0).r,
                  child: TitleWidget(
                    title: title,
                    showAllCallBack: () {
                      Navigator.push(
                          context,
                          FadeRoute(
                              page: SeeAllEvents(
                            title: title,
                            events: snapshot.data!,
                          )));
                    },
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      snapshot.data!.length > 12 ? 12 : snapshot.data!.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(left: 16.0).r,
                        child: InkWell(
                          onTap: () {
                            _generateInteractTelemetryData(
                                clickId: TelemetryIdentifier.cardContent,
                                subType: telemetrySubtype,
                                snapshot.data![index].identifier);
                            Navigator.push(
                                context,
                                FadeRoute(
                                    page: EventsDetailsScreenv2(
                                  eventId: snapshot.data![index].identifier,
                                )));
                          },
                          child: EventsCardV2(
                            event: snapshot.data![index],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return SizedBox();
        });
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
