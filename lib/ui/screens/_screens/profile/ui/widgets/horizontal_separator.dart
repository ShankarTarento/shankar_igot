import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';

class HorizontalSeparator extends StatelessWidget {
  final Color bgColor;

  const HorizontalSeparator({super.key, this.bgColor = AppColors.appBarBackground});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Container(
          height: 2.w,
          width: 1.0.sw,
          color: AppColors.grey08,
          margin: EdgeInsets.only(left: 16, right: 16).r),
    );
  }
}
