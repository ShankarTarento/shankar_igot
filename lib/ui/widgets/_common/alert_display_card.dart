import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';

class AlertDisplayCard extends StatelessWidget {
  final message;
  final bool enableAlertIcon;
  final bool showActionButton;
  final String? buttonTitle;
  final Function? buttonCallback;
  const AlertDisplayCard(
      {Key? key,
      required this.message,
      this.enableAlertIcon = true,
      this.showActionButton = false,
      this.buttonTitle,
      this.buttonCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 16).r,
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.mandatoryRed),
          borderRadius: BorderRadius.circular(8).r,
          color: AppColors.primaryOne.withValues(alpha: 0.16)),
      child: Column(
        children: [
          Row(children: [
            if (enableAlertIcon)
              SizedBox(
                height: 52.w,
                width: 52.w,
                child: Icon(
                  Icons.warning,
                  color: AppColors.mandatoryRed,
                  size: 52.sp,
                ),
              ),
            if (enableAlertIcon)
              SizedBox(
                width: 16.w,
              ),
            Flexible(
              child: Text(
                message,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w400, fontSize: 14.sp),
              ),
            )
          ]),
          if (showActionButton && (buttonTitle != null))
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 8).w,
                  height: 40.w,
                  child: ElevatedButton(
                    onPressed: () {
                      if (buttonCallback != null) {
                        buttonCallback!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.darkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30).r,
                        side: BorderSide(color: AppColors.darkBlue),
                      ),
                    ),
                    child: Text(
                      buttonTitle ?? '',
                      style: GoogleFonts.lato(
                        color: AppColors.appBarBackground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
