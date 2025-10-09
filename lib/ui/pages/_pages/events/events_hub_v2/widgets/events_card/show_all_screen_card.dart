import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/creator_strip.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_card_image.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_certificate.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_time_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_type_pill.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/live_icon.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../constants/index.dart';

class ShowAllScreenCard extends StatelessWidget {
  final Event event;
  const ShowAllScreenCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            FadeRoute(page: EventsDetailsScreenv2(eventId: event.identifier)));
      },
      child: Container(
        margin: EdgeInsets.all(8).r,
        height: 400.w,
        width: 1.sw,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(8).r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 1.sw,
              height: 230.w,
              child: EventCardImage(
                  isLive: Helper.isEventLive(
                      endDate: event.endDate.toString(),
                      endTime: event.endTime.toString(),
                      startDate: event.startDate.toString(),
                      startTime: event.startTime.toString()),
                  duration: event.duration != null
                      ? int.parse(event.duration!)
                      : null,
                  imageUrl: Helper.convertImageUrl(event.eventIcon ?? "")),
            ),
            Container(
              height: 170.w,
              padding: const EdgeInsets.only(
                      left: 12.0, right: 12, top: 8, bottom: 8)
                  .r,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventTypePill(
                    imageUrl: "assets/img/event_type_icon.svg",
                    title: event.eventType ?? "",
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: Helper.isEventLive(
                                endDate: event.endDate.toString(),
                                endTime: event.endTime.toString(),
                                startDate: event.startDate.toString(),
                                startTime: event.startTime.toString())
                            ? 0.5.sw
                            : 0.7.sw,
                        child: Text(
                          event.name ?? "",
                          style: GoogleFonts.lato(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Spacer(),
                      Helper.isEventLive(
                              endDate: event.endDate.toString(),
                              endTime: event.endTime.toString(),
                              startDate: event.startDate.toString(),
                              startTime: event.startTime.toString())
                          ? Row(
                              children: [
                                LiveIcon(),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.mlive,
                                  style: GoogleFonts.lato(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textHeadingColor,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            )
                          : SizedBox(),
                    ],
                  ),
                  CreatorStrip(
                    fontSize: 14,
                    creatorName: event.source != null ? event.source! : 'iGOT',
                  ),
                  event.startDate != null && event.startTime != null
                      ? EventTime(
                          eventDate: event.startDate,
                          eventTime: event.startTime,
                          fontSize: 14,
                        )
                      : SizedBox(),
                  EventCertificate(
                    fontSize: 14,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
