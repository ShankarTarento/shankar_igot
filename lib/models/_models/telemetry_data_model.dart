class TelemetryDataModel {
  String id;
  String? contentType;
  String? subType;
  String? clickId;
  String? pageId;
  String? objectType;

  TelemetryDataModel(
      {required this.id,
      this.contentType,
      this.subType,
      this.clickId,
      this.pageId,
      this.objectType});

  factory TelemetryDataModel.fromJson(Map<String, dynamic> json) =>
      TelemetryDataModel(
          id: json['id'] ?? '',
          contentType: json['contentType'],
          subType: json['subType'],
          clickId: json['clickId'],
          pageId: json['pageId'],
          objectType: json['objectType']);
}
