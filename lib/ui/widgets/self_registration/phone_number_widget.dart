import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/respositories/index.dart';

import '../../../constants/index.dart';
import '../../../feedback/constants.dart';
import '../../../localization/index.dart';

class PhoneNumberWidget extends StatefulWidget {
  final bool isFocused;
  final ValueChanged<String?>? onSaved;
  final GlobalKey<FormState> formKey;
  final ValueChanged<bool> mobileVerified;
  final String? mobileNumber;
  final bool isMobileVerified;
  final ValueChanged<String>? changeFocus;
  final ProfileRepository profileRepository;

  PhoneNumberWidget(
      {super.key,
      this.isFocused = false,
      this.onSaved,
      required this.formKey,
      required this.mobileVerified,
      this.mobileNumber,
      this.isMobileVerified = false,
      this.changeFocus,
      ProfileRepository? profileRepository})
      : profileRepository = profileRepository ?? ProfileRepository();
  @override
  State<PhoneNumberWidget> createState() => PhoneNumberWidgetState();
}

class PhoneNumberWidgetState extends State<PhoneNumberWidget> {
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController _mobileNoOTPController = TextEditingController();
  final FocusNode mobileNumberFocus = FocusNode();
  final FocusNode otpFocus = FocusNode();
  bool freezeMobileField = false;
  bool _hasSendOTPRequest = false;
  bool isMobileNumberVerified = false;
  bool showResendOption = false;
  String? timeFormat;
  int resendOTPTime = RegistrationType.resendOtpTimeLimit;
  Timer? _timer;

  @override
  void didUpdateWidget(PhoneNumberWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateFocus();
    if (widget.mobileNumber != null &&
        widget.mobileNumber != mobileNoController.text) {
      mobileNoController.text = widget.mobileNumber!;
    }
    if (widget.isMobileVerified &&
        widget.isMobileVerified != isMobileNumberVerified) {
      isMobileNumberVerified = widget.isMobileVerified;
    }
  }

