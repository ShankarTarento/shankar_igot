import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EnrollmentDetailsForm extends StatefulWidget {
  final Map? surveyform;
  final int? formId;
  final String? courseDetails;
  final String? courseId;
  final Batch? batch;
  final ValueChanged<String>? enrollParentAction;
  final Function()? previousPage;

  const EnrollmentDetailsForm(
      {Key? key,
      this.surveyform,
      this.courseId,
      this.formId,
      this.enrollParentAction,
      this.batch,
      this.previousPage,
      this.courseDetails})
      : super(key: key);

  @override
  State<EnrollmentDetailsForm> createState() => _EnrollmentDetailsFormState();
}

class _EnrollmentDetailsFormState extends State<EnrollmentDetailsForm> {
  Map<int, String> answerVal = {};
  int radioIndex = 0;
  List mandatoryFields = [];
  bool enableConfirmbtn = false;
  List surveyFields = [];
  List<TextEditingController> textFieldControllers = [];
  List checkedItems = [];
  Map<int, List> checkboxAnswerVal = {};
  var formResponse;
  final LearnService learnService = LearnService();
  double rating = 3;

  @override
  void initState() {
    surveyFields = widget.surveyform!['fields'] != null
        ? widget.surveyform!['fields']
        : [];
    mandatoryFields = widget.surveyform?['mandatoryFields'] != null
        ? widget.surveyform!['mandatoryFields']
        : [];
    if (surveyFields.length == 0) {
    } else {
      for (var i = 0; i < surveyFields.length; i++) {
        textFieldControllers.add(TextEditingController());
        textFieldControllers[i] = TextEditingController();
        checkedItems.add([]);
      }
    }
    checkSubmitBtnStatus();
    super.initState();
  }

