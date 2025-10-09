import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_category_model.dart';
import 'package:karmayogi_mobile/models/_models/survey_form_model.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_survey_form/services/blended_program_survey_services.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_survey_form/skeleton/form_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_survey_form/widgets/custom_date_picker.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_survey_form/widgets/custom_dropdown.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_survey_form/widgets/custom_filter_box.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_survey_form/widgets/custom_radio_button.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_survey_form/widgets/custom_rating.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_survey_form/widgets/custom_text_field.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:http/http.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BlendedProgramSurveyForm extends StatefulWidget {
  final Batch batch;
  final String courseId;
  final Map surveyFormData;
  final ValueChanged<String>? enrollParentAction;
  const BlendedProgramSurveyForm(
      {super.key,
      required this.batch,
      required this.courseId,
      required this.surveyFormData,
      required this.enrollParentAction});

  @override
  State<BlendedProgramSurveyForm> createState() =>
      _BlendedProgramSurveyFormState();
}

class _BlendedProgramSurveyFormState extends State<BlendedProgramSurveyForm> {
  Map<FormDataModel, TextEditingController> controllers = {};
  Map<FormDataModel, TextEditingController> ratingController = {};

  Map<FormDataModel, String> radioButtonValue = {};
  Map<FormDataModel, String> dropdownValue = {};
  Map<FormDataModel, List<String>> checkboxValue = {};

  String title = "";
  List<Widget> formBody = [];
  late Future<List<List<Widget>>> body;
  @override
  void initState() {
    body = groupFieldsBySeparator(widget.surveyFormData);
    super.initState();
  }

  TextEditingController getController(FormDataModel fieldId) {
    if (!controllers.containsKey(fieldId)) {
      controllers[fieldId] = TextEditingController();
    }
    return controllers[fieldId]!;
  }

  TextEditingController getRatingController(FormDataModel fieldId) {
    if (!ratingController.containsKey(fieldId)) {
      ratingController[fieldId] = TextEditingController();
    }
    return ratingController[fieldId]!;
  }

  String getRadioButtonValue(FormDataModel fieldId) {
    if (!radioButtonValue.containsKey(fieldId)) {
      radioButtonValue[fieldId] = '';
    }
    return radioButtonValue[fieldId]!;
  }

  List<String> getCheckboxValue(FormDataModel fieldId) {
    if (!checkboxValue.containsKey(fieldId)) {
      checkboxValue[fieldId] = [];
    }
    return checkboxValue[fieldId]!;
  }

