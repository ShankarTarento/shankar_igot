import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class NetworkCardSkeleton extends StatefulWidget {
  const NetworkCardSkeleton({super.key});

  @override
  State<NetworkCardSkeleton> createState() => _NetworkCardSkeletonState();
}

class _NetworkCardSkeletonState extends State<NetworkCardSkeleton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190.w,
      width: 175.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 36.w,
            child: Container(
              height: 155.w,
              width: 175.w,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.w),
                border: Border.all(
                  color: AppColors.grey16,
                  width: 1.w,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 35.w),
                  ContainerSkeleton(
                    height: 24.h,
                    width: 0.38.sw,
                  ),
                  SizedBox(height: 4.w),
                  ContainerSkeleton(
                    height: 24.h,
                    width: 0.32.sw,
                  ),
                  SizedBox(height: 6.w),
                  ContainerSkeleton(
                    height: 24.h,
                    width: 0.20.sw,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: ContainerSkeleton(
                height: 76.h,
                width: 76.h,
                radius: 40.r,
                // decoration: BoxDecoration(
                //   color: AppColors.grey24,
                //   shape: BoxShape.circle,
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
