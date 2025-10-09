import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/otp_field_popup.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/validations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../constants/_constants/app_constants.dart'
    show RegExpressions, isNetcoreActive;
import '../../../../../../services/_services/smartech_service.dart';

class OtpVerificationField extends StatefulWidget {
  final FocusNode fieldFocus;
  final BuildContext parentContext;
  final TextEditingController fieldController;
  final bool isToUpdateMobileNumber;
  final bool isEmailField;
  final ValueNotifier<bool> isVerifiedNotifier;
  final Function(dynamic) onChanged;
  final TextStyle? fieldTheme;
  final TextStyle? countryCodeTheme;
  final double? enabledBorderRadius;
  final List<String> countryCodeList;
  OtpVerificationField(
      {Key? key,
      required this.fieldFocus,
      required this.parentContext,
      required this.fieldController,
      this.isToUpdateMobileNumber = false,
      this.isEmailField = false,
      required this.isVerifiedNotifier,
      required this.onChanged,
      this.fieldTheme,
      this.countryCodeTheme,
      this.enabledBorderRadius,
      this.countryCodeList = const []})
      : super(key: key);

  @override
  State<OtpVerificationField> createState() => OtpVerificationFieldState();
}

class OtpVerificationFieldState extends State<OtpVerificationField> {
  final ProfileService profileService = ProfileService();
  final ProfileRepository profileRepository = ProfileRepository();
  // List<String> _countryCodes = [];
  final TextEditingController _otpController = TextEditingController();
  ValueNotifier<String> _countryCode = ValueNotifier('');
  ValueNotifier<bool> _showResendOption = ValueNotifier(false);
  ValueNotifier<String> _timeFormat = ValueNotifier('');

  final FocusNode _otpFocus = FocusNode();

  bool _hasVerified = false;
  late String mobile;
  Timer? _timer;

  int? _resendOTPTime = 180;

  RegExp regExpEmail = RegExpressions.validEmail;
  List<String> approvedDomains = [];
  String _email = '';

