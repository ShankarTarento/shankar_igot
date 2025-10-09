import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class EventInsightsModel {
  final MultiLingualText title;
  final String icon;
  final String key;
  final bool enabled;

  EventInsightsModel({
    required this.title,
    required this.icon,
    required this.key,
    required this.enabled,
  });

  factory EventInsightsModel.fromJson(Map<String, dynamic> json) {
    return EventInsightsModel(
      title: MultiLingualText.fromJson(json['title']),
      icon: json['icon'] ?? '',
      key: json['key'] ?? '',
      enabled: json['enabled'] ?? false,
    );
  }
}
