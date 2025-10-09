import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import '../../constants/index.dart';

class TooltipWidget extends StatelessWidget {
  final String message;
  final double iconSize;
  final Color iconColor, textColor;
  final double width;
  final TooltipTriggerMode triggerMode;
  final bool isBgColorRequired;
  final IconData icon;

  TooltipWidget(
      {Key? key,
      required this.message,
      this.iconSize = 16,
      this.iconColor = AppColors.greys60,
      this.textColor = AppColors.avatarText,
      this.width = 300,
      this.triggerMode = TooltipTriggerMode.tap,
      this.isBgColorRequired = true,
      this.icon = Icons.info_outline_rounded})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      showDuration: Duration(seconds: 3),
      tailBaseWidth: 16.w,
      triggerMode: triggerMode,
      backgroundColor: isBgColorRequired ? AppColors.greys60 : null,
      child: Icon(
        icon,
        color: iconColor,
        size: iconSize.sp,
      ),
      content: Container(
        width: width.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)).r,
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0).r,
          child: HtmlWidget(
            message,
            textStyle: RegExpressions.htmlValidator.hasMatch(message)
                ? null
                : GoogleFonts.lato(
                    color: textColor,
                    height: 1.33.w,
                    letterSpacing: 0.25.w,
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}
