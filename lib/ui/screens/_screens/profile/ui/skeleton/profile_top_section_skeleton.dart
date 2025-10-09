import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';
import '../../../../../skeleton/index.dart';
import 'edit_profile_icon_skeleton.dart';

class ProfileTopSectionSkeleton extends StatelessWidget {
  final Color color;

  const ProfileTopSectionSkeleton({Key? key, this.color = AppColors.grey04})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appBarBackground,
      padding: EdgeInsets.only(top: 16, left: 16, right: 16).r,
      child: Column(
        children: [
          Row(
            children: [
              EditProfileIconSkeleton(color: color),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerSkeleton(
                    width: 0.65.sw,
                    radius: 0,
                    color: color,
                  ),
                  SizedBox(height: 4.w),
                  ContainerSkeleton(
                    width: 0.65.sw,
                    radius: 0,
                    color: color,
                  ),
                  SizedBox(height: 4.w),
                  ContainerSkeleton(
                    width: 0.65.sw,
                    radius: 0,
                    color: color,
                  ),
                  // Mentor tag should be dispalyed if the user has the mentor role
                  ContainerSkeleton(
                    width: 0.65.sw,
                    radius: 0,
                    color: color,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
