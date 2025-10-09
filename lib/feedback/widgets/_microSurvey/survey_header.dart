import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SurveyHeader extends StatefulWidget {
  final int questionIndex;
  final int? totalQuestions;
  SurveyHeader({required this.questionIndex, this.totalQuestions});
  @override
  _SurveyCompletedState createState() => _SurveyCompletedState();
}

class _SurveyCompletedState extends State<SurveyHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 0).r,
      child: Text(
        'Question ${widget.questionIndex + 1} of ${widget.totalQuestions}',
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }
}
