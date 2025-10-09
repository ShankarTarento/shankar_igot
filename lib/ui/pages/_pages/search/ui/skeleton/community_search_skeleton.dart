import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_card_widget_skeleton.dart';
import 'package:karmayogi_mobile/util/skeleton_animation.dart';

class CommunitySearchSkeleton extends StatefulWidget {
  CommunitySearchSkeleton({
    Key? key,
  }) : super(key: key);

  CommunitySearchSkeletonState createState() => CommunitySearchSkeletonState();
}

class CommunitySearchSkeletonState extends State<CommunitySearchSkeleton>
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
          _communityListSkeletonView(2),
        ],
      ),
    );
  }

  Widget _communityListSkeletonView(int itemCount) {
    return Container(
      height: 0.68.sh,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        itemCount: itemCount, // Use itemCount for ListView.builder
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 24, right: 24).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ContentSkeleton(index, itemCount),
                ContentSkeleton(index, itemCount)
              ],
            ),
          );
        },
      ),
    );
  }

  AnimationConfiguration ContentSkeleton(int index, int itemCount) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 475),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Row(
            children: [
              CommunityCardWidgetSkeleton(
                color: animationValue.value!,
              )
            ],
          ),
        ),
      ),
    );
  }
}
