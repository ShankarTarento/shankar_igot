import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:igot_ui_components/ui/widgets/alert_dialog/alert_dialog.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_contentPlayers/course_assessment_player.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import '../../../../localization/_langs/english_lang.dart';
import '../../../pages/_pages/toc/model/navigation_model.dart';
import './../../../../feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'assessment_completed_screen_item.dart';

class AssessmentCompletedScreen extends StatefulWidget {
  final String timeSpent;
  final Map apiResponse;
  final assessmentsInfo;
  final primaryCategory;
  final CourseHierarchyModel course;
  final identifier;
  final updateContentProgress;
  final String batchId;
  final bool fromSectionalCutoff;
  final NavigationModel resourceInfo;
  final bool isFeatured;
  final String courseCategory;
  final bool isPreRequisite;

  AssessmentCompletedScreen(this.timeSpent, this.apiResponse,
      {this.assessmentsInfo,
      this.primaryCategory,
      required this.course,
      this.identifier,
      this.updateContentProgress,
      required this.batchId,
      required this.fromSectionalCutoff,
      required this.resourceInfo,
      this.isFeatured = false,
      required this.courseCategory,
      this.isPreRequisite = false});
  @override
  _AssessmentCompletedScreenState createState() =>
      _AssessmentCompletedScreenState();
}

class _AssessmentCompletedScreenState extends State<AssessmentCompletedScreen> {
  get boxDecoration => BoxDecoration(
          border: Border(
        top: BorderSide(color: AppColors.grey04),
        bottom: BorderSide(color: AppColors.grey04),
      ));

  get leftPadding => 16.0;

  @override
  void initState() {
    super.initState();
    if (widget.isFeatured) _publicAssessmentDialog();
  }

