import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants/_constants/color_constants.dart';
import './../../constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyCompleted extends StatefulWidget {
  final int totalQuestions;
  final int questionsAnswered;
  final String timeSpent;
  SurveyCompleted(this.totalQuestions, this.questionsAnswered, this.timeSpent);
  @override
  _SurveyCompletedState createState() => _SurveyCompletedState();
}

class _SurveyCompletedState extends State<SurveyCompleted> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 231.w,
        width: double.infinity.w,
        margin: EdgeInsets.only(top: 8.0).r,
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 24).r,
          child: Column(
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        size: 20.sp, color: FeedbackColors.avatarGreen),
                    Padding(
                      padding: const EdgeInsets.only(left: 11).r,
                      child: Text(
                        AppLocalizations.of(context)!.mCommonGoodWork,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16).r,
                child: Text(
                  AppLocalizations.of(context)!.mCommonYourScore,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 7).r,
                child: Container(
                  height: 52.w,
                  width: 88.w,
                  color: FeedbackColors.ghostWhite,
                  child: Center(
                    child: Text(
                      (widget.questionsAnswered / widget.totalQuestions * 100)
                              .ceil()
                              .toString() +
                          " %",
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontSize: 20.sp,
                          ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24).r,
                child: Text(
                  AppLocalizations.of(context)!.mStaticWeDontRecordScores,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
      Container(
        height: 244.w,
        width: double.infinity.w,
        margin: EdgeInsets.only(top: 8.0, bottom: 16).r,
        decoration: BoxDecoration(
          color: AppColors.appBarBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24).r,
              child: Text(
                AppLocalizations.of(context)!.mStaticPerformanceSummary,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 14.sp,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 8, right: 24).r,
              child: Container(
                height: 48.w,
                color: FeedbackColors.black04,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 19).r,
                      child: Icon(Icons.done,
                          size: 20.sp, color: FeedbackColors.avatarGreen),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 11).r,
                      child: Text(
                        '${widget.questionsAnswered} ${AppLocalizations.of(context)!.mCommonQuestionsAnswered}',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            widget.totalQuestions - widget.questionsAnswered > 0
                ? Padding(
                    padding:
                        const EdgeInsets.only(left: 24, top: 8, right: 24).r,
                    child: Container(
                      height: 48.w,
                      color: FeedbackColors.black04,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 19).r,
                            child: SvgPicture.asset(
                              'assets/img/skip_next.svg',
                              // width: 40.0.w,
                              // height: 56.0.h,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 11).r,
                            child: Text(
                              '${widget.totalQuestions - widget.questionsAnswered} ${AppLocalizations.of(context)!.mCommonQuestionsNotAnswered}',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 8, right: 24).r,
              child: Container(
                height: 48.w,
                color: FeedbackColors.black04,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 19).r,
                      child: Icon(Icons.timer,
                          size: 20.sp, color: FeedbackColors.blueCard),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 11).r,
                      child: Text(
                        '${AppLocalizations.of(context)!.mCommonTimeSpent} ${widget.timeSpent}',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
