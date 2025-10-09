import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class ContentStripModel {
  MultiLingualText? title;
  MultiLingualText? toolTipMessage;
  bool enabled;
  bool filterWithDate;
  bool showNoResourceFound;
  Map<String, dynamic>? request;
  String apiUrl;
  String telemetrySubType;
  String telemetryPrimaryCategory;
  String telemetryIdentifier;
  String requestType;

  ContentStripModel({
    this.title,
    this.toolTipMessage,
    required this.enabled,
    this.request,
    required this.apiUrl,
    required this.showNoResourceFound,
    required this.telemetrySubType,
    required this.telemetryIdentifier,
    required this.filterWithDate,
    required this.telemetryPrimaryCategory,
    this.requestType = "POST",
  });

  factory ContentStripModel.fromMap(Map<String, dynamic> map) {
    return ContentStripModel(
      title:
          map['title'] != null ? MultiLingualText.fromJson(map['title']) : null,
      toolTipMessage: map['toolTipMessage'] != null
          ? MultiLingualText.fromJson(map['toolTipMessage'])
          : null,
      enabled: map['enabled'] ?? false,
      request: Map<String, dynamic>.from(map['request'] ?? {}),
      apiUrl: map['apiUrl'],
      telemetryPrimaryCategory: map['telemetryPrimaryCategory'] ?? "",
      telemetrySubType: map['telemetrySubType'] ?? "",
      telemetryIdentifier: map['telemetryIdentifier'] ?? "",
      showNoResourceFound: map['showNoResourceFound'] ?? true,
      filterWithDate: map['filterWithDate'] ?? false,
      requestType: map['requestType'] ?? "POST",
    );
  }
}
