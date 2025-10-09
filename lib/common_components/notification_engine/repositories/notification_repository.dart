import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/services/http_service.dart';
import 'package:http/http.dart' as Http;
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_model.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_stats.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class NotificationRepository {
  final _storage = FlutterSecureStorage();

  static List<NotificationSubtypeStats> _notificationsStats = [];

  static List<NotificationSubtypeStats> get notificationsStats =>
      _notificationsStats;

  // static int? _cachedUnreadCount;
  static final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0);

  Future<int> getUnreadNotificationCount(/*{bool forceRefresh = false}*/) async {

    // if (!forceRefresh && _cachedUnreadCount != null) {
    //   unreadCountNotifier.value = _cachedUnreadCount!;
    //   return _cachedUnreadCount!;
    // }

    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);
      String? deptId = await _storage.read(key: Storage.deptId);

      if (token == null || wid == null || deptId == null) {
        throw Exception('Missing required authentication details');
      }

      Http.Response response = await HttpService.get(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.notificationUnReadCount),
        headers: NetworkHelper.postHeaders(token, wid, deptId),
      );

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        int count = data['result']?['unread'] ?? 0;
        // _cachedUnreadCount = count;
        unreadCountNotifier.value = count;
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      debugPrint('Error in getUnreadNotificationCount: $e');
      return 0;
    }
  }

  Future<List<NotificationSubtypeStats>> getNotificationCount() async {
    _notificationsStats = [];
    _notificationsStats.add(
      NotificationSubtypeStats(
        read: 0,
        unread: 0,
        name: 'All',
        id: 'ALL',
      ),
    );
    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);
      String? deptId = await _storage.read(key: Storage.deptId);

      if (token == null || wid == null || deptId == null) {
        throw Exception('Missing required authentication details');
      }

      Http.Response response = await HttpService.get(
        apiUri: Uri.parse(
            ApiUrl.baseUrl + ApiUrl.getNotifications + "?page=0&size=0"),
        headers: NetworkHelper.postHeaders(token, wid, deptId),
      );

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        List rawData = data['result']['subtypeStats'] ?? [];

        for (var notification in rawData) {
          try {
            _notificationsStats.add(
              NotificationSubtypeStats.fromJson(
                  notification as Map<String, dynamic>),
            );
          } catch (e) {
            debugPrint('Error parsing notification: $e');
          }
        }
        return _notificationsStats;
      } else {
        throw Exception(
            'Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getNotifications: $e');
      return [];
    }
  }

  Future<List<NotificationModel>> getNotifications(
      {required int page, required int size, String? subtype}) async {
    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);
      String? deptId = await _storage.read(key: Storage.deptId);

      if (token == null || wid == null || deptId == null) {
        throw Exception('Missing required authentication details');
      }

      String apiUrl = ApiUrl.getNotifications +
          '?page=$page&size=$size&sub_type=${subtype ?? ""}';

      Http.Response response = await HttpService.get(
        apiUri: Uri.parse(ApiUrl.baseUrl + apiUrl),
        headers: NetworkHelper.postHeaders(token, wid, deptId),
      );

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        List rawData = data['result']['notifications'] ?? [];

        List<NotificationModel> notifications = [];

        for (var notification in rawData) {
          try {
            notifications.add(
              NotificationModel.fromJson(notification as Map<String, dynamic>),
            );
          } catch (e) {
            debugPrint('Error parsing notification: $e');
          }
        }
        return notifications;
      } else {
        throw Exception(
            'Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in getNotifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead({
    required String type,
    List<String>? notificationIds,
  }) async {
    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);
      String? deptId = await _storage.read(key: Storage.deptId);

      if (token == null || wid == null || deptId == null) {
        throw Exception('Missing required authentication details');
      }

      Map<String, dynamic> requestBody = {
        "type": type,
        if (notificationIds != null) "ids": notificationIds,
      };

      final body = jsonEncode({"request": requestBody});

      Http.Response response = await Http.patch(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.markNotificationAsRead),
        headers: NetworkHelper.postHeaders(token, wid, deptId),
        body: body,
      );

      if (response.statusCode == 200) {
        // var responseBody = jsonDecode(response.body);
        debugPrint("----Notification marked as read-----");
      } else {
        throw Exception(
            'Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in markNotificationAsRead: $e');
      throw e;
    }
  }

  Future<void> resetNotificationCount() async {
    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);
      String? deptId = await _storage.read(key: Storage.deptId);

      if (token == null || wid == null || deptId == null) {
        throw Exception('Missing required authentication details');
      }

      Http.Response response = await HttpService.get(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.resetNotificationCount),
        headers: NetworkHelper.postHeaders(token, wid, deptId),
      );

      if (response.statusCode == 200) {
        // _cachedUnreadCount = 0;
        unreadCountNotifier.value = 0;
        debugPrint("----unread notification count reset to 0-----");
      } else {
        throw Exception(
            'Failed to mark all notifications as read: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in markAllNotificationsAsRead: $e');
      throw e;
    }
  }

  Future<List<NotificationSettingModel>> getNotificationSettings() async {
    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);
      String? deptId = await _storage.read(key: Storage.deptId);

      if (token == null || wid == null || deptId == null) {
        throw Exception('Missing required authentication details');
      }

      Http.Response response = await HttpService.get(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.notificationSettingRead),
        headers: NetworkHelper.postHeaders(token, wid, deptId),
      );

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        List<NotificationSettingModel> notificationSettings = [];
        if (data['result']['settings'] is List) {
          notificationSettings = (data['result']['settings'] as List)
              .map((item) => NotificationSettingModel.fromJson(item))
              .toList();
        }
        return notificationSettings;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool?> updateNotificationSettings(
      String notificationType, bool isEnabled) async {
    try {
      String? token = await _storage.read(key: Storage.authToken);
      String? wid = await _storage.read(key: Storage.wid);
      String? deptId = await _storage.read(key: Storage.deptId);

      if (token == null || wid == null || deptId == null) {
        throw Exception('Missing required authentication details');
      }

      Map<String, dynamic> data = {
        "request": {"notificationType": notificationType, "enabled": isEnabled}
      };

      Http.Response response = await HttpService.post(
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.notificationSettingUpdate),
        body: data,
        headers: NetworkHelper.postHeaders(token, wid, deptId),
      );

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        if (data['result']['enabled'] is bool) {
          return (data['result']['enabled'] as bool);
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
