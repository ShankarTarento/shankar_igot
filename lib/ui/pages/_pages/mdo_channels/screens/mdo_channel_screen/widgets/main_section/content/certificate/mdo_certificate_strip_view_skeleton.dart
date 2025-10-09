import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'mdo_certificate_of_week_skeleton.dart';

class MdoCertificateStripViewSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _contentSkeletonView();
  }

  Widget _contentSkeletonView() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0).w,
      child: Column(
        children: [
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
          SizedBox(height: 8.w),
          MdoCertificateOfWeekSkeleton()
        ],
      ),
    );
  }
}
