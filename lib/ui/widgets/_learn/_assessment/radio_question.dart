import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/html_webview_widget.dart';

import '../../../../constants/index.dart';

class RadioQuestion extends StatefulWidget {
  final question;
  final String? questionText;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final int? correctAnswer;
  final ValueChanged<Map> parentAction;
  final bool isNewAssessment;
  final String? id;
  RadioQuestion(this.question, this.questionText, this.currentIndex,
      this.answerGiven, this.showAnswer, this.correctAnswer, this.parentAction,
      {this.isNewAssessment = false, this.id});
  @override
  _RadioQuestionState createState() => _RadioQuestionState();
}

class _RadioQuestionState extends State<RadioQuestion> {
  String _radioValue = '';
  int? _correctAnswer;
  late String _qId;

  @override
  void initState() {
    super.initState();
    _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
    _radioValue = widget.answerGiven;
    _correctAnswer = widget.correctAnswer;
  }

  @override
  void didUpdateWidget(RadioQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    _radioValue = widget.answerGiven;
    _correctAnswer = widget.correctAnswer;
  }

  @override
  Widget build(BuildContext context) {
    if (_qId !=
        (widget.isNewAssessment ? widget.id : widget.question['questionId'])) {
      _radioValue = widget.answerGiven;
      _correctAnswer = widget.correctAnswer;
      _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
    }
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 30).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 15).r,
                  child: HtmlWebviewWidget(
                    htmlText: widget.questionText != null
                        ? widget.questionText
                        : widget.question['question'],
                    textStyle: GoogleFonts.lato(
                        color: FeedbackColors.black87,
                        fontWeight: FontWeight.w400,
                        fontSize: 14.0.sp,
                        height: 1.5),
                  )),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.question['options'].length,
                itemBuilder: (context, index) {
                  return Container(
                      width: 1.sw,
                      margin: const EdgeInsets.only(top: 8, bottom: 4).r,
                      decoration: BoxDecoration(
                        color: _radioValue ==
                                    (widget.isNewAssessment
                                        ? widget.question['options'][index]
                                                ['value']['body']
                                            .toString()
                                        : widget.question['options'][index]
                                            ['value']) &&
                                _correctAnswer == index &&
                                widget.showAnswer
                            ? FeedbackColors.positiveLightBg
                            : _radioValue ==
                                        (widget.isNewAssessment
                                            ? widget.question['options'][index]
                                                    ['value']['body']
                                                .toString()
                                            : widget.question['options'][index]
                                                ['text']) &&
                                    _correctAnswer != index &&
                                    widget.showAnswer
                                ? FeedbackColors.negativeLightBg
                                : _radioValue ==
                                        (widget.isNewAssessment
                                            ? widget.question['options'][index]['value'] != null
                                                ? widget.question['options'][index]['value']['body'].toString()
                                                : ''
                                            : widget.question['options'][index]['text'])
                                    ? AppColors.darkBlue.withValues(alpha: 0.16)
                                    : _correctAnswer == index && widget.showAnswer
                                        ? FeedbackColors.positiveLightBg
                                        : AppColors.greys.withValues(alpha: 0.04),
                        borderRadius:
                            BorderRadius.all(const Radius.circular(10.0)).r,
                        border: Border.all(
                          color: _radioValue ==
                                      (widget.isNewAssessment
                                          ? widget.question['options'][index]
                                                  ['value']['body']
                                              .toString()
                                          : widget.question['options'][index]
                                              ['text']) &&
                                  _correctAnswer == index &&
                                  widget.showAnswer
                              ? FeedbackColors.positiveLight
                              : _radioValue ==
                                          (widget.isNewAssessment
                                              ? widget.question['options']
                                                      [index]['value']['body']
                                                  .toString()
                                              : widget.question['options']
                                                  [index]['text']) &&
                                      _correctAnswer != index &&
                                      widget.showAnswer
                                  ? FeedbackColors.negativeLight
                                  : _radioValue ==
                                          (widget.isNewAssessment
                                              ? widget.question['options'][index]['value']['body'].toString()
                                              : widget.question['options'][index]['text'])
                                      ? AppColors.darkBlue
                                      : _correctAnswer == index && widget.showAnswer
                                          ? FeedbackColors.positiveLight
                                          : AppColors.greys.withValues(alpha: 0.04),
                        ),
                      ),
                      child: RadioListTile<String>(
                        activeColor: _radioValue ==
                                    (widget.isNewAssessment
                                        ? widget.question['options'][index]['value']['body']
                                            .toString()
                                        : widget.question['options'][index]
                                            ['text']) &&
                                _correctAnswer == index &&
                                widget.showAnswer
                            ? FeedbackColors.positiveLight
                            : _radioValue ==
                                        (widget.isNewAssessment
                                            ? widget.question['options'][index]
                                                    ['value']['body']
                                                .toString()
                                            : widget.question['options'][index]
                                                ['text']) &&
                                    _correctAnswer != index &&
                                    widget.showAnswer
                                ? FeedbackColors.negativeLight
                                : _radioValue ==
                                        (widget.isNewAssessment
                                            ? widget.question['options'][index]
                                                    ['value']['body']
                                                .toString()
                                            : widget.question['options'][index]['text'])
                                    ? AppColors.darkBlue
                                    : _correctAnswer == index && widget.showAnswer
                                        ? FeedbackColors.positiveLight
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
                        value: widget.isNewAssessment
                            ? widget.question['options'][index]['value']['body']
                                .toString()
                            : widget.question['options'][index]['text'],
                        onChanged: (value) {
                          if (!widget.showAnswer) {
                            widget.parentAction({
                              'index': _qId,
                              // 'question': widget.question['question'],
                              'value': value,
                              'isCorrect': widget.isNewAssessment
                                  ? widget.question['options'][index]['answer']
                                  : widget.question['options'][index]
                                      ['isCorrect']
                            });
                            setState(() {
                              _radioValue = value.toString();
                            });
                          }
                          // if (!widget.showAnswer && widget.answerGiven == '') {
                          // }
                        },
                        selected:
                            (_radioValue == widget.question['options'][index]),
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
            fontSize: 14.sp,
          );
  }
}
