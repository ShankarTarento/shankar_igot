import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/repositories/notification_repository.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/widgets/notification_menu_view.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class NotificationIcon extends StatefulWidget {
  final Color? iconColor;
  const NotificationIcon({super.key, this.iconColor});

  @override
  State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  final GlobalKey _notificationIconKey = GlobalKey();

  @override
  void initState() {
    NotificationRepository().getUnreadNotificationCount(/*forceRefresh: true*/);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationRepository.unreadCountNotifier,
      builder: (context, count, _) {
        return InkWell(
          key: _notificationIconKey,
          onTap: () {
            if (count != 0) {
              NotificationRepository().resetNotificationCount();
            }
            _showNotificationsMenu(context);
          },
          child: Stack(
            children: [
              Icon(
                Icons.notifications,
                color: widget.iconColor ?? AppColors.darkBlue,
                size: 26.sp,
              ),
              if (count > 0)
                Positioned(
                  right: 0,
                  child: Container(
                    width: 13.w,
                    height: 13.w,
                    decoration: const BoxDecoration(
                      color: AppColors.negativeLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: TextStyle(
                          color: AppColors.appBarBackground,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsMenu(BuildContext context) {
    final renderBox =
        _notificationIconKey.currentContext?.findRenderObject() as RenderBox?;
    showMenu(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      constraints: BoxConstraints(
        maxWidth: 0.85.sw,
        maxHeight: 0.63.sh,
        minWidth: 0.85.sw,
      ),
      context: context,
      position: RelativeRect.fromLTRB(
          100.w,
          renderBox != null && renderBox.hasSize
              ? renderBox.localToGlobal(Offset.zero).dy + renderBox.size.height
              : 100.h,
          0,
          0),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: GestureDetector(
            onTap: () {},
            child: SizedBox(
              width: 0.85.sw,
              height: 0.63.sh,
              child: NotificationMenuView(),
            ),
          ),
        ),
      ],
    );
  }
}
