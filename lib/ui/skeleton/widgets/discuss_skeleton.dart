import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';

class DiscussSkeleton extends StatefulWidget {
  const DiscussSkeleton({Key? key}) : super(key: key);
  DiscussSkeletonState createState() => DiscussSkeletonState();
}

class DiscussSkeletonState extends State<DiscussSkeleton>
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16).r,
      height: 158.w,
      width: double.infinity.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12).r,
        color: AppColors.appBarBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(16, 16, 16, 8).r,
            color: animation.value,
            height: 28.w,
            width: 0.7.sw,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 8).r,
            color: animation.value,
            height: 28.w,
            width: 0.9.sw,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 16).r,
            color: animation.value,
            height: 28.w,
            width: 0.8.sw,
          ),
        ],
      ),
    );
  }
}
