import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/edit_profile_mandatory_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class OtpFieldPopup extends StatefulWidget {
  final BuildContext parentContext;
  final TextEditingController otpController;
  final TextEditingController fieldController;
  final bool isEmailField;
  final Function() onResendPressed;
  final String timeFormat;
  final bool showResendOption;
  final Function() verifyOtpAction;
  final int resendOtpTime;
  const OtpFieldPopup(
      {Key? key,
      required this.parentContext,
      required this.otpController,
      this.isEmailField = false,
      required this.onResendPressed,
      required this.timeFormat,
      required this.showResendOption,
      required this.fieldController,
      required this.verifyOtpAction,
      required this.resendOtpTime})
      : super(key: key);

  @override
  State<OtpFieldPopup> createState() => _OtpFieldPopupState();
}

class _OtpFieldPopupState extends State<OtpFieldPopup> {
  final ProfileService profileService = ProfileService();
  ValueNotifier<String> _otp = ValueNotifier('');
  ValueNotifier<String> _timeFormat = ValueNotifier('');
  ValueNotifier<bool> _showResendOption = ValueNotifier(false);
  late int _resendOTPTime;
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    _resendOTPTime = widget.resendOtpTime;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.only(left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.grey08, borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.isEmailField
                      ? AppLocalizations.of(widget.parentContext)!
                          .mProfileEnterOtpForEmail
                      : AppLocalizations.of(widget.parentContext)!
                          .mProfileEnterOtpForMobile,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              SizedBox(height: 8),
              FieldNameWidget(
                  fieldName: AppLocalizations.of(widget.parentContext)!
                      .mEditProfileEnterOtp),
              Container(
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    controller: widget.otpController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    obscureText: true,
                    onChanged: (value) => _otp.value = value,
                    validator: (String? value) {
                      if (value != null && value.isEmpty) {
                        return AppLocalizations.of(widget.parentContext)!
                            .mEditProfileEnterOtp;
                      } else
                        return null;
                    },
                    style: GoogleFonts.lato(fontSize: 14.0),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.appBarBackground,
                      contentPadding: EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0),
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.grey16)),
                      hintText: AppLocalizations.of(widget.parentContext)!
                          .mEditProfileEnterOtp,
                      hintStyle: GoogleFonts.lato(
                          color: AppColors.grey40,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: AppColors.darkBlue, width: 1.0),
                      ),
                    ),
                  )),
              SizedBox(height: 16),
              ValueListenableBuilder(
                  valueListenable: _showResendOption,
                  builder: (BuildContext context, bool showResendOption,
                      Widget? child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(widget.parentContext)!
                              .mProfileNotRecievedOtp,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.greys60),
                        ),
                        SizedBox(width: 4),
                        Row(
                          children: [
                            TextButton(
                                style: TextButton.styleFrom(
                                    foregroundColor: AppColors.darkBlue,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity(vertical: -4)),
                                onPressed: showResendOption
                                    ? () {
                                        widget.onResendPressed();
                                        _startTimer();
                                      }
                                    : null,
                                child: Text(
                                    AppLocalizations.of(widget.parentContext)!
                                        .mEditProfileResendOtp)),
                            Visibility(
                              visible: !showResendOption,
                              child: ValueListenableBuilder(
                                valueListenable: _timeFormat,
                                builder: (context, timeFormat, child) =>
                                    Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text('($timeFormat)',
                                      style: GoogleFonts.lato(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: AppColors.greys60)),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  }),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buttonWidget(
                    text: AppLocalizations.of(widget.parentContext)!
                        .mStaticCancel,
                    textColor: AppColors.darkBlue,
                    borderColor: AppColors.darkBlue,
                    bgColor: Colors.transparent,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  ValueListenableBuilder(
                      valueListenable: _otp,
                      builder:
                          (BuildContext context, String otp, Widget? child) {
                        return buttonWidget(
                          text: AppLocalizations.of(widget.parentContext)!
                              .mProfileSubmitRequest,
                          textColor: AppColors.appBarBackground,
                          bgColor: otp.isNotEmpty
                              ? AppColors.darkBlue
                              : AppColors.grey40,
                          onTap: () => otp.isNotEmpty
                              ? _verifyOTP(otp: otp, parentContext: context)
                              : null,
                        );
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonWidget(
      {required Color textColor,
      required Color bgColor,
      Color? borderColor,
      required String text,
      required Function() onTap}) {
    return InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(50),
              border: borderColor != null
                  ? Border.all(color: borderColor)
                  : Border.fromBorderSide(BorderSide.none)),
          child: Center(
            child: Text(text,
                style: GoogleFonts.lato(
                    color: textColor, fontWeight: FontWeight.w600)),
          ),
        ));
  }

  _verifyOTP({required String otp, required BuildContext parentContext}) async {
    final response = widget.isEmailField
        ? await profileService.verifyPrimaryEmailOTP(
            widget.fieldController.text.trim(), otp)
        : await profileService.verifyMobileNumberOTP(
            widget.fieldController.text.trim(), otp);

    if (response['params']['errmsg'] == null ||
        response['params']['errmsg'] == '') {
      var profileUpdateResponse;
      //call extPatch
      if (widget.isEmailField) {
        profileUpdateResponse = await profileService.updateUserPrimaryEmail(
            email: widget.fieldController.text.trim(),
            contextToken: response['result']['contextToken']);
      } else {
        Map profileData = {
          "personalDetails": {
            "mobile": int.parse(widget.fieldController.text.trim()),
            "phoneVerified": true
          },
        };
        profileUpdateResponse =
            await profileService.updateProfileDetails(profileData);
      }
      if (profileUpdateResponse['params']['status'] == 'success' ||
          profileUpdateResponse['params']['status'] == 'SUCCESS') {
        Helper.showSnackBarMessage(
            context: widget.parentContext,
            text: widget.isEmailField
                ? AppLocalizations.of(widget.parentContext)!
                    .mEditProfileEmailVerifiedMessage
                : AppLocalizations.of(widget.parentContext)!
                    .mEditProfileMobileVerifiedMessage,
            bgColor: AppColors.positiveLight);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          widget.verifyOtpAction();
        });
      } else {
        Helper.showSnackBarMessage(
            context: widget.parentContext,
            text: profileUpdateResponse['params']['errmsg'].toString(),
            bgColor: AppColors.negativeLight);
      }
    } else {
      Helper.showSnackBarMessage(
          context: widget.parentContext,
          text: response['params']['errmsg'].toString(),
          bgColor: AppColors.negativeLight);
    }
    Navigator.of(parentContext).pop();
  }

  void _startTimer() {
    _showResendOption.value = false;
    _resendOTPTime = widget.resendOtpTime;
    _timeFormat.value = EditProfileMandatoryHelper.formatHHMMSS(_resendOTPTime);
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_resendOTPTime == 0) {
          timer.cancel();
          _showResendOption.value = true;
        } else {
          if (mounted) {
            _resendOTPTime--;
          }
        }
        _timeFormat.value =
            EditProfileMandatoryHelper.formatHHMMSS(_resendOTPTime);
      },
    );
  }
}
