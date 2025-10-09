import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class NotificationSubtypeStats {
  final int read;
  final int unread;
  final String name;
  final String id;

  NotificationSubtypeStats({
    required this.read,
    required this.unread,
    required this.name,
    required this.id,
  });

  factory NotificationSubtypeStats.fromJson(Map<String, dynamic> json) {
    try {
      final int read = json['read'] is int ? json['read'] : 0;
      final int unread = json['unread'] is int ? json['unread'] : 0;
      final String nameRaw = json['name']?.toString() ?? '';

      return NotificationSubtypeStats(
        read: read,
        unread: unread,
        name: Helper.capitalize(nameRaw) + ' (${read + unread})',
        id: nameRaw,
      );
    } catch (e, stackTrace) {
      debugPrint('Error parsing NotificationSubtypeStats: $e\n$stackTrace');

      return NotificationSubtypeStats(
        read: 0,
        unread: 0,
        name: 'Unknown (0)',
        id: '',
      );
    }
  }
}