  @override
  void dispose() {
    super.dispose();
    mobileNumberFocus.dispose();
    otpFocus.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(8),
      color: AppColors.grey24,
      dashPattern: [10, 8],
      strokeWidth: 1,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                    text: AppLocalizations.of(context)!.mRegistermobileNumber,
                    style: GoogleFonts.lato(
                        color: AppColors.greys87,
                        fontWeight: FontWeight.w700,
                        height: 1.5.w,
                        letterSpacing: 0.25,
                        fontSize: 14.sp),
                    children: [
                      TextSpan(
                          text: ' *',
                          style: GoogleFonts.lato(
                              color: AppColors.mandatoryRed,
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp))
                    ]),
              ),
              freezeMobileField
                  ? TextButton(
                      key: Key('EditButton'),
                      onPressed: () {
                        setState(() {
                          freezeMobileField = false;
                          isMobileNumberVerified = false;
                          _hasSendOTPRequest = false;
                          otpFocus.unfocus();
                        });
                        FocusScope.of(otpFocus.context!)
                            .requestFocus(mobileNumberFocus);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero.r,
                        minimumSize: Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 4).r,
                            child: Icon(Icons.edit,
                                size: 18.sp, color: AppColors.darkBlue),
                          ),
                          Text(
                            AppLocalizations.of(context)!.mStaticEdit,
                            style: GoogleFonts.lato(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue),
                          )
                        ],
                      ))
                  : Center()
            ],
          ),
          Container(
              padding: EdgeInsets.only(top: 6).r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4).r,
              ),
              child: Focus(
                child: TextFormField(
                  key: Key('Mobile'),
                  textInputAction: TextInputAction.next,
                  focusNode: mobileNumberFocus,
                  onChanged: (value) {
                    if (widget.onSaved != null) {
                      widget.onSaved!(value);
                    }
                    setState(() {
                      _hasSendOTPRequest = false;
                      isMobileNumberVerified = false;
                    });
                  },
                  maxLength: 10,
                  readOnly: freezeMobileField || isMobileNumberVerified,
                  controller: mobileNoController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? value) {
                    if (value!.trim().isEmpty && value.trim().length != 10 ||
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
                    fillColor: freezeMobileField
                        ? AppColors.grey04
                        : AppColors.appBarBackground,
                    counterText: '',
                    suffixIcon: isMobileNumberVerified
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.positiveLight,
                          )
                        : null,
                    contentPadding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0).r,
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.grey16)),
                    hintText: AppLocalizations.of(context)!
                        .mRegisterEnterMobileNumber,
                    hintStyle: GoogleFonts.lato(
                        color: AppColors.grey40,
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w400),
                    errorStyle: GoogleFonts.lato(
                        fontSize: 14.0.sp, fontWeight: FontWeight.w400),
                    enabled: !freezeMobileField,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: AppColors.darkBlue, width: 1.0),
                    ),
                  ),
                ),
              )),
          isMobileNumberVerified
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        key: Key('ChangeNumber'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero.r,
                          minimumSize: Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          setState(() {
                            isMobileNumberVerified = false;
                          });
                          widget.mobileVerified(false);
                          FocusScope.of(context)
                              .requestFocus(mobileNumberFocus);
                        },
                        child: Text(
                          AppLocalizations.of(context)!
                              .mStaticChangeMobileNumber,
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.darkBlue),
                        ),
                      )),
                )
              : Center(),
          !_hasSendOTPRequest && !isMobileNumberVerified
              ? Padding(
                  padding: (mobileNoController.text.trim().length == 10 &&
                          RegExpressions.validPhone
                              .hasMatch(mobileNoController.text.trim()))
                      ? EdgeInsets.only(top: 16).r
                      : EdgeInsets.zero.r,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 0.3.sw,
                      padding: EdgeInsets.only(top: 8).w,
                      child: ElevatedButton(
                        key: Key('sendMobileOTP'),
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color>(
                                    (states) {
                              if (states.contains(WidgetState.disabled)) {
                                return AppColors.darkBlue.withValues(
                                    alpha: 0.5); // Custom disabled color
                              }
                              return AppColors.darkBlue; // Enabled color
                            }),
                            padding: WidgetStateProperty.all<EdgeInsets>(
                                const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 8)),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(63)))),
                        onPressed: mobileNoController.text.trim().length == 10
                            ? () async {
                                await _sendOTPToVerifyNumber();
                              }
                            : null,
                        child: Text(
                          AppLocalizations.of(context)!.mStaticSendOtp,
                          style: GoogleFonts.lato(
                              letterSpacing: 0.5,
                              fontSize: 14.sp,
                              color: AppColors.appBarBackground,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                )
              : !isMobileNumberVerified
                  ? Padding(
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
                                      key: Key('PhoneOTPField'),
                                      obscureText: true,
                                      textInputAction: TextInputAction.next,
                                      focusNode: otpFocus,
                                      controller: _mobileNoOTPController,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
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
                                      style:
                                          GoogleFonts.lato(fontSize: 14.0.sp),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.appBarBackground,
                                        contentPadding: EdgeInsets.fromLTRB(
                                                16.0, 0.0, 20.0, 0.0)
                                            .r,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: AppColors.grey16)),
                                        hintText: AppLocalizations.of(context)!
                                            .mStaticEnterOtp,
                                        hintStyle: GoogleFonts.lato(
                                            color: AppColors.grey40,
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w400),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: AppColors.darkBlue,
                                              width: 1.0),
                                        ),
                                      ),
                                    ),
                                  )),
                              Container(
                                width: 0.3.sw,
                                child: ElevatedButton(
                                  key: Key('VerifyMobileOTP'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkBlue,
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                  onPressed: () async {
                                    otpFocus.unfocus();
                                    await _verifyOTP(
                                        _mobileNoOTPController.text);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .mRegisterverifyOTP,
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
                          !showResendOption && !isMobileNumberVerified
                              ? Container(
                                  padding: EdgeInsets.only(top: 16).r,
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '${AppLocalizations.of(context)!.mRegisterresendOTPAfter} $timeFormat',
                                    style: GoogleFonts.lato(
                                        height: 1.429.w,
                                        letterSpacing: 0.5,
                                        fontSize: 14.sp,
                                        color: AppColors.grey40,
                                        fontWeight: FontWeight.w700),
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.topLeft,
                                  // padding: EdgeInsets.only(top: 8),
                                  child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero.r,
                                        minimumSize: Size(50, 50),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        _sendOTPToVerifyNumber();
                                        setState(() {
                                          showResendOption = false;
                                          resendOTPTime = RegistrationType
                                              .resendOtpTimeLimit;
                                        });
                                      },
                                      child: Text(
                                          AppLocalizations.of(context)!
                                              .mRegisterresendOTP,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium!)),
                                ),
                        ],
                      ),
                    )
                  : Center(),
          SizedBox(
            height: 16.w,
          )
        ],
      ),
    );
  }

  _sendOTPToVerifyNumber() async {
    final response = await widget.profileRepository
        .generateMobileNumberOTP(mobileNoController.text);
    if (response == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.mStaticOtpSentToMobile,
              style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
              )),
          backgroundColor: AppColors.positiveLight,
        ),
      );
      setState(() {
        _hasSendOTPRequest = true;
        freezeMobileField = true;
        _mobileNoOTPController.clear();
        showResendOption = false;
        resendOTPTime = RegistrationType.resendOtpTimeLimit;
      });
      FocusScope.of(context).requestFocus(otpFocus);
      startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response,
            style: GoogleFonts.lato(
              color: AppColors.appBarBackground,
            ),
          ),
          backgroundColor: AppColors.primaryTwo,
        ),
      );
    }
  }

  _verifyOTP(otp) async {
    final String response = await widget.profileRepository
        .verifyMobileNumberOTP(mobileNoController.text, otp);

    if (response == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.mStaticMobileVerifiedMessage,
                  style: GoogleFonts.lato(
                    color: AppColors.appBarBackground,
                  )),
          backgroundColor: AppColors.positiveLight,
        ),
      );
      setState(() {
        _hasSendOTPRequest = false;
        isMobileNumberVerified = true;
        _timer?.cancel();
      });
      widget.mobileVerified(true);
      mobileNumberFocus.unfocus();
      if (widget.changeFocus != null) {
        widget.changeFocus!(EnglishLang.whatsappConsent);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response,
            style: GoogleFonts.lato(
              color: AppColors.appBarBackground,
            ),
          ),
          backgroundColor: AppColors.primaryTwo,
        ),
      );
    }
    setState(() {
      freezeMobileField = false;
    });
  }

  void startTimer() {
    resendOTPTime = RegistrationType.resendOtpTimeLimit;
    timeFormat = formatHHMMSS(resendOTPTime);
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (resendOTPTime == 0) {
          setState(() {
            timer.cancel();
            showResendOption = true;
          });
        } else {
          if (mounted) {
            setState(() {
              resendOTPTime--;
            });
          }
        }
        timeFormat = formatHHMMSS(resendOTPTime);
      },
    );
  }

  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return '$minutesStr:$secondsStr';
    }

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  void updateFocus() {
    if (widget.isFocused) {
      FocusScope.of(context).requestFocus(mobileNumberFocus);
    }
  }
}
