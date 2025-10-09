import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/skeleton/index.dart';

import '../../../constants/index.dart';

class CourseCardSkeleton extends StatelessWidget {
  final Color? color;

  const CourseCardSkeleton({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: 8).r,
        height: 250.w,
        width: 0.6.sw,
        decoration: BoxDecoration(
            color: AppColors.grey08, borderRadius: BorderRadius.circular(12).r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ContainerSkeleton(
                height: 80.w,
                width: 1.sw,
                color: color!,
              ),
            ),
            SizedBox(height: 16.w),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16).r,
              child:
                  ContainerSkeleton(height: 25.w, width: 150.w, color: color!),
            ),
            SizedBox(height: 16.w),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).r,
                child: ContainerSkeleton(
                  height: 25.w,
                  width: 200.w,
                  color: color!,
                )),
            SizedBox(height: 16.w),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).r,
                child: Row(children: [
                  Expanded(
                    child: ContainerSkeleton(
                      height: 25.w,
                      width: 25.w,
                      color: color!,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ContainerSkeleton(
                      height: 25.w,
                      width: 150.w,
                      color: color!,
                    ),
                  )
                ])),
            SizedBox(height: 8.w),
          ],
        ));
  }
}
