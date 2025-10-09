import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';

enum LogConstants {
  EventScreenViewed('event_screen_viewed'),
  EventTokenUpdateSuccess('event_token_update_success'),
  EventTokenUpdateFailed('event_token_update_failed'),
  EventGeneric('event_generic');

  final String value;
  const LogConstants(this.value);
}

class AppLogger {
  // Singleton pattern
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  // This is used to access the logger instance throughout the app
  static AppLogger get INSTANCE => _instance;

  // Log a generic event
  Future<void> logEvent(LogConstants eventName,
      {Map<String, Object> parameters = const {}}) async {
    await FirebaseAnalytics.instance
        .logEvent(name: eventName.value, parameters: parameters);
  }

  // Log specific events for Screen Views where screenName is of type AppUrl
  void logScreenViewed(AppUrl screenName) {
    logEvent(LogConstants.EventScreenViewed,
        parameters: {'screen_name': screenName});
  }
}
