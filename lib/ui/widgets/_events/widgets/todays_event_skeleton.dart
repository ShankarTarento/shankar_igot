import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

import '../../../../constants/index.dart';

class TodaysEventSkeleton extends StatefulWidget {
  const TodaysEventSkeleton({super.key});

  @override
  State<TodaysEventSkeleton> createState() => _TodaysEventSkeletonState();
}

class _TodaysEventSkeletonState extends State<TodaysEventSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16).r,
      margin: EdgeInsets.only(left: 16),
      height: 150.w,
      width: 0.9.sw,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.appBarBackground),
      child: Row(
        children: [
          ContainerSkeleton(
            height: 80.w,
            width: 0.3.sw,
          ),
          SizedBox(
            width: 16.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerSkeleton(
                height: 20.w,
                width: 0.25.sw,
              ),
              SizedBox(
                height: 10.w,
              ),
              ContainerSkeleton(
                height: 20.w,
                width: 0.23.sw,
              ),
              SizedBox(
                height: 12.w,
              ),
              ContainerSkeleton(
                height: 20.w,
                width: 0.2.sw,
              ),
            ],
          )
        ],
      ),
    );
  }
}
