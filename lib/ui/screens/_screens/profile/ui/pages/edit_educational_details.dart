import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../localization/index.dart';
import '../../../../../pages/_pages/search/utils/search_helper.dart';
import '../../../../../widgets/_common/button_widget_v2.dart';
import '../widgets/field_name_widget.dart';
import '../../utils/profile_helper.dart';
import '../../view_model/profile_education_qualification_view_model.dart';
import '../widgets/profile_edit_hearder.dart';
import '../widgets/selectable_field.dart';

class EditEducationalDetails extends StatefulWidget {
  final String? degree;
  final String? fieldOfStudy;
  final String? instituteName;
  final String? startYear;
  final String? endYear;
  final String? uuid;
  final bool isUpdate;
  final VoidCallback updateCallback;

  const EditEducationalDetails(
      {super.key,
      this.degree,
      this.fieldOfStudy,
      this.instituteName,
      this.startYear,
      this.endYear,
      this.uuid,
      this.isUpdate = false,
      required this.updateCallback});
  @override
  State<EditEducationalDetails> createState() => _EditEducationalDetailsState();
}

class _EditEducationalDetailsState extends State<EditEducationalDetails> {
  String degree = '';
  String fieldOfStudy = '';
  String instituteName = '';
  String startYear = '';
  String endYear = '';
  List<String> degreeList = [];
  List<String> institutionList = [];
  List<String> startYearList = [];
  List<String> endYearList = [];
  ValueNotifier<bool> isChanged = ValueNotifier(false);
  ValueNotifier<String?> degreeErrMsg = ValueNotifier(null);
  ValueNotifier<String?> instituteErrMsg = ValueNotifier(null);
  ValueNotifier<String?> fieldOfStudyErrMsg = ValueNotifier(null);
  TextEditingController fieldOfStudyController = TextEditingController();
  TextEditingController degreeController = TextEditingController();
  TextEditingController instituteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fieldOfStudy = widget.fieldOfStudy ?? '';
    fieldOfStudyController.text = fieldOfStudy;
    startYear = widget.startYear ?? '';
    endYear = widget.endYear ?? '';
    fetchData();
  }

  @override
  void dispose() {
    fieldOfStudyController.dispose();
    degreeController.dispose();
    instituteController.dispose();
    isChanged.dispose();
    degreeErrMsg.dispose();
    instituteErrMsg.dispose();
    fieldOfStudyErrMsg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 1.0.sh,
        padding: const EdgeInsets.only(top: 32).r,
        child: GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Padding(
                padding: const EdgeInsets.all(16.0).r,
                child: Column(children: [
                  ProfileEditHeader(
                      title: AppLocalizations.of(context)!
                          .mProfileEducationalQualifications,
                      callback: () => Navigator.pop(context)),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(children: [
                    // Degree
                    FieldNameWidget(
                      isMandatory: true,
                      fieldName: AppLocalizations.of(context)!.mProfileDegree,
                    ),
                    SelectableField(
                        value: degree,
                        placeholder:
                            AppLocalizations.of(context)!.mStaticTypeHere,
                        onTap: () {
                          ProfileHelper().showSearchableBottomSheet(
                              context: context,
                              items: degreeList,
                              defaultItem: EnglishLang.other,
                              onItemSelected: (String value) async {
                                degree = value;
                                checkChanges();
                                if (mounted) {
                                  setState(() {});
                                }
                              });
                        }),
                    if (degree == EnglishLang.other)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0).r,
                        child: FieldNameWidget(
                          isMandatory: true,
                          fieldName:
                              AppLocalizations.of(context)!.mProfileDegreeName,
                        ),
                      ),
                    if (degree == EnglishLang.other)
                      getTextField(
                          controller: degreeController,
                          placeholder:
                              AppLocalizations.of(context)!.mProfileEnterDegree,
                          regex: RegExpressions
                              .alphabetWithAmbresandDotCommaSlashBracket,
                          maxLength: 80,
                          errMsg: degreeErrMsg,
                          onChanged: (String value) {
                            checkChanges();
                            if (mounted) {
                              setState(() {});
                            }
                          }),
                    //Field of Study
                    FieldNameWidget(
                      isMandatory: true,
                      fieldName:
                          AppLocalizations.of(context)!.mProfileFieldOfStudy,
                    ),
                    SizedBox(height: 8.w),
                    getTextField(
                        controller: fieldOfStudyController,
                        placeholder: AppLocalizations.of(context)!
                            .mProfileFieldOfStudyPlaceHolder,
                        regex: RegExpressions.alphabets,
                        maxLength: 250,
                        errMsg: fieldOfStudyErrMsg,
                        onChanged: (String value) {
                          fieldOfStudy = value;
                          checkChanges();
                          if (mounted) {
                            setState(() {});
                          }
                        }),
                    SizedBox(height: 8.w),
                    // Institutions
                    FieldNameWidget(
                      isMandatory: true,
                      fieldName:
                          AppLocalizations.of(context)!.mProfileInstituteName,
                    ),
                    SelectableField(
                        value: instituteName,
                        placeholder: AppLocalizations.of(context)!
                            .mProfileInstitutePlaceHolder,
                        onTap: () {
                          ProfileHelper().showSearchableBottomSheet(
                              context: context,
                              items: institutionList,
                              defaultItem: EnglishLang.other,
                              onItemSelected: (String value) async {
                                instituteName = value;
                                checkChanges();
                                if (mounted) {
                                  setState(() {});
                                }
                              });
                        }),
                    if (instituteName == EnglishLang.other)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0).r,
                        child: FieldNameWidget(
                          isMandatory: true,
                          fieldName: AppLocalizations.of(context)!
                              .mProfileInstituteName,
                        ),
                      ),
                    if (instituteName == EnglishLang.other)
                      getTextField(
                          controller: instituteController,
                          placeholder: AppLocalizations.of(context)!
                              .mProfileOtherInstituteName,
                          regex: RegExpressions
                              .alphabetWithAmbresandDotCommaSlashBracket,
                          maxLength: 125,
                          onChanged: (String value) {
                            checkChanges();
                            if (mounted) {
                              setState(() {});
                            }
                          },
                          errMsg: fieldOfStudyErrMsg),
                    // Start Date
                    FieldNameWidget(
                      isMandatory: true,
                      fieldName:
                          AppLocalizations.of(context)!.mProfileStartYear,
                    ),
                    SelectableField(
                        value: startYear,
                        placeholder:
                            AppLocalizations.of(context)!.mProfileSelectYear,
                        onTap: () {
                          EducationQualificationViewModel()
                              .showYearPickerDialog(context,
                                  selectedYear: startYear.isNotEmpty
                                      ? int.tryParse(startYear)
                                      : DateTime.now().year,
                                  lastDate: DateTime(DateTime.now().year))
                              .then((value) {
                            if (value != null) {
                              startYear = value.toString();
                              checkChanges();
                              if (mounted) {
                                setState(() {});
                              }
                            }
                          });
                        }),
                    SizedBox(height: 8.w),
                    // End Date
                    FieldNameWidget(
                      isMandatory: true,
                      fieldName: AppLocalizations.of(context)!.mProfileEndYear,
                    ),
                    SelectableField(
                        value: endYear,
                        placeholder:
                            AppLocalizations.of(context)!.mProfileSelectYear,
                        onTap: () {
                          EducationQualificationViewModel()
                              .showYearPickerDialog(context,
                                  selectedYear: endYear.isNotEmpty
                                      ? int.tryParse(endYear)
                                      : DateTime.now().year,
                                  firstDate: startYear.isNotEmpty
                                      ? DateTime(int.parse(startYear))
                                      : DateTime(DateTime.now().year - 100))
                              .then((value) {
                            if (value != null) {
                              endYear = value.toString();
                              checkChanges();
                              if (mounted) {
                                setState(() {});
                              }
                            }
                          });
                        }),
                    SizedBox(height: 8.w),
                  ]))),
                  Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                          width: 0.8.sw,
                          child: ValueListenableBuilder(
                              valueListenable: isChanged,
                              builder: (BuildContext context, bool isChanged,
                                  Widget? child) {
                                return ButtonWidgetV2(
                                    text: widget.isUpdate
                                        ? AppLocalizations.of(context)!
                                            .mCommonupdate
                                        : AppLocalizations.of(context)!
                                            .mEditProfileAdd,
                                    textColor: AppColors.appBarBackground,
                                    // isLoading: savePressed,
                                    bgColor: isChanged
                                        ? AppColors.darkBlue
                                        : AppColors.grey40,
                                    onTap: isChanged
                                        ? () async {
                                            if (degreeController
                                                    .text.isNotEmpty &&
                                                ((widget.degree == null) ||
                                                    (widget.degree != null &&
                                                        widget.degree !=
                                                            degreeController
                                                                .text))) {
                                              await EducationQualificationViewModel()
                                                  .updateDegreeMasterList(
                                                      degreeController.text);
                                            }
                                            if (instituteController
                                                    .text.isNotEmpty &&
                                                ((widget.instituteName ==
                                                        null) ||
                                                    (widget.instituteName !=
                                                            null &&
                                                        widget.instituteName !=
                                                            instituteController
                                                                .text))) {
                                              await EducationQualificationViewModel()
                                                  .updateInstitutionMasterList(
                                                      instituteController.text);
                                            }
                                            if (widget.isUpdate &&
                                                ((degree == EnglishLang.other &&
                                                        degreeController
                                                            .text.isEmpty) ||
                                                    (instituteName ==
                                                            EnglishLang.other &&
                                                        instituteController
                                                            .text.isEmpty))) {
                                              SearchHelper().showOverlayMessage(
                                                  AppLocalizations.of(context)!
                                                      .mStaticPleaseFillAllMandatory,
                                                  context,
                                                  duration: 3);
                                            } else {
                                              widget.isUpdate
                                                  ? await EducationQualificationViewModel().updateEducation(
                                                      context,
                                                      degree: degree == EnglishLang.other &&
                                                              degreeController.text !=
                                                                  widget.degree
                                                          ? degreeController
                                                              .text
                                                          : degree != EnglishLang.other &&
                                                                  degree !=
                                                                      widget
                                                                          .degree
                                                              ? degree
                                                              : '',
                                                      fieldOfStudy: fieldOfStudy != widget.fieldOfStudy
                                                          ? fieldOfStudy
                                                          : '',
                                                      instituteName: instituteName == EnglishLang.other &&
                                                              instituteController.text !=
                                                                  widget
                                                                      .instituteName
                                                          ? instituteController
                                                              .text
                                                          : instituteName != EnglishLang.other &&
                                                                  instituteName !=
                                                                      widget
                                                                          .instituteName
                                                              ? instituteName
                                                              : '',
                                                      startYear: startYear != widget.startYear
                                                          ? startYear
                                                          : '',
                                                      endYear: endYear != widget.endYear
                                                          ? endYear
                                                          : '',
                                                      uuid: widget.uuid ?? '')
                                                  : await EducationQualificationViewModel().addEducation(context,
                                                      degree: degree == EnglishLang.other
                                                          ? degreeController.text
                                                          : degree,
                                                      fieldOfStudy: fieldOfStudy,
                                                      instituteName: instituteName == EnglishLang.other ? instituteController.text : instituteName,
                                                      startYear: startYear,
                                                      endYear: endYear);
                                            }
                                            widget.updateCallback();
                                          }
                                        : null);
                              })))
                ]))),
      ),
    );
  }

  void checkChanges() {
    isChanged.value = ((degree.isNotEmpty && degree != widget.degree) ||
        (fieldOfStudy.isNotEmpty && fieldOfStudy != widget.fieldOfStudy) ||
        (instituteName.isNotEmpty && instituteName != widget.instituteName) ||
        (startYear.isNotEmpty && startYear != widget.startYear) ||
        (endYear.isNotEmpty && endYear != widget.endYear));
  }

  Future<void> fetchData() async {
    degreeList = await EducationQualificationViewModel().getDegreeList();
    if (widget.degree != null && widget.degree!.isNotEmpty) {
      if (degreeList.contains(widget.degree)) {
        degree = widget.degree!;
      } else {
        degree = EnglishLang.other;
        degreeController.text = widget.degree ?? '';
      }
    }
    institutionList =
        await EducationQualificationViewModel().getInstitutionList();
    if (widget.instituteName != null && widget.instituteName!.isNotEmpty) {
      if (institutionList.contains(widget.instituteName)) {
        instituteName = widget.instituteName!;
      } else {
        instituteName = EnglishLang.other;
        instituteController.text = widget.instituteName ?? '';
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  getTextField(
      {required TextEditingController controller,
      required String placeholder,
      required Null Function(String value) onChanged,
      RegExp? regex,
      int? maxLength,
      required ValueNotifier<String?> errMsg}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLength: maxLength,
          onChanged: (value) {
            if (regex != null) {
              if (!regex.hasMatch(value)) {
                errMsg.value = AppLocalizations.of(context)!
                    .mProfileSpecialCharacterNotApplowed;
              } else {
                errMsg.value = null;
              }
            }
            onChanged(value);
          },
          keyboardType: TextInputType.name,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: AppColors.greys),
          decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 2).r,
              hintText: placeholder,
              hintStyle: Theme.of(context).textTheme.labelLarge,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(63).r,
                borderSide: BorderSide(color: AppColors.grey24),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(63).r,
                borderSide: BorderSide(color: AppColors.grey24),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(63).r,
                borderSide: BorderSide(color: AppColors.darkBlue),
              ),
              counterStyle: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: AppColors.grey40)),
        ),
        ValueListenableBuilder(
            valueListenable: errMsg,
            builder: (context, value, child) {
              return Visibility(
                visible: value != null,
                child: Text(value ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: AppColors.negativeLight)),
              );
            })
      ],
    );
  }
}
