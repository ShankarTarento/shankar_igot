import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class MySpaceModel {
  final String type;
  final MultiLingualText title;
  final bool enabled;
  final bool enableTheme;
  final String backgroundColor;
  final Map enrollmentApi;
  final String cbpApiUrl;
  final List<MySpaceTabItem> tabItems;

  MySpaceModel({
    required this.type,
    required this.title,
    required this.enabled,
    required this.enableTheme,
    required this.backgroundColor,
    required this.enrollmentApi,
    required this.cbpApiUrl,
    required this.tabItems,
  });

  factory MySpaceModel.fromJson(Map<String, dynamic> json) {
    return MySpaceModel(
      type: json['type'],
      title: MultiLingualText.fromJson(json['title']),
      enabled: json['enabled'],
      enableTheme: json['enableTheme'],
      backgroundColor: json['backgroundColor'],
      enrollmentApi: json['enrollmentApi'],
      cbpApiUrl: json['cbpApiUrl'],
      tabItems: (json['tabItems'] as List)
          .map((item) => MySpaceTabItem.fromJson(item))
          .toList(),
    );
  }
}

class MySpaceTabItem {
  final MultiLingualText title;
  final bool isEnabled;
  final String type;
  final List<MultiLingualText> filterItems;
  String telemetrySubType;
  String telemetryPrimaryCategory;
  String telemetryIdentifier;

  MySpaceTabItem({
    required this.title,
    required this.isEnabled,
    required this.type,
    required this.filterItems,
    required this.telemetrySubType,
    required this.telemetryIdentifier,
    required this.telemetryPrimaryCategory,
  });

  factory MySpaceTabItem.fromJson(Map<String, dynamic> json) {
    return MySpaceTabItem(
        isEnabled: json['enabled'],
        title: MultiLingualText.fromJson(json['title']),
        type: json['type'],
        filterItems: json['filterItems'] != null
            ? (json['filterItems'] as List)
                .map((item) => MultiLingualText.fromJson(item))
                .toList()
            : [],
        telemetryPrimaryCategory: json['telemetryPrimaryCategory'] ?? '',
        telemetryIdentifier: json['telemetryIdentifier'] ?? '',
        telemetrySubType: json['telemetrySubType'] ?? '');
  }
}
