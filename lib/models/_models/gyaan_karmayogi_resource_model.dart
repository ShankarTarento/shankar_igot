import 'package:karmayogi_mobile/models/_models/gyaan_sector_model.dart';

class GyaanKarmayogiResource {
  List<String>? ownershipType;
  String? previewUrl;
  List<CreatorContact>? creatorContacts;
  String? channel;
  List<String>? organisation;
  List<String>? language;
  String? source;
  late String mimeType;
  String? objectType;
  String? primaryCategory;
  String? contentEncoding;
  String? artifactUrl;
  String? contentType;
  Trackable? trackable;
  late String identifier;
  List<String>? audience;
  bool? isExternal;
  String? visibility;
  String? consumerId;
  DiscussionForum? discussionForum;
  String? mediaType;
  String? osId;
  String? graphId;
  String? nodeType;
  String? lastPublishedBy;
  int? version;
  String? license;
  String? prevState;
  String? lastPublishedOn;
  String? iLFuncObjectType;
  String? name;
  String? status;
  String? code;
  Credentials? credentials;
  String? prevStatus;
  String? description;
  String? streamingUrl;
  String? posterImage;
  String? idealScreenSize;
  String? createdOn;
  String? duration;
  String? contentDisposition;
  String? lastUpdatedOn;
  String? dialcodeRequired;
  List<String>? os;
  String? iLSysNodeType;
  List<String>? seFWIds;
  String? resourceCategory;
  int? pkgVersion;
  String? versionKey;
  String? idealScreenDensity;
  String? framework;
  String? createdBy;
  int? compatibilityLevel;
  String? contentUrl;
  String? iLUniqueId;
  int? maxUserInBatch;
  int? nodeId;
  List<SectorDetails>? sector;
  String? subSector;
  String? resourceType;

  GyaanKarmayogiResource({
    this.ownershipType,
    this.previewUrl,
    this.creatorContacts,
    this.channel,
    this.organisation,
    this.language,
    this.source,
    required this.mimeType,
    this.objectType,
    this.primaryCategory,
    this.contentEncoding,
    this.artifactUrl,
    this.contentType,
    this.trackable,
    required this.identifier,
    this.audience,
    this.isExternal,
    this.visibility,
    this.consumerId,
    this.discussionForum,
    this.mediaType,
    this.osId,
    this.graphId,
    this.nodeType,
    this.lastPublishedBy,
    this.version,
    this.license,
    this.prevState,
    this.lastPublishedOn,
    this.iLFuncObjectType,
    this.name,
    this.status,
    this.code,
    this.credentials,
    this.prevStatus,
    this.description,
    this.streamingUrl,
    this.posterImage,
    this.idealScreenSize,
    this.createdOn,
    this.duration,
    this.contentDisposition,
    this.lastUpdatedOn,
    this.dialcodeRequired,
    this.os,
    this.iLSysNodeType,
    this.seFWIds,
    this.resourceCategory,
    this.pkgVersion,
    this.versionKey,
    this.idealScreenDensity,
    this.framework,
    this.createdBy,
    this.compatibilityLevel,
    this.contentUrl,
    this.iLUniqueId,
    this.maxUserInBatch,
    this.nodeId,
    this.sector,
    this.subSector,
    this.resourceType,
  });

  GyaanKarmayogiResource.fromJson(Map<String, dynamic> json) {
    ownershipType = List<String>.from(json['ownershipType']);

    previewUrl = json['previewUrl'];

    channel = json['channel'];
    organisation = List<String>.from(json['organisation']);
    language = List<String>.from(json['language']);
    source = json['source'];
    mimeType = json['mimeType'];
    objectType = json['objectType'];
    primaryCategory = json['primaryCategory'];
    contentEncoding = json['contentEncoding'];
    artifactUrl = json['artifactUrl'];
    contentType = json['contentType'];
    trackable = json['trackable'] != null
        ? Trackable.fromJson(json['trackable'])
        : null;
    identifier = json['identifier'];
    audience = List<String>.from(json['audience']);
    isExternal = json['isExternal'];
    visibility = json['visibility'];
    consumerId = json['consumerId'];
    discussionForum = json['discussionForum'] != null
        ? DiscussionForum.fromJson(json['discussionForum'])
        : null;
    mediaType = json['mediaType'];
    osId = json['osId'];
    graphId = json['graph_id'];
    nodeType = json['nodeType'];
    lastPublishedBy = json['lastPublishedBy'];
    version = json['version'];
    license = json['license'];
    prevState = json['prevState'];
    lastPublishedOn = json['lastPublishedOn'];
    iLFuncObjectType = json['IL_FUNC_OBJECT_TYPE'];
    name = json['name'];
    status = json['status'];
    code = json['code'];
    credentials = json['credentials'] != null
        ? Credentials.fromJson(json['credentials'])
        : null;
    prevStatus = json['prevStatus'];
    description = json['description'];
    streamingUrl = json['streamingUrl'];
    posterImage = json['posterImage'];
    idealScreenSize = json['idealScreenSize'];
    createdOn = json['createdOn'];
    duration = json['duration'];
    contentDisposition = json['contentDisposition'];
    lastUpdatedOn = json['lastUpdatedOn'];
    dialcodeRequired = json['dialcodeRequired'];
    os = json['0s'] != null ? List<String>.from(json['0s']) : null;
    iLSysNodeType = json['IL_SYS_NODE_TYPE'];
    seFWIds =
        json['se_FWIds'] != null ? List<String>.from(json['se_FWIds']) : null;
    resourceCategory = json['resourceCategory'];
    pkgVersion = json['pkgVersion'];
    versionKey = json['versionKey'];
    idealScreenDensity = json['idealScreenDensity'];
    framework = json['framework'];
    createdBy = json['createdBy'];
    compatibilityLevel = json['compatibilityLevel'];
    contentUrl = json['content_url'];
    iLUniqueId = json['IL_UNIQUE_ID'];
    maxUserInBatch = json['maxUserInBatch'];
    nodeId = json['node_id'];
    sector = json['sectorDetails_v1'] != null
        ? (json['sectorDetails_v1'] as List)
            .map((item) => SectorDetails.fromJson(item))
            .toList()
        : null;
    subSector = json['subSectorName'];
    resourceType = json['resourceType'];
  }
}

class CreatorContact {
  String? id;
  String? name;
  String? email;

  CreatorContact({this.id, this.name, this.email});

  CreatorContact.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }
}

class Trackable {
  String? enabled;
  String? autoBatch;

  Trackable({this.enabled, this.autoBatch});

  Trackable.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
    autoBatch = json['autoBatch'];
  }
}

class DiscussionForum {
  String? enabled;

  DiscussionForum({this.enabled});

  DiscussionForum.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
  }
}

class Credentials {
  String? enabled;

  Credentials({this.enabled});

  Credentials.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
  }
}
