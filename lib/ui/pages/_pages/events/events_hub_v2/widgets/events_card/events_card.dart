import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/creator_strip.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_card_image.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_certificate.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_time_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_type_pill.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/live_icon.dart';
import 'package:karmayogi_mobile/util/index.dart';

import '../../../../../../../constants/index.dart';

class EventsCardV2 extends StatelessWidget {
  final Event event;
  const EventsCardV2({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310.w,
      width: 245.w,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(8).r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 245.w,
            height: 140.w,
            child: EventCardImage(
              isLive: Helper.isEventLive(
                  endDate: event.endDate.toString(),
                  endTime: event.endTime.toString(),
                  startDate: event.startDate.toString(),
                  startTime: event.startTime.toString()),
              duration:
                  event.duration != null ? int.parse(event.duration!) : null,
              imageUrl: Helper.convertImageUrl(event.eventIcon ?? ""),
            ),
          ),
          Container(
            height: 170.w,
            padding: const EdgeInsets.all(8.0).r,
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
                          ? 0.2.sw
                          : 0.25.sw,
                      child: Text(
                        event.name ?? "",
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
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
                                "Live",
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
                  creatorName: event.source != null ? event.source! : 'iGOT',
                ),
                EventTime(
                  eventDate: event.startDate,
                  eventTime: event.startTime,
                ),
                EventCertificate()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
