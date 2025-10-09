import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../../feedback/constants.dart';
import '../../../../util/helper.dart';
import './../../../../constants/index.dart';

class SingleFillInTheBlankQuestion extends StatefulWidget {
  final question;
  final int currentIndex;
  final answerGiven;
  final bool showAnswer;
  final ValueChanged<Map> parentAction;
  SingleFillInTheBlankQuestion(this.question, this.currentIndex,
      this.answerGiven, this.showAnswer, this.parentAction);
  @override
  _SingleFillInTheBlankQuestionState createState() =>
      _SingleFillInTheBlankQuestionState();
}

class _SingleFillInTheBlankQuestionState
    extends State<SingleFillInTheBlankQuestion> {
  final TextEditingController _optionController = TextEditingController();
  List<String> _questionText = [];
  late String _questionId;

  @override
  void initState() {
    _questionText =
        widget.question['question'].split(ASSESSMENT_FITB_QUESTION_INPUT);
    _questionId = widget.question['questionId'];
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questionId != widget.question['questionId']) {
      _optionController.text = widget.answerGiven;
      _questionId = widget.question['questionId'];
    }
    return Container(
        height: 1.sh - 30.w,
        padding: const EdgeInsets.all(32).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 15),
              child: HtmlWidget(Helper.decodeHtmlEntities(_questionText[0]),
                  textStyle: getTextStyle(_questionText[0])),
            ),
            Container(
                width: 1.sw,
                margin: const EdgeInsets.only(bottom: 20).r,
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  borderRadius: BorderRadius.circular(4).r,
                ),
                child: Focus(
                  child: TextFormField(
                    onEditingComplete: () {
                      widget.parentAction({
                        'index': widget.question['questionId'],
                        'isCorrect': widget.question['options'][0]['isCorrect'],
                        'value': _optionController.text,
                        'optionId': widget.question['options'][0]['optionId'],
                        'text': widget.question['options'][0]['text'],
                      });
                    },
                    enabled:
                        (widget.answerGiven != null && widget.answerGiven != '')
                            ? false
                            : true,
                    textInputAction: TextInputAction.done,
                    controller: _optionController,
                    style: GoogleFonts.lato(fontSize: 14.0.sp),
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0).r,
                        // border: OutlineInputBorder(
                        //     borderSide: BorderSide(color: AppColors.grey16)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey16),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.darkBlue),
                        ),
                        hintText: '',
                        hintStyle: Theme.of(context).textTheme.labelLarge),
                  ),
                )),
            Container(
              padding: const EdgeInsets.only(bottom: 15),
              child: HtmlWidget(Helper.decodeHtmlEntities(_questionText[1]),
                  textStyle: getTextStyle(_questionText[1])),
            ),
            widget.showAnswer
                ? Container(
                    child: Text(
                      widget.question['options'][0]['text'],
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.greenOne),
                    ),
                  )
                : Center()
          ],
        ));
  }

  TextStyle? getTextStyle(String htmlText) {
    return htmlText.contains('<strong>')
        ? null
        : GoogleFonts.lato(
            color: FeedbackColors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          );
  }
}
