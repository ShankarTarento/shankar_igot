import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/_constants/color_constants.dart';

class AlertDialogWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String primaryButtonText;
  final VoidCallback onPrimaryButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final String? primaryButtonIcon;

  AlertDialogWidget(
      {this.title,
      this.subtitle,
      required this.primaryButtonText,
      required this.onPrimaryButtonPressed,
      this.secondaryButtonText,
      this.onSecondaryButtonPressed,
      this.primaryButtonIcon});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Image.asset(
            'assets/img/examlist.png',
            fit: BoxFit.fill,
          ),
          title != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    title!,
                    style: GoogleFonts.lato(
                      color: AppColors.darkBlue,
                      fontSize: 20.0.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.25,
                    ),
                  ),
                )
              : Center(),
        ],
      ),
      content: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.lato(
                color: AppColors.greys,
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.25,
              ),
            )
          : null,
      actions: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.whiteGradientOne,
                      borderRadius: BorderRadius.all(Radius.circular(6))),
                  width: secondaryButtonText != null &&
                          onSecondaryButtonPressed != null
                      ? 0.37.sw
                      : 0.75.sw,
                  child: TextButton(
                    onPressed: onPrimaryButtonPressed,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        primaryButtonIcon != null
                            ? Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: SvgPicture.asset(
                                  primaryButtonIcon!,
                                  fit: BoxFit.fill,
                                ),
                              )
                            : Center(),
                        Text(primaryButtonText),
                      ],
                    ),
                  ),
                ),
                if (secondaryButtonText != null &&
                    onSecondaryButtonPressed != null)
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.whiteGradientOne,
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                    margin: EdgeInsets.only(left: 8),
                    width: 0.37.sw,
                    child: TextButton(
                      onPressed: onSecondaryButtonPressed,
                      child: Text(secondaryButtonText!),
                    ),
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
