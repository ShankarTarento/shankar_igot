import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoResultFoundWidget extends StatelessWidget {
  const NoResultFoundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16).r,
            child: SvgPicture.asset(
              'assets/img/empty_search.svg',
              alignment: Alignment.center,
              // color: AppColors.grey16,
              width: 0.2.sw,
              height: 0.2.sh,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.mStaticNoResultsFound,
            style: GoogleFonts.lato(
              color: AppColors.greys60,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 1.5.w,
              letterSpacing: 0.25,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
