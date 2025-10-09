import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class SettingsTileItem extends StatelessWidget {
  final VoidCallback onTap;
  final Widget leadingIcon;
  final String title;
  final bool showArrow;

  const SettingsTileItem({
    Key? key,
    required this.onTap,
    required this.leadingIcon,
    required this.title,
    this.showArrow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12).r,
        ),
        padding: const EdgeInsets.all(15).r,
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8).r,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20).r,
              child: leadingIcon,
            ),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.lato(
                  color: AppColors.greys87,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.5.w,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.primaryBlue,
                size: 16.sp,
              ),
          ],
        ),
      ),
    );
  }
}


