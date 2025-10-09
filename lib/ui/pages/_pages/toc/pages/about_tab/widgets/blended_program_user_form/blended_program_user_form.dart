import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_other_primary_details.dart';
import 'package:karmayogi_mobile/models/_models/verifiable_details_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_user_form/constants/survey_form_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_user_form/services/blended_program_form_services.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_user_form/widgets/edit_designation_details.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_user_form/widgets/edit_group_details.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_user_form/widgets/form_drop_down.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_user_form/widgets/verify_email_field.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_user_form/widgets/verify_phone_field.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/cadre_details_data_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/cadre_request_data_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/cadre_details_section.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/select_from_bottomsheet.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/text_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/validations.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../services/index.dart';
import '../../../../../../../screens/_screens/profile/view_model/profile_other_details_view_model.dart';

class BlendedProgramUserForm extends StatefulWidget {
  final bool isCadreProgram;

  final Function() saveAndNext;
  final Batch selectedBatch;
  final String courseId;
  final String title;
  final List<Map<String, dynamic>> bpEnrolMandatoryProfileFields;
  const BlendedProgramUserForm(
      {super.key,
      required this.isCadreProgram,
      required this.courseId,
      required this.title,
      required this.selectedBatch,
      required this.saveAndNext,
      required this.bpEnrolMandatoryProfileFields});

  @override
  State<BlendedProgramUserForm> createState() => _BlendedProgramUserFormState();
}

class _BlendedProgramUserFormState extends State<BlendedProgramUserForm> {
  List<Widget> formWidgets = [];

  final FocusNode _dobFocus = FocusNode();
  final FocusNode _pinCodeFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _errorMessage = '';

  DateTime? _dobDate;

  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _motherTongueController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late Future<CadreDetailsDataModel>? cadreDataFuture;

  ValueNotifier<dynamic> _selectedGender = ValueNotifier('');
  ValueNotifier<String?> _selectedCategory = ValueNotifier('');
  ValueNotifier<Map<dynamic, dynamic>?> _cadreSectionValueNotifier =
      ValueNotifier(null);
  ValueNotifier<bool>? _isMobileVerified;
  ValueNotifier<bool>? _isEmailVerified;

