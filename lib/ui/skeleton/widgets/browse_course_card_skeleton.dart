import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';

import '../../../constants/_constants/color_constants.dart';

class BrowseCourseCardSkeleton extends StatelessWidget {
  const BrowseCourseCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContainerSkeleton(
      height: 160.w,
      width: double.infinity,
      padding: 16.w,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ContainerSkeleton(
          height: 28.w,
          width: 100.w,
          radius: 25.w,
          color: AppColors.grey08,
        ),
        SizedBox(height: 8.w),
        Expanded(
          child: Row(
            children: [
              ContainerSkeleton(
                width: 135.w,
                radius: 16.w,
                color: AppColors.grey16,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  children: [
                    ContainerSkeleton(
                      width: double.infinity,
                      height: 24.w,
                      radius: 16.w,
                      color: AppColors.grey16,
                    ),
                    SizedBox(height: 8.w),
                    Row(
                      children: [
                        ContainerSkeleton(
                          width: 36.w,
                          height: 30.w,
                          radius: 8.w,
                          color: AppColors.grey08,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ContainerSkeleton(
                            width: double.infinity,
                            height: 24.w,
                            radius: 16.w,
                            color: AppColors.grey08,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}
