import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';

class RouteToGeneralSignupWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
return RichText(
                    textAlign: TextAlign.center,
                    key: Key('RouteToGeneralSignUp'),
                    text: TextSpan(
                        text:
                            '${AppLocalizations.of(context)!.mSelfRegisterKnowOrganisationMessage} ',
                        style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontWeight: FontWeight.w400,
                            fontSize: 18.sp,
                            letterSpacing: 0.25),
                        children: [
                          WidgetSpan(
                              child: InkWell(
                            onTap: () =>
                                Navigator.of(context).pushNamed(AppUrl.signUp),
                            child: Text(
                              AppLocalizations.of(context)!
                                  .mStaticClickHere
                                  .toLowerCase(),
                              style: GoogleFonts.lato(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.sp,
                                  letterSpacing: 0.25,
                                  height: 1.0),
                            ),
                          )),
                          TextSpan(
                            text:
                                ' ${AppLocalizations.of(context)!.mSelfRegisterToRegister}',
                          )
                        ]));
  }

}