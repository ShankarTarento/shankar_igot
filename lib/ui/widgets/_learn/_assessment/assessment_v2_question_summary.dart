import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/index.dart';
import '../../index.dart';

class AssessmentV2QuestionSummary extends StatefulWidget {
  const AssessmentV2QuestionSummary(
      {Key? key,
      required this.questionIndex,
      required this.microSurvey,
      required this.generateInteractTelemetryData,
      required this.flaggedQuestions,
      required this.savedQuestions,
      required this.notAnsweredQuestions,
      required this.changeQuestion})
      : super(key: key);

  final int questionIndex;
  final List microSurvey;
  final generateInteractTelemetryData;
  final List flaggedQuestions;
  final List savedQuestions;
  final List notAnsweredQuestions;
  final IntCallback changeQuestion;

  @override
  State<AssessmentV2QuestionSummary> createState() =>
      _AssessmentV2QuestionSummaryState();
}

class _AssessmentV2QuestionSummaryState
    extends State<AssessmentV2QuestionSummary> {
  bool _showQuestionIndex = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.whiteGradientOne,
            border: Border(
              bottom: BorderSide(
                color: AppColors.grey16,
                width: 2.0,
              ),
            ),
          ),
          child: Visibility(
            visible: _showQuestionIndex,
            child: Column(
              children: [
                if (widget.questionIndex < widget.microSurvey.length)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16).r,
                    child: AssessmentV2QuestionIndexWidget(
                      microSurvey: widget.microSurvey,
                      generateInteractTelemetryData:
                          widget.generateInteractTelemetryData,
                      questionIndex: widget.questionIndex,
                      flaggedQuestions: widget.flaggedQuestions,
                      savedQuestions: widget.savedQuestions,
                      notAnsweredQuestions: widget.notAnsweredQuestions,
                      changeQuestion: widget.changeQuestion,
                    ),
                  ),
                AssessmentV2ColorCodeWidget(),
              ],
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 8).r,
              height: 26.w,
              width: 50.w,
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4).r,
              decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5))
                      .r),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _showQuestionIndex = !_showQuestionIndex;
                  });
                },
                iconSize: 20.w,
                icon: _showQuestionIndex
                    ? Icon(
                        Icons.arrow_upward_rounded,
                        color: AppColors.appBarBackground,
                      )
                    : Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.appBarBackground,
                      ),
                padding: EdgeInsets.zero,
              ),
            )),
      ],
    );
  }
}
