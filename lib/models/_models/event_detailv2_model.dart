import 'dart:convert';

import 'package:karmayogi_mobile/models/index.dart';

import '../../ui/widgets/_events/models/event_batch_model.dart';

class EventDetailV2 {
  String? createdByName;
  String? cqfVersion;
  String endDate;
  bool? isMetaEditingDisabled;
  String? channel;
  String? publishedOn;
  List<String>? language;
  String? mimeType;
  String? objectType;
  String? createrEmail;
  String? eventIcon;
  String? streamType;
  List<Speaker>? speakers;
  String? contentEncoding;
  String? contentType;
  Trackable? trackable;
  String identifier;
  List<String>? audience;
  bool? isExternal;
  String? visibility;
  String? consumerId;
  //String? eventType;
  String? osId;
  List<String>? languageCode;
  int? version;
  String? categoryType;
  String name;
  String startDate;
  String? status;
  String? code;
  String? description;
  String? submitedOn;
  String? locale;
  String? createdOn;
  bool? isContentEditingDisabled;
  bool? authoringDisabled;
  int? duration;
  dynamic creatorDetails;
  String? expiryDate;
  List<EventHandout>? eventHandouts;
  String? registrationEndDate;
  String? contentDisposition;
  String? lastUpdatedOn;
  String startTime;
  String? owner;
  String? lastStatusChangedOn;
  List<String>? createdFor;
  String? versionKey;
  String? registrationLink;
  String? createdBy;
  int? leafNodesCount;
  String? learningObjective;
  String? source;
  String endTime;
  String? category;
  String? resourceType;
  List<EventBatchModel>? batches;
  List<CompetencyPassbook>? competencyV6;
  List<dynamic>? recordedLinks;
  String? instructions;

  EventDetailV2({
    this.createdByName,
    this.cqfVersion,
    required this.endDate,
    this.isMetaEditingDisabled,
    this.channel,
    this.publishedOn,
    this.language,
    this.mimeType,
    this.objectType,
    this.createrEmail,
    this.eventIcon,
    this.streamType,
    this.speakers,
    this.contentEncoding,
    this.contentType,
    this.trackable,
    required this.identifier,
    this.audience,
    this.isExternal,
    this.visibility,
    this.consumerId,
    // this.eventType,
    this.osId,
    this.languageCode,
    this.version,
    this.categoryType,
    required this.name,
    required this.startDate,
    this.status,
    this.code,
    this.description,
    this.submitedOn,
    this.locale,
    this.createdOn,
    this.isContentEditingDisabled,
    this.authoringDisabled,
    this.duration,
    this.creatorDetails,
    this.expiryDate,
    this.eventHandouts,
    this.registrationEndDate,
    this.contentDisposition,
    this.lastUpdatedOn,
    required this.startTime,
    this.owner,
    this.lastStatusChangedOn,
    this.createdFor,
    this.versionKey,
    this.registrationLink,
    this.createdBy,
    this.leafNodesCount,
    this.learningObjective,
    this.source,
    required this.endTime,
    this.category,
    this.resourceType,
    this.batches,
    this.competencyV6,
    this.recordedLinks,
    this.instructions,
  });

