import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../skeleton/index.dart';
import '../widgets/horizontal_separator.dart';
import 'primary_details_section_skeleton.dart';
import 'profile_data_strip_skeleton.dart';

class ProfileTabSkeleton extends StatelessWidget {
  final Color? color;
  final bool isMyProfile;

  const ProfileTabSkeleton({Key? key, this.color, this.isMyProfile = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      if (isMyProfile)
        ProfileDataStripSkeleton(color: color, isMyProfile: isMyProfile),
      SizedBox(height: 8.w),
      ContainerSkeleton(
        height: 0.3.sw,
        radius: 8,
        color: color,
      ),
      HorizontalSeparator(),
      PrimaryDetailsSectionSkeleton(color: color),
      HorizontalSeparator(),
      PrimaryDetailsSectionSkeleton(color: color)
    ]);
  }
}
