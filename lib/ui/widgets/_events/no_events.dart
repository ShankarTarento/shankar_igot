import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoEventsWidget extends StatelessWidget {
  const NoEventsWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity.w,
      color: AppColors.appBarBackground,
      padding: const EdgeInsets.all(16).r,
      child: Text(
        AppLocalizations.of(context)!.mEventsNoEvent,
        style: GoogleFonts.lato(color: AppColors.greys87, fontSize: 14.sp),
      ),
    );
  }
}
