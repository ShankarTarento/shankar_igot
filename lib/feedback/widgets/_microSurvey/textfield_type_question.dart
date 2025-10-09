import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/index.dart';
import '../../../constants/_constants/color_constants.dart';
import './../../constants.dart';

class TextFieldTypeQuestion extends StatefulWidget {
  final question;
  final int currentIndex;
  final answerGiven;
  final ValueChanged<Map> parentAction;

  TextFieldTypeQuestion(
      this.question, this.currentIndex, this.answerGiven, this.parentAction);
  @override
  _TextFieldTypeQuestionState createState() => _TextFieldTypeQuestionState();
}

class _TextFieldTypeQuestionState extends State<TextFieldTypeQuestion> {
  final textController = TextEditingController();
  int? _currentIndex;
  Color borderColor = FeedbackColors.textFieldBorder;

  @override
  void initState() {
    super.initState();
    // if (widget.question.answer != null) {
    //   textController.text = widget.question.answer;
    // }
  }

  _reloadData() {
    textController.text = '';
    if (widget.question.answer != null) {
      textController.text = widget.question.answer;
    }
    if (widget.answerGiven != null) {
      textController.text = widget.answerGiven;
    }
    _currentIndex = widget.currentIndex;
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex != widget.currentIndex) {
      _reloadData();
      // widget.parentAction({
      //   'index': widget.question.id - 1,
      //   'question': widget.question.question,
      //   'value': textController.text
      // });
    }

    return Container(
        padding: const EdgeInsets.all(32).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 15).r,
              child: Text(
                widget.question.question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Container(
              height: widget.question.fieldType == QuestionType.textarea
                  ? 137.w
                  : 50.w,
              width: 360.w,
              padding: const EdgeInsets.only(left: 10).r,
              child: TextField(
                keyboardType: widget.question.fieldType == QuestionType.textarea
                    ? TextInputType.multiline
                    : widget.question.fieldType == QuestionType.email
                        ? TextInputType.emailAddress
                        : (widget.question.fieldType == QuestionType.numeric ||
                                widget.question.fieldType == QuestionType.date)
                            ? TextInputType.number
                            : TextInputType.text,
                textInputAction: TextInputAction.done,
                textCapitalization:
                    widget.question.fieldType == QuestionType.textarea
                        ? TextCapitalization.sentences
                        : TextCapitalization.none,
                controller: textController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                onTap: () => setState(() {
                  borderColor = AppColors.darkBlue;
                }),
                onEditingComplete: () {
                  setState(() {
                    borderColor = FeedbackColors.textFieldBorder;
                  });
                  FocusScope.of(context).unfocus();
                },
                onChanged: (text) {
                  widget.parentAction({
                    'index': widget.question.id - 1,
                    'question': widget.question.question,
                    'value': text
                  });
                },
              ),
              decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  border: Border.all(color: borderColor)),
            ),
          ],
        ));
  }
}
