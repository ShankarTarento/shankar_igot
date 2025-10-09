import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class MdoAllContentScreenSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _toolBarView(),
            _courseListView(),
          ],
        ),
      ),
    );
  }

  Widget _toolBarView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).w,
      child: Container(
        width: double.infinity,
        child: ContainerSkeleton(
          width: double.maxFinite,
          height: 40.w,
          radius: 100.w,
        ),
      ),
    );
  }

  Widget _courseListView() {
    return AnimationLimiter(
      child: Container(
        child: Column(children: [
          for (int i = 0; i < 8; i++)
            AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Container(
                    margin: EdgeInsets.only(left: 16, right: 16, bottom: 8).w,
                    child: ContainerSkeleton(
                      height: 144.w,
                      width: double.maxFinite,
                      radius: 12.w,
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
