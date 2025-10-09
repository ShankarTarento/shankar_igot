import 'package:karmayogi_mobile/models/_models/gyaan_sector_model.dart';

class ResourceDetails {
  String? instructions;
  String? previewUrl;
  List<String>? organisation;
  List<String>? language;
  String? source;
  String? mimeType;
  String? appIcon;
  String? primaryCategory;
  String? artifactUrl;
  String? contentType;
  String? identifier;
  bool? isExternal;
  List<String>? languageCode;
  String? lastPublishedOn;
  String? name;
  String? status;
  String? description;
  String? posterImage;
  String? createdOn;
  String? duration;
  String? lastUpdatedOn;
  List<String>? createdFor;
  String? resourceCategory;
  String? createdBy;
  int? compatibilityLevel;
  List<SectorDetails>? sectors;

  ResourceDetails({
    this.instructions,
    this.previewUrl,
    this.organisation,
    this.language,
    this.source,
    this.mimeType,
    this.appIcon,
    this.primaryCategory,
    this.artifactUrl,
    this.contentType,
    this.identifier,
    this.isExternal,
    this.languageCode,
    this.lastPublishedOn,
    this.name,
    this.status,
    this.description,
    this.posterImage,
    this.createdOn,
    this.duration,
    this.lastUpdatedOn,
    this.createdFor,
    this.resourceCategory,
    this.createdBy,
    this.compatibilityLevel,
    this.sectors,
  });

  ResourceDetails.fromJson(Map<String, dynamic> json) {
    instructions = json['instructions'];
    previewUrl = json['previewUrl'];
    organisation = json['organisation']?.cast<String>();
    language = json['language']?.cast<String>();
    source = json['source'];
    mimeType = json['mimeType'];
    appIcon = json['appIcon'];
    primaryCategory = json['primaryCategory'];
    artifactUrl = json['artifactUrl'];
    contentType = json['contentType'];
    identifier = json['identifier'];
    isExternal = json['isExternal'];
    languageCode = json['languageCode']?.cast<String>();
    lastPublishedOn = json['lastPublishedOn'];
    name = json['name'];
    status = json['status'];
    description = json['description'];
    posterImage = json['posterImage'];
    createdOn = json['createdOn'];
    duration = json['duration'];
    lastUpdatedOn = json['lastUpdatedOn'];
    createdFor =
        json['createdFor'] != null ? json['createdFor'].cast<String>() : null;
    resourceCategory = json['resourceCategory'];
    createdBy = json['createdBy'];
    compatibilityLevel = json['compatibilityLevel'];
    sectors = json['sectorDetails_v1'] != null
        ? (json['sectorDetails_v1'] as List)
            .map((item) => SectorDetails.fromJson(item))
            .toList()
        : null;
  }
}
