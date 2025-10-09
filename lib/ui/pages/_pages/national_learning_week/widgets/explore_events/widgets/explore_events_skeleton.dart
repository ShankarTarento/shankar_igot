import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class ExploreEventsSkeleton extends StatefulWidget {
  const ExploreEventsSkeleton({super.key});

  @override
  State<ExploreEventsSkeleton> createState() => _ExploreEventsSkeletonState();
}

class _ExploreEventsSkeletonState extends State<ExploreEventsSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: 170.w,
      width: 1.sw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.grey16,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerSkeleton(
            height: 80.w,
            width: 90.w,
          ),
          SizedBox(
            width: 16,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerSkeleton(
                height: 30.w,
                width: 250.w,
              ),
              SizedBox(
                height: 16.w,
              ),
              ContainerSkeleton(
                height: 30.w,
                width: 150.w,
              ),
              SizedBox(
                height: 16.w,
              ),
              ContainerSkeleton(
                height: 30.w,
                width: 100.w,
              ),
            ],
          )
        ],
      ),
    );
  }
}
