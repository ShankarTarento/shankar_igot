
class MicroSiteInsightsDataModel {
  late List<MicroSiteInsightsData> data;

  MicroSiteInsightsDataModel(
      {required this.data,});

  MicroSiteInsightsDataModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <MicroSiteInsightsData>[];
      json['data'].forEach((v) {
        data.add(MicroSiteInsightsData.fromJson(v));
      });
    }
  }
}

class MicroSiteInsightsData {
  String? icon;
  String? iconColor;
  String? value;
  String? valueColor;
  String? valueColorV2;
  String? valueColorMobV2;
  String? label;
  String? labelColor;
  String? labelColorV2;
  String? background;
  String? backgroundV2;
  String? iconBackgroupColorV2;

  MicroSiteInsightsData({
    this.icon,
    this.iconColor,
    this.value,
    this.valueColor,
    this.valueColorV2,
    this.valueColorMobV2,
    this.label,
    this.labelColor,
    this.labelColorV2,
    this.background,
    this.backgroundV2,
    this.iconBackgroupColorV2,
  });

  factory MicroSiteInsightsData.fromJson(Map<String, dynamic> json) {
    return MicroSiteInsightsData(
      icon: json['icon'],
      iconColor: json['iconColor'],
      value: json['value'],
      valueColor: json['valueColor'],
      valueColorV2: json['valueColorV2'],
      valueColorMobV2: json['valueColorMobV2'],
      label: json['label'],
      labelColor: json['labelColor'],
      labelColorV2: json['labelColorV2'],
      background: json['background'],
      backgroundV2: json['backgroundV2'],
      iconBackgroupColorV2: json['iconBackgroupColorV2'],
    );
  }
}