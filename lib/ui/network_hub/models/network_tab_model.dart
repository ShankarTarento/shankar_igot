import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkTabModel {
  final UserConnectionStatus id;
  final String title;
  final int? count;

  NetworkTabModel({
    required this.id,
    required this.title,
    this.count,
  });
}

List<NetworkTabModel> getConnectionTabs({required BuildContext context}) {
  return [
    NetworkTabModel(
        id: UserConnectionStatus.Approved,
        title: AppLocalizations.of(context)!.mMyConnections),
    NetworkTabModel(
        id: UserConnectionStatus.Received,
        title: AppLocalizations.of(context)!.mStaticRequests),
    NetworkTabModel(
        id: UserConnectionStatus.Pending,
        title: AppLocalizations.of(context)!.mSent),
    NetworkTabModel(
        id: UserConnectionStatus.BlockedOutgoing,
        title: AppLocalizations.of(context)!.mBlocked),
  ];
}

List<NetworkTabModel> getConnectionTabsV2({
  required BuildContext context,
  List<dynamic>? values,
}) {
  final statusMap = <String, UserConnectionStatus>{
    'Approved': UserConnectionStatus.Approved,
    'Received': UserConnectionStatus.Received,
    'Requested': UserConnectionStatus.Pending,
    'Blocked Outgoing': UserConnectionStatus.BlockedOutgoing,
  };

  final counts = <UserConnectionStatus, int>{};
  if (values != null) {
    for (var item in values) {
      final status = statusMap[item['name']];
      final count = item['count'];
      if (status != null && count is int) {
        counts[status] = count;
      }
    }
  }

  return [
    NetworkTabModel(
      id: UserConnectionStatus.Approved,
      title: AppLocalizations.of(context)!.mMyConnections,
      count: counts[UserConnectionStatus.Approved],
    ),
    NetworkTabModel(
      id: UserConnectionStatus.Received,
      title: AppLocalizations.of(context)!.mStaticRequests,
      count: counts[UserConnectionStatus.Received],
    ),
    NetworkTabModel(
      id: UserConnectionStatus.Pending,
      title: AppLocalizations.of(context)!.mSent,
      count: counts[UserConnectionStatus.Pending],
    ),
    NetworkTabModel(
      id: UserConnectionStatus.BlockedOutgoing,
      title: AppLocalizations.of(context)!.mBlocked,
      count: counts[UserConnectionStatus.BlockedOutgoing],
    ),
  ];
}
