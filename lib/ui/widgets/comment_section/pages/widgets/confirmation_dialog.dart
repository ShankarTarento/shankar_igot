import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class ConfirmationDialogWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String primaryButtonText;
  final VoidCallback onPrimaryButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;

  ConfirmationDialogWidget({
    this.title,
    this.subtitle,
    required this.primaryButtonText,
    required this.onPrimaryButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Icon(
            Icons.warning,
            color: AppColors.primaryOne,
            size: 36.w,
          ),
          title != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8).r,
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      color: AppColors.primaryBlue,
                      fontSize: 16.0.sp,
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
              textAlign: TextAlign.center,
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8).w,
            child: Row(
              children: [
                if (secondaryButtonText != null &&
                    onSecondaryButtonPressed != null)
                  GestureDetector(
                      onTap: onSecondaryButtonPressed,
                      child: Container(
                          width: 0.27.sw,
                          alignment: Alignment.center,
                          padding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 4)
                                  .w,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryBlue),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.w)),
                          ),
                          child: Text(
                            secondaryButtonText!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.sp,
                                ),
                          ))),
                Spacer(),
                GestureDetector(
                    onTap: onPrimaryButtonPressed,
                    child: Container(
                        margin: EdgeInsets.only(left: 8),
                        width: 0.27.sw,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 4).w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          border: Border.all(color: AppColors.primaryBlue),
                          borderRadius: BorderRadius.all(Radius.circular(12.w)),
                        ),
                        child: Text(
                          primaryButtonText,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.appBarBackground,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp,
                                  ),
                        ))),
              ],
            ),
          ),
        )
      ],
    );
  }
}
