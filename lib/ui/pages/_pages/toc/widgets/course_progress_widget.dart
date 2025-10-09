import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants/index.dart';

class CourseProgressWidget extends StatelessWidget {
  final double progress;
  final double width;
  const CourseProgressWidget(
      {Key? key, required this.progress, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width,
            child: Row(
              children: [
                Text(
                  (progress * 100).toInt() == COURSE_COMPLETION_PERCENTAGE
                      ? AppLocalizations.of(context)!.mCommoncompleted
                      : AppLocalizations.of(context)!.mStaticOverallProgress,
                  style: GoogleFonts.lato(
                      color: (progress * 100).toInt() ==
                              COURSE_COMPLETION_PERCENTAGE
                          ? AppColors.appBarBackground
                          : AppColors.greys,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400),
                ),
                Spacer(),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: GoogleFonts.lato(
                      color: (progress * 100).toInt() ==
                              COURSE_COMPLETION_PERCENTAGE
                          ? AppColors.appBarBackground
                          : AppColors.greys,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 4.w,
          ),
          SizedBox(
            height: 4.w,
            width: width,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Color.fromARGB(40, 35, 35, 35),
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.orangeTourText),
            ),
          ),
        ],
      ),
    );
  }
}
