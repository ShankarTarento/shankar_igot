import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart'; // Assuming you have AppColors defined here
import '../index.dart'; // Assuming you have ContainerSkeleton defined here

class CompetencyPassbookSkeletonPage extends StatefulWidget {
  final double? height, width;

  const CompetencyPassbookSkeletonPage({Key? key, this.height, this.width})
      : super(key: key);

  @override
  CompetencyPassbookSkeletonPageState createState() =>
      CompetencyPassbookSkeletonPageState();
}

class CompetencyPassbookSkeletonPageState
    extends State<CompetencyPassbookSkeletonPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(begin: AppColors.grey04, end: AppColors.grey08),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: AppColors.grey08, end: AppColors.grey04),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _animation.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10).r,
      child: Container(
        height: 1.sh,
        child: Column(
          children: [
            Expanded(
              child: Container(
                height: 0.3.sh,
                width: double.infinity.w,
                decoration: BoxDecoration(
                  color: _animation.value,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0),
                  ).r,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15).r,
              child: ContainerSkeleton(
                  height: 40.w,
                  width: 1.sw,
                  color: _animation.value!,
                  radius: 8.r),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 15).r,
              child: ContainerSkeleton(
                  height: 0.2.sh,
                  width: 1.sw,
                  color: _animation.value!,
                  radius: 8.r),
            ),
            ContainerSkeleton(
                height: 0.2.sh,
                width: 1.sw,
                color: _animation.value!,
                radius: 8.r),
          ],
        ),
      ),
    );
  }
}
