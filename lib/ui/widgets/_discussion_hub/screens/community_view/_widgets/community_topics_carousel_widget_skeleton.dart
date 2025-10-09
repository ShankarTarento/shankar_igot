import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';
import 'package:karmayogi_mobile/util/skeleton_animation.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';

class CommunityTopicsCarouselWidgetSkeleton extends StatefulWidget {
  CommunityTopicsCarouselWidgetSkeleton({
    Key? key,
  }) : super(key: key);

  CommunityTopicsCarouselWidgetSkeletonState createState() =>
      CommunityTopicsCarouselWidgetSkeletonState();
}

class CommunityTopicsCarouselWidgetSkeletonState
    extends State<CommunityTopicsCarouselWidgetSkeleton>
    with TickerProviderStateMixin, SkeletonAnimation {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationValue,
        builder: (context, child) {
          return _buildLayout();
        });
  }

  Widget _buildLayout() {
    return Container(
      margin: EdgeInsets.only(top: 16, bottom: 16).w,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16)
                    .r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ContainerSkeleton(
                  height: 24.w,
                  width: 0.6.sw,
                  radius: 12.w,
                  color: animationValue.value!,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 2.0).r,
                  child: ContainerSkeleton(
                    height: 24.w,
                    width: 0.2.sw,
                    radius: 12.w,
                    color: animationValue.value!,
                  ),
                )
              ],
            ),
          ),
          _communityListSkeletonView(3),
        ],
      ),
    );
  }

  Widget _communityListSkeletonView(int itemCount) {
    return Container(
      height: 182.w,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: itemCount, // Use itemCount for ListView.builder
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 475),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: (index == 0) ? 16 : 8,
                      right: (index < (itemCount - 1)) ? 0 : 16),
                  child: _communityTopicListItemView(),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _communityTopicListItemView() {
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
          child: Padding(
              padding:
                  EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24).w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerSkeleton(
                    height: 24.w,
                    width: 27.w,
                    color: animationValue.value!,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 8,
                    ).w,
                    child: ContainerSkeleton(
                      height: 24.w,
                      width: double.maxFinite,
                      color: animationValue.value!,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12).w,
                    child: ContainerSkeleton(
                      height: 24.w,
                      width: double.maxFinite,
                      color: animationValue.value!,
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(left: 4).r,
                        child: ContainerSkeleton(
                          height: 18.w,
                          width: 80.w,
                          color: animationValue.value!,
                        ),
                      )
                    ],
                  ),
                ],
              ))),
    );
  }
}
