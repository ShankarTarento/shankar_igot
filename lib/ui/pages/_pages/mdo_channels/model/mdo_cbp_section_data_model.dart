class MdoCBPSectionDataModel {
  CBPSectionData? data;

  MdoCBPSectionDataModel(
      { this.data,
      });

  MdoCBPSectionDataModel.fromJson(Map<String, dynamic>? json) {
    if (json != null && json.containsKey('data')) {
      data = CBPSectionData.fromJson(json['data']);
    }
  }
}

class CBPSectionData {
  String? title;
  String? panelborder;
  String? panelBackground;
  CBPColorConfig? header;
  CBPItemColorConfig? listItem;
  List<CBPListData>? list;

  CBPSectionData(
      {
        this.title,
        this.panelborder,
        this.panelBackground,
        this.header,
        this.listItem,
        this.list,
      });

  CBPSectionData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    panelborder = json['panelborder'];
    panelBackground = json['panelBackground'];
    header = CBPColorConfig.fromJson(json['header']);
    listItem = CBPItemColorConfig.fromJson(json['listItem']);
    if (json['list'] != null) {
      list = <CBPListData>[];
      json['list'].forEach((v) {
        list?.add(CBPListData.fromJson(v));
      });
    }
  }
}

class CBPListData {
  String? title;
  String? downloadUrl;

  CBPListData({
    this.title,
    this.downloadUrl,
  });

  CBPListData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    downloadUrl = json['downloaUrl'];
  }
}

class CBPColorConfig {
  String? background;
  String? color;

  CBPColorConfig({
    this.background,
    this.color,
  });

  CBPColorConfig.fromJson(Map<String, dynamic> json) {
    background = json['background'];
    color = json['color'];
  }
}

class CBPItemColorConfig {
  String? background;
  String? border;

  CBPItemColorConfig({
    this.background,
    this.border,
  });

  CBPItemColorConfig.fromJson(Map<String, dynamic> json) {
    background = json['background'];
    border = json['border'];
  }
}
