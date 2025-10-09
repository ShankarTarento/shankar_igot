import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';

class CourseEnrolPopupWidget extends StatelessWidget {
  final VoidCallback closeButtonPressed;

  const CourseEnrolPopupWidget({super.key, required this.closeButtonPressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 0, 8).w,
      width: 1.sw,
      color: AppColors.grey16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 0.75.sw,
            child: RichText(
              text: TextSpan(
                children: [
                  textWidget(AppLocalizations.of(context)!.mStaticEarn + ' ',
                      FontWeight.w400),
                  textWidget(
                      '$FIRST_ENROLMENT_POINT ' +
                          AppLocalizations.of(context)!.mStaticKarmaPoints +
                          ' ',
                      FontWeight.w900),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: SvgPicture.asset(
                      'assets/img/kp_icon.svg',
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                  textWidget(
                      ' ' +
                          AppLocalizations.of(context)!
                              .mStaticFirstCourseEnrolment,
                      FontWeight.w400)
                ],
              ),
            ),
          ),
          IconButton(
              onPressed: () {
                closeButtonPressed();
              },
              icon: Icon(
                Icons.close,
                size: 24.sp,
                color: AppColors.greys60,
              ))
        ],
      ),
    );
  }

  TextSpan textWidget(String message, FontWeight font) {
    return TextSpan(
      text: message,
      style: TextStyle(
          color: AppColors.greys87,
          fontSize: 12.sp,
          fontWeight: font,
          letterSpacing: 0.25),
    );
  }
}
