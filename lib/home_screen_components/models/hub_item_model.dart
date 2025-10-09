import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class HubItemModel {
  MultiLingualText title;
  MultiLingualText description;
  String imageUrl;
  String? telemetryId;
  String navigationRoute;
  bool isEnabled;
  bool isNew;
  Color? iconColor;
  Color? backgroundColor;

  HubItemModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.telemetryId,
    required this.navigationRoute,
    required this.isEnabled,
    this.isNew = false,
    this.iconColor,
    this.backgroundColor,
  });
  factory HubItemModel.fromJson(Map<String, dynamic> json) {
    return HubItemModel(
      title: MultiLingualText.fromJson(json['title']),
      description: MultiLingualText.fromJson(json['description']),
      imageUrl: json['imageUrl'],
      telemetryId: json['telemetryId'],
      navigationRoute: json['navigationRoute'],
      isEnabled: json['enabled'],
      isNew: json['isNew'] ?? false,
      backgroundColor: json['backgroundColor'] != null
          ? int.tryParse(json['backgroundColor']) != null
              ? Color(int.parse(json['backgroundColor']))
              : null
          : null,
      iconColor: json['iconColor'] != null
          ? int.tryParse(json['iconColor']) != null
              ? Color(int.parse(json['iconColor']))
              : null
          : null,
    );
  }
}
