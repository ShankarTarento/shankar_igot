import 'dart:convert';

import 'package:karmayogi_mobile/models/_models/reference_nodes.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

import '../../constants/index.dart';
import '../index.dart';

class CourseHierarchyModel {
  String? source;
  String mimeType;
  List<String> leafNodes;
  String? objectType;
  String appIcon;
  List<CourseHierarchyModelChild>? children;
  String primaryCategory;
  String mimeTypesCount;
  String contentType;
  String identifier;
  List<String>? childNodes;
  bool cumulativeTracking;
  String name;
  String? status;
  String description;
  String posterImage;
  String courseCategory;
  String duration;
  int compatibilityLevel;
  int? maxUserInBatch;
  String? license;
  List<Batch>? batches;
  List<CreatorModel> authors;
  List<CreatorModel> curators;
  List<ReferenceNode>? referenceNodes;
  List keywords;
  String contextLockingType;

  CourseHierarchyModel(
      {this.source,
      required this.mimeType,
      required this.leafNodes,
      this.objectType,
      required this.appIcon,
      this.children,
      required this.primaryCategory,
      required this.mimeTypesCount,
      required this.contentType,
      required this.identifier,
      this.childNodes,
      required this.cumulativeTracking,
      required this.name,
      this.status,
      required this.description,
      required this.posterImage,
      required this.courseCategory,
      required this.duration,
      required this.compatibilityLevel,
      this.maxUserInBatch,
      this.license,
      this.batches,
      this.referenceNodes,
      required this.authors,
      required this.curators,
      required this.keywords,
      required this.contextLockingType});

  factory CourseHierarchyModel.fromJson(Map<String, dynamic> json) {
    final String courseType = getCourseCategory(json);
    return CourseHierarchyModel(
        source: json['source'],
        mimeType: json['mimeType'] ?? '',
        leafNodes: json['leafNodes'] != null
            ? List<String>.from(json['leafNodes'].map((x) => x))
            : [],
        objectType: json['objectType'],
        appIcon: json['appIcon'] ?? '',
        children: List<CourseHierarchyModelChild>.from(
            json['children'].map((x) => CourseHierarchyModelChild.fromJson(x))),
        primaryCategory: json['primaryCategory'] ?? '',
        mimeTypesCount: json['mimeTypesCount'] ?? '',
        contentType: json['contentType'] ?? '',
        identifier: json['identifier'] ?? '',
        childNodes: json['childNodes'] != null
            ? List<String>.from(json['childNodes'].map((x) => x))
            : null,
        cumulativeTracking: PrimaryCategory.programCategoriesList
            .contains(courseType.toLowerCase()),
        name: json['name'] ?? '',
        status: json['status'],
        description: json['description'] ?? '',
        posterImage: json['posterImage'] ?? '',
        courseCategory: courseType,
        duration: json['duration'] != null
            ? DateTimeHelper.getFullTimeFormat(json['duration'])
            : json['expectedDuration'] != null
                ? DateTimeHelper.getFullTimeFormat(json['expectedDuration'].toString())
                : '',
        compatibilityLevel: json['compatibilityLevel'] ?? 0,
        maxUserInBatch: json['maxUserInBatch'],
        license: json['license'],
        batches: json['batches'] != null
            ? List<Batch>.from(json['batches'].runtimeType == String
                ? jsonDecode(json['batches']).map((x) => Batch.fromJson(x))
                : json['batches'].map((x) => Batch.fromJson(x)))
            : null,
        authors: json['creatorDetails'] != null && json['creatorDetails'].isNotEmpty
            ? List<CreatorModel>.from(jsonDecode(json['creatorDetails'])
                .map((x) => CreatorModel.fromJson(x)))
            : [],
        curators:
            json['creatorContacts'] != null && json['creatorContacts'].isNotEmpty
                ? List<CreatorModel>.from(jsonDecode(json['creatorContacts'])
                    .map((x) => CreatorModel.fromJson(x)))
                : [],
        referenceNodes: json['referenceNodes'] != null
            ? List<ReferenceNode>.from(json['referenceNodes'].runtimeType == String ? jsonDecode(json['referenceNodes']).map((x) => ReferenceNode.fromJson(x)) : json['referenceNodes'].map((x) => ReferenceNode.fromJson(x)))
            : null,
        keywords: json['keywords'] ?? [],
        contextLockingType: json['contextLockingType'] ?? '');
  }
  static String getCourseCategory(Map<String, dynamic> json) {
    return json['redirectUrl'] != null
        ? 'External Course'
        : json['courseCategory'] != null
            ? json['courseCategory']
            : json['content'] != null &&
                    json['content']['courseCategory'] != null
                ? json['content']['courseCategory']
                : json['primaryCategory'] != null
                    ? json['primaryCategory']
                    : json['content'] != null &&
                            json['content']['primaryCategory'] != null
                        ? json['content']['primaryCategory']
                        : '';
  }
}

