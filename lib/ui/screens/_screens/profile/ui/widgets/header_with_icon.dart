import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';

class HeaderWithIcon extends StatelessWidget {
  final String title;
  final VoidCallback onAddCallback;
  final bool showClose;
  final bool hideIcon;

  const HeaderWithIcon(
      {super.key,
      required this.title,
      required this.onAddCallback,
      this.showClose = false,
      this.hideIcon = false});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: AppColors.greys)),
      hideIcon
          ? Center()
          : IconButton(
              onPressed: onAddCallback,
              padding: EdgeInsets.only(left: 24).r,
              icon: Icon(
                showClose ? Icons.close : Icons.add,
                size: 24.sp,
                color: AppColors.darkBlue,
              ))
    ]);
  }
}
