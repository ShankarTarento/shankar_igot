import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';
import 'package:karmayogi_mobile/util/skeleton_animation.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';

class TopicListSkeleton extends StatefulWidget {
  final int itemCount;
  final double verticalMargin;
  final double horizontalMargin;
  TopicListSkeleton(
      {Key? key,
      this.itemCount = 1,
      this.verticalMargin = 0,
      this.horizontalMargin = 0})
      : super(key: key);

  TopicListSkeletonState createState() => TopicListSkeletonState();
}

class TopicListSkeletonState extends State<TopicListSkeleton>
    with TickerProviderStateMixin, SkeletonAnimation {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
      margin: EdgeInsets.symmetric(
          vertical: widget.verticalMargin, horizontal: widget.horizontalMargin),
      child: AnimatedBuilder(
          animation: animationValue,
          builder: (context, child) {
            return _buildTopicListView();
          }),
    );
  }

  Widget _buildTopicListView() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16).r,
      width: double.maxFinite,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: widget.itemCount,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: _communityTopicListItemView()),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _communityTopicListItemView() {
    return Container(
      height: 140.w,
      margin: EdgeInsets.only(bottom: 8).r,
      child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
            color: AppColors.appBarBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerSkeleton(
                  height: 24.w,
                  width: 27.w,
                  color: animationValue.value!,
                ),
                SizedBox(
                  height: 8.w,
                ),
                ContainerSkeleton(
                  height: 30.w,
                  width: 0.6.sw,
                  color: animationValue.value!,
                ),
                SizedBox(
                  height: 8.w,
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ContainerSkeleton(
                      height: 20.w,
                      width: 100.w,
                      color: animationValue.value!,
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}