class CourseHierarchyModelChild {
  String duration;
  String? parent;
  List<PurpleChild>? children;
  String name;
  String? source;
  String identifier;
  String description;
  int compatibilityLevel;
  String primaryCategory;
  String appIcon;
  String mimeType;
  List<String> leafNodes;
  String contentType;
  String leafNodesCount;
  String courseCategory;
  List<String>? childNodes;
  int? index;
  List<String>? parentCollections;
  String artifactUrl;
  String maxQuestions;
  String mimeTypesCount;
  String? streamingUrl;
  bool? isMandatory;

  CourseHierarchyModelChild(
      {required this.duration,
      this.parent,
      this.children,
      required this.name,
      this.source,
      required this.identifier,
      required this.description,
      required this.compatibilityLevel,
      required this.primaryCategory,
      required this.appIcon,
      required this.mimeType,
      required this.leafNodes,
      required this.contentType,
      required this.leafNodesCount,
      required this.courseCategory,
      this.childNodes,
      this.index,
      this.parentCollections,
      required this.artifactUrl,
      required this.maxQuestions,
      required this.mimeTypesCount,
      this.streamingUrl,
      this.isMandatory
      });

  factory CourseHierarchyModelChild.fromJson(Map<String, dynamic> json) =>
      CourseHierarchyModelChild(
          duration: json['duration'] != null
              ? DateTimeHelper.getFullTimeFormat(json['duration'])
              : json['expectedDuration'] != null
                  ? DateTimeHelper.getFullTimeFormat(
                      json['expectedDuration'].toString())
                  : '',
          parent: json['parent'],
          children: json['children'] != null
              ? List<PurpleChild>.from(
                  json['children'].map((x) => PurpleChild.fromJson(x)))
              : null,
          name: json['name'] ?? '',
          source: json['source'],
          identifier: json['identifier'] ?? '',
          description: json['description'] ?? '',
          compatibilityLevel: json['compatibilityLevel'] ?? 0,
          primaryCategory: json['primaryCategory'] ?? '',
          appIcon: json['appIcon'] ?? '',
          mimeType: json['mimeType'] ?? '',
          leafNodes: json['leafNodes'] != null
              ? List<String>.from(json['leafNodes'].map((x) => x))
              : [],
          contentType: json['contentType'] ?? '',
          leafNodesCount: json['leafNodesCount'] != null
              ? json['leafNodesCount'].toString()
              : '',
          courseCategory: json['courseCategory'] ?? '',
          childNodes: json['childNodes'] != null
              ? List<String>.from(json['childNodes'].map((x) => x))
              : null,
          index: json['index'],
          parentCollections: json['parentCollections'] != null
              ? List<String>.from(json['parentCollections'].map((x) => x))
              : null,
          artifactUrl: json['artifactUrl'] ?? '',
          maxQuestions: json['maxQuestions'] != null
              ? json['maxQuestions'].toString()
              : '',
          mimeTypesCount: json['mimeTypesCount'] ?? '',
          streamingUrl: json['streamingUrl'],
          isMandatory: json['isMandatory'] ?? false
      );

