import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class LearningWeekModel {
  final bool enabled;
  final String startDate;
  final String endDate;
  final MultiLingualText? title;
  final MultiLingualText? description;
  final MultiLingualText? buttonText;
  final String? orgId;
  final String? orgName;

  LearningWeekModel({
    required this.enabled,
    required this.startDate,
    required this.endDate,
    this.title,
    this.description,
    this.buttonText,
    this.orgId,
    this.orgName,
  });

  factory LearningWeekModel.fromJson(Map<String, dynamic> json) {
    return LearningWeekModel(
      enabled: json['enabled'] ?? false,
      startDate: json['startDate'],
      endDate: json['endDate'],
      title: json['title'] != null
          ? MultiLingualText.fromJson(json['title'])
          : null,
      description: json['description'] != null
          ? MultiLingualText.fromJson(json['description'])
          : null,
      buttonText: json['buttonText'] != null
          ? MultiLingualText.fromJson(json['buttonText'])
          : null,
      orgId: json['orgId'],
      orgName: json['orgName'],
    );
  }
}
