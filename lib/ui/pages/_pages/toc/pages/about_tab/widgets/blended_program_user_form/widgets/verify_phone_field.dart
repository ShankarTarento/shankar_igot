import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';

import '../../../../../../../../../respositories/index.dart';

class VerifyPhoneField extends StatefulWidget {
  final Function(bool) onChanged;
  final Function(String) mobileNumber;
  final TextEditingController mobileController;
  final String? unverifiedPhone;
  final bool isVerified;

  const VerifyPhoneField(
      {super.key,
      required this.onChanged,
      required this.mobileNumber,
      required this.isVerified,
      this.unverifiedPhone,
      required this.mobileController});

  @override
  State<VerifyPhoneField> createState() => _VerifyPhoneFieldState();
}

class _VerifyPhoneFieldState extends State<VerifyPhoneField> {
  bool _freezeMobileField = false;
  final FocusNode _otpFocus = FocusNode();

  final FocusNode _mobileNumberFocus = FocusNode();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _mobileNoOTPController = TextEditingController();

  bool _hasSendOTPRequest = false;
  bool _isMobileNumberVerified = false;
  bool _showResendOption = false;
  int _resendOTPTime = RegistrationType.resendOtpTimeLimit;
  String? _timeFormat;

  ProfileRepository profileRepository = ProfileRepository();
  Timer? _timer;

