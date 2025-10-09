import 'package:flutter/material.dart';

class Hub {
  final int id;
  final String title;
  final String description;
  final Object icon;
  final Color iconColor;
  final bool? comingSoon;
  final String? url;
  final int? points;
  final String? svgIcon;
  final Object? svgColor;
  final bool? svg;
  final String? telemetryId;
  final String? externalUrl;
  final bool? enabled;

  const Hub(
      {required this.id,
      required this.title,
      required this.description,
      required this.icon,
      required this.iconColor,
      this.comingSoon,
      this.url,
      this.points,
      this.svgIcon,
      this.svgColor,
      this.svg,
      this.externalUrl,
      this.telemetryId,
      this.enabled});
}
