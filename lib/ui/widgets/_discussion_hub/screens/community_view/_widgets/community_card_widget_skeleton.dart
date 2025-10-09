import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';

class CommunityCardWidgetSkeleton extends StatelessWidget {
  final Color color;

  const CommunityCardWidgetSkeleton({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return _communityListItemView();
  }

  Widget _communityListItemView() {
    return ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(12.w),
      ),
      child: Container(
          width: 172.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
            color: AppColors.appBarBackground,
          ),
          child: Column(
            children: [
              Container(
                height: 98.w,
                child: Stack(
                  children: [
                    ContainerSkeleton(
                      height: 98.w,
                      width: double.maxFinite,
                      color: color,
                    ),
                  ],
                ),
              ),
              Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24)
                          .w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContainerSkeleton(
                        height: 18.w,
                        width: 120.w,
                        color: color,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          bottom: 12,
                        ).w,
                        child: Row(
                          children: [
                            ContainerSkeleton(
                              height: 12.w,
                              width: 30.w,
                              color: color,
                            ),
                            Spacer(),
                            ContainerSkeleton(
                              height: 6.w,
                              width: 6.w,
                              color: color,
                            ),
                            Spacer(),
                            ContainerSkeleton(
                              height: 12.w,
                              width: 30.w,
                              color: color,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          ContainerSkeleton(
                            height: 16.w,
                            width: 24.w,
                            color: color,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 4).r,
                            child: ContainerSkeleton(
                              height: 16.w,
                              width: 80.w,
                              color: color,
                            ),
                          )
                        ],
                      ),
                    ],
                  ))
            ],
          )),
    );
  }
}
