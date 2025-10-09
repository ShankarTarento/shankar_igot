import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class NetworkHubHelper {
  static String getRequestCreatedTime({required String createdAt}) {
    try {
      final DateFormat format = DateFormat("EEE MMM dd HH:mm:ss 'UTC' yyyy");
      final DateTime parsedDate = format.parseUtc(createdAt);

      Duration difference = DateTime.now().toUtc().difference(parsedDate);

      if (difference.inDays > 0) {
        return '${difference.inDays} d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} m';
      } else if (difference.inSeconds > 0) {
        return '${difference.inSeconds} s';
      } else {
        return 'Just now';
      }
    } catch (e) {
      debugPrint('Invalid date format: $createdAt');
      return '';
    }
  }
}
