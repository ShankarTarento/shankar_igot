import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../index.dart';

class TabSkeleton extends StatelessWidget {
  final double? iconHeight;
  final double? iconWidth;
  final double? radius;
  final Color? color;

  const TabSkeleton(
      {Key? key, this.iconHeight, this.iconWidth, this.radius, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContainerSkeleton(
          height: iconHeight,
          width: iconWidth,
          radius: radius,
          color: color,
        ),
        SizedBox(height: 8.w),
        ContainerSkeleton(
          height: 25.w,
          width: 80.w,
          color: color,
        )
      ],
    );
  }
}
