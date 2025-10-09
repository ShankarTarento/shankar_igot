import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';
import '../../../../../skeleton/index.dart';

class PrimaryDetailsSectionSkeleton extends StatelessWidget {
  final Color? color;

  const PrimaryDetailsSectionSkeleton({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).r,
        color: AppColors.appBarBackground,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ContainerSkeleton(
                width: 0.5.sw,
                height: 25.w,
                radius: 8,
                color: color,
              ),
              SizedBox(height: 8.w),
              ContainerSkeleton(
                height: 25.w,
                width: 80.w,
                color: color,
              )
            ],
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            width: 0.7.sw,
            height: 25.w,
            radius: 8,
            color: color,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            width: 0.7.sw,
            height: 25.w,
            radius: 8,
            color: color,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            width: 0.7.sw,
            height: 25.w,
            radius: 8,
            color: color,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            width: 0.7.sw,
            height: 25.w,
            radius: 8,
            color: color,
          ),
          SizedBox(height: 8.w),
        ]));
  }
}