  @override
  void initState() {
    super.initState();
    _populateMobileNumber();
    _getResendTimeOTP();
    if (widget.isEmailField) {
      getApprovedEmailDomains();
    }
    if (widget.isToUpdateMobileNumber) {
      Future.delayed(Duration(milliseconds: 1000), () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          FocusScope.of(context).requestFocus(widget.fieldFocus);
        });
        setState(() {});
      });
    }
  }

  _populateMobileNumber() {
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    dynamic personalDetails = profileDetails?.personalDetails;
    if (widget.isEmailField && profileDetails != null) {
      widget.fieldController.text = profileDetails.primaryEmail;
      _email = profileDetails.primaryEmail;
    } else {
      if (personalDetails != null) {
        widget.fieldController.text = personalDetails['mobile'] != null
            ? personalDetails['mobile'].toString()
            : '';
      }
    }
  }

  Future<void> _getResendTimeOTP() async {
    _resendOTPTime =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getResendOtpTime();
  }

  // _getCountryCodes() async {
  //   _countryCodes = await EditProfileMandatoryHelper.getNationalities(context);
  // }

  _showPopupToEnterOtp() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return ValueListenableBuilder(
              valueListenable: _showResendOption,
              builder:
                  (BuildContext context, bool showResendOption, Widget? child) {
                return ValueListenableBuilder(
                    valueListenable: _timeFormat,
                    builder: (BuildContext context, String timeFormat,
                        Widget? child) {
                      return OtpFieldPopup(
                          otpController: _otpController,
                          parentContext: widget.parentContext,
                          onResendPressed: () =>
                              _sendOTPToVerifyNumber(isFromResend: true),
                          showResendOption: showResendOption,
                          fieldController: widget.fieldController,
                          timeFormat: timeFormat,
                          isEmailField: widget.isEmailField,
                          verifyOtpAction: _verifyOtpAction,
                          resendOtpTime: _resendOTPTime ?? 180);
                    });
              });
        });
  }

  _sendOTPToVerifyNumber({bool isFromResend = false}) async {
    final response = widget.isEmailField
        ? await profileService
            .generatePrimaryEmailOTP(widget.fieldController.text.trim())
        : await profileService
            .generateMobileNumberOTP(widget.fieldController.text.trim());

    if (response['params']['errmsg'] == null ||
        response['params']['errmsg'] == '') {
      if (!isFromResend) {
        _showPopupToEnterOtp();
      }
      widget.fieldFocus.unfocus();
      setState(() {
        _otpController.clear();
        _hasVerified = false;
        widget.isVerifiedNotifier.value = false;
      });
    } else {
      Helper.showSnackBarMessage(
          context: context,
          text: response['params']['errmsg'].toString(),
          bgColor: AppColors.negativeLight);
    }
  }

  Future<void> getApprovedEmailDomains() async {
    approvedDomains = await profileRepository.getApprovedEmailDomains();
  }

  bool checkIsEmailApproved(String email) {
    if (approvedDomains.contains(Helper.extractEmailDomain(email))) {
      return true;
    }
    return false;
  }

  _verifyOtpAction() async {
    await Provider.of<ProfileRepository>(context, listen: false)
        .getProfileDetailsById('');
    setState(() {
      _hasVerified = true;
      widget.isVerifiedNotifier.value = true;
    });
    _onChange();
    /** SMT User Profile update **/
    smtUpdateUserPatchDetail();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocus.dispose();
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileRepository>(
        builder: (context, profileRepository, _) {
      mobile = profileRepository.profileDetails?.rawDetails['profileDetails']
                  ['personalDetails'] !=
              null
          ? profileRepository.profileDetails!
              .rawDetails['profileDetails']['personalDetails']['mobile']
              .toString()
          : '';

      if (widget.isEmailField) {
        _hasVerified = profileRepository.profileDetails?.primaryEmail ==
            widget.fieldController.text.trim();
        widget.isVerifiedNotifier.value = _hasVerified;
      } else {
        _hasVerified = profileRepository.profileDetails
                    ?.rawDetails['profileDetails']['personalDetails'] !=
                null
            ? profileRepository.profileDetails!.rawDetails['profileDetails']
                        ['personalDetails']['phoneVerified'] !=
                    null
                ? profileRepository.profileDetails!.rawDetails['profileDetails']
                        ['personalDetails']['phoneVerified'] is String
                    ? bool.parse(profileRepository
                            .profileDetails!.rawDetails['profileDetails']
                        ['personalDetails']['phoneVerified'])
                    : profileRepository.profileDetails!.rawDetails['profileDetails']
                        ['personalDetails']['phoneVerified']
                : false
            : false;

        if (widget.fieldController.text.trim().length > 9 &&
            (mobile == widget.fieldController.text.trim())) {
          widget.isVerifiedNotifier.value = profileRepository.profileDetails
                      ?.rawDetails['profileDetails']['personalDetails'] !=
                  null
              ? profileRepository.profileDetails!.rawDetails['profileDetails']
                          ['personalDetails']['phoneVerified'] !=
                      null
                  ? (profileRepository.profileDetails!.rawDetails['profileDetails']
                          ['personalDetails']['phoneVerified'] is String
                      ? bool.parse(
                          profileRepository.profileDetails!.rawDetails['profileDetails']
                              ['personalDetails']['phoneVerified'])
                      : profileRepository.profileDetails!.rawDetails['profileDetails']
                          ['personalDetails']['phoneVerified'])
                  : false
              : false;
        } else {
          widget.isVerifiedNotifier.value = false;
        }
      }
      return Column(
        children: [
          FieldNameWidget(
            fieldName: widget.isEmailField
                ? AppLocalizations.of(context)!.mRegisteremail
                : AppLocalizations.of(context)!.mProfileMobileNumber,
            fieldTheme: widget.fieldTheme,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8).r,
            child: Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: !widget.isEmailField,
                      child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.appBarBackground,
                              borderRadius: BorderRadius.all(Radius.circular(
                                      widget.enabledBorderRadius ?? 4))
                                  .w,
                              border: Border.all(color: AppColors.grey16)),
                          height: 48.0,
                          width: widget.enabledBorderRadius != null
                              ? 0.2.sw
                              : 0.165.sw,
                          child: ValueListenableBuilder(
                              valueListenable: _countryCode,
                              builder: (BuildContext context,
                                  String countryCode, Widget? child) {
                                return Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('+91',
                                          style: widget.countryCodeTheme ??
                                              Theme.of(context)
                                                  .textTheme
                                                  .labelLarge),
                                      widget.countryCodeList.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  EdgeInsets.only(left: 6.w),
                                              child: Icon(
                                                  Icons
                                                      .keyboard_arrow_down_outlined,
                                                  color: AppColors.blackLegend),
                                            )
                                          : SizedBox()
                                    ],
                                  ),
                                );
                              })),
                    ),
                    Expanded(
                      child: Container(
                        margin: widget.isEmailField
                            ? null
                            : EdgeInsets.only(left: 8).r,
                        //  width: widget.isEmailField ? 1.sw - 64.w : 0.65.sw,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4).r,
                        ),
                        child: TextFormField(
                            textInputAction: TextInputAction.next,
                            focusNode: widget.fieldFocus,
                            onFieldSubmitted: (term) {},
                            onChanged: (value) {
                              setState(() {
                                _hasVerified = false;
                                widget.isVerifiedNotifier.value = false;
                                if (value.trim().length > 9 &&
                                    (mobile == value.trim())) {}
                              });
                              _onChange();
                            },
                            controller: widget.fieldController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            maxLength: widget.isEmailField ? null : 10,
                            validator: (String? value) {
                              if (widget.isEmailField) {
                                String? message =
                                    Validations.validatePrimaryEmail(
                                        context: context, value: value ?? '');
                                if (message != null) return message;
                                if (!checkIsEmailApproved(value ?? '') &&
                                    ((_email != value) && !_hasVerified)) {
                                  return AppLocalizations.of(context)!
                                      .mProfileNotApprovedDomain;
                                }
                                return null;
                              } else {
                                return Validations.validateMobile(
                                    context: context, value: value ?? "");
                              }
                            },
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: AppColors.greys),
                            keyboardType: widget.isEmailField
                                ? TextInputType.emailAddress
                                : TextInputType.phone,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.appBarBackground,
                              counterText: '',
                              suffixIcon: (!widget.isEmailField &&
                                          _hasVerified == true &&
                                          widget.fieldController.text
                                                  .toString()
                                                  .trim() ==
                                              mobile.toString().trim()) ||
                                      (widget.isEmailField &&
                                          profileRepository.profileDetails
                                                  ?.primaryEmail ==
                                              widget.fieldController.text
                                                  .trim())
                                  ? Icon(
                                      Icons.check,
                                    )
                                  : null,
                              contentPadding:
                                  EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0).r,
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      widget.enabledBorderRadius != null
                                          ? BorderRadius.circular(
                                                  widget.enabledBorderRadius!)
                                              .r
                                          : BorderRadius.zero,
                                  borderSide:
                                      BorderSide(color: AppColors.grey16)),
                              hintText:
                                  AppLocalizations.of(context)!.mStaticTypeHere,
                              helperText: widget.isEmailField
                                  ? (regExpEmail.hasMatch(
                                          widget.fieldController.text.trim())
                                      ? null
                                      : AppLocalizations.of(context)!
                                          .mEditProfileAddValidEmail)
                                  : (((!widget.isEmailField &&
                                              widget.fieldController.text
                                                      .trim()
                                                      .length ==
                                                  10) &&
                                          RegExpressions.validPhone.hasMatch(
                                              widget.fieldController.text
                                                  .trim()))
                                      ? null
                                      : AppLocalizations.of(context)!
                                          .mEditProfilePleaseAddValidNumber),
                              hintStyle: Theme.of(context).textTheme.labelLarge,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: widget.enabledBorderRadius != null
                                    ? BorderRadius.circular(
                                            widget.enabledBorderRadius!)
                                        .r
                                    : BorderRadius.zero,
                                borderSide: BorderSide(
                                    color: AppColors.darkBlue, width: 1.0.w),
                              ),
                            )),
                      ),
                    ),
                  ],
                )),
          ),
          Visibility(
            visible: ((widget.isEmailField
                        ? profileRepository.profileDetails?.primaryEmail
                        : mobile.toString()) !=
                    widget.fieldController.text.trim() ||
                !_hasVerified),
            child: Padding(
              padding: const EdgeInsets.only(top: 4).r,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkBlue,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  onPressed: (widget.isEmailField
                          ? checkIsEmailApproved(
                                  widget.fieldController.text.trim())
                              ? Validations.isValidEmail(
                                  context: context,
                                  value: widget.fieldController.text.trim())
                              : false
                          : Validations.isValidMobile(
                              context: context,
                              value: widget.fieldController.text.trim()))
                      ? () async {
                          await _sendOTPToVerifyNumber();
                        }
                      : null,
                  child: Text(
                    AppLocalizations.of(context)!.mProfileGetOTP,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
            ),
          )
        ],
      );
    });
  }

  void _onChange() async {
    await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      widget.onChanged(widget.fieldController.text);
    }
  }

  void smtUpdateUserPatchDetail() async {
    if (widget.fieldController.text.isNotEmpty) {
      try {
        if (isNetcoreActive) {
          bool _isUpdateUserProfileEnabled =
              await Provider.of<LearnRepository>(context, listen: false)
                  .isSmartechEventEnabled(
                      eventName: SMTTrackEvents.userProfilePush, reload: false);
          if (_isUpdateUserProfileEnabled) {
            bool _isTrackProfileUpdateEnabled =
                await Provider.of<LearnRepository>(context, listen: false)
                    .isSmartechEventEnabled(
                        eventName: SMTTrackEvents.profileUpdate);
            SmartechService.updateUserPatchDetail(
                context: context,
                profileAttributeUpdated: (widget.isEmailField)
                    ? SMTUserProfileKeys.email
                    : SMTUserProfileKeys.mobile,
                isTrackProfileUpdateEnabled: _isTrackProfileUpdateEnabled,
                userPatchData: {
                  (widget.isEmailField)
                          ? SMTUserProfileKeys.email
                          : SMTUserProfileKeys.mobile:
                      "${widget.fieldController.text}"
                });
          }
        }
      } catch (_) {
        print(_);
      }
    }
  }
}
