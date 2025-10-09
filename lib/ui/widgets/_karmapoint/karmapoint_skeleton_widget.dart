import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import '../../skeleton/widgets/container_skeleton.dart';

class KarmaPointAppbarSkeletonWidget extends StatefulWidget {
  const KarmaPointAppbarSkeletonWidget({Key? key}) : super(key: key);

  @override
  _KarmaPointAppbarSkeletonWidgetState createState() =>
      _KarmaPointAppbarSkeletonWidgetState();
}

class _KarmaPointAppbarSkeletonWidgetState
    extends State<KarmaPointAppbarSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
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
            begin: AppColors.grey08,
            end: AppColors.grey16,
          ),
        ),
        TweenSequenceItem<Color?>(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey08,
            end: AppColors.grey16,
          ),
        ),
      ],
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerSkeleton(
                height: 32.w, width: 32.w, color: animation.value!),
            SizedBox(width: 4.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ContainerSkeleton(
                        height: 8.w, width: 65.w, color: animation.value!),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: ContainerSkeleton(
                          height: 8.w, width: 10.w, color: animation.value!),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4).w,
                  child: ContainerSkeleton(
                      height: 8.w, width: 24.w, color: animation.value!),
                )
              ],
            ),
          ],
        ));
  }
}
