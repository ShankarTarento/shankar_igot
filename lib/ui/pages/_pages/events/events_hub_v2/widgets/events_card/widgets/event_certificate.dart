import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class EventCertificate extends StatelessWidget {
  final double fontSize;

  const EventCertificate({super.key, this.fontSize = 12.0});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          height: 24.w,
          width: 24.w,
          'assets/img/certificate_icon.svg',
          colorFilter: ColorFilter.mode(
            AppColors.greys60,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(
          width: 4.w,
        ),
        Text(
          "Certification",
          style: GoogleFonts.lato(
            color: AppColors.greys60,
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }
}
