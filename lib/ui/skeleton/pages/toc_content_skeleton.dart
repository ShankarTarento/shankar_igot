import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../index.dart';

class TocContentSkeletonPage extends StatefulWidget {
  const TocContentSkeletonPage({Key? key}) : super(key: key);
  TocContentSkeletonPageState createState() => TocContentSkeletonPageState();
}

class TocContentSkeletonPageState extends State<TocContentSkeletonPage>
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
            begin: AppColors.grey04,
            end: AppColors.grey08,
          ),
        ),
        TweenSequenceItem(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.w),
          ContainerSkeleton(
            height: 80.w,
            width: 1.sw,
            color: animation.value!,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            height: 80.w,
            width: 1.sw,
            color: animation.value!,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            height: 80.w,
            width: 1.sw,
            color: animation.value!,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            height: 80.w,
            width: 1.sw,
            color: animation.value!,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            height: 80.w,
            width: 1.sw,
            color: animation.value!,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            height: 80.w,
            width: 1.sw,
            color: animation.value!,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            height: 80.w,
            width: 1.sw,
            color: animation.value!,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            height: 80.w,
            width: 1.sw,
            color: animation.value!,
          ),
          SizedBox(height: 8.w),
          ContainerSkeleton(
            height: 80.w,
            width: 1.sw,
            color: animation.value!,
          ),
        ],
      ),
    );
  }
}
