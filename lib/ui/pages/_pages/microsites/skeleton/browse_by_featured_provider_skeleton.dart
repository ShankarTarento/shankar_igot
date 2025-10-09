import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class BrowseByFeaturedProviderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Column(
      children: [
        Container(
            padding:
                const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
            alignment: Alignment.centerLeft,
            child: ContainerSkeleton(
              height: 18.w,
              width: 200.w,
              radius: 8.w,
            )),
        Container(
          height: 168.w,
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(bottom: 8).w,
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: 4,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                        child: Container(
                            width: 250.w,
                            margin: EdgeInsets.only(
                              left: (index == 0) ? 24 : 8,
                              right: (index == 3) ? 24 : 0,
                            ).w,
                            child: ContainerSkeleton(
                              height: double.maxFinite,
                              width: 250.w,
                              radius: 12.w,
                            ))),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
