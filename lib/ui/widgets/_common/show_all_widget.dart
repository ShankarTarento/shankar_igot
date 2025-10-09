import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';

class ShowAllWidget extends StatelessWidget {
  const ShowAllWidget({
    super.key,
    this.showAllFontSize = 14,
  });

  final double? showAllFontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.mLearnShowAll,
          style: GoogleFonts.lato(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w400,
            fontSize: showAllFontSize!.sp,
            letterSpacing: 0.12.r,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        Icon(
          Icons.chevron_right,
          color: AppColors.darkBlue,
          size: 20.w,
        )
      ],
    );
  }
}
