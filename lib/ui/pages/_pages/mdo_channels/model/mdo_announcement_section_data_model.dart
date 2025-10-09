class MdoAnnouncementSectionDataModel {
  bool isDisabled;
  AnnouncementDataModel? data;

  MdoAnnouncementSectionDataModel({this.data, this.isDisabled = false});

  factory MdoAnnouncementSectionDataModel.fromJson(Map<String, dynamic> json) {
    return MdoAnnouncementSectionDataModel(
      data: json['data'] != null
          ? AnnouncementDataModel.fromJson(json['data'])
          : null,
      isDisabled: json['disable'] ?? false,
    );
  }
}

class AnnouncementDataModel {
  String? title;
  String? logoUrl;
  String? mobileIcon;
  int? maxCount;
  AnnouncementHeaderData? header;
  late List<AnnouncementListItemData> list;

  AnnouncementDataModel({
    this.title,
    this.logoUrl,
    this.mobileIcon,
    this.maxCount,
    this.header,
    required this.list,
  });

  AnnouncementDataModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    logoUrl = json['logoUrl'];
    mobileIcon = json['mobileIcon'];
    maxCount = json['maxCount'];
    header = AnnouncementHeaderData.fromJson(json["header"]);
    if (json['list'] != null) {
      list = <AnnouncementListItemData>[];
      json['list'].forEach((v) {
        list.add(AnnouncementListItemData.fromJson(v));
      });
    }
  }
}

class AnnouncementListItemData {
  String? description;

  AnnouncementListItemData({
    this.description,
  });

  AnnouncementListItemData.fromJson(Map<String, dynamic> json) {
    description = json['description'];
  }
}

class AnnouncementHeaderData {
  String? background;
  String? color;

  AnnouncementHeaderData({
    this.background,
    this.color,
  });

  AnnouncementHeaderData.fromJson(Map<String, dynamic> json) {
    background = json['background'];
    color = json['color'];
  }
}
