import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../index.dart';

class CourseCardVerticalSkeletonPage extends StatefulWidget {
  const CourseCardVerticalSkeletonPage({Key? key}) : super(key: key);
  CourseCardVerticalSkeletonPageState createState() =>
      CourseCardVerticalSkeletonPageState();
}

class CourseCardVerticalSkeletonPageState
    extends State<CourseCardVerticalSkeletonPage>
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
      width: 1.sw,
      margin: EdgeInsets.only(top: 16).r,
      child: ListView.separated(
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 4).r,
          child: Container(
            margin: EdgeInsets.only(bottom: 8).r,
            padding: EdgeInsets.fromLTRB(8, 8, 0, 8).r,
            color: AppColors.appBarBackground,
            child: Row(
              children: [
                Expanded(
                  child: CardSkeletonPage(
                      height: 100.w,
                      width:0.4.sw),
                ),
                SizedBox(width: 2.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CardSkeletonPage(height: 24.w, width: 24.w),
                        SizedBox(width: 2.w),
                        CardSkeletonPage(
                            height: 20.w,
                            width: 0.3.sw)
                      ],
                    ),
                    SizedBox(height: 8.w),
                    CardSkeletonPage(
                        height: 20.w,
                        width: 0.25.sw)
                  ],
                )
              ],
            ),
          ),
        ),
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemCount: 3,
        shrinkWrap: true,
      ),
    );
  }
}
