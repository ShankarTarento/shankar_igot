import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import '../../../../../../../constants/_constants/color_constants.dart';

class MdoChannelStripWidgetSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _contentSkeletonView();
  }

  Widget _contentSkeletonView() {
    return Container(
      padding: EdgeInsets.only(top: 16).w,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16).w,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ContainerSkeleton(
                    height: 25.w,
                    width: 150.w,
                  ),
                  ContainerSkeleton(
                    height: 25.w,
                    width: 100.w,
                  )
                ]),
          ),
          Container(
            height: 156.w,
            margin: EdgeInsets.only(top: 16).w,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                        child: FadeInAnimation(
                            child: Container(
                                width: 0.6.sw,
                                margin: EdgeInsets.only(
                                        left: (index == 0) ? 16 : 0,
                                        right: (index == 4) ? 16 : 8)
                                    .w,
                                child: Container(
                                    padding: EdgeInsets.all(4).w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.w)),
                                      color: AppColors.grey08,
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 86.w,
                                          padding: EdgeInsets.all(8).w,
                                          child: ContainerSkeleton(
                                            height: 62.w,
                                            width: double.maxFinite,
                                            radius: 12.w,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                                  top: 8, left: 8, right: 8)
                                              .w,
                                          child: ContainerSkeleton(
                                            height: 40.w,
                                            width: double.maxFinite,
                                            radius: 12.w,
                                          ),
                                        )
                                      ],
                                    )))),
                      ));
                }),
          ),
        ],
      ),
    );
  }
}
