import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../skeleton/index.dart';

class ProfileDataStripSkeleton extends StatelessWidget {
  final Color? color;
  final bool isMyProfile;

  const ProfileDataStripSkeleton(
      {Key? key, this.color, this.isMyProfile = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.r,
          childAspectRatio: 1.7,
        ),
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        children: [
          ContainerSkeleton(
            height: 0.3.sw,
            radius: 8,
            color: color,
          ),
          ContainerSkeleton(
            height: 0.3.sw,
            radius: 8,
            color: color,
          ),
          ContainerSkeleton(
            height: 0.3.sw,
            radius: 8,
            color: color,
          )
        ]);
  }
}
