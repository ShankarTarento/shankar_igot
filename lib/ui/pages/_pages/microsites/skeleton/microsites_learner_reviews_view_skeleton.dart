import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class MicroSitesLearnerReviewsViewSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 8,
          ).w,
          child: ContainerSkeleton(
            height: 18.w,
            width: 0.5.sw,
            radius: 12.w,
          ),
        ),
        _learnerListView(),
        _learnerReviewSectionView(),
        _learnerReviewedContentView(),
      ],
    );
  }

  Widget _learnerListView() {
    return Container(
      margin: EdgeInsets.only(top: 16).w,
      padding: EdgeInsets.only(left: 16, bottom: 8).w,
      height: 70.w,
      alignment: Alignment.center,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  horizontalOffset: 50,
                  child: FadeInAnimation(
                    child: _learnerListItem(),
                  ),
                ));
          }),
    );
  }

  Widget _learnerListItem() {
    return Container(
      margin: EdgeInsets.only(
        right: 4,
      ).w,
      child: ContainerSkeleton(
        height: 48.w,
        width: 62.w,
        radius: 100.w,
      ),
    );
  }

  Widget _learnerReviewSectionView() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 8).w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 8, right: 8).w,
            child: ContainerSkeleton(
              height: 18.w,
              width: 0.5.sw,
              radius: 12.w,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8).w,
            child: ContainerSkeleton(
              height: 28.w,
              width: 0.3.sw,
              radius: 12.w,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8).w,
            child: ContainerSkeleton(
              height: 88.w,
              width: 0.8.sw,
              radius: 12.w,
            ),
          ),
          ContainerSkeleton(
            height: 2.w,
            width: 185.w,
            radius: 10.w,
          ),
        ],
      ),
    );
  }

  Widget _learnerReviewedContentView() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8).w,
            child: ContainerSkeleton(
              height: 18.w,
              width: 0.5.sw,
              radius: 12.w,
            ),
          ),
          Container(
            height: 140.w,
            margin: EdgeInsets.only(top: 8).w,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ContainerSkeleton(
              height: 100.w,
              width: double.maxFinite,
              radius: 12.w,
            ),
          ),
        ],
      ),
    );
  }
}
