import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/notification_icon.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/profile_picture.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/language_dropdown.dart';

class MyLearningAppBarContent extends StatelessWidget {
  final profileParentAction;
  final GlobalKey<ScaffoldState>? drawerKey;
  const MyLearningAppBarContent(
      {super.key, this.drawerKey, this.profileParentAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6).w,
      padding: const EdgeInsets.only(top: 8, bottom: 8).w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(children: [
            ProfilePicture(
              profileParentAction: profileParentAction,
              drawerKey: drawerKey,
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 120.w,
              child: Text(
                AppLocalizations.of(context)!.mTabMyLearnings,
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    letterSpacing: 0.12,
                    color: AppColors.greys87),
                overflow: TextOverflow.ellipsis,
              ),
            )
          ]),
          Spacer(),
          LanguageDropdown(
            isHomePage: true,
          ),
          SizedBox(width: 12.w),
          NotificationIcon(),
        ],
      ),
    );
  }
}
