import 'dart:async';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../util/telemetry_repository.dart';

class BottomSection extends StatefulWidget {
  final String startdate;
  final String enddate;
  final String courseId;
  final String? progress;
  const BottomSection(
      {Key? key,
      required this.startdate,
      required this.courseId,
      this.progress,
      required this.enddate})
      : super(key: key);

  @override
  State<BottomSection> createState() => _BottomSectionState();
}

class _BottomSectionState extends State<BottomSection> {
  late Duration _remainingTime;
  late Timer _timer;
  @override
  void initState() {
    print("------------${widget.progress}");
    super.initState();
    _remainingTime = DateTime.parse(widget.startdate.replaceAll('Z', ''))
        .difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = DateTime.parse(widget.startdate.replaceAll('Z', ''))
            .difference(DateTime.now());

        if (_remainingTime.inSeconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generateInteractTelemetryData(String contentId,
      {required String subType,
      String? primaryCategory,
      String? objectType,
      required String clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null ? primaryCategory : objectType,
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    int days = _remainingTime.inDays;
    int hours = _remainingTime.inHours.remainder(24);
    int minutes = _remainingTime.inMinutes.remainder(60);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0).w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _remainingTime.inSeconds <= 0
              ? SizedBox(
                  height: 32.h,
                  // width: 141.h,
                  child: ElevatedButton(
                    onPressed: () {
                      _generateInteractTelemetryData(widget.courseId,
                          subType: 'scheduled-assessment',
                          clickId: TelemetryIdentifier.cardContent);
                      Navigator.pushNamed(context, AppUrl.courseTocPage,
                          arguments: CourseTocModel.fromJson(
                              {'courseId': widget.courseId}));
                    },
                    child: Text(
                      widget.progress != null &&
                              int.tryParse(widget.progress!) != null
                          ? AppLocalizations.of(context)!.mLearnResume +
                              " " +
                              AppLocalizations.of(context)!.mCommonProgram
                          : AppLocalizations.of(context)!.mStartAssessment,
                      style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.appBarBackground),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30).w,
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    _buildCountdownPart(
                        days,
                        AppLocalizations.of(context)!
                            .mStaticDays
                            .toUpperCase()),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4).r,
                      child: Text(":", style: TextStyle(fontSize: 8.sp)),
                    ),
                    _buildCountdownPart(
                        hours,
                        AppLocalizations.of(context)!
                            .mStaticHours
                            .toUpperCase()),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, right: 4).r,
                      child: Text(
                        ":",
                        style: TextStyle(fontSize: 8.sp),
                      ),
                    ),
                    _buildCountdownPart(
                        minutes,
                        AppLocalizations.of(context)!
                            .mStaticMins
                            .toUpperCase()),
                  ],
                ),
          Container(
            margin: EdgeInsets.only(left: 20).r,
            padding: EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5).r,
            decoration: BoxDecoration(
                color: widget.progress != null &&
                        int.tryParse(widget.progress!) != null
                    ? AppColors.greenFour
                    : Colors.red,
                borderRadius: BorderRadius.circular(4).r),
            child: Text(
              _remainingTime.inSeconds <= 0
                  ? "${DateTimeHelper.getDateTimeInFormat(widget.enddate, desiredDateFormat: IntentType.dateFormat2)}"
                  : "${DateTimeHelper.getDateTimeInFormat(widget.startdate, desiredDateFormat: IntentType.dateFormat2)}",
              style: GoogleFonts.lato(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.appBarBackground),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCountdownPart(int value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedFlipCounter(
          duration: Duration(milliseconds: 500),
          value: value,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          width: 2.w,
        ),
        Text(
          unit,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w400,
            fontSize: 8.sp,
            color: AppColors.greys60,
          ),
        ),
      ],
    );
  }

  bool hasEndDatePasses() {
    DateTime date = DateTime.parse(widget.enddate);

    return (date.isAfter(DateTime.now()));
  }
}
