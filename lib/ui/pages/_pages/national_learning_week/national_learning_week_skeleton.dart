import 'package:flutter/material.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class NationalLearningWeekSkeleton extends StatefulWidget {
  const NationalLearningWeekSkeleton({super.key});

  @override
  State<NationalLearningWeekSkeleton> createState() =>
      _NationalLearningWeekSkeletonState();
}

class _NationalLearningWeekSkeletonState
    extends State<NationalLearningWeekSkeleton> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerSkeleton(
              height: 400.w,
              width: 1.sw,
            ),
            SizedBox(
              height: 16.w,
            ),
            ContainerSkeleton(
              height: 100.w,
              width: 1.sw,
            ),
            SizedBox(
              height: 16.w,
            ),
            Center(
              child: CircleAvatar(
                radius: 70.r,
                backgroundColor: AppColors.grey04,
              ),
            ),
            SizedBox(
              height: 16.w,
            ),
            ContainerSkeleton(
              height: 40.w,
              width: 0.5.sw,
            ),
            SizedBox(
              height: 16.w,
            ),
            ContainerSkeleton(
              height: 200.w,
              width: 1.sw,
            ),
          ],
        ),
      ),
    );
  }
}
