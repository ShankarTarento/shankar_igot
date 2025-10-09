import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class TranscriptSkeleton extends StatefulWidget {
  const TranscriptSkeleton({super.key});

  @override
  State<TranscriptSkeleton> createState() => _TranscriptSkeletonState();
}

class _TranscriptSkeletonState extends State<TranscriptSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: EdgeInsets.symmetric(vertical: 8.w),
          child: getSkeleton(),
        ),
      ),
    );
  }

  Widget getSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerSkeleton(
          height: 18.w,
          width: 0.15.sw,
        ),
        SizedBox(width: 8.w),
        ContainerSkeleton(
          height: 18.w,
          width: 0.15.sw,
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerSkeleton(
              height: 22.w,
              width: 0.55.sw,
            ),
            SizedBox(height: 4.w),
            ContainerSkeleton(
              height: 22.w,
              width: 0.45.sw,
            ),
          ],
        )
      ],
    );
  }
}
