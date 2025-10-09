import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/events_insights_model.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_hub_insights/widget/event_engagement/event_engagement.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_hub_insights/widget/event_schedule/event_schedule.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_image_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class EventInsightsStrip extends StatelessWidget {
  final Map<String, dynamic> eventsConfig;
  const EventInsightsStrip({super.key, required this.eventsConfig});

  List<Widget> getConfigData(context) {
    List<Widget> eventInsightsCards = [];

    try {
      if (eventsConfig['version2'] != null &&
          eventsConfig['version2']['sectionList'] != null) {
        for (var e in eventsConfig['version2']['sectionList']) {
          if (e != null && e['key']?.toString() == 'eventsHome') {
            var leftSectionData = e['data']?['leftSection']?['data'];

            if (leftSectionData != null) {
              leftSectionData.forEach((key, value) {
                if (key == EventConstants.myEngagements) {
                  MultiLingualText? title = value['title'] != null
                      ? MultiLingualText.fromJson(value['title'])
                      : null;
                  List<EventInsightsModel> insights = [];

                  try {
                    if (value['data'] != null && value['data'] is List) {
                      insights = List<EventInsightsModel>.from(
                        value['data']
                            .map((e) => EventInsightsModel.fromJson(e)),
                      );
                    } else {
                      throw Exception("Data is not a valid list");
                    }
                  } catch (e) {
                    debugPrint("Error while parsing insights data: $e");
                  }
                  eventInsightsCards.addAll([
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0).w,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            FadeRoute(
                              page: EventEngagement(
                                title:
                                    title != null ? title.getText(context) : "",
                                data: insights,
                              ),
                            ),
                          );
                        },
                        child: eventInsightsCard(
                          imagePath: "assets/img/event_engagement.svg",
                          title: title != null ? title.getText(context) : "",
                        ),
                      ),
                    ),
                  ]);
                }

                // Handle the "eventsCalendar" case
                if (key == EventConstants.eventsCalendar) {
                  MultiLingualText? title = value['title'] != null
                      ? MultiLingualText.fromJson(value['title'])
                      : null;

                  eventInsightsCards.addAll([
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0).r,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            FadeRoute(
                              page: EventSchedule(
                                title:
                                    title != null ? title.getText(context) : "",
                              ),
                            ),
                          );
                        },
                        child: eventInsightsCard(
                          imagePath: "assets/img/event_calendar.svg",
                          title: title != null ? title.getText(context) : "",
                        ),
                      ),
                    ),
                  ]);
                }
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error in getConfigData: $e");
    }
    return eventInsightsCards;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [...getConfigData(context)],
      ),
    );
  }

  Widget eventInsightsCard({required String title, required String imagePath}) {
    return Container(
        padding: EdgeInsets.all(3).r,
        height: 85.w,
        width: 120.w,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey08),
          borderRadius: BorderRadius.circular(8).r,
          color: AppColors.appBarBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageWidget(
              fit: BoxFit.contain,
              imageUrl: imagePath,
              height: 35.w,
              width: 45.w,
              color: AppColors.primaryOne,
            ),
            SizedBox(
              height: 3.w,
            ),
            Text(
              Helper.capitalizeEachWordFirstCharacter(title),
              style: GoogleFonts.lato(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ));
  }
}
