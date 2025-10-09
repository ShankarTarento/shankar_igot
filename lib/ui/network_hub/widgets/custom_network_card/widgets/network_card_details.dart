import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/user_connection_request.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class CustomNetworkCardDetails extends StatelessWidget {
  final NetworkUser user;

  const CustomNetworkCardDetails({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          buildProfileAvatar(user),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Helper.capitalizeEachWordFirstCharacter(user.fullName),
                  style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.w),
                user.professionalDetails.isNotEmpty
                    ? Text(
                        user.professionalDetails[0].designation,
                        style: GoogleFonts.lato(
                            fontSize: 14.sp,
                            color: AppColors.greys60,
                            fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )
                    : SizedBox(),
                SizedBox(height: 4.w),
                Text(
                  user.departmentName,
                  style: GoogleFonts.lato(
                      fontSize: 12.sp,
                      color: AppColors.greys60,
                      fontWeight: FontWeight.w400),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileAvatar(NetworkUser user) {
    bool hasImage =
        user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;

    return hasImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(26.r),
            child: ImageWidget(
              imageUrl: user.profileImageUrl!,
              height: 48.h,
              width: 48.w,
              radius: 24.r,
            ),
          )
        : Container(
            height: 48.w,
            width: 48.w,
            decoration: BoxDecoration(
              color: AppColors
                  .networkBg[Random().nextInt(AppColors.networkBg.length)],
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              Helper.getInitialsNew(user.fullName),
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
  }
}
