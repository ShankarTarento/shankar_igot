import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/index.dart';
import '../index.dart';

class TocContentHeaderSkeletonPage extends StatelessWidget {
  const TocContentHeaderSkeletonPage({Key? key}) : super(key: key);

  Widget _buildSkeletonLine(double height, double width) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.w),
      child: ContainerSkeleton(
        height: height,
        width: width,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkBlue,
      padding: const EdgeInsets.symmetric(horizontal: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonLine(16.w, 0.2.sw),
          _buildSkeletonLine(16.w, 0.7.sw),
          _buildSkeletonLine(16.w, 0.5.sw),
          _buildSkeletonLine(16.w, 0.6.sw),
          Padding(
            padding: EdgeInsets.only(bottom: 18.w),
            child: Row(
              children: [
                ContainerSkeleton(
                  height: 27.w,
                  width: 0.2.sw,
                ),
                SizedBox(width: 4.w),
                ContainerSkeleton(
                  height: 16.w,
                  width: 0.15.sw,
                ),
              ],
            ),
          ),
          _buildSkeletonLine(16.w, 0.4.sw),
        ],
      ),
    );
  }
}
