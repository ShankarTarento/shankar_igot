import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../constants/index.dart';
import '../../../../index.dart';

class TocPlayerPdfScreen extends StatelessWidget {
  final Widget player;
  final String resourcename;
  TocPlayerPdfScreen(
      {Key? key, required this.player, required this.resourcename})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.mOpenresource('PDF'),
          style: GoogleFonts.lato(
              color: AppColors.appBarBackground,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              letterSpacing: 0.25),
        ),
        SizedBox(
          height: 16.w,
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PDFStructureWidget(
                      resourcename: resourcename, player: player)),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6).r,
            decoration: BoxDecoration(
                color: AppColors.orangeTourText,
                borderRadius: BorderRadius.circular(63).r),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/img/icons-file-types-pdf-alternate.svg',
                  colorFilter:
                      ColorFilter.mode(AppColors.greys87, BlendMode.srcIn),
                  height: 24.w,
                  width: 24.w,
                ),
                SizedBox(width: 6.w),
                Text(
                  AppLocalizations.of(context)!.mStaticOpen,
                  style: GoogleFonts.lato(
                      color: AppColors.deepBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      letterSpacing: 0.25),
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }
}