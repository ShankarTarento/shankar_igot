import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/_constants/color_constants.dart';

class SectionHeading extends StatelessWidget {
  final String text;

  SectionHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 20, bottom: 10).r,
      child: Text(
        text,
        style: GoogleFonts.lato(
          color: AppColors.greys87,
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          letterSpacing: 0.12,
        ),
      ),
    );
  }
}
