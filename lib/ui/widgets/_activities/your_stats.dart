import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/models/_models/event_summary.dart';
import 'package:karmayogi_mobile/respositories/_respositories/event_repository.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:provider/provider.dart';

class YourStats extends StatefulWidget {
  final int progress;
  final int certificate;
  final int learningHour;
  final VoidCallback? myLearningInProgressCallback;
  final VoidCallback? myLearningCompletedCallback;

  const YourStats(this.progress, this.certificate, this.learningHour,
      {this.myLearningInProgressCallback,
      this.myLearningCompletedCallback,
      Key? key})
      : super(key: key);

  @override
  State<YourStats> createState() => _YourStatsState();
}

class _YourStatsState extends State<YourStats> {
  UserEventEnrolmentInfo? eventSummary;

  @override
  void initState() {
    eventSummary = Provider.of<EventRepository>(context, listen: false)
        .userEventEnrolmentInfo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int enrolledEvents = eventSummary?.eventsEnrolled ?? 0;
    int attendedEvents = eventSummary?.eventsAttended ?? 0;
    int hoursSpent = eventSummary?.timeSpentOnEventsInSec ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        statusWidget(
            (widget.progress + (enrolledEvents - attendedEvents)).toString(),
            'assets/img/play_course.svg',
            AppLocalizations.of(context)!.mStaticInprogress,
            context, callback: () {
          if (widget.myLearningInProgressCallback != null) {
            widget.myLearningInProgressCallback!();
          }
        }),
        SizedBox(width: 8.w),
        statusWidget(
            (widget.certificate + attendedEvents).toString(),
            'assets/img/certificate_icon.svg',
            AppLocalizations.of(context)!.mCommonCertificates,
            context, callback: () {
          if (widget.myLearningCompletedCallback != null) {
            widget.myLearningCompletedCallback!();
          }
        }),
        SizedBox(width: 8.w),
        statusWidget(
            getLearningHour(
                eventsLearningHours: hoursSpent,
                courseLearningHours: widget.learningHour),
            'assets/img/time_active.svg',
            AppLocalizations.of(context)!.mCommonLearningHours,
            context, callback: () {
          if (widget.myLearningInProgressCallback != null) {
            widget.myLearningInProgressCallback!();
          }
        }),
      ],
    );
  }

  Widget statusWidget(count, imagePath, text, contextn,
      {required Function callback}) {
    return Flexible(
      child: InkWell(
        onTap: () => callback(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              imagePath,
              width: 20.0.w,
              height: 20.0.w,
            ),
            SizedBox(height: 4.w),
            SizedBox(
              height: 0.03.sh,
              child: Text(
                text,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      letterSpacing: 0.12.r,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4.w),
            Text(
              count,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  letterSpacing: 0.12.r),
            ),
          ],
        ),
      ),
    );
  }

  String getLearningHour(
      {required int courseLearningHours, required int eventsLearningHours}) {
    return DateTimeHelper.getTimeFormat(
        (courseLearningHours + eventsLearningHours).toString());
  }
}
