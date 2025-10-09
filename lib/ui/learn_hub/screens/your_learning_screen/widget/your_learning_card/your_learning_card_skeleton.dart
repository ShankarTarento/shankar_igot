import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class YourLearningCardSkeleton extends StatelessWidget {
  const YourLearningCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.w,
      width: 0.8.sw,
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8).r,
      ),
      child: Row(
        children: [
          ContainerSkeleton(
            height: 100.w,
            width: 120.w,
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ContainerSkeleton(
                width: 0.55.sw,
                height: 22.w,
              ),
              SizedBox(height: 8.h),
              ContainerSkeleton(
                width: 0.5.sw,
                height: 22.w,
              ),
              SizedBox(height: 8.h),
              ContainerSkeleton(
                width: 0.4.sw,
                height: 22.w,
              )
            ],
          )
        ],
      ),
    );
  }
}
