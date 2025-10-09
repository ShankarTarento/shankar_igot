import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:karmayogi_mobile/respositories/index.dart';

import '../../../../../../../../../util/index.dart';

class VerifyEmailField extends StatefulWidget {
  final TextEditingController emailController;
  final bool isEmailVerified;
  final Function(bool) onChanged;
  final Function(String) email;

  const VerifyEmailField(
      {super.key,
      required this.onChanged,
      required this.email,
      required this.emailController,
      required this.isEmailVerified});

  @override
  _VerifyEmailFieldState createState() => _VerifyEmailFieldState();
}

class _VerifyEmailFieldState extends State<VerifyEmailField> {
  final ProfileRepository profileRepository = ProfileRepository();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailOTPController = TextEditingController();

  bool _freezeEmailField = false;
  bool _hasSendEmailOTPRequest = false;
  bool _isEmailVerified = false;
  bool _showEmailResendOption = false;
  final FocusNode _emailOtpFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  String? _timeFormatEmail;
  int _resendEmailOTPTime = RegistrationType.resendEmailOtpTimeLimit;
  Timer? _timerEmail;
  List<String> approvedDomains = [];

  @override
  void dispose() {
    _emailController.dispose();
    _emailOTPController.dispose();
    _timerEmail?.cancel();
    _emailOtpFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _emailController.text = widget.emailController.text;
    _isEmailVerified = widget.isEmailVerified;
    getApprovedEmailDomains();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildEmailField();
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEmailLabel(),
        SizedBox(
          height: 8,
        ),
        _buildEmailInput(),
        if (_isEmailVerified) _buildChangeEmailAddress(),
        if (!_isEmailVerified &&
            !_hasSendEmailOTPRequest &&
            _emailController.text != widget.emailController.text)
          _buildSendEmailOtp(),
        if (_hasSendEmailOTPRequest) _buildVerifyEmailOtp(),
      ],
    );
  }

  Row _buildEmailLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            text: AppLocalizations.of(context)!.mRegisteremail,
            style: GoogleFonts.lato(
              color: AppColors.greys87,
              fontWeight: FontWeight.w700,
              height: 1.5.w,
              letterSpacing: 0.25,
              fontSize: 14.sp,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                    color: AppColors.mandatoryRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp),
              ),
            ],
          ),
        ),
        if (_freezeEmailField) _buildEditEmailButton(),
      ],
    );
  }

  TextButton _buildEditEmailButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _freezeEmailField = false;
          _onEmailChanged("");
          FocusScope.of(context).requestFocus(FocusNode());
        });
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(50, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4).r,
            child: Icon(
              Icons.edit,
              size: 18.sp,
              color: AppColors.darkBlue,
            ),
          ),
          Text(AppLocalizations.of(context)!.mStaticEdit,
              style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue)),
        ],
      ),
    );
  }

  TextFormField _buildEmailInput() {
    return TextFormField(
      controller: _emailController,
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: _isEmailVerified,
      validator: _validateEmail,
      onChanged: _onEmailChanged,
      style: GoogleFonts.lato(fontSize: 14.0.sp),
      keyboardType: TextInputType.emailAddress,
      focusNode: _emailFocus,
      decoration: _inputDecoration(
          AppLocalizations.of(context)!.mRegisterenterYourEmailAddress),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.mRegisterEmailMandatory;
    }
    if (!RegExpressions.validEmail.hasMatch(value)) {
      return AppLocalizations.of(context)!.mRegistervalidEmail;
    }
    if (!checkIsEmailApproved(value)) {
      return AppLocalizations.of(context)!.mProfileNotApprovedDomain;
    }
    return null;
  }

  void _onEmailChanged(String value) {
    setState(() {
      _hasSendEmailOTPRequest = false;
      _isEmailVerified = false;
      widget.onChanged(widget.emailController.text != _emailController.text);
    });
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      filled: true,
      fillColor:
          _freezeEmailField ? AppColors.grey04 : AppColors.appBarBackground,
      errorMaxLines: 3,
      contentPadding: EdgeInsets.fromLTRB(16.0, 14.0, 0.0, 14.0).r,
      border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey08, width: 1.0)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey16, width: 1.0)),
      hintText: hintText,
      hintStyle: GoogleFonts.lato(
          color: AppColors.grey40,
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w400),
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.0)),
      suffixIcon: _isEmailVerified || _emailFocus.hasFocus
          ? _emailFocus.hasFocus
              ? InkWell(
                  onTap: () {
                    _emailFocus.unfocus();
                    _freezeEmailField = false;
                    _emailController.text = widget.emailController.text;
                    _hasSendEmailOTPRequest = false;
                    _isEmailVerified = widget.isEmailVerified;
                    setState(() {});
                  },
                  child: Icon(
                    Icons.close,
                    color: AppColors.greys60,
                  ),
                )
              : Icon(Icons.check_circle, color: AppColors.positiveLight)
          : null,
    );
  }

  Padding _buildChangeEmailAddress() {
    return Padding(
      padding: const EdgeInsets.only(top: 8).r,
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () {
            setState(() {
              _isEmailVerified = false;
              FocusScope.of(context).requestFocus(_emailFocus);
            });
          },
          child: Text(
            AppLocalizations.of(context)!.mStaticChangeEmailAddress,
            style: GoogleFonts.lato(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: AppColors.darkBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildSendEmailOtp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.mStaticOtpSentToEmailDesc,
            style: GoogleFonts.lato(fontWeight: FontWeight.w500, height: 1.5.w),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: _canSendOtp() ? _sendOTPToVerifyEmail : null,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue),
          child: Text(
            AppLocalizations.of(context)!.mRegistersendOTP,
            style: GoogleFonts.lato(
                height: 1.429.w,
                letterSpacing: 0.5,
                fontSize: 14.sp,
                color: AppColors.appBarBackground,
                fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  bool _canSendOtp() {
    return RegExpressions.validEmail.hasMatch(_emailController.text.trim()) &&
        checkIsEmailApproved(_emailController.text.trim());
  }

  Future<void> _sendOTPToVerifyEmail() async {
    final String response =
        await profileRepository.generatePrimaryEmailOTP(_emailController.text);
    if (response.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.mStaticOtpSentToEmail,
          AppColors.positiveLight);
      setState(() {
        _hasSendEmailOTPRequest = true;
        _freezeEmailField = true;
        _emailOTPController.clear();
        _resendEmailOTPTime = RegistrationType.resendEmailOtpTimeLimit;
      });
      _startEmailOtpTimer();
    } else {
      _showSnackBar(response, AppColors.primaryTwo);
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
                width: 0.4.sw,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () async {
                    await _verifyEmailOTP(_emailOTPController.text);
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
                    style: GoogleFonts.lato(),
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
                        _sendOTPToVerifyEmail();
                        setState(() {
                          _showEmailResendOption = false;
                          _resendEmailOTPTime =
                              RegistrationType.resendEmailOtpTimeLimit;
                        });
                      },
                      child: Text(
                          AppLocalizations.of(context)!.mRegisterresendOTP)),
                ),
        ],
      ),
    );
  }

  Future<void> _verifyEmailOTP(String otp) async {
    final String response = await profileRepository.verifyPrimaryEmailOTP(
        _emailController.text, otp);
    if (response.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.mStaticEmailVerifiedMessage,
          AppColors.positiveLight);
      setState(() {
        _hasSendEmailOTPRequest = false;
        _isEmailVerified = true;
        widget.email(_emailController.text);
        widget.onChanged(true);
      });
    } else {
      _showSnackBar(response, AppColors.primaryTwo);
    }
    setState(() {
      _freezeEmailField = false;
    });
  }

  void _startEmailOtpTimer() {
    _timeFormatEmail = formatHHMMSS(_resendEmailOTPTime);
    const oneSec = Duration(seconds: 1);
    _timerEmail = Timer.periodic(oneSec, (timer) {
      if (_resendEmailOTPTime == 0) {
        setState(() {
          timer.cancel();
          _showEmailResendOption = true;
        });
      } else {
        setState(() {
          _resendEmailOTPTime--;
          _timeFormatEmail = formatHHMMSS(_resendEmailOTPTime);
        });
      }
    });
  }

  String formatHHMMSS(int seconds) {
    final hours = (seconds / 3600).truncate();
    seconds %= 3600;
    final minutes = (seconds / 60).truncate();
    final secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:$secondsStr'
        : '${minutes.toString().padLeft(2, '0')}:$secondsStr';
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
}
