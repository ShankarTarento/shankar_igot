import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';

class FormSkeleton extends StatefulWidget {
  const FormSkeleton({super.key});

  @override
  State<FormSkeleton> createState() => _FormSkeletonState();
}

class _FormSkeletonState extends State<FormSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30.w,
        ),
        ...List.generate(8, (index) => _buildFormSkeleton()),
      ],
    );
  }

  Widget _buildFormSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerSkeleton(
          height: 30,
          width: 0.5.sw,
        ),
        SizedBox(height: 8.w),
        ContainerSkeleton(
          height: 50,
          width: 1.sw,
        ),
        SizedBox(height: 30.w),
      ],
    );
  }
}