  Future _publicAssessmentDialog() async {
    if ((widget.apiResponse['pass'] ?? false) == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext cxt) {
              return AlertDialogWidget(
                dialogRadius: 8,
                icon: SvgPicture.asset(
                  'assets/img/file_info_icon.svg',
                  colorFilter:
                      ColorFilter.mode(AppColors.darkBlue, BlendMode.srcIn),
                  width: 38.0.w,
                  height: 40.0.w,
                ),
                subtitle: AppLocalizations.of(context)!
                    .mAssessmentGuestCongratulationMessage,
                primaryButtonText: AppLocalizations.of(context)!.mStaticOk,
                onPrimaryButtonPressed: () async {
                  Navigator.of(cxt).pop();
                },
                primaryButtonTextStyle: GoogleFonts.lato(
                  color: AppColors.appBarBackground,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0.sp,
                  height: 1.5.w,
                ),
                primaryButtonBgColor: AppColors.darkBlue,
              );
            });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.primaryBlue,
    ));
    return widget.apiResponse.runtimeType != String
        ? SafeArea(
            child: Scaffold(
              body: _buildLayout(),
              bottomSheet: _actionButton(),
            ),
          )
        : Center();
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
          if (widget.fromSectionalCutoff) {
            Navigator.of(context).pop(true);
          }
        },
      ),
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
                widget.primaryCategory == PrimaryCategory.practiceAssessment
                    ? AppLocalizations.of(context)!
                        .mAssessmentCheckYourKnowledge
                    : AppLocalizations.of(context)!
                        .mAssessmentAssessmentResults,
                style: GoogleFonts.montserrat(
                  color: AppColors.appBarBackground,
                  fontSize: 24.0.sp,
                  fontWeight: FontWeight.w600,
                ),
              )),
          _containerBody(),
        ],
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
                  widget.primaryCategory == PrimaryCategory.practiceAssessment
                      ? Container(
                          height: 92.w,
                          width: 92.w,
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 4).r,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                AppColors.positiveLight.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)).r,
                          ),
                          child: Container(
                            height: 68.w,
                            width: 68.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.positiveLight
                                  .withValues(alpha: 0.07),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)).r,
                            ),
                            child: Container(
                              height: 36.w,
                              width: 36.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.positiveLight,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100)).r,
                              ),
                              child: Icon(
                                Icons.check,
                                color: AppColors.appBarBackground,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.fromLTRB(16, 16, 16, 4).r,
                          child: Stack(alignment: Alignment.center, children: [
                            SizedBox(
                              height: 92.w,
                              width: 92.w,
                              child: CircularProgressIndicator(
                                value: (widget.apiResponse['overallResult'] !=
                                        null)
                                    ? (widget.apiResponse['overallResult']) /
                                        100
                                    : 0,
                                backgroundColor: AppColors.grey08,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.apiResponse['pass'] != null
                                        ? (widget.apiResponse['pass']
                                            ? FeedbackColors.positiveLight
                                            : FeedbackColors.negativeLight)
                                        : FeedbackColors.positiveLight),
                              ),
                            ),
                            Center(
                                child: Column(
                              children: [
                                Text(
                                  (widget.apiResponse['passPercentage'] != null)
                                      ? widget.apiResponse['overallResult'] >=
                                              widget
                                                  .apiResponse['passPercentage']
                                          ? widget.apiResponse['overallResult']
                                                  .toStringAsFixed(0)
                                                  .toString() +
                                              '%'
                                          : widget.apiResponse['overallResult']
                                                  .toStringAsFixed(0)
                                                  .toString() +
                                              '%'
                                      : widget.apiResponse['pass']
                                          ? widget.apiResponse['overallResult']
                                                  .toStringAsFixed(0)
                                                  .toString() +
                                              '%'
                                          : widget.apiResponse['overallResult']
                                                  .toStringAsFixed(0)
                                                  .toString() +
                                              '%',
                                  style: GoogleFonts.lato(
                                      color: widget.apiResponse['pass'] != null
                                          ? (widget.apiResponse['pass']
                                              ? FeedbackColors.positiveLight
                                              : FeedbackColors.negativeLight)
                                          : FeedbackColors.positiveLight,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20.0.sp,
                                      letterSpacing: 0.25.r),
                                ),
                                SizedBox(height: 4.w),
                                Text(
                                  (widget.apiResponse['passPercentage'] != null)
                                      ? widget.apiResponse['overallResult'] >=
                                              widget
                                                  .apiResponse['passPercentage']
                                          ? AppLocalizations.of(context)!
                                              .mPass
                                              .toUpperCase()
                                          : AppLocalizations.of(context)!
                                              .mFail
                                              .toUpperCase()
                                      : widget.apiResponse['pass']
                                          ? AppLocalizations.of(context)!
                                              .mPass
                                              .toUpperCase()
                                          : AppLocalizations.of(context)!
                                              .mFail
                                              .toUpperCase(),
                                  style: GoogleFonts.lato(
                                      color: AppColors.greys60,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.0.sp,
                                      letterSpacing: 0.25),
                                ),
                              ],
                            )),
                          ]),
                        ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.fromLTRB(86, 4, 86, 16).r,
                    child: Text(
                      widget.primaryCategory ==
                              PrimaryCategory.practiceAssessment
                          ? EnglishLang.keepLearning
                          : widget.apiResponse['passPercentage'] == null
                              ? (widget.apiResponse['pass']
                                  ? AppLocalizations.of(context)!.mPass
                                  : EnglishLang.failed)
                              : (widget.apiResponse['overallResult'] >=
                                      widget.apiResponse['passPercentage']
                                  ? widget.apiResponse['overallResult'] == 100
                                      ? EnglishLang.acedAssessment
                                      : EnglishLang.passedSuccessfully
                                  : EnglishLang.tryAgain),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.0.sp,
                          letterSpacing: 0.25),
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
        widget.apiResponse['children'] == null
            ? Container()
            : Column(
                children: [
                  for (var i = 0;
                      i < widget.apiResponse['children'].length;
                      i++)
                    Container(
                      width: double.infinity.w,
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
                                          AppColors.primaryBlue,
                                          BlendMode.srcIn),
                                    ),
                                    SizedBox(width: 8.0.w),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .mTotalQuestion,
                                      style: GoogleFonts.lato(
                                          decoration: TextDecoration.none,
                                          color: AppColors.greys87,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.25),
                                    )
                                  ],
                                ),
                                Spacer(), // Add space between text and icon
                                Text(
                                  widget.apiResponse['children'][i]['total'] ==
                                          1
                                      ? '${widget.apiResponse['children'][i]['total']} ${AppLocalizations.of(context)!.mCommonQuestion}'
                                      : '${widget.apiResponse['children'][i]['total']} ${AppLocalizations.of(context)!.mCommonQuestions}',
                                  style: GoogleFonts.lato(
                                      decoration: TextDecoration.none,
                                      color: AppColors.greys87,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.25),
                                )
                              ],
                            ),
                            decoration: boxDecoration,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                    top: 24, left: leftPadding, bottom: 16)
                                .r,
                            child: Text(
                              AppLocalizations.of(context)!
                                  .mYourPerformanceSummary,
                              style: GoogleFonts.lato(
                                  color: FeedbackColors.black87,
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.25),
                            ),
                          ),
                          _summaryItem(i),
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

  Widget _summaryItem(int i) {
    return Column(
      children: [
        widget.apiResponse['children'][i]['correct'] > 0
            ? AssessmentCompletedScreenItem(
                itemIndex: i,
                apiResponse: widget.apiResponse,
                color: AppColors.positiveLight,
                type: 'correct',
                title: widget.apiResponse['children'][i]['correct'] == 1
                    ? widget.apiResponse['children'][i]['correct'].toString() +
                        '  ' +
                        AppLocalizations.of(context)!.mStaticOneCorrect
                    : widget.apiResponse['children'][i]['correct'].toString() +
                        '  ' +
                        AppLocalizations.of(context)!.mStaticCorrect)
            : Center(),
        widget.apiResponse['children'][i]['incorrect'] > 0
            ? AssessmentCompletedScreenItem(
                itemIndex: i,
                apiResponse: widget.apiResponse,
                color: AppColors.negativeLight,
                type: 'incorrect',
                title: widget.apiResponse['children'][i]['incorrect'] == 1
                    ? widget.apiResponse['children'][i]['incorrect']
                            .toString() +
                        '  ' +
                        AppLocalizations.of(context)!.mStaticOneIncorrect
                    : widget.apiResponse['children'][i]['incorrect']
                            .toString() +
                        '  ' +
                        AppLocalizations.of(context)!.mStaticIncorrect)
            : Center(),
        widget.apiResponse['children'][i]['blank'] > 0
            ? AssessmentCompletedScreenItem(
                itemIndex: i,
                apiResponse: widget.apiResponse,
                color: AppColors.greys60,
                type: 'blank',
                title: widget.apiResponse['children'][i]['blank'].toString() +
                    '  ' +
                    AppLocalizations.of(context)!.mStaticNotAttempted)
            : Center(),
      ],
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
            width: 0.44.sw,
            child: TextButton(
              onPressed: () async {
                await Navigator.pushReplacement(
                    context,
                    FadeRoute(
                        page: CourseAssessmentPlayer(
                            widget.course,
                            widget.identifier,
                            widget.updateContentProgress,
                            widget.batchId,
                            parentCourseId: widget.course.identifier,
                            resourceNavigateItems: widget.resourceInfo,
                            isFeatured: widget.isFeatured,
                            courseCategory: widget.courseCategory,
                            isPreRequisite: widget.isPreRequisite)));
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.appBarBackground,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50).r,
                    side: BorderSide(color: AppColors.primaryBlue)),
              ),
              child: Text(
                AppLocalizations.of(context)!.mStaticTryAgain,
                style: GoogleFonts.lato(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          Container(
            height: 58,
            width: 0.44.sw,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50).r,
                    side: BorderSide(color: AppColors.primaryBlue)),
              ),
              child: Text(
                AppLocalizations.of(context)!.mFinish,
                style: GoogleFonts.lato(
                  color: AppColors.appBarBackground,
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
