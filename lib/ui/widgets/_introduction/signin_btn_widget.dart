import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants/index.dart';

class SigninBtnWidget extends StatelessWidget {
  const SigninBtnWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(AppUrl.loginPage),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                shape: StadiumBorder(),
                minimumSize: Size(.7.sw, 50.w)),
            child: Text(
              AppLocalizations.of(context)!.mBtnSignIn,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                color: AppColors.appBarBackground,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                height: 1.375,
                letterSpacing: 0.125,
              ),
            )),
        Padding(
          padding: EdgeInsets.only(top: 10.h, bottom: 150.h),
          child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppUrl.selfRegister),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.appBarBackground,
                minimumSize: Size(.7.sw, 50.w),
                side: BorderSide(color: AppColors.darkBlue, width: 1.w),
                shape: StadiumBorder(),
              ),
              child: Text(
                AppLocalizations.of(context)!.mCommonRegister,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  color: AppColors.darkBlue,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.375,
                  letterSpacing: 0.125,
                ),
              )),
        ),
      ],
    );
  }
}