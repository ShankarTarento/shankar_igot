import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';

class PublicProfileDashboardRepository with ChangeNotifier {
  UserConnectionStatus? userConnectionStatus;

  Future<UserConnectionStatus> getUserRelationshipStatus(String userId) async {
    try {
      final response = await ProfileService().getConnectionRelationship(userId);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final status = data['result']?['response']?['status'];

        if (status != null) {
          return updateConnectionStatus(
              mapStatusToUserConnectionStatus(status));
        }
      } else {
        debugPrint(
            "Failed to get user relationship status. Code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error getting relationship status: $e");
    }

    return updateConnectionStatus(UserConnectionStatus.Connect);
  }

  UserConnectionStatus updateConnectionStatus(UserConnectionStatus status) {
    userConnectionStatus = status;
    notifyListeners();
    return status;
  }

  static UserConnectionStatus mapStatusToUserConnectionStatus(String status) {
    if (status == UserConnectionStatus.UnBlocked.name) {
      return UserConnectionStatus.Connect;
    } else if (status == UserConnectionStatus.Approved.name) {
      return UserConnectionStatus.Approved;
    } else if (status == UserConnectionStatus.Rejected.name ||
        status == UserConnectionStatus.Withdrawn.name ||
        status == UserConnectionStatus.Removed.name) {
      return UserConnectionStatus.Connect;
    } else if (status.replaceAll(" ", "") ==
        UserConnectionStatus.BlockedOutgoing.name) {
      return UserConnectionStatus.BlockedOutgoing;
    } else if (status == UserConnectionStatus.Pending.name) {
      return UserConnectionStatus.Pending;
    } else if (status == UserConnectionStatus.Received.name) {
      return UserConnectionStatus.Received;
    } else if (status.replaceAll(" ", "") ==
        UserConnectionStatus.BlockedIncoming.name) {
      return UserConnectionStatus.BlockedIncoming;
    }

    return UserConnectionStatus.Connect;
  }
}
