import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class TitleSkeleton extends StatelessWidget {
  const TitleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ContainerSkeleton(
          height: 35,
          width: 0.5.sw,
        ),
        Spacer(),
        ContainerSkeleton(
          height: 35,
          width: 0.25.sw,
        ),
        SizedBox(
          width: 8.w,
        )
      ],
    );
  }
}
