import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/helper/notification_helper.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_model.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/widgets/notification_card.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/skeleton/widgets/container_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final bool isLoadingMore;
  final bool hasMore;
  final ScrollController scrollController;
  final Function(String notificationId) markNotificationAsRead;

  const NotificationList({
    Key? key,
    required this.notifications,
    required this.isLoadingMore,
    required this.hasMore,
    required this.scrollController,
    required this.markNotificationAsRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty && !isLoadingMore) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: notifications.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == notifications.length) {
          if (isLoadingMore) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0).r,
              child: Column(
                children: List.generate(7, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0).r,
                    child: ContainerSkeleton(
                      height: 91.w,
                      width: double.infinity,
                    ),
                  );
                }),
              ),
            );
          }
          return SizedBox.shrink();
        }

        final notification = notifications[index];
        return InkWell(
            onTap: () {
              if (!notification.read) {
                markNotificationAsRead(notification.notificationId);
              }
              _generateInteractTelemetryData(
                  clickId: notification.notificationId);
              NotificationHelper.handleNotificationNavigation(
                  context: context, notification: notification);
            },
            child: NotificationCard(notificationModel: notification));
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64.sp,
            color: AppColors.greys60,
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.mNoNotificationsFound,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.greys87,
            ),
          ),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }

  void _generateInteractTelemetryData({required String clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        contentId: clickId,
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        subType: TelemetrySubType.notificationEngine,
        clickId: clickId,
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
