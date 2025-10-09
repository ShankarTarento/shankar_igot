import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/microsite_expandable_text.dart';
import '../../../../../../constants/_constants/color_constants.dart';

class MicroSiteInfraItemWidget extends StatelessWidget {
  final String title;
  final String value;
  final Color? titleColor;
  final Color? valueColor;
  MicroSiteInfraItemWidget(
      {required this.title,
      required this.value,
      this.titleColor,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 0).w,
          child: Text(
            value,
            style: GoogleFonts.montserrat(
              color: valueColor ?? AppColors.appBarBackground,
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
              height: 1.5.w,
              letterSpacing: 0.25.w,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 0).w,
          child: MicroSiteExpandableText(
            text: title,
            style: GoogleFonts.lato(
              color: titleColor ?? AppColors.appBarBackground.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              height: 1.5.w,
              letterSpacing: 0.25.w,
            ),
            maxLines: 3,
            showMaxLine: false,
            maxCharacter: 30,
            showMaxCharacter: true,
            enableCollapse: true,
          ),
        ),
      ],
    );
  }
}
