import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';

class ProfileFormFieldValue extends StatelessWidget {
  final String? text;
  final bool isVerified;
  final bool isApprovalField;
  final dynamic approvedValue;
  final bool isGroup;
  final bool showDefaultText;
  const ProfileFormFieldValue(
      {Key? key,
      this.text,
      this.isVerified = false,
      this.isApprovalField = false,
      this.approvedValue,
      this.isGroup = false,
      this.showDefaultText = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                  text != null && text.toString().isNotEmpty
                      ? text.toString()
                      : EnglishLang.noValue,
                  style: showDefaultText
                      ? TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.greys87,
                          fontWeight: FontWeight.w400)
                      : Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: AppColors.blackLegend)),
            ),
            Visibility(
              visible: isVerified && text != null && text.toString().isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 8).r,
                child: SvgPicture.asset(
                  'assets/img/approved.svg',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            )
          ],
        ),
        Visibility(
          // visible: isApprovalField && !isVerified,
          visible: isApprovalField && !isVerified ||
              (isApprovalField && text == null && (text.toString().isNotEmpty)),
          child: Container(
              padding: EdgeInsets.fromLTRB(12, 4, 12, 4).r,
              margin: EdgeInsets.only(top: 8).r,
              decoration: BoxDecoration(
                  color: AppColors.mandatoryRed,
                  borderRadius: BorderRadius.all(Radius.circular(50).r)),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.mProfileNotVerified,

                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                              fontWeight: FontWeight.w600,
                            )
                            .copyWith(color: AppColors.appBarBackground),
                      ),
                      SizedBox(width: 4.w),
                      CircleAvatar(
                        backgroundColor: AppColors.appBarBackground,
                        maxRadius: 6.r,
                        child: Center(
                            child: Text(
                          '!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize: 8.sp,
                              color: AppColors.greys),
                        )),
                      )
                    ],
                  )
                ],
              )),
        ),
      ],
    );
  }
}
