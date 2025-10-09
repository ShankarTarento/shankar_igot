import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/_constants/color_constants.dart';

class ScheduledAssesmentSkeleton extends StatefulWidget {
  const ScheduledAssesmentSkeleton({Key? key}) : super(key: key);

  @override
  State<ScheduledAssesmentSkeleton> createState() =>
      _ScheduledAssesmentSkeletonState();
}

class _ScheduledAssesmentSkeletonState extends State<ScheduledAssesmentSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<Color?> animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    animation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey08,
            end: AppColors.grey16,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey08,
            end: AppColors.grey16,
          ),
        ),
      ],
    ).animate(_controller!)
      ..addListener(() {
        setState(() {});
      });
    _controller!.repeat();
  }

  @override
  dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188.w,
      width: 1.sw,
      padding: EdgeInsets.all(16).r,
      decoration: BoxDecoration(
          color: AppColors.appBarBackground,
          border: Border.all(color: AppColors.grey16),
          borderRadius: BorderRadius.circular(8).r),
      child: Column(children: [
        Row(
          children: [
            Container(
              height: 75.w,
              width: 0.31.sw,
              color: animation.value,
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 25,
                  width: 0.4.sw,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: animation.value,
                  ),
                ),
                SizedBox(
                  height: 16.w,
                ),
                Container(
                  height: 25.w,
                  width: 0.3.sw,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: animation.value,
                  ),
                ),
              ],
            )
          ],
        ),
        SizedBox(
          height: 8.w,
        ),
        Container(
          height: 68.w,
          color: animation.value,
        )
      ]),
    );
  }
}
