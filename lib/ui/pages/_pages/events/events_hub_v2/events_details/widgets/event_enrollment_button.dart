import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/event_detailv2_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/event_player_v2/event_player_v2.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class EventEnrollmentButton extends StatefulWidget {
  final EventDetailV2 eventDetail;
  final Function enrollCallback;
  final bool enableEventEnroll;
  final Function reloadCallback;
  final bool isEnrolled;
  const EventEnrollmentButton(
      {super.key,
      required this.enrollCallback,
      required this.eventDetail,
      required this.reloadCallback,
      required this.isEnrolled,
      required this.enableEventEnroll});

  @override
  State<EventEnrollmentButton> createState() => _EventEnrollmentButtonState();
}

class _EventEnrollmentButtonState extends State<EventEnrollmentButton> {
  @override
  Widget build(BuildContext context) {
    return widget.enableEventEnroll
        ? (!widget.isEnrolled)
            ? eventEnrollButton()
            : eventActionButton()
        : eventActionButton();
  }

  Widget eventEnrollButton() {
    return SizedBox(
      height: 45.w,
      child: ElevatedButton(
        onPressed: () {
          widget.enrollCallback();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30).r,
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.mLearnEnroll,
          style: GoogleFonts.lato(
              color: AppColors.appBarBackground,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget eventActionButton() {
    return SizedBox(
      height: 45.w,
      child: ElevatedButton(
        onPressed: () {
          _generateInteractTelemetryData(widget.eventDetail.identifier,
              subType: TelemetrySubType.watchRecording);
          eventAction();
        },
        style: OutlinedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.appBarBackground,
          side: BorderSide(width: 1, color: AppColors.darkBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40).r,
          ),
        ),
        child: Text(
          _getButtonText(),
          style: GoogleFonts.lato(
              color: AppColors.darkBlue,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void eventAction() {
    if (Helper.getEventStatus(
                endDate: widget.eventDetail.endDate.toString(),
                endTime: widget.eventDetail.endTime.toString(),
                startDate: widget.eventDetail.startDate.toString(),
                startTime: widget.eventDetail.startTime.toString()) ==
            EnglishLang.started &&
        widget.eventDetail.registrationLink != null) {
      if (widget.enableEventEnroll) {
        getEventPlayScreen(widget.eventDetail.registrationLink ?? '');
      } else {
        Helper.doLaunchUrl(
            url: widget.eventDetail.registrationLink ?? '',
            mode: LaunchMode.externalApplication);
      }
    } else if (Helper.getEventStatus(
            endDate: widget.eventDetail.endDate.toString(),
            endTime: widget.eventDetail.endTime.toString(),
            startDate: widget.eventDetail.startDate.toString(),
            startTime: widget.eventDetail.startTime.toString()) ==
        EnglishLang.completed) {
      if (widget.enableEventEnroll) {
        if (widget.eventDetail.registrationLink != null) {
          if (widget.isEnrolled) {
            getEventPlayScreen(widget.eventDetail.registrationLink ?? '');
          } else {
            Helper.doLaunchUrl(
                url: widget.eventDetail.registrationLink ?? '',
                mode: LaunchMode.externalApplication);
          }
        }
      } else {
        if (widget.eventDetail.recordedLinks != null) {
          Helper.doLaunchUrl(
              url: (widget.eventDetail.recordedLinks!.first ?? '').toString(),
              mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  String _getButtonText() {
    if (Helper.getEventStatus(
            endDate: widget.eventDetail.endDate.toString(),
            endTime: widget.eventDetail.endTime.toString(),
            startDate: widget.eventDetail.startDate.toString(),
            startTime: widget.eventDetail.startTime.toString()) ==
        EnglishLang.completed) {
      if (widget.enableEventEnroll) {
        return AppLocalizations.of(context)!.mEventsBtnViewRecording;
      } else {
        return (widget.eventDetail.recordedLinks != null)
            ? AppLocalizations.of(context)!.mEventsBtnViewRecording
            : AppLocalizations.of(context)!.mStaticEventIsCompleted;
      }
    } else {
      return (Helper.getEventStatus(
                  endDate: widget.eventDetail.endDate.toString(),
                  endTime: widget.eventDetail.endTime.toString(),
                  startDate: widget.eventDetail.startDate.toString(),
                  startTime: widget.eventDetail.startTime.toString()) ==
              EnglishLang.notStarted)
          ? AppLocalizations.of(context)!.mStaticEventIsNotCompleted
          : AppLocalizations.of(context)!.mStaticJoinEvent;
    }
  }

  void getEventPlayScreen(String mediaLink) {
    Navigator.push(
      context,
      FadeRoute(
        page: EventPlayerV2Screen(
          eventDetail: widget.eventDetail,
          mediaLink: mediaLink,
          isEnrolled: widget.isEnrolled,
        ),
      ),
    );
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '',
      String? primaryCategory,
      bool isObjectNull = false,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.eventDetailsPageUri
            .replaceAll(':eventId', widget.eventDetail.identifier),
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.events,
        objectType: primaryCategory ?? (isObjectNull ? null : subType),
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