  @override
  void initState() {
    _isMobileNumberVerified = widget.isVerified;
    _mobileNoController.text =
        widget.unverifiedPhone ?? widget.mobileController.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildPhoneNumberField();
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMobileNumberHeader(),
        _buildMobileNumberInput(),
      ],
    );
  }

  Widget _buildMobileNumberHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: AppLocalizations.of(context)!.mRegistermobileNumber,
                style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontWeight: FontWeight.w700,
                  height: 1.5.w,
                  letterSpacing: 0.25,
                  fontSize: 14.sp,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.mandatoryRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
        if (_freezeMobileField) _buildEditButton(),
      ],
    );
  }

  Widget _buildEditButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _freezeMobileField = false;
          _hasSendOTPRequest = false;
          _otpFocus.unfocus();
          FocusScope.of(_otpFocus.context!).requestFocus(_mobileNumberFocus);
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.edit,
            size: 18.sp,
            color: AppColors.darkBlue,
          ),
          Text(AppLocalizations.of(context)!.mStaticEdit,
              style: GoogleFonts.lato(
                  color: AppColors.darkBlue,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMobileNumberInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            padding: EdgeInsets.only(top: 6).r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4).r,
            ),
            child: Focus(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (term) {
                  // FocusScope.of(context).unfocus();
                },
                focusNode: _mobileNumberFocus,
                onChanged: (value) {
                  widget.onChanged(widget.mobileController.text == value);

                  if (widget.mobileController.text != value) {
                    setState(() {
                      _hasSendOTPRequest = false;
                      _isMobileNumberVerified = false;
                    });
                  }
                },
                maxLength: 10,
                readOnly: _freezeMobileField || _isMobileNumberVerified,
                controller: _mobileNoController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (String? value) {
                  if (value!.trim().isEmpty) {
                    return AppLocalizations.of(context)!
                        .mStaticEmptyMobileNumber;
                  } else if (value.trim().length != 10 ||
                      !RegExpressions.validPhone.hasMatch(value)) {
                    return AppLocalizations.of(context)!
                        .mStaticPleaseAddValidNumber;
                  } else
                    return null;
                },
                style: GoogleFonts.lato(fontSize: 14.0.sp),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _freezeMobileField
                      ? AppColors.grey04
                      : AppColors.appBarBackground,
                  counterText: '',
                  suffixIcon:
                      _isMobileNumberVerified || _mobileNumberFocus.hasFocus
                          ? _mobileNumberFocus.hasFocus
                              ? InkWell(
                                  onTap: () {
                                    _mobileNumberFocus.unfocus();
                                    _mobileNoController.text =
                                        widget.mobileController.text;
                                    widget.onChanged(widget.isVerified);
                                    _isMobileNumberVerified = widget.isVerified;
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: AppColors.greys60,
                                  ),
                                )
                              : Icon(
                                  Icons.check_circle,
                                  color: AppColors.positiveLight,
                                )
                          : null,
                  contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0).r,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grey08)),
                  hintText: AppLocalizations.of(context)!.mStaticMobileNumber,
                  helperText: (_isMobileNumberVerified ||
                          (_mobileNoController.text.trim().length == 10 &&
                              RegExpressions.validPhone
                                  .hasMatch(_mobileNoController.text.trim())))
                      ? null
                      : AppLocalizations.of(context)!
                          .mStaticPleaseAddValidNumber,
                  hintStyle: GoogleFonts.lato(
                      color: AppColors.grey40,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w400),
                  enabled: !_freezeMobileField,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.grey16)),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: AppColors.darkBlue, width: 1.0),
                  ),
                ),
              ),
            )),
        _isMobileNumberVerified ? _buildChangeMobileNumberButton() : Center(),
        !_hasSendOTPRequest &&
                widget.mobileController.text != _mobileNoController.text
            ? _buildSendOTPButton()
            : _hasSendOTPRequest
                ? verifyOtpSection()
                : Center(),
        SizedBox(
          height: 16.w,
        )
      ],
    );
  }

  Widget verifyOtpSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16).r,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 0.475.sw,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4).r,
                  ),
                  child: Focus(
                    child: TextFormField(
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      focusNode: _otpFocus,
                      controller: _mobileNoOTPController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return AppLocalizations.of(context)!
                                .mStaticEnterOtp;
                          } else
                            return null;
                        } else {
                          return null;
                        }
                      },
                      style: GoogleFonts.lato(fontSize: 14.0.sp),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.appBarBackground,
                        contentPadding:
                            EdgeInsets.fromLTRB(16.0, 0.0, 20.0, 0.0).r,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.grey16)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.grey16)),
                        hintText: AppLocalizations.of(context)!.mStaticEnterOtp,
                        hintStyle: GoogleFonts.lato(
                            color: AppColors.grey40,
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w400),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.darkBlue, width: 1.0),
                        ),
                      ),
                    ),
                  )),
              Container(
                width: 0.4.sw,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () async {
                    await _verifyOTP(_mobileNoOTPController.text);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.mRegisterverifyOTP,
                    style: GoogleFonts.lato(
                        height: 1.429.w,
                        letterSpacing: 0.5,
                        fontSize: 14.sp,
                        color: AppColors.appBarBackground,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          !_showResendOption && !_isMobileNumberVerified
              ? Container(
                  padding: EdgeInsets.only(top: 16).r,
                  alignment: Alignment.topLeft,
                  child: Text(
                    '${AppLocalizations.of(context)!.mRegisterresendOTPAfter} $_timeFormat',
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      color: AppColors.darkBlue,
                    ),
                  ),
                )
              : Container(
                  alignment: Alignment.topLeft,
                  // padding: EdgeInsets.only(top: 8),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero.r,
                        minimumSize: Size(50, 50),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        _sendOTPToVerifyNumber();
                        setState(() {
                          _showResendOption = false;
                          _resendOTPTime = RegistrationType.resendOtpTimeLimit;
                        });
                      },
                      child: Text(
                          AppLocalizations.of(context)!.mRegisterresendOTP,
                          style: Theme.of(context).textTheme.headlineMedium!)),
                ),
        ],
      ),
    );
  }

  Widget _buildChangeMobileNumberButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero.r,
              minimumSize: Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              setState(() {
                _isMobileNumberVerified = false;
              });
              FocusScope.of(context).requestFocus(_mobileNumberFocus);
            },
            child: Text(
              AppLocalizations.of(context)!.mStaticChangeMobileNumber,
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: AppColors.darkBlue),
            ),
          )),
    );
  }

  Widget _buildSendOTPButton() {
    return Padding(
      padding: (_mobileNoController.text.trim().length == 10 &&
              RegExpressions.validPhone
                  .hasMatch(_mobileNoController.text.trim()))
          ? EdgeInsets.only(top: 16).r
          : EdgeInsets.zero.r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: 0.6.sw,
              child: Text(
                AppLocalizations.of(context)!.mRegisterVerifyMobile,
                style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.5.w),
              )),
          Container(
            width: 0.3.sw,
            padding: EdgeInsets.only(top: 8).w,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _mobileNoController.text.trim().length == 10
                  ? () async {
                      await _sendOTPToVerifyNumber();
                    }
                  : null,
              child: Text(
                AppLocalizations.of(context)!.mStaticSendOtp,
                style: GoogleFonts.lato(
                    height: 1.429.w,
                    letterSpacing: 0.5,
                    fontSize: 14.sp,
                    color: AppColors.appBarBackground,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _sendOTPToVerifyNumber() async {
    final String response = await profileRepository
        .generateMobileNumberOTP(_mobileNoController.text);
    if (response == '') {
      _showSnackBar(AppLocalizations.of(context)!.mStaticOtpSentToMobile,
          AppColors.positiveLight);
      setState(() {
        _hasSendOTPRequest = true;
        _freezeMobileField = true;
        _mobileNoOTPController.clear();
        _showResendOption = false;
        _resendOTPTime = RegistrationType.resendOtpTimeLimit;
      });
      FocusScope.of(context).requestFocus(_otpFocus);
      _startTimer();
    } else {
      _showSnackBar(response, AppColors.primaryTwo);
    }
  }

  _verifyOTP(String otp) async {
    final String response = await profileRepository.verifyMobileNumberOTP(
        _mobileNoController.text, otp);
    if (response == '') {
      _showSnackBar(AppLocalizations.of(context)!.mStaticMobileVerifiedMessage,
          AppColors.positiveLight);
      setState(() {
        _hasSendOTPRequest = false;
        _isMobileNumberVerified = true;

        widget.onChanged(true);
        widget.mobileNumber(_mobileNoController.text);
        _timer?.cancel();
      });
    } else {
      _showSnackBar(response, AppColors.primaryTwo);
      widget.mobileNumber(_mobileNoController.text);
    }
    setState(() {
      _freezeMobileField = false;
    });
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

  void _startTimer() {
    _resendOTPTime = RegistrationType.resendOtpTimeLimit;
    _timeFormat = formatHHMMSS(_resendOTPTime);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendOTPTime == 0) {
        setState(() {
          timer.cancel();
          _showResendOption = true;
        });
      } else {
        setState(() {
          _resendOTPTime--;
          _timeFormat = formatHHMMSS(_resendOTPTime);
        });
      }
    });
  }

  String formatHHMMSS(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return hours == '00' ? '$minutes:$secs' : '$hours:$minutes:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpFocus.dispose();
    _mobileNumberFocus.dispose();
    _mobileNoOTPController.dispose();
    super.dispose();
  }
}
