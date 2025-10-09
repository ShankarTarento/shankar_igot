import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class LearnTabModel {
  final MultiLingualText title;
  final String type;
  final bool enabled;
  final List<TabItems> tabItems;

  LearnTabModel({
    required this.title,
    required this.type,
    required this.enabled,
    required this.tabItems,
  });

  // Factory constructor for LearnTabModel from JSON
  factory LearnTabModel.fromJson(Map<String, dynamic> json) {
    return LearnTabModel(
      title: MultiLingualText.fromJson(json['title']),
      type: json['type'],
      enabled: json['enabled'],
      tabItems: json['tabItems'] != null
          ? (json['tabItems'] as List)
              .map((item) => TabItems.fromJson(item))
              .toList()
          : [],
    );
  }
}

class TabItems {
  MultiLingualText title;
  String type;
  bool isEnabled;
  List<FilterItems>? filterItems;
  ContentStripModel? courseStripData;
  ContinueLearningModel? continueLearningModel;
  String telemetrySubType;
  String telemetryPrimaryCategory;
  String telemetryIdentifier;

  TabItems({
    required this.title,
    required this.type,
    required this.isEnabled,
    this.courseStripData,
    this.filterItems,
    this.continueLearningModel,
    required this.telemetrySubType,
    required this.telemetryIdentifier,
    required this.telemetryPrimaryCategory,
  });

  // Factory constructor for TabItems from JSON
  factory TabItems.fromJson(Map<String, dynamic> json) {
    return TabItems(
        title: MultiLingualText.fromJson(json['title']),
        type: json['type'],
        courseStripData: json['type'] == WidgetConstants.courseStrip ||
                json['type'] == WidgetConstants.providers ||
                json['type'] == WidgetConstants.trainingInstitutes
            ? ContentStripModel.fromMap(json)
            : null,
        filterItems: json['filterItems'] != null &&
                    json['type'] == WidgetConstants.pills ||
                json['type'] == WidgetConstants.dropdown
            ? (json['filterItems'] as List)
                .map((item) => FilterItems.fromJson(item))
                .toList()
            : null,
        continueLearningModel:
            json['type'] == WidgetConstants.myLearningEvents ||
                    json['type'] == WidgetConstants.myLearningCourses ||
                    json['type'] == WidgetConstants.cbpCourses
                ? ContinueLearningModel.fromJson(json)
                : null,
        isEnabled: json['enabled'],
        telemetryPrimaryCategory: json['telemetryPrimaryCategory'] ?? '',
        telemetryIdentifier: json['telemetryIdentifier'] ?? '',
        telemetrySubType: json['telemetrySubType'] ?? '');
  }
}

class FilterItems {
  final MultiLingualText filterTitle;
  final ContentStripModel courseStrip;

  FilterItems({
    required this.filterTitle,
    required this.courseStrip,
  });

  // Factory constructor for FilterItems from JSON
  factory FilterItems.fromJson(Map<String, dynamic> json) {
    return FilterItems(
        filterTitle: MultiLingualText.fromJson(json['title']),
        courseStrip: ContentStripModel.fromMap(json['data']));
  }
}

class ContinueLearningModel {
  final Map<String, dynamic>? enrollmentApi;
  final List<MultiLingualText> filterItems;

  ContinueLearningModel({required this.filterItems, this.enrollmentApi});

  factory ContinueLearningModel.fromJson(Map<String, dynamic> json) {
    return ContinueLearningModel(
        enrollmentApi: json['enrollmentApi'],
        filterItems: json['filterItems'] != null
            ? (json['filterItems'] as List)
                .map((item) => MultiLingualText.fromJson(item))
                .toList()
            : []);
  }
}
