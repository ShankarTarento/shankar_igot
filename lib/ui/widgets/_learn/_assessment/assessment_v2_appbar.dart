import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import '../../../../constants/index.dart';
import '../../../../feedback/constants.dart';

class AssessmentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String primaryCategory;
  final duration;
  final int totalQuestionCount;

  const AssessmentAppBar(
      {Key? key,
      required this.title,
      required this.primaryCategory,
      this.duration,
      required this.totalQuestionCount})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0.w,
      elevation: 0,
      toolbarHeight: 150,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Padding(
                padding: const EdgeInsets.only(left: 10).r,
                child: Text(
                  title,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                      color: FeedbackColors.black87,
                      fontSize: 16.0.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.25),
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list,
                        size: 20,
                        color: AppColors.darkBlue,
                      ),
                      Text(
                        totalQuestionCount == 1
                            ? '${totalQuestionCount.toString()} ${AppLocalizations.of(context)!.mStaticQuestion}'
                            : '${totalQuestionCount.toString()} ${AppLocalizations.of(context)!.mStaticQuestions}',
                        overflow: TextOverflow.fade,
                        style: GoogleFonts.lato(
                            color: FeedbackColors.black87,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.25),
                      ),
                    ],
                  )),
              duration != null && duration != 0
                  ? Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 20,
                            color: AppColors.darkBlue,
                          ),
                          Text(
                            DateTimeHelper.getFullTimeFormat(duration.toString(),
                                timelyDurationFlag: true),
                            overflow: TextOverflow.fade,
                            style: GoogleFonts.lato(
                                color: FeedbackColors.black87,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.25),
                          ),
                        ],
                      ))
                  : Center(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100);
}
