import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common_components/notification_engine/notification_icon.dart';
import '../../../constants/_constants/color_constants.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final Widget? leading;
  const CustomSliverAppBar({super.key, required this.title, this.leading});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      shadowColor: Colors.transparent,
      toolbarHeight: 60.w,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Icon(Icons.arrow_back_ios_sharp,
            size: 24.sp, color: AppColors.greys60),
      ),
      pinned: true,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leading ?? const SizedBox.shrink(),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 16.sp,
                  fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 16.0).r,
            child: NotificationIcon(),
          )
        ],
      ),
    );
  }
}
