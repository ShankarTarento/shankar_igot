import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/_constants/color_constants.dart';

class HubInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  const HubInfoCard(
      {Key? key,
      required this.title,
      required this.description,
      required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 16,
              ).r,
              child: SvgPicture.asset(
                '$icon',
                colorFilter:
                    ColorFilter.mode(AppColors.darkBlue, BlendMode.srcIn),
              ),
            ),
            Text('$title',
                style: GoogleFonts.montserrat(
                    color: AppColors.secondaryBlack,
                    // height: 2,
                    fontSize: 18.0.sp,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8).r,
          child: Text(
            '$description',
            style: GoogleFonts.montserrat(
                color: AppColors.greys60,
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }
}
