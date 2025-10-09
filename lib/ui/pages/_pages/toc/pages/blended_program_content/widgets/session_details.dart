import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/blended_program_content/widgets/attendence_marker.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import '../../../../../../../constants/_constants/app_constants.dart';
import 'course_type_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SessionDetails extends StatefulWidget {
  final SessionDetailV2 session;
  final Batch? batch;
  final BatchAttribute selectedBatchAttributes;
  final Course courseDetails;
  final bool isEnrolledCourse;
  final Function() onAttendanceMarked;
  const SessionDetails(
      {Key? key,
      required this.session,
      this.batch,
      required this.onAttendanceMarked,
      required this.isEnrolledCourse,
      required this.selectedBatchAttributes,
      required this.courseDetails})
      : super(key: key);

  @override
  State<SessionDetails> createState() => _SessionDetailsState();
}

class _SessionDetailsState extends State<SessionDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16).r,
      child: Column(children: [
        Row(
          children: [
            SizedBox(
              width: 1.sw / 1.4,
              child: Text(
                widget.session.title,
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            CourseTypeButton(
              title: widget.session.sessionType,
            )
          ],
        ),
        SizedBox(
          height: 8.w,
        ),
        Row(
          children: [
            Text(
              DateTimeHelper.getDateTimeInFormat(widget.session.startDate,
                  desiredDateFormat: IntentType.dateFormat2),
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8).r,
              child: CircleAvatar(
                radius: 1.r,
                backgroundColor: AppColors.greys60,
              ),
            ),
            Icon(
              Icons.play_circle,
              color: AppColors.greys60,
            ),
            SizedBox(
              width: 6.w,
            ),
            Text(
              "${widget.session.sessionDuration}",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8).r,
              child: CircleAvatar(
                radius: 1.r,
                backgroundColor: AppColors.greys60,
              ),
            ),
            Text(
              "${widget.session.startTime} to ${widget.session.endTime}",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 16).r,
          padding: EdgeInsets.only(top: 16, left: 16, bottom: 16, right: 34).r,
          // height: 92,
          width: 1.sw,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8).r,
            color: AppColors.orange32,
            border: Border.all(color: AppColors.primaryOne),
          ),
          child: Row(children: [
            SizedBox(
              width: 1.sw / 1.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session.description,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 4.w,
                  ),
                  widget.session.sessionAttendanceStatus
                      ? Text(
                          AppLocalizations.of(context)!.mBlendedProgramAttendanceMarked("${getTImeFormat(widget.session.lastCompletedTime)}"),
                          style: GoogleFonts.lato(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.mBlendedProgramMarkAttendance,
                          style: GoogleFonts.lato(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ],
              ),
            ),
            Spacer(),
            widget.batch != null
                ? AttendenceMarker(
                    onAttendanceMarked: widget.onAttendanceMarked,
                    isEnrolledCourse: widget.isEnrolledCourse,
                    session: widget.session,
                    batch: widget.batch!,
                    courseDetails: widget.courseDetails,
                    selectedBatchAttributes: widget.selectedBatchAttributes,
                  )
                : Center(),
          ]),
        )
      ]),
    );
  }

  String getTImeFormat(dateString) {
    String formattedDateString = dateString.substring(0, 19);
    DateTime dateTime = DateTime.parse(formattedDateString);

    return DateFormat('h:mm a').format(dateTime);
  }
}