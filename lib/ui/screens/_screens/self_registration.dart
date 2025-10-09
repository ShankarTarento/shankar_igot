import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../models/index.dart';
import '../../../respositories/index.dart';
import '../../../util/index.dart';
import '../../widgets/index.dart';
import '../../widgets/self_registration/route_to_general_signup_widget.dart';

class SelfRegistration extends StatefulWidget {
  @override
  State<SelfRegistration> createState() => SelfRegistrationState();
}

class SelfRegistrationState extends State<SelfRegistration> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController linkTextController = TextEditingController();
  bool isRegisterBtnEnabled = false;
  @override
  void initState() {
    super.initState();
    linkTextController.addListener(checkLinkIsPasted);
  }

  @override
  void dispose() {
    linkTextController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (formKey.currentState!.validate()) {
      String linkValidationMessage = await ProfileRepository()
          .getRegisterLinkValidated(linkTextController.text);
      if (linkValidationMessage.toLowerCase() ==
          EnglishLang.linkActiveMessage.toLowerCase()) {
        String? orgId = Helper.extractOrgIdFromString(linkTextController.text);
        if (orgId != null) {
          Navigator.of(context).pushNamed(AppUrl.registrationDetails,
              arguments: RegistrationLinkModel(
                  orgId: orgId, link: linkTextController.text));
        }
      } else {
        Helper.verifyLinkAndShowMessage(linkValidationMessage, context);
      }
    }
  }

  void _scanQR() {
    Navigator.of(context).pushNamed(AppUrl.registrationQRScanner);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0.w),
        child: SelfRegisterAppbar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: 1.0.sw,
            padding: EdgeInsets.only(top: 48, right: 16, left: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RegisterTitleWidget(context),
                SizedBox(height: 24),
                Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            AppLocalizations.of(context)!
                                .mRegisterLinkRegistration,
                            style: GoogleFonts.lato(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.blackLegend)),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          child: TextFormField(
                            onTapOutside: (event) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            controller: linkTextController,
                            autocorrect: false,
                            cursorColor: AppColors.darkBlue,
                            style: GoogleFonts.lato(fontSize: 14.0.sp),
                            decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .mRegisterPasteYourLinkHere,
                                labelStyle: GoogleFonts.lato(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.grey40),
                                errorStyle: GoogleFonts.lato(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.grey40)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.darkBlue, width: 2))),
                            validator: (value) {
                              if (value != null &&
                                  !Helper.isValidRegistrationLink(value)) {
                                return AppLocalizations.of(context)!
                                    .mRegisterIcorrectLinkFormat;
                              }
                              return null;
                            },
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            width: 0.8.sw,
                            child: ElevatedButton(
                                onPressed:
                                    isRegisterBtnEnabled ? _submitForm : null,
                                style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                            (states) {
                                      if (states
                                          .contains(WidgetState.disabled)) {
                                        return AppColors.darkBlue.withValues(
                                            alpha:
                                                0.5); // Custom disabled color
                                      }
                                      return AppColors
                                          .darkBlue; // Enabled color
                                    }),
                                    padding: WidgetStateProperty.all<EdgeInsets>(
                                        const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 16)),
                                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(63)))),
                                child:
                                    Text(AppLocalizations.of(context)!.mCommonRegister,
                                        style: GoogleFonts.lato(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.appBarBackground))),
                          ),
                        )
                      ],
                    )),
                SizedBox(height: 48),
                SeparatorWidget(),
                Center(
                  child: SizedBox(
                    width: 0.8.sw,
                    child: ElevatedButton(
                        onPressed: _scanQR,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(63))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/img/qr_registration.svg',
                              height: 18.w,
                              width: 18.w,
                            ),
                            SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.mRegisterScanQR,
                                style: GoogleFonts.lato(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.appBarBackground)),
                          ],
                        )),
                  ),
                ),
                SizedBox(height: 48),
                SeparatorWidget(),
                RouteToGeneralSignupWidget()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding RegisterTitleWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GradientLine(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text(AppLocalizations.of(context)!.mRegisterWithQRorLink,
                maxLines: 3,
                style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.greys)),
          ),
          GradientLine()
        ],
      ),
    );
  }

  void checkLinkIsPasted() {
    bool status = linkTextController.text.isNotEmpty;
    if (status != isRegisterBtnEnabled) {
      setState(() {
        isRegisterBtnEnabled = status;
      });
    }
  }
}
