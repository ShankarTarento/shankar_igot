import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../../../constants/index.dart';
import '../../../../../skeleton/index.dart';

class CourseSearchSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ContainerSkeleton(height: 20.w, width: 160.w, radius: 8.w),
              ContainerSkeleton(height: 20.w, width: 80.w, radius: 8.w)
            ],
          ),
        ),
        SizedBox(height: 8.w),
        AnimationLimiter(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16).r,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 16).r,
                            padding: EdgeInsets.all(16).r,
                            decoration: BoxDecoration(
                                color: AppColors.appBarBackground,
                                borderRadius: BorderRadius.circular(16).r),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(children: [
                                    SizedBox(
                                      width: 0.3.sw,
                                      height: 75.w,
                                      child: ContainerSkeleton(
                                          width: double.infinity,
                                          height: 140.w,
                                          radius: 12.r),
                                    ),
                                    SizedBox(height: 4.w),
                                    ContainerSkeleton(
                                        width: 0.3.sw,
                                        height: 20.w,
                                        radius: 12.r),
                                  ]),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0)
                                          .r,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ContainerSkeleton(
                                                width: 0.3.sw,
                                                height: 20.w,
                                                radius: 12.r),
                                            SizedBox(height: 4.w),
                                            ContainerSkeleton(
                                                width: 0.5.sw,
                                                height: 20.w,
                                                radius: 12.r),
                                            SizedBox(height: 4.w),
                                            ContainerSkeleton(
                                                width: 0.45.sw,
                                                height: 20.w,
                                                radius: 12.r),
                                            SizedBox(height: 4.w),
                                            ContainerSkeleton(
                                                width: 0.3.sw,
                                                height: 20.w,
                                                radius: 12.r),
                                            SizedBox(height: 4.w),
                                            ContainerSkeleton(
                                                width: 0.3.sw,
                                                height: 20.w,
                                                radius: 12.r)
                                          ]),
                                    ),
                                  )
                                ]),
                          ))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
