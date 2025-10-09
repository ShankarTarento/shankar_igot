import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../index.dart';

class CompetencyPassbookThemeSkeletonPage extends StatefulWidget {
  const CompetencyPassbookThemeSkeletonPage({
    Key? key,
  }) : super(key: key);
  CompetencyPassbookThemeSkeletonPageState createState() =>
      CompetencyPassbookThemeSkeletonPageState();
}

class CompetencyPassbookThemeSkeletonPageState
    extends State<CompetencyPassbookThemeSkeletonPage>
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
    return Container(
      height: 1.sh,
      width: 1.sw,
      padding: EdgeInsets.all(16).r,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ContainerSkeleton(
                height: 0.1.sh, width: 0.7.sw, color: animation.value!),
            ContainerSkeleton(
                height: 70.w, width: 0.2.sw, color: animation.value!)
          ],
        ),
        SizedBox(height: 16.w),
        ContainerSkeleton(height: 0.3.sh, width: 1.sw, color: animation.value!),
        SizedBox(height: 16.w),
        ContainerSkeleton(height: 0.4.sh, width: 1.sw, color: animation.value!),
      ]),
    );
  }
}
