import 'package:flutter/material.dart';

class BottomBarModel {
  final Widget widget;
  final String route;

  BottomBarModel({
    required this.widget,
    required this.route,
  });

  BottomBarModel copyWith({
    Widget? widget,
    String? route,
    bool? isActive,
  }) {
    return BottomBarModel(
      widget: widget ?? this.widget,
      route: route ?? this.route,
    );
  }
}
