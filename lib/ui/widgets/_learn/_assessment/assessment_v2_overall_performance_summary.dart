import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../constants/index.dart';
import '../../../../util/helper.dart';

class AssessmentV2OverallPerformanceSummary extends StatefulWidget {
  final String timeSpent;
  final Map apiResponse;
  final String primaryCategory;
  final VoidCallback? popBack;
  final bool showBack;

  AssessmentV2OverallPerformanceSummary(
      {required this.timeSpent,
      required this.apiResponse,
      required this.primaryCategory,
      this.popBack,
      this.showBack = false});

  @override
  State<AssessmentV2OverallPerformanceSummary> createState() =>
      _AssessmentV2OverallPerformanceSummaryState();
}

class _AssessmentV2OverallPerformanceSummaryState
    extends State<AssessmentV2OverallPerformanceSummary> {
  late List overallSummaryData;
  int overallSummaryDisplayCount = 3;
  bool showFullOverallPerformanceSummary = false;

  @override
  void initState() {
    super.initState();
  }

  void updateSummaryList() {
    overallSummaryData = [
      widget.primaryCategory != PrimaryCategory.practiceAssessment &&
              widget.apiResponse['totalSectionMarks'] != null
          ? summaryWidget(
              bgColor: AppColors.blueBgShade,
              imagePath: 'assets/img/speed.svg',
              summaryText:
                  '${Helper.handleNumber(widget.apiResponse['totalSectionMarks'])}/${widget.apiResponse['totalMarks']}',
              description: AppLocalizations.of(context)!.mAssessmentScore)
          : null,
      widget.primaryCategory != PrimaryCategory.practiceAssessment &&
              widget.apiResponse['timeTakenForAssessment'] != null
          ? summaryWidget(
              bgColor: AppColors.timeGreenShade,
              imagePath: 'assets/img/nest_clock_farsight_analog.svg',
              summaryText: DateFormat('HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      widget.apiResponse['timeTakenForAssessment'],
                      isUtc: true)),
              description: AppLocalizations.of(context)!.mAssessmentTimeTaken)
          : null,
      summaryWidget(
          bgColor: AppColors.pinkBgShade,
          imagePath: 'assets/img/assignment.svg',
          summaryText: widget.apiResponse['total'] == null
              ? '${widget.apiResponse['correct'] + widget.apiResponse['incorrect']}/${widget.apiResponse['correct'] + widget.apiResponse['incorrect'] + widget.apiResponse['blank']}'
              : '${widget.apiResponse['total'] - widget.apiResponse['blank']}/${widget.apiResponse['total']}',
          description: AppLocalizations.of(context)!.mAssessmentAttempted),
      summaryWidget(
          bgColor: AppColors.orangeCorrectShade,
          imagePath: 'assets/img/check_circle.svg',
          summaryText: widget.apiResponse['total'] == null
              ? '${widget.apiResponse['correct']}/${widget.apiResponse['correct'] + widget.apiResponse['incorrect'] + widget.apiResponse['blank']}'
              : '${widget.apiResponse['correct']}/${widget.apiResponse['total']}',
          description: AppLocalizations.of(context)!.mAssessmentCorrect),
      summaryWidget(
          bgColor: AppColors.redBgShade,
          imagePath: 'assets/img/assessment_cancel.svg',
          summaryText: widget.apiResponse['incorrect'].toString(),
          description: AppLocalizations.of(context)!.mAssessmentWrong),
      widget.apiResponse['overallResult'] != null
          ? summaryWidget(
              bgColor: AppColors.greenBgShade,
              imagePath: 'assets/img/target.svg',
              summaryText:
                  '${double.parse(widget.apiResponse['overallResult'].toString()).toStringAsFixed(2)}%',
              description: AppLocalizations.of(context)!.mAssessmentAccuracy)
          : null
    ];
    overallSummaryData.removeWhere((item) => item == null);
  }

  @override
  Widget build(BuildContext context) {
    updateSummaryList();
    return Column(
      children: [
        Row(
          children: [
            widget.showBack
                ? InkWell(
                    onTap: () {
                      widget.popBack!();
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.darkBlue,
                        size: 30,
                        weight: 10,
                      ),
                    ),
                  )
                : SizedBox(
                    width: 16,
                  ),
            summaryScreenHeader(AppLocalizations.of(context)!
                .mAssessmentMyOverallPerformanceSummary),
          ],
        ),
        ...overallSummaryData.take(overallSummaryDisplayCount).toList(),
        SizedBox(height: 8.w),
        overallSummaryData.length > 3
            ? Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showFullOverallPerformanceSummary =
                          !showFullOverallPerformanceSummary;
                      overallSummaryDisplayCount =
                          showFullOverallPerformanceSummary
                              ? overallSummaryData.length
                              : 3;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16).r,
                      backgroundColor: showFullOverallPerformanceSummary
                          ? AppColors.darkBlue
                          : AppColors.appBarBackground,
                      side: BorderSide(color: AppColors.darkBlue),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(63)).r)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showFullOverallPerformanceSummary
                            ? AppLocalizations.of(context)!.mAssessmentCollapse
                            : AppLocalizations.of(context)!.mStaticViewAll,
                        style: GoogleFonts.lato(
                          color: showFullOverallPerformanceSummary
                              ? AppColors.appBarBackground
                              : AppColors.darkBlue,
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.25,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        showFullOverallPerformanceSummary
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 20.sp,
                        color: showFullOverallPerformanceSummary
                            ? AppColors.appBarBackground
                            : AppColors.darkBlue,
                      )
                    ],
                  ),
                ),
              )
            : Center(),
      ],
    );
  }

  Container summaryWidget(
      {required Color bgColor,
      required String imagePath,
      required String summaryText,
      required String description}) {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 16, right: 16).r,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4).r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)).r,
        color: AppColors.appBarBackground,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 45.w,
                height: 45.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(63).r, color: bgColor),
              ),
              Positioned.fill(
                child: Center(
                  child: SvgPicture.asset(
                    imagePath,
                    colorFilter: ColorFilter.mode(
                        AppColors.appBarBackground, BlendMode.srcIn),
                    height: 30.w,
                    width: 30.w,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summaryText,
                style: GoogleFonts.robotoSlab(
                    decoration: TextDecoration.none,
                    color: AppColors.greys87,
                    fontSize: 18.4.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.25),
              ),
              SizedBox(height: 4.0.w),
              Text(
                description,
                style: GoogleFonts.robotoSlab(
                    decoration: TextDecoration.none,
                    color: AppColors.greys87,
                    fontSize: 18.4.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.25),
              ),
            ],
          )
        ],
      ),
    );
  }

  Padding summaryScreenHeader(String text) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 16, 8).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: GoogleFonts.robotoSlab(
                color: AppColors.darkBlue,
                fontSize: 20.0.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
                padding: EdgeInsets.only(top: 8).r,
                width: 100.w,
                child: Divider(
                  thickness: 4.w,
                  color: AppColors.orangeDividerShade,
                )),
          ],
        ));
  }
}
