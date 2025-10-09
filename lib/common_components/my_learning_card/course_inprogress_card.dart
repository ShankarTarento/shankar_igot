import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/my_learning_card/my_learning_card_header.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class CourseInprogressCard extends StatelessWidget {
  final Course course;
  const CourseInprogressCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: 0.9.sw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12).r,
        border: Border.all(color: AppColors.grey08, width: 1.w),
        color: AppColors.appBarBackground,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              MyLearningCardHeader(
                course: course,
              ),
              course.raw['content']['status'] == 'Live'
                  ? SizedBox()
                  : Positioned(
                      child: Container(
                          height: 100.w,
                          color: AppColors.appBarBackground
                              .withValues(alpha: 0.7)))
            ],
          ),
          SizedBox(
            height: 16.w,
          ),
          Row(
            children: [
              Column(
                children: [
                  course.duration != null && course.completionPercentage != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/img/time_active.svg',
                                width: 20.0.w,
                                height: 20.0.w,
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(left: 4).r,
                                  child: Text(
                                    getRemainingTime(course.duration,
                                            course.completionPercentage) ??
                                        "",
                                    style: GoogleFonts.lato(
                                      color: AppColors.greys87,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.0.sp,
                                    ),
                                  ))
                            ],
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 5.w,
                  ),
                  course.completionPercentage != null
                      ? SizedBox(
                          width: 0.4.sw,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5).r,
                            child: LinearProgressIndicator(
                              minHeight: 4.w,
                              backgroundColor: AppColors.grey16,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.verifiedBadgeIconColor,
                              ),
                              value: course.completionPercentage != null
                                  ? course.completionPercentage! / 100
                                  : 0,
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
              Spacer(),
              SizedBox(
                width: 0.35.sw,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0).r),
                        padding: EdgeInsets.symmetric(vertical: 8.0).r,
                        backgroundColor: AppColors.darkBlue),
                    onPressed: () {
                      // _generateInteractTelemetryData(
                      //     widget.course.raw['contentId'],
                      //     edataId: TelemetryIdentifier.cardContent,
                      //     subType: TelemetrySubType.myLearning,
                      //     primaryCategory: widget.course.raw['primaryCategory']);
                      Navigator.pushNamed(context, AppUrl.courseTocPage,
                          arguments:
                              CourseTocModel.fromJson({'courseId': course.id}));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            course.completionPercentage == null ||
                                    course.completionPercentage == 0
                                ? Helper().capitalizeFirstCharacter(
                                    AppLocalizations.of(context)!.mLearnStart)
                                : Helper().capitalizeFirstCharacter(
                                    AppLocalizations.of(context)!
                                        .mStaticResume),
                            style: GoogleFonts.lato(
                                fontSize: 14.sp,
                                color: AppColors.appBarBackground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Icon(
                          Icons.play_circle_fill,
                          color: AppColors.avatarText,
                          size: 24.sp,
                        )
                      ],
                    )),
              )
            ],
          )
        ],
      ),
    );
  }

  String? getRemainingTime(duration, completionPercentage) {
    try {
      if (completionPercentage != 0 && course.duration != null) {
        int totalDuration = int.parse(course.duration!);
        int remainingTime =
            ((totalDuration - ((completionPercentage * totalDuration) / 100))
                .toInt());
        return getTimeFormat(remainingTime.toString()) != null
            ? getTimeFormat(remainingTime.toString())! + ' to go'
            : null;
      } else {
        return getTimeFormat(duration) != null
            ? getTimeFormat(duration)! + ' to go'
            : null;
      }
    } catch (e) {
      print('Error in getRemainingTime: $e');
      return null;
    }
  }

  static String? getTimeFormat(duration) {
    try {
      int parsedDuration = int.parse(duration);
      int hours = Duration(seconds: parsedDuration).inHours;
      int minutes = Duration(seconds: parsedDuration).inMinutes;
      String time;

      if (hours > 0) {
        time =
            hours.toString() + 'hrs ' + (minutes - hours * 60).toString() + 'm';
      } else {
        time = minutes.toString() + ' min';
      }
      return time;
    } catch (e) {
      print('Error in getTimeFormat: $e');
      return null;
    }
  }
}
