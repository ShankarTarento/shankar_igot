import '../../microsites/model/ati_cti_microsite_data_model.dart';
import 'mdo_announcement_section_data_model.dart';
import 'mdo_cbp_section_data_model.dart';

class MdoMainSectionDataModel {
  late TabSectionData tabSection;
  late MdoCBPSectionDataModel cbpPlanSection;
  late MdoAnnouncementSectionDataModel announcementSection;
  StateLearningWeekModel? stateLearningWeekSection;

  MdoMainSectionDataModel({
    required this.tabSection,
    required this.cbpPlanSection,
    required this.announcementSection,
    this.stateLearningWeekSection,
  });

  MdoMainSectionDataModel.fromJson(Map<String, dynamic> json) {
    tabSection = TabSectionData.fromJson(json["tabSection"]);
    cbpPlanSection = MdoCBPSectionDataModel.fromJson(json["cbpPlanSection"]);
    announcementSection =
        MdoAnnouncementSectionDataModel.fromJson(json["announcementSection"]);
    stateLearningWeekSection = json["stateLearningWeekSection"] != null
        ? StateLearningWeekModel.fromJson(json["stateLearningWeekSection"])
        : null;
  }
}

class TabSectionData {
  late List<ContentTabData> contentTab;
  late List<CoreAreaTabData> coreAreasTab;
  late List<TabData> tabs;
  late bool isDisabled;

  TabSectionData({
    required this.contentTab,
    required this.coreAreasTab,
    required this.tabs,
    this.isDisabled = false,
  });

  TabSectionData.fromJson(Map<String, dynamic> json) {
    if (json['contentTab'] != null) {
      contentTab = <ContentTabData>[];
      json['contentTab'].forEach((v) {
        contentTab.add(ContentTabData.fromJson(v));
      });
    }
    if (json['coreAreasTab'] != null) {
      coreAreasTab = <CoreAreaTabData>[];
      json['coreAreasTab'].forEach((v) {
        coreAreasTab.add(CoreAreaTabData.fromJson(v));
      });
    }
    if (json['tabs'] != null) {
      tabs = <TabData>[];
      json['tabs'].forEach((v) {
        tabs.add(TabData.fromJson(v));
      });
    }
    isDisabled = json['disable'] ?? false;
  }
}

class ContentTabData {
  late bool active;
  late bool enabled;
  String? title;
  String? key;
  int? order;
  List<ColumnData> column = [];

  ContentTabData({
    required this.active,
    required this.enabled,
    this.title,
    this.key,
    this.order,
    required this.column,
  });

  ContentTabData.fromJson(Map<String, dynamic> json) {
    active = json['active'] ?? false;
    enabled = json['enabled'] ?? false;
    title = json['title'];
    order = json['order'];
    key = json['key'];
    if (json['column'] != null) {
      column = <ColumnData>[];
      json['column'].forEach((v) {
        column.add(ColumnData.fromJson(v));
      });
    }
  }
}

class CoreAreaTabData {
  late bool active;
  late bool enabled;
  String? title;
  int? order;
  List<ColumnData> column = [];

  CoreAreaTabData({
    required this.active,
    required this.enabled,
    this.title,
    this.order,
    required this.column,
  });

  CoreAreaTabData.fromJson(Map<String, dynamic> json) {
    active = json['active'] ?? false;
    enabled = json['enabled'] ?? false;
    title = json['title'];
    order = json['order'];
    if (json['column'] != null) {
      column = <ColumnData>[];
      json['column'].forEach((v) {
        column.add(ColumnData.fromJson(v));
      });
    }
  }
}

class TabData {
  late String name;

  TabData({
    required this.name,
  });

  TabData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
}

class StateLearningWeekModel {
  final Map<String, dynamic>? keyHighlights;
  final Map<String, dynamic>? speakerOfTheDay;
  final Map<String, dynamic>? weekHighlights;
  final Map<String, dynamic>? myProgress;
  final Map<String, dynamic>? mdoLeaderboard;
  final Map<String, dynamic>? mandatoryCourse;
  final Map<String, dynamic>? exploreLearningContent;
  final Map<String, dynamic>? events;
  final Map<String, dynamic>? lookerSection;

  // Constructor
  StateLearningWeekModel({
    this.keyHighlights,
    this.speakerOfTheDay,
    this.weekHighlights,
    this.myProgress,
    this.mdoLeaderboard,
    this.mandatoryCourse,
    this.exploreLearningContent,
    this.events,
    this.lookerSection,
  });

  factory StateLearningWeekModel.fromJson(Map<String, dynamic> json) {
    return StateLearningWeekModel(
      keyHighlights: json['keyHighlights'] != null
          ? Map<String, dynamic>.from(json['keyHighlights'])
          : null,
      speakerOfTheDay: json['speakerOftheDay'] != null
          ? Map<String, dynamic>.from(json['speakerOftheDay'])
          : null,
      weekHighlights: json['weekHighlights'] != null
          ? Map<String, dynamic>.from(json['weekHighlights'])
          : null,
      myProgress: json['myprogress'] != null
          ? Map<String, dynamic>.from(json['myprogress'])
          : null,
      mdoLeaderboard: json['mdoLeaderboard'] != null
          ? Map<String, dynamic>.from(json['mdoLeaderboard'])
          : null,
      mandatoryCourse: json['mandatoryCourse'] != null
          ? Map<String, dynamic>.from(json['mandatoryCourse'])
          : null,
      exploreLearningContent: json['exploreLearningContent'] != null
          ? Map<String, dynamic>.from(json['exploreLearningContent'])
          : null,
      events: json['events'] != null
          ? Map<String, dynamic>.from(json['events'])
          : null,
      lookerSection: json['lookerSection'] != null
          ? Map<String, dynamic>.from(json['lookerSection'])
          : null,
    );
  }
}
