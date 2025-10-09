import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './../../../../models/_models/assessment_question_model.dart';
import './../../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SingleAnswerQuestion extends StatefulWidget {
  final AssessmentQuestion question;
  SingleAnswerQuestion(this.question);
  @override
  _SingleAnswerQuestionState createState() => _SingleAnswerQuestionState();
}

class _SingleAnswerQuestionState extends State<SingleAnswerQuestion> {
  int _radioValue = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(32).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 15).r,
              child: Text(
                'Q' +
                    widget.question.id.toString() +
                    '${AppLocalizations.of(context)!.mStaticOf}' +
                    ' 3',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 15).r,
              child: Text(
                widget.question.question,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.question.options.length,
              itemBuilder: (context, index) {
                return Container(
                    width: 1.sw,
                    // padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(top: 10, bottom: 10).r,
                    decoration: BoxDecoration(
                      color: _radioValue == index + 1
                          ? Color.fromRGBO(0, 116, 182, 0.05)
                          : AppColors.appBarBackground,
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0)).r,
                      border: Border.all(
                          color: _radioValue == index + 1
                              ? AppColors.primaryThree
                              : AppColors.grey16),
                    ),
                    child: RadioListTile(
                      groupValue: _radioValue,
                      title: Text(
                        widget.question.options[index],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      value: index + 1,
                      onChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            _radioValue = value;
                          });
                        }
                      },
                    ));
              },
            ),
          ],
        ));
  }
}
