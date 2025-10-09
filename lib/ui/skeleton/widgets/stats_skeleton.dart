import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../index.dart';

class StatsSkeleton extends StatefulWidget {
  const StatsSkeleton({Key? key}) : super(key: key);

  @override
  _StatsSkeletonState createState() => _StatsSkeletonState();
}

class _StatsSkeletonState extends State<StatsSkeleton>
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerSkeleton(
                color: animation.value!, height: 20.w, width: 100.w),
            SizedBox(height: 16.w),
            Container(
              height: 180.w,
              padding: EdgeInsets.all(14).r,
              width: 1.sw,
              color: AppColors.appBarBackground,
              child: Column(children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TabSkeleton(
                          iconHeight: 24.w,
                          iconWidth: 24.w,
                          radius: 4.r,
                          color: animation.value),
                      TabSkeleton(
                          iconHeight: 24.w,
                          iconWidth: 24.w,
                          radius: 4.r,
                          color: animation.value),
                      TabSkeleton(
                          iconHeight: 24.w,
                          iconWidth: 24.w,
                          radius: 4.r,
                          color: animation.value),
                    ],
                  ),
                ),
                SizedBox(height: 8.w),
                ContainerSkeleton(
                    color: animation.value!, height: 73.w, width: 1.sw),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
