import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

import '../index.dart';

class CourseProgressSkeletonPage extends StatefulWidget {
  const CourseProgressSkeletonPage({Key? key}) : super(key: key);

  @override
  _CourseProgressSkeletonPageState createState() =>
      _CourseProgressSkeletonPageState();
}

class _CourseProgressSkeletonPageState extends State<CourseProgressSkeletonPage>
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
            begin: AppColors.grey08,
            end: AppColors.grey16,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey08,
            end: AppColors.grey16,
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
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8).w,
      child: Container(
          margin: EdgeInsets.fromLTRB(16, 16, 16, 0).w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12).w,
            border: Border.all(color: AppColors.grey16, width: 1),
            color: AppColors.appBarBackground,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16).w,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ContainerSkeleton(
                              width: 107.w,
                              height: 72.w,
                              color: animation.value!),
                          Padding(
                            padding: const EdgeInsets.only(left: 16).w,
                            child: Column(
                              children: [
                                ContainerSkeleton(
                                    width: 170.w,
                                    height: 20.w,
                                    color: animation.value!),
                                SizedBox(height: 4.w),
                                Row(
                                  children: [
                                    ContainerSkeleton(
                                      height: 24.w,
                                      width: 24.w,
                                      color: animation.value!,
                                    ),
                                    SizedBox(width: 4.w),
                                    ContainerSkeleton(
                                        height: 20.w,
                                        width: 130.w,
                                        color: animation.value!)
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 12.w,
                      ),
                      Container(
                        width: 1.sw,
                        child: Row(
                          children: [
                            Container(
                                width: 100.w,
                                height: 20.w,
                                color: animation.value),
                            Spacer(),
                            Container(
                                width: 100.w,
                                height: 20.w,
                                color: animation.value),
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 16).w,
                          width: 1.sw,
                          height: 40.w,
                          color: animation.value)
                    ]),
              )
            ],
          )),
    );
  }
}