  Future<List<List<Widget>>> groupFieldsBySeparator(Map? surveyForm) async {
    // Map? surveyForm = await Provider.of<LearnRepository>(context, listen: false)
    //     .getSurveyForm("1735290076456");
    title = surveyForm?['title'] ?? "";
    List fieldsData = surveyForm?['fields'] ?? [];

    List<List<Widget>> groupedFields = [];
    List<Widget> currentGroup = [];

    for (var fieldData in fieldsData) {
      try {
        FormDataModel field = FormDataModel.fromJson(fieldData);

        if (field.fieldType == QuestionType.separator) {
          if (currentGroup.isNotEmpty) {
            groupedFields.add(currentGroup);
            currentGroup = [];
          }
        } else {
          currentGroup.add(constructForm(field));
        }
      } catch (e) {
        debugPrint('Error parsing field: $e');
      }
    }

    if (currentGroup.isNotEmpty) {
      groupedFields.add(currentGroup);
    }
    setState(() {});
    return groupedFields;
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appBarBackground,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16).r,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                    future: body,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: FormSkeleton());
                      }
                      if (snapshot.hasData) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 16.0, bottom: 16)
                                        .r,
                                child: Text(
                                  title,
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20.sp,
                                  ),
                                ),
                              ),
                              ...List.generate(
                                snapshot.data!.length,
                                (index) => Column(
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.only(top: 16, bottom: 16)
                                              .r,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 238, 243, 250),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12).r),
                                      ),
                                      child: Column(
                                        children: snapshot.data![index],
                                      ),
                                    ),
                                    Divider(
                                      thickness: 1,
                                      color: AppColors.grey24,
                                      height: 20.w,
                                    ),
                                  ],
                                ),
                              ),
                            ]);
                      }
                      return SizedBox();
                    }),
                SizedBox(
                  height: 42.w,
                ),
                Text(
                  'This batch starting on ${DateTimeHelper.getDateTimeInFormat(widget.batch.startDate, desiredDateFormat: IntentType.dateFormat2)} - ${DateTimeHelper.getDateTimeInFormat(widget.batch.endDate, desiredDateFormat: IntentType.dateFormat2)}, kindly go through the content and be prepared. ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(
                  height: 30.w,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 50.w,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0).r,
                                        side: BorderSide(
                                            color: AppColors.darkBlue,
                                            width: 1.5.w))),
                            backgroundColor: WidgetStateProperty.all<Color>(
                                AppColors.appBarBackground),
                          ),
                          child: Text(
                            EnglishLang.cancel,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
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
                        height: 50.w,
                        child: ElevatedButton(
                          onPressed: submitForm,
                          style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0).r,
                                        side: BorderSide(
                                            color: AppColors.darkBlue,
                                            width: 1.5.w))),
                            backgroundColor: WidgetStateProperty.all<Color>(
                                AppColors.darkBlue),
                          ),
                          child: Text(
                            EnglishLang.confirm,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(letterSpacing: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 36.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget constructForm(FormDataModel data) {
    String type = data.fieldType.replaceAll(' ', '').toLowerCase();
    switch (type) {
      case QuestionType.boolean:
        radioButtonValue[data] = "";

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8).r,
          child: CustomRadioButton(
            showNA: data.notApplicable,
            selectedItem: getRadioButtonValue(data),
            isMandatory: data.isRequired,
            checkListItems: [
              FilterModel(title: "True"),
              FilterModel(title: "False")
            ],
            onChanged: (value) {
              radioButtonValue[data] = value.toLowerCase();
              setState(() {});
              getController(data).text = value.toLowerCase().toString();
            },
            title: data.name,
          ),
        );

      case QuestionType.date:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8).r,
          child: CustomDatePicker(
            formKey: _formKey,
            controller: getController(data),
            isMandatory: data.isRequired,
            title: data.name,
            showNA: data.notApplicable,
          ),
        );
      case QuestionType.checkbox:
        checkboxValue[data] = [];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8).r,
          child: CustomFilterCheckBox(
            checkListItems:
                data.values.map((e) => FilterModel(title: e.value!)).toList(),
            onChanged: (value) {
              checkboxValue[data] = value;
            },
            isMandatory: data.isRequired,
            title: data.name,
            showNA: data.notApplicable,
          ),
        );

      case QuestionType.dropdown:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8).r,
          child: CustomDropDown(
            formKey: _formKey,
            value: dropdownValue[data],
            title: data.name,
            isMandatory: data.isRequired,
            items: data.values
                .map(
                  (e) => e.value ?? "",
                )
                .toList(),
            onChanged: (value) {
              dropdownValue[data] = value!;
              getController(data).text = value.toString();

              setState(() {});
            },
          ),
        );

      case QuestionType.numeric || QuestionType.phoneNumber:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8).r,
          child: CustomTextField(
            maxLength: QuestionType.phoneNumber == type ? 10 : null,
            showNA: data.notApplicable,
            isMandatory: data.isRequired,
            title: data.name,
            controller: getController(data),
            inputType: TextInputType.number,
            validator: (value) {
              return BlendedProgramSurveyServices().generalValidator(
                  context: context,
                  isRequired: data.isRequired,
                  fieldType: data.fieldType,
                  value: value);
            },
          ),
        );

      case QuestionType.radio:
        radioButtonValue[data] = "";

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8).r,
          child: CustomRadioButton(
            showNA: data.notApplicable,
            selectedItem: radioButtonValue[data],
            isMandatory: data.isRequired,
            checkListItems:
                data.values.map((e) => FilterModel(title: e.value!)).toList(),
            onChanged: (value) {
              getController(data).text = value.toString();

              radioButtonValue[data] = value;
              setState(() {});
            },
            title: data.name,
          ),
        );

      case QuestionType.email:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8).r,
          child: CustomTextField(
            showNA: data.notApplicable,
            isMandatory: data.isRequired,
            title: data.name,
            controller: getController(data),
            inputType: TextInputType.emailAddress,
            validator: (value) {
              return BlendedProgramSurveyServices().generalValidator(
                  context: context,
                  isRequired: data.isRequired,
                  fieldType: data.fieldType,
                  value: value != null ? value.trim() : "");
            },
          ),
        );

      case QuestionType.textarea || QuestionType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8).r,
          child: CustomTextField(
            showNA: data.notApplicable,
            isMandatory: data.isRequired,
            isTextArea: true,
            title: data.name,
            controller: getController(data),
            inputType: TextInputType.name,
            validator: (value) {
              return BlendedProgramSurveyServices().generalValidator(
                  context: context,
                  isRequired: data.isRequired,
                  fieldType: data.fieldType,
                  value: value);
            },
          ),
        );

      case QuestionType.rating:
        getRatingController(data).text = "";

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8).r,
          child: CustomStarRating(
            isMandatory: data.isRequired,
            title: data.name,
            onRatingUpdate: (value) {
              getRatingController(data).text = value.toInt().toString();
              getController(data).text = value.toInt().toString();
            },
          ),
        );

      case QuestionType.heading:
        return Container(
          width: 1.sw,
          padding:
              const EdgeInsets.only(bottom: 8.0, left: 8, right: 8, top: 16).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.heading![0].heading ?? "",
                style: GoogleFonts.lato(
                    fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.w),
              Text(
                data.heading![0].subHeading ?? "",
                style: GoogleFonts.lato(fontSize: 14.sp),
              ),
              Divider(
                thickness: 1,
                color: AppColors.grey24,
              ),
            ],
          ),
        );

      case QuestionType.separator:
        return Container(
          color: AppColors.appBarBackground,
          child: Divider(
            thickness: 1,
            color: AppColors.grey24,
            height: 20,
          ),
        );

      default:
        return SizedBox();
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        child: Container(
          width: 1.sw,
          padding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0).r,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(3.0).r,
          ),
          child: Text(
            message,
            style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontSize: 13.sp,
                decoration: TextDecoration.none),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void submitForm() async {
    if (_formKey.currentState!.validate() &&
        validateCheckbox() &&
        validateRadioButton() &&
        validateRating()) {
      Map data = {};
      controllers.forEach((key, controller) {
        if (controller.text.trim().isNotEmpty) {
          if (key.fieldType == QuestionType.date) {
            data.addAll({
              key.name: DateTimeHelper.convertDateFormat(controller.text,
                  inputFormat: IntentType.dateFormat,
                  desiredFormat: IntentType.dateFormat4),
            });
          } else {
            if (controller.text.trim().toLowerCase() != 'n/a') {
              data.addAll({key.name: controller.text});
            }
          }
        }
      });

      if (checkboxValue.isNotEmpty) {
        checkboxValue.forEach((key, value) {
          if (value.isNotEmpty) {
            data.addAll({key.name: value});
          }
        });
      }

      Response response = await LearnService.submitForm(
          courseId: widget.courseId,
          version: widget.surveyFormData['version'],
          formId: widget.surveyFormData['id'].toString(),
          dataObject: data);
      Map<String, dynamic> result = jsonDecode(response.body);
      if (result['statusInfo'] != null &&
          result['statusInfo']['statusMessage'].toLowerCase() == 'success') {
        widget.enrollParentAction!('Confirm');
      } else {
        widget.enrollParentAction!('Failed');
        _showSnackBar(
            AppLocalizations.of(context)!.mStaticSomethingWrong, AppColors.mandatoryRed);
      }

      Navigator.pop(context);

      debugPrint("===============Form submitted");
    } else {
      _showSnackBar(AppLocalizations.of(context)!.mStaticPleaseFillAllMandatory,
          AppColors.mandatoryRed);
    }
  }

  bool validateCheckbox() {
    for (var entry in checkboxValue.entries) {
      var key = entry.key;
      var value = entry.value;

      if (key.isRequired && value.isEmpty) {
        return false;
      }
    }
    return true;
  }

  bool validateRadioButton() {
    for (var entry in radioButtonValue.entries) {
      var key = entry.key;
      var value = entry.value;

      if (key.isRequired && value.isEmpty) {
        return false;
      }
    }
    return true;
  }

  bool validateRating() {
    for (var entry in ratingController.entries) {
      var key = entry.key;
      var value = entry.value;

      if (key.isRequired && value.text.isEmpty) {
        return false;
      }
    }
    return true;
  }
}