  Widget radioTypeQstn(radiofield, index, List radioButtons) {
    // if (answerVal[index] == null) {
    //   answerVal[index] = radioButtons[0];
    // }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      question('${index + 1}. ${radiofield['name']}'),
      SizedBox(height: 16.w),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          ...List.generate(
            radioButtons.length,
            (listIndex) => Container(
              padding: EdgeInsets.only(right: 26).r,
              height: 48.w,
              margin: EdgeInsets.only(right: 20).r,
              decoration: BoxDecoration(
                border: Border.all(
                  color: (answerVal[index] == radioButtons[listIndex])
                      ? AppColors.darkBlue
                      : AppColors.grey16,
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    activeColor: AppColors.darkBlue,
                    value: radioButtons[listIndex],
                    groupValue: answerVal[index],
                    onChanged: (val) {
                      setState(() {
                        answerVal[index] = val!;
                        checkMandatoryFieldsStatus();
                      });
                    },
                  ),
                  Text(
                    radioButtons[listIndex],
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          letterSpacing: 0.25,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      )
    ]);
  }

  submitForm() async {
    var dataObject = {};
    for (int i = 0; i < surveyFields.length; i++) {
      if (surveyFields[i]['fieldType'] == FieldTypes.radio.name) {
        dataObject[surveyFields[i]['name']] = answerVal[i];
      } else if (surveyFields[i]['fieldType'] == FieldTypes.text.name ||
          surveyFields[i]['fieldType'] == FieldTypes.textarea.name) {
        dataObject[surveyFields[i]['name']] = textFieldControllers[i].text;
      } else if (surveyFields[i]['fieldType'] == FieldTypes.checkbox.name) {
        dataObject[surveyFields[i]['name']] = checkboxAnswerVal[i];
      } else if (surveyFields[i]['fieldType'] == 'rating') {
        dataObject[surveyFields[i]['name']] = rating;
      }
    }
    dataObject['Course ID and Name'] = widget.courseDetails;
    formResponse = await learnService.submitSurveyForm(
        widget.formId, dataObject, widget.courseId);
    if (formResponse == 'success') {
      setState(() {});
    }
  }

  bool checkMandatoryFieldsStatus() {
    bool completed = true;
    for (var field in mandatoryFields) {
      switch (field['fieldType']) {
        case 'text':
          int textareaCount = 0, filledFieldCount = 0;
          for (int i = 0; i < surveyFields.length; i++) {
            if (surveyFields[i]['fieldType'] == FieldTypes.text.name ||
                surveyFields[i]['fieldType'] == FieldTypes.textarea.name) {
              textareaCount++;
            }
            if (textFieldControllers[i].text.length > 0) {
              filledFieldCount++;
            }
          }
          if (textareaCount != filledFieldCount) {
            completed = false;
          }
          break;
        default:
      }
      if (!completed) {
        break;
      }
    }
    return completed;
  }

  checkSubmitBtnStatus() {
    if (checkMandatoryFieldsStatus()) {
      setState(() {
        enableConfirmbtn = true;
      });
    }
  }

  Widget textareaTypeQstn(list, index) {
    return Column(children: [
      question('${index + 1}. ${list['name']}'),
      SizedBox(
        height: 6.w,
      ),
      Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1.w, color: AppColors.grey16)),
        padding: EdgeInsets.only(left: 10, right: 10).r,
        child: TextField(
          controller: textFieldControllers[index],
          maxLines: null,
          onChanged: (value) {
            setState(() {
              enableConfirmbtn = checkMandatoryFieldsStatus();
            });
          },
          keyboardType: TextInputType.multiline,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                letterSpacing: 0.25,
                height: 1.5.w,
              ),
          decoration: InputDecoration(
            hintText: 'Type here',
            border: InputBorder.none,
            hintStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                  letterSpacing: 0.25,
                  height: 1.5.w,
                ),
          ),
        ),
      )
    ]);
  }

  Widget question(text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.displayLarge!.copyWith(
              letterSpacing: 0.25,
            ),
      ),
    );
  }

  Widget checkboxTypeQstn(checklist, index) {
    if (checkboxAnswerVal[index] == null) {
      checkboxAnswerVal[index] = [];
    }
    return Column(children: [
      question('${index + 1}. ${checklist['name']}'),
      SizedBox(
        height: 8.w,
      ),
      ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount:
              checklist['values'] != null ? checklist['values'].length : 0,
          itemBuilder: (context, checkboxIndex) {
            return Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 1, color: AppColors.grey16)),
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ).r,
              margin: EdgeInsets.only(top: 6).r,
              child: Row(
                children: [
                  Checkbox(
                    checkColor: AppColors.appBarBackground,
                    activeColor: AppColors.darkBlue,
                    value: checkboxAnswerVal[index]!
                            .contains(checklist['values'][checkboxIndex]['key'])
                        ? true
                        : false,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value!) {
                          checkboxAnswerVal[index]!
                              .add(checklist['values'][checkboxIndex]['key']);
                        } else {
                          checkboxAnswerVal[index]!.remove(
                              checklist['values'][checkboxIndex]['key']);
                        }
                        checkMandatoryFieldsStatus();
                      });
                    },
                  ),
                  Wrap(
                    children: [
                      Container(
                          width: 0.6.sw,
                          child: Text(
                            checklist['values'][checkboxIndex]['key'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  )
                ],
              ),
            );
          })
    ]);
  }

  Widget starRating(list, index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        question('${index + 1}. ${list['name']}'),
        SizedBox(
          height: 8.w,
        ),
        RatingBar.builder(
          unratedColor: AppColors.grey16,
          initialRating: 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemSize: 30,
          itemPadding: EdgeInsets.symmetric(horizontal: 0.0).r,
          itemBuilder: (context, _) => Icon(
            Icons.star_rounded,
            color: FeedbackColors.ratedColor,
          ),
          onRatingUpdate: (rate) {
            rating = rate;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 8.w,
            ),
            Text(
              AppLocalizations.of(context)!.mStaticEnterDetailsToEnrol,
              style: GoogleFonts.montserrat(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 18).r,
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: surveyFields.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 26).r,
                      child: surveyFields[index]['fieldType'] ==
                              FieldTypes.radio.name
                          ? Container(
                              color: AppColors.appBarBackground,
                              child: radioTypeQstn(
                                  surveyFields[index],
                                  index,
                                  surveyFields[index]['values']
                                      .map((e) => e['key'].toString())
                                      .toList()),
                            )
                          : surveyFields[index]['fieldType'] ==
                                      FieldTypes.text.name ||
                                  surveyFields[index]['fieldType'] ==
                                      FieldTypes.textarea.name
                              ? Container(
                                  color: AppColors.appBarBackground,
                                  child: textareaTypeQstn(
                                      surveyFields[index], index),
                                )
                              : surveyFields[index]['fieldType'] ==
                                      FieldTypes.checkbox.name
                                  ? Container(
                                      color: AppColors.appBarBackground,
                                      child: checkboxTypeQstn(
                                          surveyFields[index], index),
                                    )
                                  : surveyFields[index]['fieldType'] == 'rating'
                                      ? starRating(surveyFields[index], index)
                                      : SizedBox(),
                    );
                  }),
            ),
            Text(
              'This batch starting on ${DateTimeHelper.getDateTimeInFormat(widget.batch!.startDate, desiredDateFormat: IntentType.dateFormat2)} - ${DateTimeHelper.getDateTimeInFormat(widget.batch!.endDate, desiredDateFormat: IntentType.dateFormat2)}, kindly go through the content and be prepared. ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(
              height: 24.w,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 40.w,
                    child: ElevatedButton(
                      onPressed: () {
                        if (widget.previousPage != null) {
                          widget.previousPage!();
                        } else {
                          Navigator.pop(context);
                          widget.enrollParentAction!('Cancel');
                        }
                        //   widget.enrollParentAction('Cancel'),
                        //  Navigator.of(context).pop(true)
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0).r,
                                side: BorderSide(
                                    color: AppColors.darkBlue, width: 1.5.w))),
                        backgroundColor: WidgetStateProperty.all<Color>(
                            AppColors.appBarBackground),
                      ),
                      child: Text(
                        widget.previousPage != null
                            ? EnglishLang.previous
                            : EnglishLang.cancel,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              letterSpacing: 1,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 16.w,
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 40.w,
                    child: TextButton(
                      onPressed: !enableConfirmbtn
                          ? null
                          : () async {
                              await submitForm();
                              if (formResponse == 'success') {
                                widget.enrollParentAction!('Confirm');
                              } else {
                                widget.enrollParentAction!('Failed');
                              }
                              Navigator.pop(context);
                            },
                      style: TextButton.styleFrom(
                        backgroundColor: enableConfirmbtn
                            ? AppColors.darkBlue
                            : AppColors.shadeFour,
                      ),
                      // padding: EdgeInsets.all(15.0),
                      child: Text(
                        EnglishLang.confirm,
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  letterSpacing: 1,
                                ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
