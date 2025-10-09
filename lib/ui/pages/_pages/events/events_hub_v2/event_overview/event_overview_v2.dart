import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/_models/event_detailv2_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_overview/widgets/events_description.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_certificate.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_time_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/widgets/event_type_pill.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/models/event_enroll_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/widgets/event_complete_certificate.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/widgets/reward_message_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/index.dart';

class EventOverviewV2 extends StatefulWidget {
  final EventDetailV2? eventDetail;

  final EventEnrollData? eventEnrollData;
  final bool enableEventEnroll;
  final bool isEnrolled;

  EventOverviewV2({
    Key? key,
    this.eventDetail,
    this.eventEnrollData,
    this.enableEventEnroll = false,
    this.isEnrolled = false,
  }) : super(key: key);

  @override
  _EventOverviewState createState() => _EventOverviewState();
}

class _EventOverviewState extends State<EventOverviewV2> {
  bool isPastEventStamp(int certificateTimeStamp) {
    String expiry = widget.eventDetail!.endDate +
        ' ' +
        Helper.formatTime(widget.eventDetail!.endTime);
    DateTime expireDate = DateTime.parse(expiry);

    DateTime mCertificateTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(certificateTimeStamp);

    return (mCertificateTimeStamp.isBefore(expireDate));
  }

