import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/_constants/color_constants.dart';

class TitleSemiboldSize16 extends StatelessWidget {
  final String title;
  final int maxLines;
  final double fontSize;

  const TitleSemiboldSize16(this.title,
      {Key? key, this.maxLines = 1, this.fontSize = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.lato(
            color: AppColors.greys87,
            fontWeight: FontWeight.w600,
            fontSize: fontSize.sp,
            letterSpacing: 0.12.r,
            height: 1.5.w));
  }
}
