import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/feedback/models/micro_survey_model.dart';
import '../../../constants/index.dart';
import '../../../constants/_constants/color_constants.dart';
import './../../constants.dart';

class RadioTypeQuestion extends StatefulWidget {
  final question;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  RadioTypeQuestion(
      {required this.question,
      required this.currentIndex,
      required this.answerGiven,
      required this.showAnswer,
      required this.parentAction});
  @override
  _RadioTypeQuestionState createState() => _RadioTypeQuestionState();
}

class _RadioTypeQuestionState extends State<RadioTypeQuestion> {
  dynamic _radioValue = '';
  int _correctAnswer = 2;
  MicroSurvey? _questions;

  @override
  void initState() {
    super.initState();
    _radioValue = widget.answerGiven;
    _questions = widget.question;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.question.id != _questions!.id) {
      _questions = widget.question;
      _radioValue = widget.answerGiven;
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
                  color: _radioValue == _questions!.options[index]['key'] &&
                          _correctAnswer == index &&
                          widget.showAnswer
                      ? FeedbackColors.positiveLightBg
                      : _radioValue == _questions!.options[index]['key'] &&
                              _correctAnswer != index &&
                              widget.showAnswer
                          ? FeedbackColors.negativeLightBg
                          : _correctAnswer == index && widget.showAnswer
                              ? FeedbackColors.positiveLightBg
                              : AppColors.appBarBackground,
                  borderRadius: BorderRadius.all(const Radius.circular(4.0).r),
                  border: Border.all(
                      color: _radioValue == _questions!.options[index]['key'] &&
                              _correctAnswer == index &&
                              widget.showAnswer
                          ? FeedbackColors.positiveLight
                          : _radioValue == _questions!.options[index]['key'] &&
                                  _correctAnswer != index &&
                                  widget.showAnswer
                              ? FeedbackColors.negativeLight
                              : _radioValue == _questions!.options[index]['key']
                                  ? AppColors.darkBlue
                                  : _correctAnswer == index && widget.showAnswer
                                      ? FeedbackColors.positiveLight
                                      : FeedbackColors.black16),
                ),
                child: RadioListTile(
                  selected: true,
                  activeColor: AppColors.darkBlue,
                  groupValue: _radioValue,
                  title: Text(
                    _questions!.options[index]['key'].toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  value: _questions!.options[index]['key'].toString(),
                  onChanged: (value) {
                    if (!widget.showAnswer) {
                      widget.parentAction(
                        {
                          'index': _questions!.id - 1,
                          'question': _questions!.question,
                          'value': value
                        },
                      );
                      setState(
                        () {
                          _radioValue = value;
                        },
                      );
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