  Map<String, dynamic> toJson() => {
        'duration': duration,
        'parent': parent,
        'children': children != null
            ? List<dynamic>.from(children!.map((x) => x.toJson()))
            : null,
        'name': name,
        'source': source,
        'identifier': identifier,
        'description': description,
        'compatibilityLevel': compatibilityLevel,
        'primaryCategory': primaryCategory,
        'appIcon': appIcon,
        'mimeType': mimeType,
        'leafNodes': leafNodes.isNotEmpty
            ? List<dynamic>.from(leafNodes.map((x) => x))
            : [],
        'contentType': contentType,
        'leafNodesCount': leafNodesCount,
        'courseCategory': courseCategory,
        'childNodes': childNodes != null
            ? List<dynamic>.from(childNodes!.map((x) => x))
            : null,
        'index': index,
        'parentCollections': parentCollections != null
            ? List<dynamic>.from(parentCollections!.map((x) => x))
            : null,
        'artifactUrl': artifactUrl,
        'maxQuestions': maxQuestions,
        'mimeTypesCount': mimeTypesCount,
        'streamingUrl': streamingUrl,
        'isMandatory': isMandatory
      };

  bool get isNotEmpty => identifier != '';
}

class PurpleChild {
  List<FluffyChild>? children;
  String name;
  String identifier;
  String description;
  int compatibilityLevel;
  String primaryCategory;
  String mimeType;
  List<String> leafNodes;
  String? status;
  String leafNodesCount;
  int? index;
  String assessmentType;
  String scoreCutoffType;
  String maxQuestions;
  int totalQuestions;
  List<String>? childNodes;
  String duration;
  String? instructions;
  String artifactUrl;
  String contentType;
  String? streamingUrl;

  PurpleChild(
      {this.children,
      required this.name,
      required this.identifier,
      required this.description,
      required this.compatibilityLevel,
      required this.primaryCategory,
      required this.mimeType,
      required this.leafNodes,
      this.status,
      required this.leafNodesCount,
      this.index,
      required this.assessmentType,
      required this.scoreCutoffType,
      required this.maxQuestions,
      required this.totalQuestions,
      this.childNodes,
      required this.duration,
      this.instructions,
      required this.artifactUrl,
      required this.contentType,
      this.streamingUrl});

  factory PurpleChild.fromJson(Map<String, dynamic> json) => PurpleChild(
      children: json['children'] != null
          ? List<FluffyChild>.from(
              json['children'].map((x) => FluffyChild.fromJson(x)))
          : null,
      name: json['name'] ?? '',
      identifier: json['identifier'] ?? '',
      description: json['description'] ?? '',
      compatibilityLevel: json['compatibilityLevel'] ?? 0,
      primaryCategory: json['primaryCategory'] ?? '',
      mimeType: json['mimeType'] ?? '',
      leafNodes: json['leafNodes'] != null
          ? List<String>.from(json['leafNodes'].map((x) => x))
          : [],
      status: json['status'],
      leafNodesCount: json['leafNodesCount'] != null
          ? json['leafNodesCount'].toString()
          : '',
      index: json['index'],
      assessmentType: json['assessmentType'] ?? '',
      scoreCutoffType: json['scoreCutoffType'] ?? '',
      maxQuestions:
          json['maxQuestions'] != null ? json['maxQuestions'].toString() : '',
      totalQuestions: json['totalQuestions'] ?? 0,
      childNodes: json['childNodes'] != null
          ? List<String>.from(json['childNodes'].map((x) => x))
          : null,
      duration: json['duration'] != null
          ? DateTimeHelper.getFullTimeFormat(json['duration'])
          : json['expectedDuration'] != null
              ? DateTimeHelper.getFullTimeFormat(json['expectedDuration'].toString())
              : '',
      instructions: json['instructions'],
      artifactUrl: json['artifactUrl'] ?? '',
      contentType: json['contentType'] ?? '',
      streamingUrl: json['streamingUrl']);

