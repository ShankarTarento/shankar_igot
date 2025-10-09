import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../index.dart';

class MyacticitiesCardSkeleton extends StatefulWidget {
  const MyacticitiesCardSkeleton({Key? key}) : super(key: key);

  @override
  State<MyacticitiesCardSkeleton> createState() =>
      _MyacticitiesCardSkeletonState();
}

class _MyacticitiesCardSkeletonState extends State<MyacticitiesCardSkeleton>
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
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16).w,
          height: 360.h,
          decoration: BoxDecoration(
              color: AppColors.appBarBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: ContainerSkeleton(
                  height: 40.h,
                  width: 200.w,
                  color: animation.value!,
                ),
              ),
              SizedBox(height: 4.h),
              Divider(
                thickness: 1,
                color: animation.value!,
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TabSkeleton(
                      iconHeight: 24.h,
                      iconWidth: 24.w,
                      radius: 4.w,
                      color: animation.value!),
                  TabSkeleton(
                      iconHeight: 24.h,
                      iconWidth: 24.w,
                      radius: 4.w,
                      color: animation.value!),
                  TabSkeleton(
                      iconHeight: 24.h,
                      iconWidth: 24.w,
                      radius: 4.w,
                      color: animation.value!),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ContainerSkeleton(
                    height: 25.h,
                    width: 0.2.sw,
                    color: animation.value!,
                  ),
                  ContainerSkeleton(
                    height: 25.h,
                    width: 0.2.sw,
                    color: animation.value!,
                  ),
                  ContainerSkeleton(
                    height: 25.h,
                    width: 0.2.sw,
                    color: animation.value!,
                  ),
                  ContainerSkeleton(
                    height: 25.h,
                    width: 0.2.sw,
                    color: animation.value!,
                  )
                ],
              ),
              SizedBox(height: 10.h),
              Divider(
                thickness: 1,
                color: animation.value!,
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ContainerSkeleton(
                    height: 40.h,
                    width: 150.w,
                    color: animation.value!,
                  ),
                  ContainerSkeleton(
                    height: 40.h,
                    width: 100.w,
                    color: animation.value!,
                  )
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
              color: AppColors.grey08,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ContainerSkeleton(
                    height: 24.h,
                    width: 24.w,
                    color: animation.value!,
                  ),
                  SizedBox(width: 8),
                  ContainerSkeleton(
                    height: 25.h,
                    width: 150.w,
                    color: animation.value!,
                  ),
                ],
              ),
              ContainerSkeleton(
                height: 24.h,
                width: 24.w,
                color: animation.value!,
              )
            ],
          ),
        )
      ],
    );
  }
}
