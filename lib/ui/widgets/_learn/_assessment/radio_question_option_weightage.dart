import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/html_webview_widget.dart';

import '../../../../constants/index.dart';

class RadioQuestionOptionWeightage extends StatefulWidget {
  final question;
  final String? questionText;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  final bool isNewAssessment;
  final String? id;
  RadioQuestionOptionWeightage(this.question, this.questionText,
      this.currentIndex, this.answerGiven, this.showAnswer, this.parentAction,
      {this.isNewAssessment = false, this.id});
  @override
  _RadioQuestionOptionWeightageState createState() =>
      _RadioQuestionOptionWeightageState();
}

class _RadioQuestionOptionWeightageState
    extends State<RadioQuestionOptionWeightage> {
  int _radioValue = 0;
  late String _qId;

  @override
  void initState() {
    super.initState();
    _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
    _radioValue = widget.answerGiven != null && widget.answerGiven != ''
        ? widget.answerGiven['optionIndex']
        : -1;
  }

  @override
  void didUpdateWidget(RadioQuestionOptionWeightage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _radioValue = widget.answerGiven != null && widget.answerGiven != ''
        ? widget.answerGiven['optionIndex']
        : -1;
  }

  @override
  Widget build(BuildContext context) {
    if (_qId !=
        (widget.isNewAssessment ? widget.id : widget.question['questionId'])) {
      _radioValue = widget.answerGiven != null && widget.answerGiven != ''
          ? widget.answerGiven['optionIndex']
          : -1;
      _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
    }
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: HtmlWebviewWidget(
                      htmlText: widget.questionText != null
                          ? widget.questionText
                          : widget.question['question'],
                      textStyle: GoogleFonts.lato(
                          color: FeedbackColors.black87,
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0.sp,
                          height: 1.5))),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.question['options'].length,
                itemBuilder: (context, index) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      decoration: BoxDecoration(
                        color: _radioValue == index
                            ? AppColors.darkBlue.withValues(alpha: 0.16)
                            : AppColors.greys.withValues(alpha: 0.04),
                        borderRadius:
                            BorderRadius.all(const Radius.circular(10.0)).r,
                        border: Border.all(
                          color: _radioValue == index
                              ? AppColors.darkBlue
                              : AppColors.greys.withValues(alpha: 0.04),
                        ),
                      ),
                      child: RadioListTile(
                        activeColor: _radioValue == index
                            ? AppColors.darkBlue
                            : FeedbackColors.black16,
                        groupValue: _radioValue,
                        title: HtmlWebviewWidget(
                            htmlText: widget.isNewAssessment
                                ? widget.question['options'][index]['value']
                                        ['body']
                                    .toString()
                                : widget.question['options'][index]['text'],
                            textStyle: getTextStyle(
                                widget.isNewAssessment
                                    ? widget.question['options'][index]['value']
                                            ['body']
                                        .toString()
                                    : widget.question['options'][index]['text'],
                                fontWeight: FontWeight.w700)),
                        value: index,
                        onChanged: (value) {
                          if (!widget.showAnswer) {
                            widget.parentAction({
                              'index': _qId,
                              // 'question': widget.question['question'],
                              'value': widget.question['options'][index]
                                  ['value']['body'],
                              'isCorrect': widget.isNewAssessment
                                  ? widget.question['options'][index]['answer']
                                  : widget.question['options'][index]
                                      ['isCorrect'],
                              'optionIndex': index
                            });
                            setState(() {
                              _radioValue = index;
                            });
                          }
                          // if (!widget.showAnswer && widget.answerGiven == '') {
                          // }
                        },
                        selected: (_radioValue == index),
                      ));
                },
              ),
            ],
          )),
    );
  }

  TextStyle? getTextStyle(String htmlText,
      {FontWeight fontWeight = FontWeight.w700}) {
    return htmlText.contains('<strong>')
        ? null
        : GoogleFonts.lato(
            color: FeedbackColors.black87,
            fontWeight: fontWeight,
            fontSize: 14,
          );
  }
}