  Map<String, dynamic> toJson() {
    return {
      'children': children != null
          ? List<dynamic>.from(children!.map((x) => x.toJson()))
          : null,
      'name': name,
      'identifier': identifier,
      'description': description,
      'compatibilityLevel': compatibilityLevel,
      'primaryCategory': primaryCategory,
      'mimeType': mimeType,
      'leafNodes': leafNodes.isNotEmpty
          ? List<dynamic>.from(leafNodes.map((x) => x))
          : null,
      'status': status,
      'leafNodesCount': leafNodesCount,
      'index': index,
      'assessmentType': assessmentType,
      'scoreCutoffType': scoreCutoffType,
      'maxQuestions': maxQuestions,
      'totalQuestions': totalQuestions,
      'childNodes': childNodes != null
          ? List<dynamic>.from(childNodes!.map((x) => x))
          : null,
      'duration': duration,
      'instructions': instructions,
      'artifactUrl': artifactUrl,
      'contentType': contentType,
      'streamingUrl': streamingUrl,
    };
  }

  bool get isNotEmpty => identifier != '';
}

class FluffyChild {
  String name;
  String questionTagging;
  int noOfSection;
  String identifier;
  String description;
  int compatibilityLevel;
  String assessmentType;
  String primaryCategory;
  String? scoreCutoffType;
  String mimeType;
  String maxQuestions;
  int totalQuestions;
  String? status;
  String showMarks;
  List<String>? childNodes;
  int? index;
  String duration;
  String? instructions;
  String artifactUrl;
  String? streamingUrl;

  FluffyChild(
      {required this.name,
      required this.questionTagging,
      required this.noOfSection,
      required this.identifier,
      required this.description,
      required this.compatibilityLevel,
      required this.assessmentType,
      required this.primaryCategory,
      this.scoreCutoffType,
      required this.mimeType,
      required this.maxQuestions,
      required this.totalQuestions,
      this.status,
      required this.showMarks,
      this.childNodes,
      this.index,
      required this.duration,
      this.instructions,
      required this.artifactUrl,
      this.streamingUrl});

  factory FluffyChild.fromJson(Map<String, dynamic> json) => FluffyChild(
      name: json['name'] ?? '',
      questionTagging: json['questionTagging'] ?? '',
      noOfSection: json['noOfSection'] ?? 0,
      identifier: json['identifier'] ?? '',
      description: json['description'] ?? '',
      compatibilityLevel: json['compatibilityLevel'] ?? 0,
      assessmentType: json['assessmentType'] ?? '',
      primaryCategory: json['primaryCategory'] ?? '',
      scoreCutoffType: json['scoreCutoffType'],
      mimeType: json['mimeType'] ?? '',
      maxQuestions:
          json['maxQuestions'] != null ? json['maxQuestions'].toString() : '',
      totalQuestions: json['totalQuestions'] ?? 0,
      status: json['status'],
      showMarks: json['showMarks'] ?? 'No',
      childNodes: json['childNodes'] != null
          ? List<String>.from(json['childNodes'].map((x) => x))
          : null,
      index: json['index'],
      duration: json['duration'] != null
          ? DateTimeHelper.getFullTimeFormat(json['duration'])
          : json['expectedDuration'] != null
              ? DateTimeHelper.getFullTimeFormat(
                  json['expectedDuration'].toString())
              : '',
      instructions: json['instructions'],
      artifactUrl: json['artifactUrl'] ?? '',
      streamingUrl: json['streamingUrl']);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'questionTagging': questionTagging,
      'noOfSection': noOfSection,
      'identifier': identifier,
      'description': description,
      'compatibilityLevel': compatibilityLevel,
      'assessmentType': assessmentType,
      'primaryCategory': primaryCategory,
      'scoreCutoffType': scoreCutoffType,
      'mimeType': mimeType,
      'maxQuestions': maxQuestions,
      'totalQuestions': totalQuestions,
      'status': status,
      'showMarks': showMarks,
      'childNodes': childNodes != null
          ? List<dynamic>.from(childNodes!.map((x) => x))
          : null,
      'index': index,
      'duration': duration,
      'instructions': instructions,
      'artifactUrl': artifactUrl,
      'streamingUrl': streamingUrl,
    };
  }

  bool get isNotEmpty => identifier != '';
}
