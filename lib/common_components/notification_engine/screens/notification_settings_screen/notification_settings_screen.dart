import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_model.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/repositories/notification_repository.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/screens/notification_settings_screen/widgets/notification_settings_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/util/helper.dart';

import '../../constants/notification_constants.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {

  Future<List<NotificationSettingModel>?>? _notificationSettingFuture;
  List<NotificationSettingModel> _notificationSettings = [];
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _notificationSettingFuture = _getNotificationSettings();
  }

  Future<List<NotificationSettingModel>?> _getNotificationSettings() async {
    List<NotificationSettingModel> response = [];
    try {
      _isLoading = true;
      response = await NotificationRepository().getNotificationSettings();
      _notificationSettings = response;
      return Future.value(response);
    } catch (err) {
      _isLoading = false;
      return Future.value(response);
    }
  }
  Future<bool?> _updateNotificationSettings(NotificationSettingModel notificationData) async {
      try {
        bool? response = await NotificationRepository().updateNotificationSettings(notificationData.notificationType??'', !(notificationData.enabled??false));
        if (response != null) {
          setState(() {
            notificationData.enabled = response;
          });
          Helper.showSnackBarMessage(
            context: context,
            text: response
                ? AppLocalizations.of(context)?.mNotificationEnabled ?? ''
                : AppLocalizations.of(context)?.mNotificationDisabled ?? '',
            bgColor: AppColors.positiveLight,
          );
          return response;
        } else {
          Helper.showSnackBarMessage(context: context, text:  AppLocalizations.of(context)?.mContentSharePageSharingError ?? '', bgColor:  AppColors.negativeLight);
          return null;
        }
      } catch (err) {
        Helper.showSnackBarMessage(context: context, text:  AppLocalizations.of(context)?.mContentSharePageSharingError ?? '', bgColor:  AppColors.negativeLight);
        return null;
      }
  }

  String _getTitle(BuildContext context, String notificationType) {
    switch (notificationType) {
      case NotificationType.inApp:  
        return AppLocalizations.of(context)!.mStaticInAppNotifications;
      case NotificationType.email:
        return AppLocalizations.of(context)!.mStaticEmailNotifications;
      case NotificationType.push:
        return AppLocalizations.of(context)!.mStaticPushNotifications;
      case NotificationType.sms:
        return AppLocalizations.of(context)!.mStaticSmsNotification;
      default:
        return '';
    }
  }

  String _getDescription(BuildContext context, String notificationType) {
    switch (notificationType) {
      case NotificationType.inApp:
        return AppLocalizations.of(context)!.mStaticKeepReceivingInAppNotification;
      case NotificationType.email:
        return AppLocalizations.of(context)!.mStaticKeepReceivingEmailNotification;
      case NotificationType.push:
        return AppLocalizations.of(context)!.mStaticKeepReceivingPushNotification;
      case NotificationType.sms:
        return AppLocalizations.of(context)!.mStaticKeepReceivingSmsNotification;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.mNotifications),
      ),
      body: FutureBuilder(
        future: _notificationSettingFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return (_isLoading)
                ? _buildSkeleton()
                : Container();
          }
          if (_notificationSettings.isEmpty) {
            return Padding(
                padding: EdgeInsets.only(left: 16, right: 16).r,
                child: _noDataFound()
            );
          } else {
            return notificationListView();
          }
        },
      )
    );
  }

  Widget notificationListView() {
    return Padding(
      padding: const EdgeInsets.all(16.0).r,
      child: Column(
        children: _notificationSettings
            .where((setting) => _getTitle(context, setting.notificationType ?? '').isNotEmpty)
            .map((setting) => Padding(
          padding: EdgeInsets.only(bottom: 16.w),
          child: NotificationSettingsCard(
            title: _getTitle(context, setting.notificationType ?? ''),
            description: _getDescription(context, setting.notificationType ?? ''),
            isEnabled: setting.enabled ?? false,
            onChanged: (value) async {
              await _updateNotificationSettings(setting);
            },
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16.0).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          settingItemSkeleton(),
          settingItemSkeleton(),
          settingItemSkeleton(),
          settingItemSkeleton(),
          settingItemSkeleton(),
        ],
      ),
    );
  }

  Widget settingItemSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(8).r,
      ),
      padding: EdgeInsets.all(16).r,
      margin: EdgeInsets.only(bottom: 16).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerSkeleton(
                height: 18.r,
                width: 0.4.sw,
                radius: 8.r,
              ),
              SizedBox(height: 6.h),
              ContainerSkeleton(
                height: 16.r,
                width: 0.6.sw,
                radius: 8.r,
              ),
            ],
          ),
          ContainerSkeleton(
            height: 20.r,
            width: 40.r,
            radius: 8.r,
          ),
        ],
      ),
    );
  }

  Widget _noDataFound() {
    return Container(
      child: NoDataWidget(
        message: AppLocalizations.of(context)!.mStaticNoSettingFound,
        maxLines: 10,
      ),
    );
  }
}
