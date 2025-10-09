import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';
import 'package:karmayogi_mobile/util/skeleton_animation.dart';

class PopularCommunityWidgetSkeleton extends StatefulWidget {
  PopularCommunityWidgetSkeleton({Key? key, }) : super(key: key);

  PopularCommunityWidgetSkeletonState createState() => PopularCommunityWidgetSkeletonState();

}

class PopularCommunityWidgetSkeletonState extends State<PopularCommunityWidgetSkeleton>
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
    return Container(
      margin: EdgeInsets.only(top: 16, bottom: 16).w,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16).r,
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
          Container(
              width: double.maxFinite,
              height: 179.w,
              margin: const EdgeInsets.symmetric(horizontal: 16).r,
              padding: EdgeInsets.all(12).r,
              decoration: BoxDecoration(
                color: animationValue.value!,
                borderRadius: BorderRadius.circular(12).r,
              )),
        ],
      ),
    );
  }
}
