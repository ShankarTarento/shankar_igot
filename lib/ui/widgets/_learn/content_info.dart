import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/_constants/color_constants.dart';

class ContentInfo extends StatelessWidget {
  final String infoMessage;
  final bool isReport;
  final icon;
  final double? size;
  final Color color;
  const ContentInfo(
      {Key? key,
      required this.infoMessage,
      this.isReport = false,
      this.icon = Icons.info_outline,
      this.size,
      this.color = AppColors.greys87})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10).r,
      child: Tooltip(
        child: Icon(
          icon,
          size: size ?? 23.sp,
          color: isReport ? AppColors.primaryThree : color,
        ),
        message: infoMessage
            .replaceAll('<p class="ws-mat-primary-text">', '')
            .replaceAll('</p>', ''),
        showDuration: Duration(
            seconds: (isReport || icon == Icons.flag_rounded) ? 5 : 10),
        // preferBelow: false,
        // decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        padding: EdgeInsets.all(12).r,
        margin: EdgeInsets.only(left: 32, right: 32).r,
        verticalOffset: 20,
        triggerMode: TooltipTriggerMode.tap,
      ),
    );
  }
}