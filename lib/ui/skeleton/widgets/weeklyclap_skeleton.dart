import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../index.dart';

class WeeklyclapSkeleton extends StatefulWidget {
  const WeeklyclapSkeleton({Key? key}) : super(key: key);

  @override
  _WeeklyclapSkeletonState createState() => _WeeklyclapSkeletonState();
}

class _WeeklyclapSkeletonState extends State<WeeklyclapSkeleton>
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
        TweenSequenceItem<Color?>(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey04,
            end: AppColors.grey08,
          ),
        ),
        TweenSequenceItem<Color?>(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey04,
            end: AppColors.grey08,
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0).r,
        child: Container(
          padding: EdgeInsets.all(16).r,
          width: 1.sw,
          color: AppColors.appBarBackground,
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ContainerSkeleton(
                  height: 25.w, width: 150.w, color: animation.value!),
              ContainerSkeleton(
                  height: 25.w, width: 100.w, color: animation.value!)
            ]),
            SizedBox(height: 8.w),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 24.sp,
                  color: animation.value,
                ),
                SizedBox(width: 16.w),
                Icon(
                  Icons.circle,
                  size: 24.sp,
                  color: animation.value,
                ),
                SizedBox(width: 16.w),
                Icon(
                  Icons.circle,
                  size: 24.sp,
                  color: animation.value,
                ),
                SizedBox(width: 16.w),
                Icon(
                  Icons.circle,
                  size: 24.sp,
                  color: animation.value,
                ),
                SizedBox(width: 16.w),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
