import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_other_primary_details.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/edit_page_appbar.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/button_widget_v2.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/dropdown_selection.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/otp_verification_field.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/select_from_bottomsheet.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/text_input_field.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/validations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../util/date_time_helper.dart';
import '../widgets/edit_profile_filed_heading.dart';
import '../../view_model/profile_other_details_view_model.dart';
import '../../model/cadre_details_data_model.dart';
import '../../model/cadre_request_data_model.dart';
import '../widgets/cadre_details_section.dart';

class EditOtherDetailsSection extends StatefulWidget {
  const EditOtherDetailsSection({Key? key}) : super(key: key);

  @override
  State<EditOtherDetailsSection> createState() =>
      _EditOtherDetailsSectionState();
}

class _EditOtherDetailsSectionState extends State<EditOtherDetailsSection> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _primaryEmailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _motherTongueController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _ehrmsIdController = TextEditingController();
  final TextEditingController _retirementDateController =
      TextEditingController();

  final FocusNode _primaryEmailFocus = FocusNode();
  final FocusNode _mobileNoFocus = FocusNode();
  final FocusNode _dobFocus = FocusNode();
  final FocusNode _motherTongueFocus = FocusNode();
  final FocusNode _pinCodeFocus = FocusNode();

  ValueNotifier<dynamic> _selectedGender = ValueNotifier('');
  ValueNotifier<String> _selectedCategory = ValueNotifier('');
  ValueNotifier<bool> _savePressed = ValueNotifier(false);
  ValueNotifier<bool> _isChanged = ValueNotifier(false);
  DateTime? _dobDate;

  ValueNotifier<Map<dynamic, dynamic>?> _cadreSectionValueNotifier =
      ValueNotifier(null);
  late Future<CadreDetailsDataModel>? cadreDataFuture;
  String _errorMessage = '';

  ValueNotifier<bool> _isMobileVerified = ValueNotifier(false);
  ValueNotifier<bool> _isEmailVerified = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _populateFields();
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
    _ehrmsIdController.dispose();
    _retirementDateController.dispose();
    _primaryEmailFocus.dispose();
    _mobileNoFocus.dispose();
    _dobFocus.dispose();
    _motherTongueFocus.dispose();
    _pinCodeFocus.dispose();
    _primaryEmailController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.appBarBackground,
        appBar: EditPageAppbar(
          title: AppLocalizations.of(context)!.mProfileOtherDetails,
        ),
        body: _buildLayout(),
        bottomSheet: _bottomView(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  Widget _buildLayout() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Consumer<ProfileRepository>(builder: (BuildContext context,
          ProfileRepository profileRepository, Widget? child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16).r,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditProfileFiledHeading(
                    text: AppLocalizations.of(context)!.mProfileEmployeeId),
                TextInputField(
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    controller: _employeeIdController,
                    hintText:
                        AppLocalizations.of(context)!.mEditProfileTypeHere,
                    onChanged: (p0) => _checkForChanges(),
                    validatorFuntion: (String? value) =>
                        Validations.validateEmployeeId(
                            context: context, value: value ?? ''),
                    enabledBorderRadius: 63,
                    textStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: AppColors.greys)),
                SizedBox(height: 4.w),
                // Primary email
                OtpVerificationField(
                    key: GlobalKey(),
                    fieldFocus: _primaryEmailFocus,
                    parentContext: context,
                    fieldController: _primaryEmailController,
                    isEmailField: true,
                    isVerifiedNotifier: _isEmailVerified,
                    fieldTheme: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppColors.blackLegend),
                    enabledBorderRadius: 63,
                    onChanged: (p0) {
                      _checkForChanges();
                      _checkForCadreChanges();
                    }),
                // Gender
                FieldNameWidget(
                    fieldName: AppLocalizations.of(context)!.mProfileGender,
                    fieldTheme: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppColors.blackLegend)),
                ValueListenableBuilder(
                    valueListenable: _selectedGender,
                    builder: (BuildContext context, dynamic selectedGender,
                        Widget? child) {
                      return Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 8).r,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(63).r,
                            border: Border.all(color: AppColors.grey24)),
                        child: DropDownSelection(
                            options: EditProfileMandatoryHelper.genderRadio,
                            selectedValue: selectedGender,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.r),
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            icon: Icons.arrow_drop_down,
                            iconColor: AppColors.greys60,
                            padding: EdgeInsets.zero,
                            onChanged: (value) {
                              _selectedGender.value = value;
                              _checkForChanges();
                            }),
                      );
                    }),
                // DOB field
                FieldNameWidget(
                    fieldName: AppLocalizations.of(context)!.mProfileDOB,
                    fieldTheme: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppColors.blackLegend)),
                TextInputField(
                    focusNode: _dobFocus,
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    isDate: true,
                    controller: _dobController,
                    hintText: _dobController.text != ''
                        ? _dobController.text
                        : AppLocalizations.of(context)!.mEditProfileChooseDate,
                    suffixIcon:
                        Icon(Icons.date_range, color: AppColors.greys60),
                    enabledBorderRadius: 63,
                    textStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: AppColors.greys),
                    onTap: () async {
                      DateTime? newDate = await showDatePicker(
                          context: context,
                          initialEntryMode: DatePickerEntryMode.calendarOnly,
                          initialDate: _dobDate == null
                              ? ((_dobController.text != '') &&
                                      !RegExp(r'[a-zA-Z]')
                                          .hasMatch(_dobController.text)
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
                      _checkForChanges();
                    }),
                // Category
                FieldNameWidget(
                    fieldName: AppLocalizations.of(context)!.mProfileCategory,
                    fieldTheme: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppColors.blackLegend)),
                ValueListenableBuilder(
                    valueListenable: _selectedCategory,
                    builder: (BuildContext context, String selectedCategory,
                        Widget? child) {
                      return Container(
                        margin: EdgeInsets.only(top: 8.0, bottom: 8).r,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(63).r,
                            border: Border.all(color: AppColors.grey24)),
                        child: DropDownSelection(
                            options: EditProfileMandatoryHelper.categoryRadio,
                            selectedValue: selectedCategory,
                            icon: Icons.arrow_drop_down,
                            iconColor: AppColors.greys60,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.r),
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            padding: EdgeInsets.zero,
                            onChanged: (value) {
                              _selectedCategory.value = value!;
                              _checkForChanges();
                            }),
                      );
                    }),
                // Pincode field
                FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context)!.mProfileOfficePincode,
                    fieldTheme: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppColors.blackLegend)),
                TextInputField(
                    maxLength: 6,
                    minLines: 1,
                    focusNode: _pinCodeFocus,
                    keyboardType: TextInputType.number,
                    controller: _pinCodeController,
                    hintText: AppLocalizations.of(context)!.mStaticTypeHere,
                    enabledBorderRadius: 63,
                    textStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: AppColors.greys),
                    onChanged: (p0) => _checkForChanges(),
                    validatorFuntion: (String? value) =>
                        Validations.validatePinCode(value ?? ''),
                    onFieldSubmitted: (String value) {
                      _pinCodeFocus.unfocus();
                    },
                    counterText: ''),
                // Mobile number
                OtpVerificationField(
                    key: GlobalKey(),
                    fieldFocus: _mobileNoFocus,
                    parentContext: context,
                    fieldController: _mobileNumberController,
                    isToUpdateMobileNumber: false,
                    isVerifiedNotifier: _isMobileVerified,
                    enabledBorderRadius: 63,
                    fieldTheme: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppColors.blackLegend),
                    countryCodeTheme: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: AppColors.greys),
                    onChanged: (p0) {
                      _checkForChanges();
                      _checkForCadreChanges();
                    }),
                // Mother tongue
                FieldNameWidget(
                    fieldName:
                        AppLocalizations.of(context)!.mProfileMotherTongue,
                    fieldTheme: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(color: AppColors.blackLegend)),
                SelectFromBottomSheet(
                    parentContext: context,
                    fieldName: EnglishLang.languages,
                    controller: _motherTongueController,
                    showDefaultTextStyle: true,
                    suffixIconColor: AppColors.greys60,
                    customBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.grey16),
                        borderRadius: BorderRadius.circular(63).r),
                    callBack: () {
                      setState(() {});
                      _checkForChanges();
                    }),
                // Ehrms id
                EditProfileFiledHeading(
                    text: AppLocalizations.of(context)!
                        .mProfileEhrmsIdOrExternalSystemId),
                TextInputField(
                    minLines: 1,
                    readOnly: true,
                    keyboardType: TextInputType.text,
                    controller: _ehrmsIdController,
                    hintText:
                        AppLocalizations.of(context)!.mEditProfileTypeHere,
                    onChanged: (p0) => _checkForChanges(),
                    validatorFuntion: (String? value) =>
                        Validations.validateEmployeeId(
                            context: context, value: value ?? ''),
                    enabledBorderRadius: 63,
                    textStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: AppColors.greys)),
                // Retirement date
                EditProfileFiledHeading(
                    text: AppLocalizations.of(context)!.mDateOfRetirement),
                TextInputField(
                    minLines: 1,
                    readOnly: true,
                    keyboardType: TextInputType.text,
                    controller: _retirementDateController,
                    hintText:
                        AppLocalizations.of(context)!.mEditProfileTypeHere,
                    onChanged: (p0) => _checkForChanges(),
                    validatorFuntion: (String? value) =>
                        Validations.validateEmployeeId(
                            context: context, value: value ?? ''),
                    enabledBorderRadius: 63,
                    textStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: AppColors.greys)),

                ///cadre section start
                cadreSectionView(),
                SizedBox(
                  height: 96.w,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _bottomView() {
    return Container(
      height: 80.w,
      width: 1.sw,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24).r,
      color: AppColors.appBarBackground,
      child: Align(
          alignment: Alignment.center,
          child: ValueListenableBuilder(
              valueListenable: _savePressed,
              builder: (BuildContext context, bool savePressed, Widget? child) {
                return ValueListenableBuilder(
                    valueListenable: _isChanged,
                    builder:
                        (BuildContext context, bool isChanged, Widget? child) {
                      return ButtonWidgetV2(
                        text: AppLocalizations.of(context)!.mProfileSaveChanges,
                        textColor: AppColors.appBarBackground,
                        isLoading: savePressed,
                        bgColor:
                            isChanged ? AppColors.darkBlue : AppColors.grey40,
                        onTap: isChanged && !savePressed
                            ? () => _saveProfile()
                            : null,
                      );
                    });
              })),
    );
  }

  Widget cadreSectionView() {
    return FutureBuilder(
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
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.all(Radius.circular(16.w)),
            ),
            child: CadreDetailsSection(
                civilServiceType: cadreDetailsDataModel,
                cadreSectionValueNotifier: _cadreSectionValueNotifier,
                icon: Icons.arrow_drop_down,
                iconColor: AppColors.greys60,
                checkForChangesCallback: () {
                  _checkForCadreChanges();
                },
                fieldTheme: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: AppColors.blackLegend)),
          );
        }
      },
    );
  }

  void _populateFields() async {
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    dynamic personalDetails = profileDetails?.personalDetails;
    dynamic employmentDetails = profileDetails?.employmentDetails;
    _selectedGender.value = personalDetails['gender'];
    _selectedCategory.value = personalDetails['category'] ?? '';
    _pinCodeController.text = personalDetails['pincode'] ?? '';
    _dobController.text = personalDetails['dob'] ?? '';
    if (_dobController.text.isNotEmpty &&
        DateTimeHelper.checkDateFormat(_dobController.text,
            dateFormatStr: DateFormatString.yyyyMMdd)) {
      _dobController.text = DateTimeHelper.convertDateFormat(
          _dobController.text,
          inputFormat: DateFormatString.yyyyMMdd,
          desiredFormat: DateFormatString.ddMMyyyy);
    }
    _motherTongueController.text = personalDetails['domicileMedium'] ?? '';
    _employeeIdController.text = employmentDetails['employeeCode'] ?? '';
    _ehrmsIdController.text = profileDetails?.ehrmsId ?? 'NA';
    _retirementDateController.text = profileDetails?.dateOfRetirement ?? 'NA';
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    _errorMessage = AppLocalizations.of(context)!.mProfileProvideValidDetails;
    if (_formKey.currentState!.validate() && _validateCadreValue()) {
      try {
        _savePressed.value = true;
        await ProfileOtherDetailsViewModel.saveOtherPrimaryProfileDetails(
            context: context,
            profileOtherPrimaryDetails: ProfileOtherPrimaryDetails(
                pinCode: _pinCodeController.text,
                dob: _dobController.text,
                gender: _selectedGender.value ?? '',
                category: _selectedCategory.value,
                motherTongue: _motherTongueController.text,
                employeeId: _employeeIdController.text,
                cadreRequestData: _getCadreFormData()),
            callback: () => Navigator.pop(context));
        _savePressed.value = false;
      } catch (e) {
        _savePressed.value = false;
        debugPrint(e.toString());
      }
    } else {
      Helper.showSnackBarMessage(
          context: context, text: _errorMessage, bgColor: AppColors.greys87);
    }
  }

  _checkForChanges() {
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    dynamic personalDetails = profileDetails?.personalDetails;
    dynamic employmentDetails = profileDetails?.employmentDetails;

    _isChanged.value = false;
    if (_employeeIdController.text != employmentDetails['employeeCode'] ||
        _selectedGender.value != personalDetails['gender'] ||
        _selectedCategory.value != personalDetails['category'] ||
        _pinCodeController.text != personalDetails['pincode'] ||
        _dobController.text != personalDetails['dob'] ||
        _motherTongueController.text != personalDetails['domicileMedium']) {
      _isChanged.value = true;
    }
    return _isChanged.value;
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
          // values['cadreId'] == null || values['cadreId'].isEmpty ||
          values['cadreBatch'] == null) {
        _errorMessage =
            AppLocalizations.of(context)!.mProfileProvideValidCadreDetails;
        return false;
      }
    }
    return true;
  }

  _checkForCadreChanges() {
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    dynamic cadreDetails = profileDetails?.cadreDetails;
    _isChanged.value = false;
    final values = _cadreSectionValueNotifier.value;
    if (_isEmailVerified.value ) {
      if (cadreDetails != null) {
        if (values != null) {
          if (
              values['civilServiceTypeId'] != cadreDetails['civilServiceTypeId'] ||
              values['civilServiceId'] != cadreDetails['civilServiceId'] ||
              values['cadreId'] != cadreDetails['cadreId'] ||
              values['cadreBatch'] != cadreDetails['cadreBatch'] ||
              values['isOnCentralDeputation'] != cadreDetails['isOnCentralDeputation']) {
            _isChanged.value = true;
          }
        }
      } else {
        if (values != null) {
          _isChanged.value = true;
        }
      }
    }
    return _isChanged.value;
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
        isOnCentralDeputation: values['isOnCentralDeputation'],
      );
    }
    return null;
  }
}
