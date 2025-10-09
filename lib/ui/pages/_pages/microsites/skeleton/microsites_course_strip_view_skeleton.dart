import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import '../../../../skeleton/pages/course_card_skeleton_page.dart';

class MicroSitesCourseStripViewSkeleton extends StatelessWidget {
  final bool showHeader;

  MicroSitesCourseStripViewSkeleton({this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    return _contentSkeletonView();
  }

  Widget _contentSkeletonView() {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 0, 0, 0).w,
      height: 356,
      child: Column(
        children: [
          if (showHeader)
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ContainerSkeleton(
                height: 25.w,
                width: 150.w,
              ),
              ContainerSkeleton(
                height: 25.w,
                width: 100.w,
              )
            ]),
          if (showHeader)
            SizedBox(height: 8.w),
          Container(
            height: 296,
            child: CourseCardSkeletonPage(),
          ),
        ],
      ),
    );
  }
}
