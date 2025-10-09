import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/_constants/color_constants.dart';

class SilverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SilverAppBarDelegate(this.tabBar);

  final PreferredSizeWidget tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey08,
            blurRadius: 6.0.r,
            spreadRadius: 0.r,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(SilverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