  ValueNotifier<bool> _savePressed = ValueNotifier(false);
  bool isDesignationMasterEnabled = false;
  @override
  void initState() {
    super.initState();
    checkHomeConfig();
    _populateFields();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var item in widget.bpEnrolMandatoryProfileFields) {
        getFormWidgets(item);
      }
      setState(() {});
    });
    cadreDataFuture = _fetchCadreData();
  }

  Future<CadreDetailsDataModel> _fetchCadreData() async {
    final responseData =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getCadreConfigData();
    return CadreDetailsDataModel.fromJson(responseData);
  }

  @override
  void dispose() {
    _dobController.dispose();
    _motherTongueController.dispose();
    _pinCodeController.dispose();
    _employeeIdController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _groupController.dispose();
    _designationController.dispose();
    _dobFocus.dispose();
    _pinCodeFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0).r,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.lato(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...formWidgets,
                  SizedBox(
                    height: 40.w,
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
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
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
                            onPressed: !_savePressed.value
                                ? () {
                                    _saveProfile();
                                  }
                                : null,
                            style: ButtonStyle(
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(4.0).r,
                                      side: BorderSide(
                                          color: AppColors.darkBlue,
                                          width: 1.5.w))),
                              backgroundColor: WidgetStateProperty.all<Color>(
                                  AppColors.darkBlue),
                            ),
                            child: _savePressed.value
                                ? CircularProgressIndicator(
                                    color: AppColors.appBarBackground,
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    EnglishLang.next,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(
                                          letterSpacing: 1,
                                        ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16.w,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getFormWidgets(Map<String, dynamic> fieldData) {
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    switch (fieldData['displayName']) {
      case SurveyFormConstants.name:
        formWidgets.addAll([
          FieldNameWidget(
            fieldName: AppLocalizations.of(context)!.mStaticName,
            isMandatory: true,
          ),
          TextInputField(
              minLines: 1,
              keyboardType: TextInputType.text,
              readOnly: true,
              controller: _nameController,
              hintText: AppLocalizations.of(context)!.mProfileEnterFullName,
              onChanged: (p0) {},
              validatorFuntion: (String? value) {
                return Validations.validateFullName(
                    context: context, value: value ?? '');
              })
        ]);
        break;
      case SurveyFormConstants.organisation:
        formWidgets.addAll([
          FieldNameWidget(
              isMandatory: true,
              fieldName: widget.isCadreProgram
                  ? AppLocalizations.of(context)!
                      .mPresentMinistryDepartmentStateUT
                  : AppLocalizations.of(context)!.mStaticOrganisation),
          TextInputField(
            readOnly: true,
            minLines: 1,
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: profileDetails!.department),
            hintText: AppLocalizations.of(context)!.mStaticTypeHere,
          ),
        ]);
        break;

      case SurveyFormConstants.group:
        formWidgets.addAll([
          EditGroupDetails(
            isCadreProgram: widget.isCadreProgram,
            groupDetails: (value) {
              _groupController.text = value;
              debugPrint(value);
            },
          ),
          SizedBox(
            height: 8.w,
          )
        ]);

        break;
      case SurveyFormConstants.designation:
        formWidgets.addAll([
          EditDesignationDetails(
              isCadreProgram: widget.isCadreProgram,
              designationDetails: (value) {
                _designationController.text = value;
              },
              isOrgBasedDesignation: isDesignationMasterEnabled),
          SizedBox(
            height: 8.w,
          )
        ]);

        break;

      case SurveyFormConstants.employeeId:
        formWidgets.addAll([
          FieldNameWidget(
              isMandatory: true,
              fieldName: AppLocalizations.of(context)!.mProfileEmployeeId),
          TextInputField(
              minLines: 1,
              keyboardType: TextInputType.text,
              controller: _employeeIdController,
              hintText: AppLocalizations.of(context)!.mEditProfileTypeHere,
              onChanged: (p0) {},
              validatorFuntion: (String? value) {
                return Validations.validateEmployeeIdBLendedProgramForm(
                    context: context, value: value ?? '');
              }),
          SizedBox(
            height: 16.w,
          )
        ]);

        break;
      case SurveyFormConstants.email:
        _isEmailVerified = ValueNotifier(true);
        formWidgets.addAll([
          SizedBox(
            height: 16,
          ),
          VerifyEmailField(
            onChanged: (value) {
              _isEmailVerified?.value = value;
            },
            email: (value) {
              _emailController.text = value;
            },
            emailController: _emailController,
            isEmailVerified: _isEmailVerified!.value,
          )
        ]);
        break;
      case SurveyFormConstants.mobileNumber:
        _isMobileVerified = ValueNotifier(
            profileDetails?.personalDetails['phoneVerified'].toString() ==
                "true");

        formWidgets.addAll([
          SizedBox(
            height: 16,
          ),
          ValueListenableBuilder(
              valueListenable: _isMobileVerified!,
              builder:
                  (BuildContext context, bool isMobileVerified, Widget? child) {
                return VerifyPhoneField(
                  mobileController: _mobileController,
                  isVerified: _isMobileVerified!.value,
                  onChanged: (value) {
                    _isMobileVerified?.value = value;
                  },
                  unverifiedPhone: profileDetails != null &&
                          profileDetails.personalDetails['mobile'] != null &&
                          profileDetails.personalDetails['phoneVerified'] !=
                              null &&
                          profileDetails.personalDetails['phoneVerified']
                                  .toString() ==
                              'false'
                      ? profileDetails.personalDetails['mobile'].toString()
                      : null,
                  mobileNumber: (value) {
                    _mobileController.text = value;
                  },
                );
              })
        ]);

        break;
      case SurveyFormConstants.gender:
        formWidgets.addAll([
          FieldNameWidget(
              isMandatory: true,
              fieldName: AppLocalizations.of(context)!.mProfileGender),
          ValueListenableBuilder(
              valueListenable: _selectedGender,
              builder: (BuildContext context, dynamic selectedGender,
                  Widget? child) {
                return FormDropDown(
                    options: EditProfileMandatoryHelper.genderRadio,
                    selectedValue: selectedGender,
                    validator: (value) {
                      if (selectedGender == null || selectedGender == '') {
                        return AppLocalizations.of(context)!
                            .mProfileGenderMandatory;
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      _selectedGender.value = value;
                    });
              }),
          SizedBox(
            height: 16.w,
          )
        ]);

        break;
      case SurveyFormConstants.dateOfBirth:
        formWidgets.addAll([
          FieldNameWidget(
              isMandatory: true,
              fieldName: AppLocalizations.of(context)!.mProfileDOB),
          TextInputField(
            focusNode: _dobFocus,
            keyboardType: TextInputType.datetime,
            readOnly: true,
            isDate: true,
            controller: _dobController,
            hintText: _dobController.text != ''
                ? _dobController.text
                : AppLocalizations.of(context)!.mEditProfileChooseDate,
            suffixIcon: Icon(Icons.date_range),
            validatorFuntion: (value) {
              if (value == null || value == '') {
                return AppLocalizations.of(context)!.mProfileDOBMandatory;
              } else {
                return null;
              }
            },
            onTap: () async {
              DateTime? newDate = await showDatePicker(
                  context: context,
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  initialDate: _dobDate == null
                      ? ((_dobController.text != '') &&
                              !RegExp(r'[a-zA-Z]').hasMatch(_dobController.text)
                          ? DateTimeHelper.convertDDMMYYYYtoDateTime(
                              _dobController.text)
                          : DateTime.now())
                      : _dobDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now());
              if (newDate == null) {
                return null;
              }
              _dobDate = newDate;
              _dobController.text =
                  DateTimeHelper.convertDatetimetoDDMMYYYY(newDate);
            },
          ),
          SizedBox(
            height: 12.w,
          )
        ]);

        break;
      case SurveyFormConstants.motherTongue:
        formWidgets.addAll([
          FieldNameWidget(
            isMandatory: true,
            fieldName: AppLocalizations.of(context)!.mProfileMotherTongue,
          ),
          SelectFromBottomSheet(
            parentContext: context,
            fieldName: EnglishLang.languages,
            controller: _motherTongueController,
            showDefaultTextStyle: true,
            validator: (value) {
              if (value == '') {
                return AppLocalizations.of(context)!.mMotherTongueIsRequired;
              } else {
                return null;
              }
            },
            callBack: () {},
          ),
          SizedBox(
            height: 12.w,
          )
        ]);

        break;
      case SurveyFormConstants.category:
        formWidgets.addAll([
          FieldNameWidget(
            isMandatory: true,
            fieldName: AppLocalizations.of(context)!.mStaticCategory,
          ),
          ValueListenableBuilder<String?>(
              valueListenable: _selectedCategory,
              builder: (BuildContext context, String? selectedCategory,
                  Widget? child) {
                return FormDropDown(
                    options: EditProfileMandatoryHelper.categoryRadio,
                    selectedValue: selectedCategory,
                    validator: (value) {
                      if (selectedCategory == null || selectedCategory == '') {
                        return AppLocalizations.of(context)!
                            .mProfileCategoryMandatory;
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      _selectedCategory.value = value;
                    });
              }),
          SizedBox(
            height: 12.w,
          )
        ]);

        break;
      case SurveyFormConstants.officePinCode:
        formWidgets.addAll([
          FieldNameWidget(
              isMandatory: true,
              fieldName: AppLocalizations.of(context)!.mProfileOfficePincode),
          TextInputField(
              readOnly: false,
              minLines: 1,
              focusNode: _pinCodeFocus,
              keyboardType: TextInputType.number,
              controller: _pinCodeController,
              hintText: AppLocalizations.of(context)!.mStaticTypeHere,
              maxLength: 6,
              onChanged: (p0) {},
              validatorFuntion: (String? value) =>
                  Validations.validatePinCodeBlendedProgram(value ?? ''),
              onFieldSubmitted: (String value) {
                _pinCodeFocus.unfocus();
              }),
        ]);

        break;

      case SurveyFormConstants.ehrmsId:
        formWidgets.addAll([
          FieldNameWidget(
              isMandatory: true,
              fieldName: AppLocalizations.of(context)!.mEhrmsId),
          TextInputField(
            readOnly: true,
            minLines: 1,
            keyboardType: TextInputType.number,
            controller: TextEditingController(
                text: profileDetails?.ehrmsId == null ||
                        profileDetails?.ehrmsId == ''
                    ? "NA"
                    : profileDetails?.ehrmsId),
            hintText: AppLocalizations.of(context)!.mStaticTypeHere,
          ),
        ]);

        break;
      case SurveyFormConstants.dateOfRetirement:
        formWidgets.addAll([
          FieldNameWidget(
              isMandatory: true,
              fieldName: AppLocalizations.of(context)!.mDateOfRetirement),
          TextInputField(
            readOnly: true,
            minLines: 1,
            keyboardType: TextInputType.number,
            controller: TextEditingController(
                text: profileDetails?.dateOfRetirement == null ||
                        profileDetails?.dateOfRetirement == ''
                    ? "NA"
                    : profileDetails?.dateOfRetirement),
            hintText: AppLocalizations.of(context)!.mStaticTypeHere,
          ),
        ]);

        break;

      case SurveyFormConstants.cadreEmployee:
        if (!widget.isCadreProgram) {
          formWidgets.add(cadreSectionView());
        }

        break;

      default:
        formWidgets.add(
          SizedBox(),
        );

        debugPrint("Unknown display name=====${fieldData['displayName']}");
    }
  }

  dynamic selectedValue;

  Widget cadreSectionView() {
    return FutureBuilder<CadreDetailsDataModel>(
      future: cadreDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Container();
        } else if (!snapshot.hasData) {
          return Container();
        } else {
          CivilServiceTypeData cadreDetailsDataModel =
              snapshot.data!.civilServiceType!;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16.w)),
            ),
            child: CadreDetailsSection(
                isMandatory: true,
                civilServiceType: cadreDetailsDataModel,
                cadreSectionValueNotifier: _cadreSectionValueNotifier,
                checkForChangesCallback: () {}),
          );
        }
      },
    );
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    _errorMessage = AppLocalizations.of(context)!.mProfileProvideValidDetails;

    if (_formKey.currentState!.validate() && _validateCadreValue()) {
      if (_isMobileVerified == null || _isMobileVerified?.value == true) {
        if (_isEmailVerified == null || _isEmailVerified?.value == true) {
          debugPrint('********************validation executed');
          try {
            _savePressed.value = true;

            // Gather profile details
            final profileDetails = ProfileOtherPrimaryDetails(
              pinCode: _pinCodeController.text,
              dob: _dobController.text,
              gender: _selectedGender.value ?? '',
              category: _selectedCategory.value ?? '',
              motherTongue: _motherTongueController.text,
              employeeId: _employeeIdController.text,
              cadreRequestData: _getCadreFormData(),
              primaryEmail: _emailController.text,
              mobile: _mobileController.text,
              phoneVerified: 'true',
            );
            if (!widget.isCadreProgram) {
              // Get in-review fields
              List<dynamic> inReviewFields =
                  await Provider.of<ProfileRepository>(context, listen: false)
                      .inReview;
              for (var i = 0; i < inReviewFields.length; i++) {
                if (inReviewFields[i].name == null) {
                  await ProfileService()
                      .withdrawProfileField(wfId: inReviewFields[i].wfId);
                }
              }

              // Save verifiable profile details

              await EditProfileMandatoryHelper.saveVerifiableProfileDetails(
                context: context,
                verifiableDetails: VerifiableDetails(
                  group: _groupController.text,
                  position: _designationController.text,
                ),
              );
            }
            // Save primary profile details
            await ProfileOtherDetailsViewModel.saveOtherPrimaryProfileDetails(
              context: context,
              profileOtherPrimaryDetails: profileDetails,
              callback: () {},
            );
          } catch (e) {
            debugPrint("Error in _saveProfile: $e");

            _showSnackBar(
              AppLocalizations.of(context)!.mStaticSomethingWrongTryLater,
              AppColors.mandatoryRed,
            );
            _savePressed.value = false;
            return;
          }

          try {
            List<Profile> profileData =
                await Provider.of<ProfileRepository>(context, listen: false)
                    .getProfileDetailsById('');

            // Submit profile survey form
            bool status =
                await BlendedProgramFormServices().submitProfileSurveyForm(
              context: context,
              batch: widget.selectedBatch,
              courseId: widget.courseId,
              designation:
                  widget.isCadreProgram ? _designationController.text : null,
              updatedProfileData: profileData[0],
            );
            if (status) {
              widget.saveAndNext();
            } else {
              _showSnackBar(
                AppLocalizations.of(context)!.mStaticSomethingWrongTryLater,
                AppColors.mandatoryRed,
              );
            }
          } catch (e) {
            debugPrint("Error in retrieving or submitting profile data: $e");

            _showSnackBar(
              AppLocalizations.of(context)!.mStaticSomethingWrongTryLater,
              AppColors.mandatoryRed,
            );
          }
        } else {
          debugPrint('********************please verify email');
          _showSnackBar(
              AppLocalizations.of(context)!.mEditProfilePleaseVerifyYourEmail,
              AppColors.greys87);
        }
      } else {
        _showSnackBar(AppLocalizations.of(context)!.mRegisterVerifyMobile,
            AppColors.greys87);
      }
    } else {
      _showSnackBar(_errorMessage, AppColors.greys87);
    }

    _savePressed.value = false;
  }

  bool _validateCadreValue() {
    final values = _cadreSectionValueNotifier.value;
    if (values != null &&
        values['cadreEmployee'].toString().toLowerCase() ==
            EnglishLang.yes.toLowerCase()) {
      if (values['civilServiceTypeId'] == null ||
          values['civilServiceTypeId'].isEmpty ||
          values['civilServiceId'] == null ||
          values['civilServiceId'].isEmpty ||
          values['cadreBatch'] == null) {
        _errorMessage =
            AppLocalizations.of(context)!.mProfileProvideValidCadreDetails;
        return false;
      }
    }
    return true;
  }

  CadreRequestDataModel? _getCadreFormData() {
    final values = _cadreSectionValueNotifier.value;
    if (values != null) {
      return CadreRequestDataModel(
        cadreEmployee:
            values['cadreEmployee'] ?? Helper.capitalize(EnglishLang.no),
        civilServiceTypeId: values['civilServiceTypeId'],
        civilServiceType: values['civilServiceType'],
        civilServiceId: values['civilServiceId'],
        civilServiceName: values['civilServiceName'],
        cadreId: values['cadreId'],
        cadreName: values['cadreName'],
        cadreBatch: values['cadreBatch'],
        cadreControllingAuthorityName: values['cadreControllingAuthorityName'],
      );
    }
    return null;
  }

  void _populateFields() async {
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    dynamic personalDetails = profileDetails?.personalDetails;
    dynamic employmentDetails = profileDetails?.employmentDetails;
    dynamic professionalDetails = profileDetails != null &&
            profileDetails.professionalDetails != null &&
            profileDetails.professionalDetails!.isNotEmpty
        ? profileDetails.professionalDetails![0]
        : null;

    _selectedGender.value = personalDetails['gender'] ?? '';
    _selectedCategory.value = personalDetails['category'] ?? '';
    _pinCodeController.text = employmentDetails['pinCode'] ?? '';
    _dobController.text = personalDetails['dob'] ?? '';
    _nameController.text = profileDetails?.firstName ?? '';
    _motherTongueController.text =
        profileDetails?.personalDetails['domicileMedium'] ?? '';
    _employeeIdController.text =
        profileDetails?.employmentDetails?['employeeCode'] ?? '';
    _mobileController.text = profileDetails != null &&
            profileDetails.personalDetails['mobile'] != null &&
            profileDetails.personalDetails['phoneVerified'] != null &&
            profileDetails.personalDetails['phoneVerified'].toString() == 'true'
        ? profileDetails.personalDetails['mobile'].toString()
        : "";
    _groupController.text =
        profileDetails?.professionalDetails?.isNotEmpty == true
            ? profileDetails?.professionalDetails![0]['group'] ?? ''
            : '';
    _emailController.text = profileDetails?.primaryEmail ?? '';
    _designationController.text = profileDetails?.professionalDetails != null &&
            profileDetails!.professionalDetails!.isNotEmpty &&
            profileDetails.professionalDetails![0]['designation'] != null
        ? profileDetails.professionalDetails![0]['designation']
        : '';
    if (_dobController.text.isNotEmpty &&
        DateTimeHelper.checkDateFormat(_dobController.text,
            dateFormatStr: DateFormatString.yyyyMMdd)) {
      _dobController.text = DateTimeHelper.convertDateFormat(
          _dobController.text,
          inputFormat: DateFormatString.yyyyMMdd,
          desiredFormat: DateFormatString.ddMMyyyy);
    }
    _motherTongueController.text =
        personalDetails != null && personalDetails['domicileMedium'] != null
            ? personalDetails['domicileMedium']
            : '';
    _employeeIdController.text =
        employmentDetails != null && employmentDetails['employeeCode'] != null
            ? employmentDetails['employeeCode']
            : '';
    _groupController.text =
        professionalDetails != null && professionalDetails['group'] != null
            ? professionalDetails['group']
            : '';
    _designationController.text = professionalDetails != null &&
            professionalDetails['designation'] != null
        ? professionalDetails['designation']
        : '';
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

  Future<void> checkHomeConfig() async {
    Map<String, dynamic>? homeconfig = AppConfiguration.homeConfigData;
    Map? data;
    if (homeconfig != null) {
      for (var e in homeconfig['data']) {
        if (e['type'] == WidgetConstants.updateDesignation) {
          data = e;
        }
      }
    }

    isDesignationMasterEnabled =
        data != null && data['updateDesignation'] != null
            ? data['updateDesignation']!['enabled']
            : false;
  }
}
