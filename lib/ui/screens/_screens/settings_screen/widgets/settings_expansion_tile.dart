import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class SettingsExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const SettingsExpansionTile({
    Key? key,
    required this.title,
    required this.children,
    this.initiallyExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12).r,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: initiallyExpanded,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16).r,
            childrenPadding: EdgeInsets.zero,
            collapsedBackgroundColor: AppColors.appBarBackground,
            backgroundColor: AppColors.appBarBackground,
            iconColor: AppColors.greys87,
            collapsedIconColor: AppColors.greys87,
            title: Text(
              title,
              style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            children: children,
          ),
        ),
      ),
    );
  }
}