  factory EventDetailV2.fromJson(Map<String, dynamic> json) {
    List<CompetencyPassbook> parseCompetencies(Map<String, dynamic> json) {
      List<CompetencyPassbook> competencies = [];

      if (json['identifier'] == null) {
        return competencies;
      }
      if (json["competencies_v6"] != null) {
        if (json['competencies_v6'].runtimeType == String) {
          json['competencies_v6'] = jsonDecode(json['competencies_v6']);
        }
        for (var x in json["competencies_v6"]) {
          competencies.add(CompetencyPassbook.fromJson(
            json: x,
            courseId: json['identifier'],
            useCompetencyv6: true,
          ));
        }
      }
      return competencies;
    }

    return EventDetailV2(
      createdByName: json['createdByName'],
      cqfVersion: json['cqfVersion'],
      endDate: json['endDate'],
      isMetaEditingDisabled: json['isMetaEditingDisabled'],
      channel: json['channel'],
      publishedOn: json['publishedOn'],
      language:
          json['language'] != null ? List<String>.from(json['language']) : null,
      mimeType: json['mimeType'],
      objectType: json['objectType'],
      createrEmail: json['createrEmail'],
      eventIcon: json['appIcon'],
      streamType: json['streamType'],
      speakers: json['speakers'] != null
          ? List<Speaker>.from(json['speakers'].map((x) => Speaker.fromJson(x)))
          : null,
      contentEncoding: json['contentEncoding'],
      contentType: json['contentType'],
      trackable: json['trackable'] != null
          ? Trackable.fromJson(json['trackable'])
          : null,
      identifier: json['identifier'],
      audience:
          json['audience'] != null ? List<String>.from(json['audience']) : null,
      isExternal: json['isExternal'],
      visibility: json['visibility'],
      consumerId: json['consumerId'],
      //eventType: json['eventType'],
      osId: json['osId'],
      languageCode: json['languageCode'] != null
          ? List<String>.from(json['languageCode'])
          : null,
      version: json['version'],
      categoryType: json['categoryType'],
      name: json['name'],
      startDate: json['startDate'],
      status: json['status'],
      code: json['code'],
      description: json['description'],
      submitedOn: json['submitedOn'],
      locale: json['locale'],
      createdOn: json['createdOn'],
      isContentEditingDisabled: json['isContentEditingDisabled'],
      authoringDisabled: json['authoringDisabled'],
      duration: json['duration'],
      creatorDetails:
          (json['creatorDetails'] != null && json['creatorDetails'].isNotEmpty)
              ? jsonDecode(json['creatorDetails'])
              : [],
      expiryDate: json['expiryDate'],
      eventHandouts: json['eventHandouts'] != null
          ? List<EventHandout>.from(
              json['eventHandouts'].map((x) => EventHandout.fromJson(x)))
          : null,
      registrationEndDate: json['registrationEndDate'],
      contentDisposition: json['contentDisposition'],
      lastUpdatedOn: json['lastUpdatedOn'],
      startTime: json['startTime'],
      owner: json['owner'],
      lastStatusChangedOn: json['lastStatusChangedOn'],
      createdFor: json['createdFor'] != null
          ? List<String>.from(json['createdFor'])
          : null,
      versionKey: json['versionKey'],
      registrationLink: json['registrationLink'],
      createdBy: json['createdBy'],
      leafNodesCount: json['leafNodesCount'],
      learningObjective: json['learningObjective'],
      source: json['sourceName'],
      endTime: json['endTime'],
      category: json['category'],
      resourceType: json['resourceType'],
      recordedLinks: json['recordedLinks'],
      instructions: json['instructions'] != null ? json['instructions'] : '',
      batches: parseBatches(json['batches']),
      competencyV6: parseCompetencies(json),
    );
  }
}

class EventHandoutsModel {
  final String title;
  final String content;

  EventHandoutsModel({
    required this.title,
    required this.content,
  });

  factory EventHandoutsModel.fromJson(Map<String, dynamic> json) {
    return EventHandoutsModel(
      title: json['title'],
      content: json['content'],
    );
  }
}

List<EventBatchModel> parseBatches(dynamic batchesResponse) {
  try {
    if (batchesResponse is String) {
      final decoded = json.decode(batchesResponse);
      if (decoded is List) {
        return decoded
            .map((batchJson) => EventBatchModel.fromJson(batchJson))
            .toList();
      }
    } else if (batchesResponse is List) {
      return batchesResponse
          .map((batchJson) => EventBatchModel.fromJson(batchJson))
          .toList();
    }
  } catch (e) {
    print("Error parsing batches: $e");
  }
  return [];
}

class Speaker {
  String? email;
  String? name;
  String? description;

  Speaker({this.email, this.name, this.description});

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      email: json['email'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class Trackable {
  String? enabled;
  String? autoBatch;

  Trackable({this.enabled, this.autoBatch});

  factory Trackable.fromJson(Map<String, dynamic> json) {
    return Trackable(
      enabled: json['enabled'],
      autoBatch: json['autoBatch'],
    );
  }
}

class EventHandout {
  String? title;
  String? content;

  EventHandout({this.title, this.content});

  factory EventHandout.fromJson(Map<String, dynamic> json) {
    return EventHandout(
      title: json['title'],
      content: json['content'],
    );
  }
}
