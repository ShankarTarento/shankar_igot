import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class CustomNetworkCardSkeleton extends StatefulWidget {
  const CustomNetworkCardSkeleton({super.key});

  @override
  State<CustomNetworkCardSkeleton> createState() =>
      _CustomNetworkCardSkeletonState();
}

class _CustomNetworkCardSkeletonState extends State<CustomNetworkCardSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.w,
      width: 1.sw,
      padding: EdgeInsets.all(8).r,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8).r,
      ),
      child: Row(
        children: [
          ContainerSkeleton(
            radius: 40.r,
            height: 70.w,
            width: 70.w,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerSkeleton(
                  height: 20.h,
                  width: 0.45.sw,
                ),
                SizedBox(height: 6.h),
                ContainerSkeleton(
                  height: 20.h,
                  width: 0.5.sw,
                ),
                SizedBox(height: 6.h),
                ContainerSkeleton(
                  height: 20.h,
                  width: 0.4.sw,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          ContainerSkeleton(
            height: 40.h,
            width: 50.w,
          )
        ],
      ),
    );
  }
}
