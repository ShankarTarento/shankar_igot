import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/_assessment/radio_question_option_weightage.dart';

import '../../../../constants/index.dart';
import '../../index.dart';

class AssessmentWidget extends StatefulWidget {
  final int questionIndex;
  final List microSurvey;
  final String primaryCategory;
  final getAnsweredQuestions;
  final int answeredQuestion;
  final List questionAnswers;
  final bool showAnswer;
  final int sectionIndex;

  const AssessmentWidget(
      {Key? key,
      required this.questionIndex,
      required this.microSurvey,
      required this.primaryCategory,
      required this.questionAnswers,
      this.showAnswer = false,
      this.getAnsweredQuestions,
      required this.sectionIndex,
      this.answeredQuestion = 0})
      : super(key: key);

  @override
  State<AssessmentWidget> createState() => _AssessmentWidgetState();
}

class _AssessmentWidgetState extends State<AssessmentWidget> {
  int answeredQuestion = 0;
  @override
  void initState() {
    super.initState();
    answeredQuestion = widget.answeredQuestion;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.questionIndex >= widget.microSurvey.length
            ? PageLoader(
                bottom: 200,
              )
            : widget.microSurvey[widget.questionIndex]['qType'] ==
                    AssessmentQuestionType.radioType.toUpperCase()
                ? _radioAssessment()
                : widget.microSurvey[widget.questionIndex]['qType'] ==
                            AssessmentQuestionType.checkBoxWeightageType
                                .toUpperCase() ||
                        widget.microSurvey[widget.questionIndex]['qType'] ==
                            AssessmentQuestionType.radioWeightageType
                                .toUpperCase()
                    ? _radioOptionWeightage()
                    : widget.microSurvey[widget.questionIndex]['qType'] ==
                            AssessmentQuestionType.checkBoxType.toUpperCase()
                        ? _multiSelectAssessment()
                        : widget.microSurvey[widget.questionIndex]['qType'] ==
                                AssessmentQuestionType.matchCase.toUpperCase()
                            ? _matchCaseAssessment()
                            : checkIsFTBhaveOptions()
                                ? Container(
                                    color: AppColors.appBarBackground,
                                    child: FTBDropdown(
                                      question: widget.primaryCategory ==
                                              PrimaryCategory.finalAssessment
                                          ? widget.microSurvey[
                                              widget.questionIndex]['choices']
                                          : widget.microSurvey[widget
                                              .questionIndex]['editorState'],
                                      questionText: widget
                                              .microSurvey[widget.questionIndex]
                                          ['body'],
                                      currentIndex: widget.questionIndex + 1,
                                      answerGiven: _getQuestionAnswer(widget
                                              .microSurvey[widget.questionIndex]
                                          ['identifier']),
                                      showAnswer: widget.showAnswer,
                                      parentAction: setUserAnswer,
                                      id: widget
                                              .microSurvey[widget.questionIndex]
                                          ['identifier'],
                                    ))
                                : Container(
                                    color: AppColors.appBarBackground,
                                    child: FillInTheBlankQuestion(
                                      widget.primaryCategory ==
                                              PrimaryCategory.finalAssessment
                                          ? widget.microSurvey[
                                              widget.questionIndex]['choices']
                                          : widget.microSurvey[widget
                                              .questionIndex]['editorState'],
                                      widget.microSurvey[widget.questionIndex]
                                          ['body'],
                                      widget.questionIndex + 1,
                                      _getQuestionAnswer(widget
                                              .microSurvey[widget.questionIndex]
                                          ['identifier']),
                                      widget.showAnswer,
                                      setUserAnswer,
                                      id: widget
                                              .microSurvey[widget.questionIndex]
                                          ['identifier'],
                                    ))
      ],
    );
  }

  Widget _radioAssessment() {
    return Container(
        child: RadioQuestion(
      widget.primaryCategory == PrimaryCategory.finalAssessment
          ? widget.microSurvey[widget.questionIndex]['choices']
          : widget.microSurvey[widget.questionIndex]['editorState'],
      widget.microSurvey[widget.questionIndex]['body'],
      widget.questionIndex + 1,
      _getQuestionAnswer(
          widget.microSurvey[widget.questionIndex]['identifier']),
      widget.showAnswer,
      _getRadioQuestionCorrectAnswer(widget.primaryCategory ==
              PrimaryCategory.finalAssessment
          ? widget.microSurvey[widget.questionIndex]['choices']['options']
          : widget.microSurvey[widget.questionIndex]['editorState']['options']),
      setUserAnswer,
      isNewAssessment: true,
      id: widget.microSurvey[widget.questionIndex]['identifier'],
    ));
  }

  Widget _radioOptionWeightage() {
    return Container(
        child: RadioQuestionOptionWeightage(
      widget.primaryCategory == PrimaryCategory.finalAssessment
          ? widget.microSurvey[widget.questionIndex]['choices']
          : widget.microSurvey[widget.questionIndex]['editorState'],
      widget.microSurvey[widget.questionIndex]['body'],
      widget.questionIndex + 1,
      _getQuestionAnswer(
          widget.microSurvey[widget.questionIndex]['identifier']),
      widget.showAnswer,
      setUserAnswer,
      isNewAssessment: true,
      id: widget.microSurvey[widget.questionIndex]['identifier'],
    ));
  }

  Widget _multiSelectAssessment() {
    return Container(
        child: MultiSelectQuestion(
            widget.primaryCategory == PrimaryCategory.finalAssessment
                ? widget.microSurvey[widget.questionIndex]['choices']
                : widget.microSurvey[widget.questionIndex]['editorState'],
            widget.microSurvey[widget.questionIndex]['body'],
            widget.questionIndex + 1,
            _getQuestionAnswer(
                widget.microSurvey[widget.questionIndex]['identifier']),
            widget.showAnswer,
            setUserAnswer,
            isNewAssessment: true,
            id: widget.microSurvey[widget.questionIndex]['identifier'],
            qType: widget.microSurvey[widget.questionIndex]['qType']));
  }

  Widget _matchCaseAssessment() {
    return Container(
        child: MatchCaseQuestion(
      widget.primaryCategory == PrimaryCategory.finalAssessment
          ? widget.microSurvey[widget.questionIndex]['choices']
          : widget.microSurvey[widget.questionIndex]['editorState'],
      widget.microSurvey[widget.questionIndex]['body'],
      widget.microSurvey[widget.questionIndex]['rhsChoices'],
      widget.questionIndex + 1,
      _getQuestionAnswer(
          widget.microSurvey[widget.questionIndex]['identifier']),
      widget.showAnswer,
      setUserAnswer,
      isNewAssessment: true,
      id: widget.microSurvey[widget.questionIndex]['identifier'],
    ));
  }

  _getQuestionAnswer(_index) {
    var givenAnswer;
    for (int i = 0; i < widget.questionAnswers.length; i++) {
      if (widget.questionAnswers[i]['index'] == _index) {
        if (widget.microSurvey[widget.questionIndex]['qType'] ==
                AssessmentQuestionType.checkBoxWeightageType.toUpperCase() ||
            widget.microSurvey[widget.questionIndex]['qType'] ==
                AssessmentQuestionType.radioWeightageType.toUpperCase()) {
          givenAnswer = {
            'value': widget.questionAnswers[i]['value'],
            'optionIndex': widget.questionAnswers[i]['optionIndex']
          };
        } else {
          givenAnswer = widget.questionAnswers[i]['value'];
        }
      }
    }
    if (widget.microSurvey[widget.questionIndex]['qType'] ==
            AssessmentQuestionType.radioType.toUpperCase() ||
        widget.microSurvey[widget.questionIndex]['qType'] ==
            AssessmentQuestionType.radioWeightageType.toUpperCase() ||
        widget.microSurvey[widget.questionIndex]['qType'] ==
            AssessmentQuestionType.fitb.toUpperCase() ||
        widget.microSurvey[widget.questionIndex]['qType'] ==
            AssessmentQuestionType.fitb ||
        widget.microSurvey[widget.questionIndex]['qType'] ==
            AssessmentQuestionType.ftb.toUpperCase() ||
        widget.microSurvey[widget.questionIndex]['qType'] ==
            AssessmentQuestionType.ftb) {
      return givenAnswer != null ? givenAnswer : '';
    } else if (widget.microSurvey[widget.questionIndex]['qType'] ==
        AssessmentQuestionType.checkBoxWeightageType.toUpperCase()) {
      return givenAnswer != null ? givenAnswer : null;
    } else {
      return givenAnswer != null ? givenAnswer : [];
    }
  }

  int _getRadioQuestionCorrectAnswer(List? options) {
    int answerIndex = -1;
    if (options != null) {
      for (int i = 0; i < options.length; i++) {
        if (options[i]['answer'] is String) {
          if (options[i]['answer'] != null &&
              options[i]['answer'].toString().trim().toLowerCase() == 'true') {
            answerIndex = i;
          }
        } else if (options[i]['answer'] != null && options[i]['answer']) {
          answerIndex = i;
        }
      }
    }
    return answerIndex;
  }

  void setUserAnswer(Map answer) {
    bool matchDetected = false;
    for (int i = 0; i < widget.questionAnswers.length; i++) {
      if (widget.questionAnswers[i]['index'] == answer['index']) {
        setState(() {
          widget.questionAnswers[i]['previousValue'] =
              widget.questionAnswers[i]['value'];
          widget.questionAnswers[i]['previousStatus'] =
              widget.questionAnswers[i]['isCorrect'];
          widget.questionAnswers[i]['value'] = answer['value'];
          widget.questionAnswers[i]['isCorrect'] = answer['isCorrect'];
          widget.questionAnswers[i]['optionIndex'] = answer['optionIndex'];
          matchDetected = true;
        });
      }
    }
    if (!matchDetected) {
      setState(() {
        widget.questionAnswers.add(answer);
      });
    }
    if (widget.questionAnswers.length > 0 &&
        widget.getAnsweredQuestions != null) {
      widget.getAnsweredQuestions(widget.sectionIndex, widget.questionAnswers);
    }
    answeredQuestion = widget.questionAnswers.length;
  }

  bool checkIsFTBhaveOptions() {
    List options = widget.primaryCategory == PrimaryCategory.finalAssessment
        ? widget.microSurvey[widget.questionIndex]['choices']['options']
        : widget.microSurvey[widget.questionIndex]['editorState']['options'];
    if (widget.questionAnswers.length > 0 &&
        widget.getAnsweredQuestions != null) {}
    return (options.isNotEmpty && options.length > 1);
  }
}
