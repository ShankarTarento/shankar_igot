import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

import '../../../../../../../../constants/index.dart';

class ViewAllEventCardSkeleton extends StatelessWidget {
  const ViewAllEventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8).r,
      height: 400.w,
      width: 1.sw,
      decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          borderRadius: BorderRadius.circular(12).r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerSkeleton(
            width: double.infinity,
            height: 200.w,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerSkeleton(
                  width: 0.9.sw,
                  height: 38.w,
                ),
                SizedBox(
                  height: 10.w,
                ),
                ContainerSkeleton(
                  width: 0.7.sw,
                  height: 38.w,
                ),
                SizedBox(
                  height: 10.w,
                ),
                ContainerSkeleton(
                  width: 0.4.sw,
                  height: 38.w,
                ),
                SizedBox(
                  height: 10.w,
                ),
                ContainerSkeleton(
                  width: 0.6.sw,
                  height: 38.w,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
