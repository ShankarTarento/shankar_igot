import 'package:flutter/material.dart';

class AppNavigatorObserver extends NavigatorObserver {
  // Private static instance of the singleton
  static final AppNavigatorObserver _instance =
      AppNavigatorObserver._internal();

  // Private constructor
  AppNavigatorObserver._internal();

  /// Static getter to access the singleton instance
  static AppNavigatorObserver get instance => _instance;

  final List<Route<dynamic>> _routeHistory = [];

  /// Get route history fron the Navigator
  List<Route<dynamic>> get routeHistory => _routeHistory;

  /// Pushed a new route to Navigator
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeHistory.add(route);
    super.didPush(route, previousRoute);
  }

  /// Pop one route from Navigator
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeHistory.remove(route);
    super.didPop(route, previousRoute);
  }

  /// Remove a specific route from Navigator
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routeHistory.remove(route);
    super.didRemove(route, previousRoute);
  }

  /// Get last route pushed to Navigator
  String? getLastRouteName() {
    if (_routeHistory.isNotEmpty) {
      return _routeHistory.last.settings.name; // Get the name of the last route
    }
    return null; // Return null if there are no routes in history
  }

  /// Get route list pushed to Navigator
  List<Route<dynamic>>? getRouteList() {
    return _routeHistory;
  }
}
