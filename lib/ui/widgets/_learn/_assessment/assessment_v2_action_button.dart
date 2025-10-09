import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../constants/index.dart';

class AssessmentV2ActionButton extends StatelessWidget {
  final StringCallback onButtonPressed;
  final bool isLastSection;
  final String assessmentType;
  final int questionIndex;
  final bool isLastQuestion;
  AssessmentV2ActionButton(
      {required this.onButtonPressed,
      required this.isLastSection,
      required this.assessmentType,
      required this.questionIndex,
      required this.isLastQuestion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.only(top: 8),
      margin: EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          assessmentType != AssessmentType.optionalWeightage
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => onButtonPressed(
                          AssessmentQuestionStatus.MarkForReviewAndNext),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          backgroundColor: AppColors.whiteGradientOne,
                          side: BorderSide(color: AppColors.darkBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(63)).r)),
                      child: Text(
                        AppLocalizations.of(context)!
                            .mStaticMarkForReviewAndNext,
                        style: GoogleFonts.lato(
                          color: AppColors.greys,
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () => onButtonPressed(
                          AssessmentQuestionStatus.clearResponse),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          backgroundColor: AppColors.whiteGradientOne,
                          side: BorderSide(color: AppColors.darkBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(63)).r)),
                      child: Text(
                        AppLocalizations.of(context)!.mStaticClearResponse,
                        style: GoogleFonts.lato(
                          color: AppColors.greys,
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              questionIndex > 0
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: ElevatedButton(
                        onPressed: () =>
                            onButtonPressed(AssessmentQuestionStatus.previous),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            backgroundColor: AppColors.darkBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(63)).r)),
                        child: Text(
                          AppLocalizations.of(context)!.mStaticPrevious,
                          style: GoogleFonts.lato(
                            color: AppColors.appBarBackground,
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : Center(),
              ElevatedButton(
                onPressed: () =>
                    assessmentType == AssessmentType.optionalWeightage &&
                            isLastQuestion
                        ? null
                        : onButtonPressed(AssessmentQuestionStatus.saveAndNext),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor:
                        assessmentType == AssessmentType.optionalWeightage &&
                                isLastQuestion
                            ? AppColors.grey40
                            : AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(63)).r)),
                child: Text(
                  AppLocalizations.of(context)!.mStaticSavenNext,
                  style: GoogleFonts.lato(
                    color: AppColors.appBarBackground,
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              assessmentType != AssessmentType.optionalWeightage &&
                      !isLastSection
                  ? SizedBox(width: 4)
                  : Center(),
              assessmentType != AssessmentType.optionalWeightage &&
                      !isLastSection
                  ? ElevatedButton(
                      onPressed: () =>
                          onButtonPressed(AssessmentQuestionStatus.nextSection),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          backgroundColor: AppColors.darkBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(63)).r)),
                      child: Text(
                        AppLocalizations.of(context)!.mNextSection,
                        style: GoogleFonts.lato(
                          color: AppColors.appBarBackground,
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : Center(),
            ],
          ),
        ],
      ),
    );
  }
}
