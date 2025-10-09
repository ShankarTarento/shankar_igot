class AtiCtiMicroSitesFormDataModel {
  final String rootOrgId;
  final AtiCtiMicroSitesDataModel? data;

  AtiCtiMicroSitesFormDataModel({
    required this.rootOrgId,
    this.data,
  });

  factory AtiCtiMicroSitesFormDataModel.fromJson(Map<String, dynamic> json) {
    return AtiCtiMicroSitesFormDataModel(
      rootOrgId: json['rootOrgId'] ?? '',
      data: AtiCtiMicroSitesDataModel.fromJson(json['data'])
    );
  }
}

class AtiCtiMicroSitesDataModel {
  List<SectionListModel>? sectionList;

  AtiCtiMicroSitesDataModel({
    this.sectionList,
  });

  AtiCtiMicroSitesDataModel.fromJson(Map<String, dynamic> json) {
    if (json['sectionList'] != null) {
      sectionList = <SectionListModel>[];
      json['sectionList'].forEach((v) {
        sectionList!.add(SectionListModel.fromJson(v));
      });
    }
  }
}

class SectionListModel {
  bool? active;
  bool? enabled;
  bool? navigation;
  String? title;
  String? key;
  int? order;
  int? navOrder;
  List<ColumnData> column = [];

  SectionListModel({
    this.active,
    this.enabled,
    this.navigation,
    this.title,
    this.key,
    this.order,
    this.navOrder,
    required this.column,
  });

  SectionListModel.fromJson(Map<String, dynamic> json) {
    active = json['active'] ?? false;
    enabled = json['enabled'] ?? false;
    navigation = json['navigation'] ?? false;
    title = json['title'] ?? '';
    key = json['key'] ?? '';
    order = json['order'] ?? 0;
    navOrder = json['navOrder'] ?? 0;
    if (json['column'] != null) {
      column = <ColumnData>[];
      json['column'].forEach((v) {
        column.add(ColumnData.fromJson(v));
      });
    }
  }
}

class ColumnData {
  final bool? active;
  final bool enabled;
  final String? key;
  final String title;
  final String? background;
  final dynamic data;

  ColumnData({
    this.active,
    required this.enabled,
    required this.key,
    required this.title,
    required this.background,
    required this.data,
  });

  factory ColumnData.fromJson(Map<String, dynamic> json) {
    return ColumnData(
      active: json['active'] ?? false,
      enabled: json['enabled'] ?? false,
      key: json['key'] ?? '',
      title: json['title'] ?? '',
      background: json['background'] ?? '',
      data: json['data'] ?? {},
    );
  }
}
