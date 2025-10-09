import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AssessmentCompleted extends StatefulWidget {
  final String timeSpent;
  final Map apiResponse;
  final Function? parentAction;
  AssessmentCompleted(this.timeSpent, this.apiResponse, this.parentAction);
  @override
  _AssessmentCompletedState createState() => _AssessmentCompletedState();
}

class _AssessmentCompletedState extends State<AssessmentCompleted> {
  get boxDecoration => BoxDecoration(
          border: Border(
        top: BorderSide(color: AppColors.grey04),
        bottom: BorderSide(color: AppColors.grey04),
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _buildLayout(),
      ),
      bottomSheet: _actionButton(),
    );
  }

  Widget _buildLayout() {
    return Container(
      color: AppColors.primaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _getAppbar(),
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32).r,
              child: Text(
                AppLocalizations.of(context)!.mAssessmentAssessmentResults,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 24.sp,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
              )),
          _containerBody(),
        ],
      ),
    );
  }

  Widget _getAppbar() {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      titleSpacing: 0,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_sharp,
            size: 20.sp, color: AppColors.appBarBackground),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _containerBody() {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))
            .r,
        child: Container(
          padding: EdgeInsets.only(
            top: 8,
          ).r,
          color: AppColors.appBarBackground,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(16, 16, 16, 4).r,
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox(
                        height: 92.w,
                        width: 92.w,
                        child: CircularProgressIndicator.adaptive(
                          value: (widget.apiResponse['result'] != null)
                              ? (widget.apiResponse['result']) / 100
                              : 0,
                          backgroundColor: AppColors.grey08,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              widget.apiResponse['result'] >=
                                      widget.apiResponse['passPercent']
                                  ? FeedbackColors.positiveLight
                                  : FeedbackColors.negativeLight),
                        ),
                      ),
                      Center(
                          child: Column(
                        children: [
                          Text(
                            widget.apiResponse['result'] >=
                                    widget.apiResponse['passPercent']
                                ? widget.apiResponse['result']
                                        .toStringAsFixed(0)
                                        .toString() +
                                    ' %'
                                : widget.apiResponse['result']
                                        .toStringAsFixed(0)
                                        .toString() +
                                    ' %',
                            style: GoogleFonts.lato(
                                color: (widget.apiResponse['result'] >=
                                        widget.apiResponse['passPercent'])
                                    ? FeedbackColors.positiveLight
                                    : FeedbackColors.negativeLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 20.0.sp,
                                letterSpacing: 0.25.r),
                          ),
                          SizedBox(height: 4.w),
                          Text(
                            widget.apiResponse['result'] >=
                                    widget.apiResponse['passPercent']
                                ? AppLocalizations.of(context)!
                                    .mPass
                                    .toUpperCase()
                                : AppLocalizations.of(context)!
                                    .mFail
                                    .toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.25.r,
                                  fontSize: 12.sp,
                                ),
                          ),
                        ],
                      )),
                    ]),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.fromLTRB(86, 4, 86, 16).r,
                    child: Text(
                      widget.apiResponse['result'] >=
                              widget.apiResponse['passPercent']
                          ? widget.apiResponse['result'] == 100
                              ? AppLocalizations.of(context)!
                                  .mStaticAcedAssessment
                              : AppLocalizations.of(context)!
                                  .mStaticPassedSuccessfully
                          : AppLocalizations.of(context)!.mStaticTryAgainMsg,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0.sp,
                          letterSpacing: 0.25.r),
                    ),
                  ),
                  _overallSummary()
                ]),
          ),
        ),
      ),
    );
  }

  Widget _overallSummary() {
    return Column(
      children: [
        Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8.0, bottom: 8).r,
              padding: EdgeInsets.only(bottom: 16).r,
              decoration: BoxDecoration(
                color: AppColors.appBarBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 16).r,
                    padding: EdgeInsets.all(16.0).r,
                    child: Row(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/img/assessment_icon.svg',
                              colorFilter: ColorFilter.mode(
                                  AppColors.primaryBlue, BlendMode.srcIn),
                            ),
                            SizedBox(width: 8.0.w),
                            Text(
                              AppLocalizations.of(context)!.mTotalQuestion,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .copyWith(
                                      letterSpacing: 0.25.r,
                                      decoration: TextDecoration.none),
                            )
                          ],
                        ),
                        Spacer(), // Add space between text and icon
                        Text(
                          widget.apiResponse['total'] == 1
                              ? '${widget.apiResponse['total']} ${AppLocalizations.of(context)!.mCommonQuestion}'
                              : '${widget.apiResponse['total']} ${AppLocalizations.of(context)!.mCommonQuestions}',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge!
                              .copyWith(
                                letterSpacing: 0.25.r,
                                decoration: TextDecoration.none,
                              ),
                        )
                      ],
                    ),
                    decoration: boxDecoration,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24, left: 16, bottom: 16).r,
                    child: Text(
                      AppLocalizations.of(context)!.mYourPerformanceSummary,
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge!
                          .copyWith(letterSpacing: 0.25.r, fontSize: 12.sp),
                    ),
                  ),
                  _summaryItems(),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 100.w,
        )
      ],
    );
  }

  Widget _summaryItems() {
    return Column(
      children: [
        widget.apiResponse['correct'] > 0
            ? _summaryItem(
                'correct',
                widget.apiResponse['correct'] == 1
                    ? widget.apiResponse['correct'].toString() +
                        '  ' +
                        AppLocalizations.of(context)!.mStaticOneCorrect
                    : widget.apiResponse['correct'].toString() +
                        '  ' +
                        AppLocalizations.of(context)!.mStaticCorrect)
            : Center(),
        widget.apiResponse['inCorrect'] > 0
            ? _summaryItem(
                'inCorrect',
                widget.apiResponse['inCorrect'] == 1
                    ? widget.apiResponse['inCorrect'].toString() +
                        '  ' +
                        AppLocalizations.of(context)!.mStaticOneIncorrect
                    : widget.apiResponse['inCorrect'].toString() +
                        '  ' +
                        AppLocalizations.of(context)!.mStaticIncorrect)
            : Center(),
        widget.apiResponse['blank'] > 0
            ? _summaryItem(
                'blank',
                widget.apiResponse['blank'].toString() +
                    '  ' +
                    AppLocalizations.of(context)!.mStaticNotAttempted)
            : Center(),
      ],
    );
  }

  Widget _summaryItem(String type, String title) {
    return Container(
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          border: Border(
            top: BorderSide(color: AppColors.grey04),
            bottom: BorderSide(color: AppColors.grey04),
            left: BorderSide(color: AppColors.appBarBackground, width: 0),
          )),
      child: Row(
        children: [
          if (type.toString() == 'correct')
            Icon(Icons.done, size: 24.sp, color: AppColors.primaryBlue),
          if (type.toString() == 'inCorrect')
            SvgPicture.asset(
              'assets/img/close_black.svg',
              colorFilter:
                  ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
            ),
          if (type.toString() == 'blank')
            SvgPicture.asset(
              'assets/img/unanswered.svg',
              colorFilter:
                  ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 8).r,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton() {
    return Container(
      height: 90.w,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32).r,
      decoration: BoxDecoration(color: AppColors.appBarBackground),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 58.w,
            width: 1.sw - 32.w,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (widget.parentAction != null) {
                  widget.parentAction!();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50).r,
                    side: BorderSide(color: AppColors.primaryBlue)),
              ),
              child: Text(AppLocalizations.of(context)!.mFinish,
                  style: Theme.of(context).textTheme.displaySmall),
            ),
          ),
        ],
      ),
    );
  }
}
