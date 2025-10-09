import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/helper/notification_helper.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_model.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class NotificationCard extends StatefulWidget {
  final NotificationModel notificationModel;
  const NotificationCard({super.key, required this.notificationModel});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 16).r,
      height: 72.w,
      decoration: BoxDecoration(
          color: widget.notificationModel.read
              ? AppColors.appBarBackground
              : AppColors.blue244,
          border: Border(
            bottom: BorderSide(
              color: AppColors.grey16,
              width: 1.0,
            ),
          )),
      child: Row(
        children: [
          NotificationHelper.getNotificationIcon(
              widget.notificationModel.category),
          SizedBox(width: 8.w),
          Expanded(
              child: Text(
            widget.notificationModel.message.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
                color: AppColors.darkBlue,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700),
          )),
          SizedBox(width: 8.w),
          Text(
            NotificationHelper.getNotificationTime(
                widget.notificationModel.createdAt),
            style: GoogleFonts.lato(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greys60),
          )
        ],
      ),
    );
  }
}
