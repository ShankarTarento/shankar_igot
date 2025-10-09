import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/skeleton_loading/title_skeleton_loading.dart';
import 'package:karmayogi_mobile/ui/skeleton/index.dart';

class MyEventsSkeleton extends StatelessWidget {
  const MyEventsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0).r,
      child: Column(
        children: [TitleSkeletonLoading(), CourseCardSkeletonPage()],
      ),
    );
  }
}
