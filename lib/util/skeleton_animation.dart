import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

mixin SkeletonAnimation<T extends StatefulWidget> on State<T> {
  late AnimationController _controller;
  late Animation<Color?> animation;
  Animation<Color?> get animationValue => animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this as TickerProvider,
    );
    animation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: 1,
          tween: ColorTween(begin: AppColors.grey04, end: AppColors.grey08),
        ),
      ],
    ).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
