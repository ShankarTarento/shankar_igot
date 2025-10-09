import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants/index.dart';

class QrErrorDialog extends StatelessWidget {
  final BuildContext contxt;
  final BuildContext alertDialogContext;
  final VoidCallback resetError;
  final String message;

  const QrErrorDialog(
      {super.key,
      required this.contxt,
      required this.resetError,
      required this.alertDialogContext, required this.message});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          decoration: BoxDecoration(
            color: AppColors.appBarBackground,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/img/icon_error.svg',
                height: 24.w,
                width: 24.w,
                fit: BoxFit.fill,
              ),
              SizedBox(
                height: 16.w,
              ),
              Text(
                AppLocalizations.of(contxt)!.mStaticInvalidQR,
                style: Theme.of(contxt).textTheme.titleLarge!.copyWith(
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
              ),
              SizedBox(
                height: 16.w,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(contxt).textTheme.headlineSmall!.copyWith(
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    ),
              ),
              SizedBox(
                height: 24.sp,
              ),
              InkWell(
                key: Key('reset scanner'),
                onTap: () {
                  Navigator.of(alertDialogContext).pop();
                  resetError();
                },
                child: Text(
                  AppLocalizations.of(contxt)!.mStaticScanAgain,
                  style: Theme.of(contxt).textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              SizedBox(
                height: 10.w,
              ),
            ],
          )),
    );
  }
}
