import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';
import '../../../feedback/constants.dart';
import '../../../localization/index.dart';
import '../../../respositories/index.dart';
import '../../pages/_pages/sign_up/field_request_page.dart';

class EmailWidget extends StatefulWidget {
  final bool isFocused;
  final ValueChanged<String?>? onSaved;
  final ValueChanged<String>? changeFocus;
  final GlobalKey<FormState> formKey;
  final ValueChanged<bool> emailVerified;
  final String? name;
  final String? mobileNumber;
  final bool isMobileNumberVerified;
  final getMobileNumber;
  final ProfileRepository profileRepository;

  EmailWidget(
      {super.key,
      this.isFocused = false,
      this.onSaved,
      required this.formKey,
      required this.emailVerified,
      this.changeFocus,
      this.name,
      this.mobileNumber,
      this.isMobileNumberVerified = false,
      this.getMobileNumber,
      ProfileRepository? profileRepository})
      : profileRepository = profileRepository ?? ProfileRepository();
  @override
  State<EmailWidget> createState() => EmailWidgetState();
}

class EmailWidgetState extends State<EmailWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailOTPController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _otpFocus = FocusNode();
  final FocusNode _emailOtpFocus = FocusNode();
  bool _isEmailVerified = false;
  bool _freezeEmailField = false;
  bool _hasSendEmailOTPRequest = false;
  RegExp regExpEmail = RegExpressions.validEmail;
  Timer? _timerEmail;
  String? _timeFormatEmail;
  int _resendEmailOTPTime = RegistrationType.resendEmailOtpTimeLimit;
  bool _showEmailResendOption = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateFocus();
  }

  @override
  void didUpdateWidget(EmailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateFocus();
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _timerEmail?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(8),
      color: AppColors.grey24,
      dashPattern: [10, 8],
      strokeWidth: 1,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                    text: AppLocalizations.of(context)!.mRegisteremail,
                    style: GoogleFonts.lato(
                        color: AppColors.blackLegend,
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
              _freezeEmailField
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          _freezeEmailField = false;
                          _hasSendEmailOTPRequest = false;
                          _emailOtpFocus.unfocus();
                          FocusScope.of(_emailOtpFocus.context!)
                              .requestFocus(_emailFocus);
                        });
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
                            child: Icon(
                              Icons.edit,
                              color: AppColors.darkBlue,
                              size: 18.sp,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.mStaticEdit,
                            style: GoogleFonts.lato(
                                color: AppColors.darkBlue,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          )
                        ],
                      ))
                  : Center(),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 8).r,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4).r,
            ),
            child: Focus(
              child: TextFormField(
                key: Key('Email'),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                focusNode: _emailFocus,
                validator: (String? value) {
                  if (value != null) {
                    if (value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .mRegisterEmailMandatory;
                    }
                    String? matchedString = regExpEmail.stringMatch(value);
                    if (matchedString == null ||
                        matchedString.isEmpty ||
                        matchedString.length != value.length) {
                      return AppLocalizations.of(context)!.mRegistervalidEmail;
                    }
                    return null;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  if (widget.onSaved != null) {
                    widget.onSaved!(value);
                  }
                  setState(() {
                    _hasSendEmailOTPRequest = false;
                    _isEmailVerified = false;
                  });
                },
                onFieldSubmitted: (value) {
                  if (value.isEmpty &&
                      !widget.formKey.currentState!.validate()) {
                    return;
                  }
                  if (widget.changeFocus != null) {
                    widget.changeFocus!(EnglishLang.mobileNumber);
                  }
                },
                readOnly: (_freezeEmailField || _isEmailVerified),
                controller: _emailController,
                style: GoogleFonts.lato(fontSize: 14.0.sp),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  errorMaxLines: 3,
                  filled: true,
                  fillColor: _freezeEmailField
                      ? AppColors.grey04
                      : AppColors.appBarBackground,
                  suffixIcon: _isEmailVerified
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.positiveLight,
                        )
                      : null,
                  contentPadding: EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0).r,
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColors.grey16, width: 1.0)),
                  hintText: AppLocalizations.of(context)!
                      .mRegisterenterYourEmailAddress,
                  hintStyle: GoogleFonts.lato(
                      color: AppColors.grey40,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w400),
                  errorStyle: GoogleFonts.lato(
                      fontSize: 14.0.sp, fontWeight: FontWeight.w400),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: AppColors.darkBlue, width: 1.0),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
              visible: _isEmailVerified, child: _buildChangeEmailAddress()),
          Visibility(
              visible: !_isEmailVerified && !_hasSendEmailOTPRequest,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                    child: RichText(
                        text: TextSpan(
                            text: AppLocalizations.of(context)!
                                .mStaticNoGovtEmail,
                            style: GoogleFonts.lato(
                                color: AppColors.greys,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400),
                            children: [
                          TextSpan(
                              text: ' ' +
                                  AppLocalizations.of(context)!
                                      .mStaticRequestForHelp,
                              style: GoogleFonts.lato(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkBlue))
                        ])),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FieldRequestPage(
                                fullName: widget.name,
                                mobile: widget.mobileNumber,
                                email: _emailController.text,
                                phoneVerified: widget.isMobileNumberVerified,
                                isEmailVerified: _isEmailVerified,
                                parentAction: widget.getMobileNumber,
                                fieldName:
                                    AppLocalizations.of(context)!.mStaticDomain,
                              )));
                    }),
              )),
          Visibility(
              visible: !_isEmailVerified && !_hasSendEmailOTPRequest,
              child: _buildSendEmailOtp()),
          Visibility(
              visible: _hasSendEmailOTPRequest, child: _buildVerifyEmailOtp()),
        ],
      ),
    );
  }

  Widget _buildSendEmailOtp() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 0.3.sw,
        padding: EdgeInsets.only(top: 8).r,
        child: ElevatedButton(
          key: Key('Email_OTP'),
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppColors.darkBlue
                      .withValues(alpha: 0.5); // Custom disabled color
                }
                return AppColors.darkBlue; // Enabled color
              }),
              padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8)),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(63)))),
          onPressed: regExpEmail.hasMatch(_emailController.text.trim())
              ? () async {
                  await _sendOTPToVerifyEmail();
                  setState(() {
                    _showEmailResendOption = false;
                    _resendEmailOTPTime =
                        RegistrationType.resendEmailOtpTimeLimit;
                  });
                }
              : null,
          child: Text(
            AppLocalizations.of(context)!.mRegistersendOTP,
            style: GoogleFonts.lato(
                letterSpacing: 0.5,
                fontSize: 14.sp,
                color: AppColors.appBarBackground,
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyEmailOtp() {
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
                      key: Key('VerifyEmailOTP'),
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      focusNode: _emailOtpFocus,
                      controller: _emailOTPController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (String? value) {
                        if (value != null && value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .mRegisterenterOTP;
                        } else
                          return null;
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
                        hintText:
                            AppLocalizations.of(context)!.mRegisterenterOTP,
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
                width: 0.3.sw,
                child: ElevatedButton(
                  key: Key('VerifyOtpButton'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () async {
                    _emailOtpFocus.unfocus();
                    await verifyEmailOTP(_emailOTPController.text);
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
          !_showEmailResendOption && !_isEmailVerified
              ? Container(
                  padding: EdgeInsets.only(top: 16),
                  alignment: Alignment.topLeft,
                  child: Text(
                      '${AppLocalizations.of(context)!.mRegisterresendOTPAfter} $_timeFormatEmail',
                      style: GoogleFonts.lato(
                          height: 1.429.w,
                          letterSpacing: 0.5,
                          fontSize: 14.sp,
                          color: AppColors.grey40,
                          fontWeight: FontWeight.w700)),
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
                        _sendOTPToVerifyEmail();
                        setState(() {
                          _showEmailResendOption = false;
                          _resendEmailOTPTime =
                              RegistrationType.resendEmailOtpTimeLimit;
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

  Padding _buildChangeEmailAddress() {
    return Padding(
      padding: const EdgeInsets.only(top: 8).r,
      child: Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              setState(() {
                _isEmailVerified = false;
                widget.emailVerified(false);
              });
              FocusScope.of(context).requestFocus(_emailFocus);
            },
            child: Text(
              AppLocalizations.of(context)!.mStaticChangeEmailAddress,
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: AppColors.darkBlue),
            ),
          )),
    );
  }

  _sendOTPToVerifyEmail() async {
    final String? response =
        await widget.profileRepository.generateEmailOTP(_emailController.text);
    if (response == null || response == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.mStaticOtpSentToEmail,
              style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
              )),
          backgroundColor: AppColors.positiveLight,
        ),
      );
      setState(() {
        _hasSendEmailOTPRequest = true;
        _freezeEmailField = true;
        _emailOTPController.clear();
        _showEmailResendOption = false;
        _resendEmailOTPTime = RegistrationType.resendEmailOtpTimeLimit;
      });
      FocusScope.of(context).requestFocus(_otpFocus);
      _startEmailOtpTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response,
              style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
              )),
          backgroundColor: AppColors.primaryTwo,
        ),
      );
    }
  }

  verifyEmailOTP(otp) async {
    final String? response = await widget.profileRepository
        .verifyEmailOTP(_emailController.text, otp);

    if (response == null || response == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.mStaticEmailVerifiedMessage,
                  style: GoogleFonts.lato(
                    color: AppColors.appBarBackground,
                  )),
          backgroundColor: AppColors.positiveLight,
        ),
      );
      setState(() {
        _hasSendEmailOTPRequest = false;
        _isEmailVerified = true;
        _timerEmail!.cancel();
      });
      widget.emailVerified(true);
      if (widget.changeFocus != null) {
        _otpFocus.unfocus();
        widget.changeFocus!(EnglishLang.mobileNumber);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response,
              style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
              )),
          backgroundColor: AppColors.primaryTwo,
        ),
      );
    }
    setState(() {
      _freezeEmailField = false;
    });
  }

  void _startEmailOtpTimer() {
    _timeFormatEmail = formatHHMMSS(_resendEmailOTPTime);
    const oneSec = const Duration(seconds: 1);
    _timerEmail = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_resendEmailOTPTime == 0) {
          setState(() {
            timer.cancel();
            _showEmailResendOption = true;
          });
        } else {
          if (mounted) {
            setState(() {
              _resendEmailOTPTime--;
            });
          }
        }
        _timeFormatEmail = formatHHMMSS(_resendEmailOTPTime);
      },
    );
  }

  void updateFocus() {
    if (widget.isFocused) {
      FocusScope.of(context).requestFocus(_emailFocus);
    }
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
}
