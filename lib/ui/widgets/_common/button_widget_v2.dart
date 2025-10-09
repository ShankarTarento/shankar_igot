import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/index.dart';

class ButtonWidgetV2 extends StatelessWidget {
  final Color textColor;
  final Color bgColor;
  final Color? borderColor;
  final String text;
  final Function()? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final IconData? icon;
  const ButtonWidgetV2(
      {Key? key,
      required this.textColor,
      required this.bgColor,
      this.borderColor,
      required this.text,
      this.onTap,
      this.borderRadius = 50,
      this.padding,
      this.isLoading = false,
      this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
          padding:
              padding != null ? padding : EdgeInsets.fromLTRB(16, 8, 16, 8).r,
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius).r,
              border: borderColor != null
                  ? Border.all(color: borderColor!)
                  : Border.fromBorderSide(BorderSide.none)),
          child: Center(
            child: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(2.0).r,
                    child: SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: AppColors.appBarBackground,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(text,
                          style: GoogleFonts.lato(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp)),
                      Visibility(
                        visible: icon != null,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8).w,
                          child: Icon(
                            icon,
                            color: textColor,
                            size: 20.w,
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ));
  }
}
