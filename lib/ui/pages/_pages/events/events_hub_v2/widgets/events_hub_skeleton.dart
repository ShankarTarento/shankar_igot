import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';

class EventsHubSkeleton extends StatelessWidget {
  const EventsHubSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerSkeleton(
            width: 1.sw,
            height: 150.w,
          ),
          SizedBox(
            height: 10.w,
          ),
          ContainerSkeleton(
            width: 0.5.sw,
            height: 40.w,
          ),
          SizedBox(
            height: 10.w,
          ),
          Row(
            children: [
              ContainerSkeleton(
                width: 100.w,
                height: 80.w,
              ),
              SizedBox(
                width: 16.w,
              ),
              ContainerSkeleton(
                width: 100.w,
                height: 80.w,
              ),
            ],
          ),
          SizedBox(
            height: 24.w,
          ),
          ContainerSkeleton(
            width: 0.6.sw,
            height: 40.w,
          ),
          SizedBox(
            height: 10.w,
          ),
          CourseCardSkeletonPage()
        ],
      ),
    );
  }
}
