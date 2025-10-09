import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/models/event_enrollment_list_model.dart';
import 'package:karmayogi_mobile/ui/widgets/primary_category_widget.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyEventsInprogresCard extends StatelessWidget {
  final EventEnrollmentListModel event;
  final bool isVertical;
  const MyEventsInprogresCard(
      {super.key, required this.event, this.isVertical = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: isVertical ? null : const EdgeInsets.only(left: 16).r,
      width: isVertical ? 1.sw : 0.9.sw,
      padding: const EdgeInsets.all(12).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.all(const Radius.circular(12.0).r),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0).r,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8).r,
              child: ImageWidget(
                  imageUrl: event.event.eventIcon ?? '',
                  height: 80.w,
                  width: 120.w,
                  boxFit: BoxFit.fill),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PrimaryCategoryWidget(
                  contentType: event.event.eventType ?? "",
                  addedMargin: true,
                  forceDefaultUi: true,
                ),
                Container(
                  width: 1.sw - 150.w,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0).r,
                    child: Text(event.event.name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          color: AppColors.greys60,
                          fontSize: 16.sp,
                          letterSpacing: 0.12,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ),
                if (event.event.startTime != null && event.event.endTime != null)
                  Text(
                      '${DateTimeHelper.formatTimeForEvents(event.event.startTime)} - ${DateTimeHelper.formatTimeForEvents(event.event.endTime)}',
                      style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontSize: 14.sp,
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w400,
                      )
                  ),
                SizedBox(
                  height: 8.w,
                ),
                SizedBox(
                  width: 0.35.sw,
                  child: ElevatedButton(
                    onPressed: () {
                      if (event.event.status == WidgetConstants.live) {
                        Navigator.push(
                            context,
                            FadeRoute(
                                page: EventsDetailsScreenv2(
                              eventId: event.event.identifier,
                            )));
                        HomeTelemetryService.generateInteractTelemetryData(
                            event.event.identifier,
                            primaryCategory: PrimaryCategory.event,
                            subType: TelemetrySubType.myLearning,
                            clickId: TelemetryIdentifier.cardContent);
                      } else {
                        Helper.showSnackBarMessage(
                            context: context,
                            text: AppLocalizations.of(context)!
                                .meventArchivedMessage,
                            bgColor: AppColors.darkBlue);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60.r),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.completionPercentage > 0
                              ? AppLocalizations.of(context)!.mLearnResume
                              : AppLocalizations.of(context)!.mLearnStart,
                          style: GoogleFonts.lato(
                            decoration: TextDecoration.none,
                            color: AppColors.appBarBackground,
                            fontSize: 14.sp,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 22.w,
                            color: AppColors.appBarBackground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
