import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/pages/widgets/comment_view_skeleton.dart';
import 'package:karmayogi_mobile/util/skeleton_animation.dart';

class CommunityDetailViewSkeleton extends StatefulWidget {
  const CommunityDetailViewSkeleton({Key? key}) : super(key: key);

  @override
  CommunityDetailViewSkeletonState createState() =>
      CommunityDetailViewSkeletonState();
}

class CommunityDetailViewSkeletonState extends State<CommunityDetailViewSkeleton>
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
        }
    );
  }

  Widget _buildLayout() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16).r,
        child: AnimationLimiter(
          child: _buildCommunityDetailView(),
        ),
      ),
    );
  }

  Widget _buildCommunityDetailView() {
    return AnimationLimiter(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerSkeleton(
              height: 98.w,
              width: double.maxFinite,
              radius: 12.r,
              color: animationValue.value,
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerSkeleton(
                  height: 60.w,
                  width: 0.8.sw,
                  radius: 12.r,
                  color: animationValue.value,
                ),
                Spacer(),
                ContainerSkeleton(
                  height: 28.w,
                  width: 10.w,
                  radius: 50.r,
                  color: animationValue.value,
                ),
              ],
            ),
            SizedBox(height: 16),
            ContainerSkeleton(
              height: 38.w,
              width: double.maxFinite,
              radius: 50.r,
              color: animationValue.value,
            ),
            SizedBox(height: 16),
            Wrap(
              runAlignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              alignment: WrapAlignment.start,
              children: [
                ContainerSkeleton(
                  height: 32.w,
                  width: 0.2.sw,
                  radius: 12.r,
                  color: animationValue.value,
                ),
                SizedBox(width: 8),
                ContainerSkeleton(
                  height: 32.w,
                  width: 0.2.sw,
                  radius: 12.r,
                  color: animationValue.value,
                ),
                SizedBox(width: 8),
                ContainerSkeleton(
                  height: 32.w,
                  width: 0.2.sw,
                  radius: 12.r,
                  color: animationValue.value,
                ),
                SizedBox(width: 8),
                ContainerSkeleton(
                  height: 32.w,
                  width: 0.2.sw,
                  radius: 12.r,
                  color: animationValue.value,
                ),
              ],
            ),
            SizedBox(height: 16),
            ContainerSkeleton(
              height: 38.w,
              width: double.maxFinite,
              radius: 50.r,
              color: animationValue.value,
            ),
            SizedBox(height: 16),
            CommentViewSkeleton(itemCount: 10),
          ],
        ),
      ),
    );
  }
}
