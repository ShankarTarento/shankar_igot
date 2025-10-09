import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../index.dart';

class TocAboutSkeletonPage extends StatefulWidget {
  const TocAboutSkeletonPage({Key? key}) : super(key: key);
  TocAboutSkeletonPageState createState() => TocAboutSkeletonPageState();
}

class TocAboutSkeletonPageState extends State<TocAboutSkeletonPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();

    _animation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(begin: AppColors.grey04, end: AppColors.grey08),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(begin: AppColors.grey08, end: AppColors.grey04),
        ),
      ],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSkeleton(Widget Function(Color color) builder) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => builder(_animation.value!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0).r,
        child: _buildAnimatedSkeleton((color) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.w),
              TabOverviewIconSkeleton(color: color),
              SizedBox(height: 30.w),

              // 1st group
              _skeletonTextBlock(color),
              SizedBox(height: 30.w),

              // 2nd group
              _skeletonTextBlock(color),
              SizedBox(height: 30.w),

              // 3rd group with list
              _skeletonListGroup(color),
              SizedBox(height: 30.w),

              // 4th group
              _skeletonTextBlock(color),
              SizedBox(height: 16.w),

              _horizontalList(color, height: 70.w, itemHeight: 64.w),

              SizedBox(height: 16.w),
              ContainerSkeleton(height: 16.w, width: 1.sw, color: color),
              SizedBox(height: 8.w),
              _skeletonAvatarRow(color),
              SizedBox(height: 8.w),
              _skeletonAvatarRow(color),
              SizedBox(height: 8.w),
              ContainerSkeleton(height: 150.w, width: 1.sw, color: color),
            ],
          );
        }),
      ),
    );
  }

  Widget _skeletonTextBlock(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerSkeleton(height: 16.w, width: 0.2.sw, color: color),
        SizedBox(height: 4.w),
        ContainerSkeleton(height: 16.w, width: 1.sw, color: color),
        SizedBox(height: 4.w),
        ContainerSkeleton(height: 16.w, width: 1.sw, color: color),
      ],
    );
  }

  Widget _skeletonListGroup(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerSkeleton(height: 16.w, width: 0.25.sw, color: color),
        SizedBox(height: 4.w),
        Row(
          children: [
            ContainerSkeleton(height: 16.w, width: 0.2.sw, color: color),
            SizedBox(width: 4.w),
            ContainerSkeleton(height: 16.w, width: 0.2.sw, color: color),
          ],
        ),
        SizedBox(height: 4.w),
        _horizontalList(color, height: 90.w, itemHeight: 84.w),
      ],
    );
  }

  Widget _horizontalList(Color color,
      {required double height, required double itemHeight}) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (context, index) {
          return ContainerSkeleton(
            height: itemHeight,
            width: 0.8.sw,
            color: color,
          );
        },
      ),
    );
  }

  Widget _skeletonAvatarRow(Color color) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: color, radius: 16.r),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerSkeleton(height: 16.w, width: 0.4.sw, color: color),
            SizedBox(height: 4.w),
            ContainerSkeleton(height: 16.w, width: 0.15.sw, color: color),
          ],
        ),
      ],
    );
  }
}
