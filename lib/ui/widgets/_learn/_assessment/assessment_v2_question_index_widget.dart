import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants/index.dart';

class AssessmentV2QuestionIndexWidget extends StatelessWidget {
  final List microSurvey;
  final generateInteractTelemetryData;
  final int questionIndex;
  final List flaggedQuestions;
  final List savedQuestions;
  final List notAnsweredQuestions;
  final IntCallback changeQuestion;

  AssessmentV2QuestionIndexWidget(
      {required this.microSurvey,
      this.generateInteractTelemetryData,
      this.questionIndex = 0,
      required this.flaggedQuestions,
      required this.savedQuestions,
      required this.notAnsweredQuestions,
      required this.changeQuestion});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 16,
        ).r,
        alignment: Alignment.center,
        child: Wrap(
          direction: Axis.horizontal,
          children: microSurvey.map((item) {
            return InkWell(
              onTap: () => questionIndex != (microSurvey.indexOf(item))
                  ? changeQuestion(microSurvey.indexOf(item))
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Stack(
                  children: [
                    flaggedQuestions.contains(microSurvey.indexOf(item))
                        ? Image.asset(
                            'assets/img/assessment_marked_review.png',
                            height: 35.w,
                            width: 35.w,
                          )
                        : savedQuestions.contains(microSurvey.indexOf(item))
                            ? Image.asset(
                                'assets/img/assessment_answered.png',
                                height: 35.w,
                                width: 35.w,
                              )
                            : notAnsweredQuestions
                                    .contains(microSurvey.indexOf(item))
                                ? Image.asset(
                                    'assets/img/assessment_not_answered.png',
                                    height: 35.w,
                                    width: 35.w,
                                  )
                                : Image.asset(
                                    'assets/img/assessment_not_visited.png',
                                    height: 35.w,
                                    width: 35.w,
                                  ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '${microSurvey.indexOf(item) + 1}',
                          style: GoogleFonts.lato(
                            color: (notAnsweredQuestions
                                        .contains(microSurvey.indexOf(item)) ||
                                    flaggedQuestions
                                        .contains(microSurvey.indexOf(item)) ||
                                    savedQuestions
                                        .contains(microSurvey.indexOf(item)))
                                ? AppColors.appBarBackground
                                : AppColors.greys,
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
