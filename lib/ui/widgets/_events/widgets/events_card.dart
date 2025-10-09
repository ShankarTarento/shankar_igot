import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

import '../../../../constants/index.dart';
import '../../../../util/index.dart';
import '../../index.dart';

class EventsCard extends StatelessWidget {
  final int index;
  final String? eventIcon;
  final bool isEventLive;
  final bool isEventCompleted;
  final String eventStatus;
  final String? eventType;
  final String? eventName;
  final String startTime;
  final String endTime;
  final bool isVerticalList;
  final double? width;

  const EventsCard(
      {super.key,
      required this.index,
      this.eventIcon,
      required this.isEventLive,
      required this.isEventCompleted,
      required this.eventStatus,
      this.eventType,
      this.eventName,
      required this.startTime,
      required this.endTime,
      this.isVerticalList = false,
      this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 1.sw - 65.w,
      margin: EdgeInsets.only(
              left: ((index == 0) && !isVerticalList) ? 24 : 0,
              right: !isVerticalList ? 8 : 0)
          .r,
      padding: EdgeInsets.all(12).r,
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
              child: Stack(
                alignment: AlignmentDirectional.topEnd,
                children: [
                  MicroSiteImageView(
                    imgUrl: Helper.convertImageUrl(eventIcon ?? ''),
                    height: 120.w,
                    width: 120.w,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.all(Radius.circular(4)).r,
                  ),
                  isEventLive
                      ? Container(
                          width: 60.w,
                          height: 20.w,
                          padding: EdgeInsets.symmetric(vertical: 4).r,
                          margin: EdgeInsets.all(4).r,
                          decoration: BoxDecoration(
                            color: AppColors.avatarRed,
                            borderRadius:
                                BorderRadius.all(const Radius.circular(20.0).r),
                          ),
                          child: Center(
                            child: Text('\u2022 ' + eventStatus.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.lato(
                                  color: AppColors.appBarBackground,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.43,
                                  fontWeight: FontWeight.w700,
                                )),
                          ))
                      : Center(),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PrimaryCategoryWidget(
                contentType: eventType,
                addedMargin: true,
                forceDefaultUi: true,
              ),
              Container(
                width: isVerticalList ? 1.sw - 0.55.sw : 1.sw - 0.61.sw,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0).r,
                  child: Text(eventName ?? "",
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
              Text(
                  '${DateTimeHelper.formatTimeForEvents(startTime)} - ${DateTimeHelper.formatTimeForEvents(endTime)}',
                  style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontSize: 14.sp,
                    letterSpacing: 0.25,
                    fontWeight: FontWeight.w400,
                  )),
              roundedButton(
                buttonLabel: isEventCompleted
                    ? AppLocalizations.of(context)!.mEventsBtnViewRecording
                    : AppLocalizations.of(context)!.mStaticJoinEvent,
                bgColor: AppColors.darkBlue,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget roundedButton(
      {String buttonLabel = '',
      Color bgColor = AppColors.black,
      Color textColor = AppColors.appBarBackground}) {
    var optionButton = Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 6).r,
      margin: EdgeInsets.symmetric(vertical: 8.0).r,
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(20.0).r),
      ),
      child: Row(
        children: [
          if (isEventCompleted)
            Padding(
              padding: EdgeInsets.only(right: 4).w,
              child: Icon(
                Icons.video_call_outlined,
                size: 18.w,
                color: AppColors.appBarBackground,
              ),
            ),
          Text(
            buttonLabel,
            style: GoogleFonts.lato(
                decoration: TextDecoration.none,
                color: textColor,
                fontSize: 12.sp,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700),
          )
        ],
      ),
    );
    return optionButton;
  }
}
