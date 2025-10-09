import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/index.dart';
import './../../../../feedback/constants.dart';
import 'package:webview_flutter/webview_flutter.dart' as Webview;

import 'html_webview_widget.dart';

class MultiSelectQuestion extends StatefulWidget {
  final question;
  final String? _questionText;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  final bool isNewAssessment;
  final String? id;
  final String? qType;
  MultiSelectQuestion(this.question, this._questionText, this.currentIndex,
      this.answerGiven, this.showAnswer, this.parentAction,
      {this.isNewAssessment = false, this.id, this.qType});
  @override
  _MultiSelectQuestionQuestionState createState() =>
      _MultiSelectQuestionQuestionState();
}

class _MultiSelectQuestionQuestionState extends State<MultiSelectQuestion> {
  Map<int, bool> isChecked = {
    1: false,
    2: false,
    3: false,
    4: false,
  };
  List selectedOptions = [];
  List<int> _correctAnswer = [];
  late String _qId;
  Webview.WebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
    _updateChanges();
  }

  _updateChanges() async {
    if (widget.question['options'].length > 4) {
      for (var i = 5; i < widget.question['options'].length + 1; i++) {
        final entry = <int, bool>{i: false};
        isChecked.addEntries(entry.entries);
      }
    }
    if (widget.answerGiven != null) {
      selectedOptions = widget.answerGiven;
      for (int i = 0; i < widget.question['options'].length; i++) {
        if ((widget.isNewAssessment &&
                widget.question['options'][i]['value'] != null) ||
            !widget.isNewAssessment) {
          if (selectedOptions.contains(widget.isNewAssessment
              ? widget.question['options'][i]['value']['value']
              : widget.question['options'][i]['optionId'])) {
            isChecked[i + 1] = true;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_qId !=
        (widget.isNewAssessment ? widget.id : widget.question['questionId'])) {
      isChecked = {
        1: false,
        2: false,
        3: false,
        4: false,
      };
      _updateChanges();
      _qId = widget.isNewAssessment ? widget.id : widget.question['questionId'];
    } else if (_qId ==
            (widget.isNewAssessment
                ? widget.id
                : widget.question['questionId']) &&
        isChecked.containsValue(true)) {
      isChecked = {
        1: false,
        2: false,
        3: false,
        4: false,
      };
      _updateChanges();
    }
    return SingleChildScrollView(
      child: Container(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 15).r,
                  child: HtmlWebviewWidget(
                      htmlText: widget._questionText != null
                          ? widget._questionText
                          : widget.question['question'],
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(height: 1.5.w))),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.question['options'].length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 1.sw,
                    // padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(top: 10, bottom: 4).r,
                    decoration: BoxDecoration(
                      color: isChecked[index + 1]! &&
                              _correctAnswer.contains(index) &&
                              widget.showAnswer
                          ? FeedbackColors.positiveLightBg
                          : isChecked[index + 1]! &&
                                  !_correctAnswer.contains(index) &&
                                  widget.showAnswer
                              ? FeedbackColors.negativeLightBg
                              : _correctAnswer.contains(index) &&
                                      widget.showAnswer
                                  ? FeedbackColors.positiveLightBg
                                  : _correctAnswer.contains(index) &&
                                          widget.showAnswer
                                      ? FeedbackColors.negativeLightBg
                                      : isChecked[index + 1]! &&
                                              _correctAnswer.contains(index) &&
                                              widget.showAnswer
                                          ? FeedbackColors.positiveLightBg
                                          : isChecked[index + 1]!
                                              ? AppColors.darkBlue
                                                  .withValues(alpha: 0.16)
                                              : AppColors.greys
                                                  .withValues(alpha: 0.04),
                      borderRadius:
                          BorderRadius.all(const Radius.circular(10.0)).r,
                      border: Border.all(
                        color: isChecked[index + 1]! &&
                                _correctAnswer.contains(index) &&
                                widget.showAnswer
                            ? FeedbackColors.positiveLight
                            : isChecked[index + 1]! &&
                                    !_correctAnswer.contains(index) &&
                                    widget.showAnswer
                                ? FeedbackColors.negativeLight
                                : _correctAnswer.contains(index) &&
                                        widget.showAnswer
                                    ? FeedbackColors.positiveLight
                                    : _correctAnswer.contains(index) &&
                                            widget.showAnswer
                                        ? FeedbackColors.negativeLight
                                        : isChecked[index + 1]! &&
                                                _correctAnswer
                                                    .contains(index) &&
                                                widget.showAnswer
                                            ? FeedbackColors.positiveLight
                                            : isChecked[index + 1]!
                                                ? AppColors.darkBlue
                                                : AppColors.greys
                                                    .withValues(alpha: 0.04),
                      ),
                    ),
                    child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        side: BorderSide(width: 0.8.w),
                        activeColor:
                            _correctAnswer.contains(index) && widget.showAnswer
                                ? FeedbackColors.positiveLight
                                : !_correctAnswer.contains(index) &&
                                        widget.showAnswer
                                    ? FeedbackColors.negativeLight
                                    : AppColors.darkBlue,
                        dense: true,
                        //font change
                        title: HtmlWebviewWidget(
                            htmlText: widget.isNewAssessment
                                ? widget.question['options'][index]['value'] !=
                                        null
                                    ? widget.question['options'][index]['value']
                                            ['body']
                                        .toString()
                                    : ''
                                : widget.question['options'][index]['text'],
                            textStyle: getTextStyle(widget.isNewAssessment
                                ? widget.question['options'][index]['value'] !=
                                        null
                                    ? widget.question['options'][index]['value']
                                            ['body']
                                        .toString()
                                    : ''
                                : widget.question['options'][index]['text'])),
                        value: isChecked[index + 1],
                        onChanged: (bool? value) {
                          if (!widget.showAnswer) {
                            if (value!) {
                              if (!selectedOptions.contains(
                                  widget.isNewAssessment
                                      ? widget.question['options'][index]
                                          ['value']['value']
                                      : widget.question['options'][index]
                                          ['optionId'])) {
                                selectedOptions.add(widget.isNewAssessment
                                    ? widget.question['options'][index]['value']
                                        ['value']
                                    : widget.question['options'][index]
                                        ['optionId']);
                              }
                            } else {
                              if (selectedOptions.contains(
                                  widget.isNewAssessment
                                      ? widget.question['options'][index]
                                          ['value']['value']
                                      : widget.question['options'][index]
                                          ['optionId'])) {
                                selectedOptions.remove(widget.isNewAssessment
                                    ? widget.question['options'][index]['value']
                                        ['value']
                                    : widget.question['options'][index]
                                        ['optionId']);
                              }
                            }
                            widget.parentAction({
                              'index': _qId,
                              'isCorrect': widget.isNewAssessment
                                  ? widget.question['options'][index]['answer']
                                  : widget.question['options'][index]
                                      ['isCorrect'],
                              'value': selectedOptions
                            });
                            setState(() {
                              isChecked[index + 1] = value;
                            });
                          }
                        }),
                  );
                },
              ),
            ],
          )),
    );
  }

  TextStyle? getTextStyle(String htmlText) {
    return htmlText.contains('<strong>')
        ? null
        : Theme.of(context).textTheme.displayLarge!.copyWith(
              fontWeight: FontWeight.w600,
            );
  }
}
