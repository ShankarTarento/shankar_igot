import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../index.dart';

class TabOverviewIconSkeleton extends StatelessWidget {
  final Color color;

  const TabOverviewIconSkeleton({Key? key, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
            height: 55,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GetItems(color: color),
              GetItems(color: color),
              GetItems(color: color),
              GetItems(color: color),
              GetItems(color: color),
            ])));
  }
}

class GetItems extends StatelessWidget {
  const GetItems({
    Key? key,
    required this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0).r,
      child: Column(
        children: [
          Expanded(
            child: ContainerSkeleton(
              height: 16.w,
              width: 20.w,
              color: color,
            ),
          ),
          SizedBox(height: 8.w),
          Expanded(
            child: ContainerSkeleton(
              height: 16.w,
              width: 60.w,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
