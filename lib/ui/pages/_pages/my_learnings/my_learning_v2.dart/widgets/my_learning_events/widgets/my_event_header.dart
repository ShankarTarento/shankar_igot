import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/primary_category_widget.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../widgets/_events/models/event_enrollment_list_model.dart';

class MyEventHeader extends StatelessWidget {
  final EventEnrollmentListModel event;
  const MyEventHeader({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Row(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PrimaryCategoryWidget(
                        contentType: event.event.eventType ?? "",
                        addedMargin: true,
                        forceDefaultUi: true,
                      ),
                      Container(
                        width: 1.sw - 150.w,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0).r,
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
                            )),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.w),
            Row(
              children: [
                Icon(
                  Icons.check,
                  size: 20.sp,
                  color: AppColors.positiveLight,
                ),
                Text(
                  Helper.capitalize(
                      AppLocalizations.of(context)!.mStaticCompleted),
                  style: GoogleFonts.lato(
                    color: AppColors.positiveLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
        event.event.status == WidgetConstants.live
            ? SizedBox()
            : Positioned(
                child: Container(
                height: 90.w,
                color: AppColors.appBarBackground.withValues(alpha: 0.7),
              ))
      ],
    );
  }
}
