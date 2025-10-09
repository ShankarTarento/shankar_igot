import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/live_icon.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class EventsScheduleCard extends StatelessWidget {
  final Event event;

  final bool showDivider;
  const EventsScheduleCard({
    super.key,
    required this.event,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 0.68.sw,
              child: Text(
                event.name ?? "",
                style: GoogleFonts.lato(
                    fontSize: 16.sp, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                        width: 4,
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
        SizedBox(
          height: 8.w,
        ),
        Text(
          event.description ?? "",
          style: GoogleFonts.lato(fontSize: 14.sp, fontWeight: FontWeight.w400),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(
          height: 8.w,
        ),
        Helper.getEventStatusBasedOnDate(event: event) == EnglishLang.past
            ? SizedBox()
            : Row(
                children: [
                  Icon(Icons.access_time,
                      color: AppColors.greys60, size: 16.sp),
                  SizedBox(
                    width: 4.w,
                  ),
                  Text(getTime()),
                ],
              ),
        SizedBox(
          height: 4.w,
        ),
        showDivider
            ? Divider(
                color: AppColors.greys60,
              )
            : SizedBox()
      ],
    );
  }

  String getTime() {
    try {
      return DateTimeHelper.convertTo12HourFormat(
          DateTimeHelper.formatTimeForEvents(event.startTime));
    } catch (e) {
      return "";
    }
  }
}
