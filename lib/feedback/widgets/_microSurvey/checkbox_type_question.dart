import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/feedback/models/micro_survey_model.dart';
import '../../../constants/index.dart';
import '../../../constants/_constants/color_constants.dart';
import './../../constants.dart';

class CheckboxTypeQuestion extends StatefulWidget {
  final question;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  CheckboxTypeQuestion(
      {required this.question,
      required this.currentIndex,
      required this.answerGiven,
      required this.showAnswer,
      required this.parentAction});
  @override
  _CheckboxTypeQuestionState createState() => _CheckboxTypeQuestionState();
}

class _CheckboxTypeQuestionState extends State<CheckboxTypeQuestion> {
  Map<int, bool> isChecked = {
    1: false,
    2: false,
    3: false,
    4: false,
  };
  List<int> _correctAnswer = [2, 3];
  MicroSurvey? _questions;
  dynamic _answerGiven;

  @override
  void initState() {
    super.initState();
    _questions = widget.question;
    _answerGiven = widget.answerGiven;
    if (_questions!.options.length > 4) {
      for (var i = 5; i < _questions!.options.length + 1; i++) {
        final entry = <int, bool>{i: false};
        isChecked.addEntries(entry.entries);
      }
    }

    if (_answerGiven != null) {
      for (int i = 0; i < _questions!.options.length; i++) {
        if (_answerGiven.contains(_questions!.options[i]['key'])) {
          isChecked[i + 1] = true;
        } else {
          isChecked[i + 1] = false;
        }
      }
    } else {
      _answerGiven = [];
      for (var i = 0; i < _questions!.options.length; i++) {
        isChecked[i + 1] = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.question.id != _questions!.id) {
      setState(() {
        _questions = null;
        _questions = widget.question;
        _answerGiven = widget.answerGiven;
      });
      if (_questions!.options.length > 4) {
        for (var i = 5; i < _questions!.options.length + 1; i++) {
          final entry = <int, bool>{i: false};
          isChecked.addEntries(entry.entries);
        }
      }

      if (_answerGiven != null) {
        for (int i = 0; i < _questions!.options.length; i++) {
          if (_answerGiven.contains(_questions!.options[i]['key'])) {
            isChecked[i + 1] = true;
          } else {
            isChecked[i + 1] = false;
          }
        }
      } else {
        _answerGiven = [];
        for (var i = 0; i < _questions!.options.length; i++) {
          isChecked[i + 1] = false;
        }
      }
    }
    return Container(
        padding: const EdgeInsets.all(32).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 15).r,
              child: Text(
                _questions!.question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _questions!.options.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 1.sw,
                  margin: const EdgeInsets.only(top: 10, bottom: 10).r,
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
                                        : AppColors.appBarBackground,
                    borderRadius:
                        BorderRadius.all(const Radius.circular(4.0).r),
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
                                              _correctAnswer.contains(index) &&
                                              widget.showAnswer
                                          ? FeedbackColors.positiveLight
                                          : isChecked[index + 1]!
                                              ? AppColors.darkBlue
                                              : FeedbackColors.black16,
                    ),
                  ),
                  child: CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: _correctAnswer.contains(index) &&
                              widget.showAnswer
                          ? FeedbackColors.positiveLight
                          : !_correctAnswer.contains(index) && widget.showAnswer
                              ? FeedbackColors.negativeLight
                              : AppColors.darkBlue,
                      dense: true,
                      //font change
                      title: Text(
                        _questions!.options[index]['key'].toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      value: isChecked[index + 1],
                      onChanged: (bool? value) {
                        if (!widget.showAnswer) {
                          if (value!) {
                            if (!_answerGiven
                                .contains(_questions!.options[index]['key'])) {
                              _answerGiven
                                  .add(_questions!.options[index]['key']);
                            }
                          } else {
                            if (_answerGiven
                                .contains(_questions!.options[index]['key'])) {
                              _answerGiven
                                  .remove(_questions!.options[index]['key']);
                            }
                          }
                          widget.parentAction({
                            'index': _questions!.id - 1,
                            'question': _questions!.question,
                            'value': _answerGiven
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
        ));
  }
}
