import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShowAllCard extends StatelessWidget {
  final double? height;
  const ShowAllCard({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 12, right: 12).r,
      height: height ?? SHOWALL_CARD_HEIGHT,
      width: SHOWALL_CARD_WIDTH,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12).r,
          border: Border.all(color: AppColors.darkBlue)),
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.mStaticShowAll,
          style: GoogleFonts.lato(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.12,
          ),
        ),
      ),
    );
  }
}
