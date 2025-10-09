import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/notification_icon.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class HubsCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leadingIcon;
  final Function()? onBackPressed;
  final double titleSpacing;
  final double elevation;
  final Widget? titlePrefixIcon;

  HubsCustomAppBar({
    this.title,
    this.leadingIcon,
    this.onBackPressed,
    this.elevation = 0,
    this.titleSpacing = 0,
    this.titlePrefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation,
      backgroundColor: AppColors.appBarBackground,
      titleSpacing: titleSpacing,
      leading: IconButton(
        icon: leadingIcon ?? Icon(Icons.arrow_back_ios_sharp, size: 24.sp, color: AppColors.greys60),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (titlePrefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 4.0).r,
              child: titlePrefixIcon,
            ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0).r,
              child: Text(
                title ?? '',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 16.sp,
                  color: Colors.black87,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 16.0).r,
            child: NotificationIcon(),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