  @override
  Widget build(BuildContext context) {
    return widget.eventDetail != null
        ? Container(
            margin: EdgeInsets.only(top: 16.r),
            padding: EdgeInsets.all(16).r,
            decoration: BoxDecoration(
                color: AppColors.blue244,
                borderRadius: BorderRadius.circular(8).r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.mEventInformation,
                  style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.0.sp,
                  ),
                ),
                Divider(
                  color: AppColors.greys60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 12).r,
                  child: EventTypePill(
                    imageUrl: "assets/img/event_type_icon.svg",
                    title: widget.eventDetail!.resourceType ?? "",
                  ),
                ),
                Text(
                  widget.eventDetail?.name ?? '',
                  style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0.sp,
                  ),
                ),
                if (widget.eventDetail!.status != null &&
                    (Helper.getEventStatus(
                            endDate: widget.eventDetail!.endDate.toString(),
                            endTime: widget.eventDetail!.endTime.toString(),
                            startDate: widget.eventDetail!.startDate.toString(),
                            startTime:
                                widget.eventDetail!.startTime.toString()) ==
                        EnglishLang.started))
                  Container(
                      width: 60.w,
                      margin: EdgeInsets.only(top: 16).r,
                      padding: EdgeInsets.symmetric(vertical: 4).r,
                      decoration: BoxDecoration(
                        color: AppColors.avatarRed,
                        borderRadius:
                            BorderRadius.all(const Radius.circular(20.0).r),
                      ),
                      child: Center(
                        child: Text(
                            '\u2022 ' +
                                widget.eventDetail!.status
                                    .toString()
                                    .toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.lato(
                              color: AppColors.appBarBackground,
                              fontSize: 12.sp,
                              letterSpacing: 0.43,
                              fontWeight: FontWeight.w700,
                            )),
                      )),
                if (widget.enableEventEnroll &&
                    (widget.eventEnrollData != null))
                  eventCertificate(),
                if (widget.enableEventEnroll &&
                    (Helper.getEventStatus(
                            endDate: widget.eventDetail!.endDate.toString(),
                            endTime: widget.eventDetail!.endTime.toString(),
                            startDate: widget.eventDetail!.startDate.toString(),
                            startTime:
                                widget.eventDetail!.startTime.toString()) !=
                        EnglishLang.completed))
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(top: 16).r,
                    child: RewardMessageCards(
                      textOne:
                          AppLocalizations.of(context)!.mEventEnrollKarmaPoints,
                      textTwo:
                          ' ${AppLocalizations.of(context)!.mEventEnrollKarmaPointsMessage}',
                      description:
                          AppLocalizations.of(context)!.mStaticKarmaPointInfo,
                    ),
                  ),
                if (((widget.isEnrolled &&
                            isPastEventStamp(
                                widget.eventEnrollData?.completedOn ?? 0)) &&
                        (widget.eventEnrollData?.status ?? 0) >= 2) &&
                    (Helper.getEventStatus(
                            endDate: widget.eventDetail!.endDate.toString(),
                            endTime: widget.eventDetail!.endTime.toString(),
                            startDate: widget.eventDetail!.startDate.toString(),
                            startTime:
                                widget.eventDetail!.startTime.toString()) ==
                        EnglishLang.completed))
                  Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(top: 16).r,
                    child: RewardMessageCards(
                      textOne: '',
                      textTwo:
                          ' ${AppLocalizations.of(context)!.mEventEnrollEarnedKarmaPoints}',
                      description:
                          AppLocalizations.of(context)!.mStaticKarmaPointInfo,
                    ),
                  ),
                if (widget.enableEventEnroll && widget.isEnrolled)
                  certificateInProgressWidget(),
                widget.eventDetail?.source != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 16).r,
                        child: Text(
                          "By ${widget.eventDetail!.source!}",
                          style: GoogleFonts.lato(
                              color: AppColors.greys,
                              decoration: TextDecoration.none,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      )
                    : SizedBox(),
                EventsDescription(
                  eventDescription: widget.eventDetail!.description ?? "",
                ),
                SizedBox(
                  height: 16.w,
                ),
                EventTime(
                  eventDate: widget.eventDetail!.startDate,
                  eventTime: widget.eventDetail!.startTime,
                  fontSize: 14.sp,
                ),
                widget.eventDetail?.duration != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8).r,
                        child: Row(
                          children: [
                            Icon(
                              Icons.hourglass_empty,
                              color: AppColors.greys60,
                              size: 20.sp,
                            ),
                            Text(
                              Helper.getDuration(
                                  durationInMinutes:
                                      widget.eventDetail!.duration!),
                              style: GoogleFonts.lato(
                                color: AppColors.greys60,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                      )
                    : SizedBox(),
                EventCertificate(
                  fontSize: 14.sp,
                ),
              ],
            ),
          )
        : SizedBox();
  }

  Widget eventCertificate() {
    return Container(
      child: ((widget.isEnrolled &&
                  (widget.eventEnrollData?.status ?? 0) >= 2) &&
              Helper.getEventStatus(
                      endDate: widget.eventDetail!.endDate.toString(),
                      endTime: widget.eventDetail!.endTime.toString(),
                      startDate: widget.eventDetail!.startDate.toString(),
                      startTime: widget.eventDetail!.startTime.toString()) ==
                  EnglishLang.completed)
          ? EventCompleteCertificate(
              name: widget.eventDetail?.name ?? '',
              identifier: widget.eventDetail?.identifier ?? '',
              completedOn: widget.eventEnrollData?.completedOn,
              issuedCertificates: widget.eventEnrollData?.issuedCertificates,
              isCertificateProvided:
                  ((widget.eventEnrollData?.issuedCertificates ?? [])
                      .isNotEmpty),
              telemetryEnv: TelemetryEnv.events,
              pageIdentifier: TelemetryPageIdentifier.eventHomePageId)
          : SizedBox(),
    );
  }

  Widget certificateInProgressWidget() {
    return ((((widget.eventEnrollData?.issuedCertificates ?? []).isEmpty) &&
            (widget.eventEnrollData?.status ?? 0) > 1))
        ? Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(top: 16).r,
            child: Container(
              width: double.maxFinite,
              alignment: Alignment.center,
              padding: EdgeInsets.all(16).r,
              decoration: BoxDecoration(
                  color:
                      AppColors.verifiedBadgeIconColor.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.verifiedBadgeIconColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8).r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0).w,
                child: Text(
                  AppLocalizations.of(context)!
                      .mEventEnrollPendingCertificateMessage,
                  style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0.sp,
                  ),
                ),
              ),
            ))
        : SizedBox();
  }
}
