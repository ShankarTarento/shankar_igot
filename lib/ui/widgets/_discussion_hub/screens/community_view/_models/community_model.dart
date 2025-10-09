
class CommunityModel {
  List<CommunityItemData>? data;
  final Facets? facets;
  int? totalCount;
  List<AdditionalInfo>? additionalInfo;

  CommunityModel({this.data, this.facets, this.totalCount, this.additionalInfo});

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => CommunityItemData.fromJson(item))
          .toList(),
      facets: (json['facets'] is Map<String, dynamic> && json['facets'].isNotEmpty)
          ? Facets.fromJson(json['facets'])
          : null,
      totalCount: json['totalCount'] as int?,
      additionalInfo: (json['additionalInfo'] as List<dynamic>?)
          ?.map((item) => AdditionalInfo.fromJson(item))
          .toList(),
    );
  }
}

class CommunityItemData {
  final String? createdByUserId;
  final String? communityAccessLevel;
  final String? description;
  final String? communityTagId;
  final String? updatedOn;
  final String? updatedByUserId;
  final int? countOfPeopleJoined;
  final int? countOfPostCreated;
  final String? orgId;
  final String? orgName;
  final String? orgLogo;
  final int? countOfPeopleLiked;
  final List<String>? tags;
  final int? topicId;
  final String? topicName;
  final String? communityName;
  final String? communityId;
  final String? status;
  final String? imageUrl;
  final String? posterImageUrl;
  final String? communityGuideLines;
  bool? isUserJoined;

  CommunityItemData({
    this.createdByUserId,
    this.communityAccessLevel,
    this.description,
    this.communityTagId,
    this.updatedOn,
    this.updatedByUserId,
    this.countOfPeopleJoined,
    this.countOfPostCreated,
    this.orgId,
    this.orgName,
    this.orgLogo,
    this.countOfPeopleLiked,
    this.tags,
    this.topicId,
    this.topicName,
    this.communityName,
    this.communityId,
    this.status,
    this.imageUrl,
    this.posterImageUrl,
    this.communityGuideLines,
    this.isUserJoined,
  });

  factory CommunityItemData.fromJson(Map<String, dynamic> json) {
    return CommunityItemData(
      createdByUserId: json['createdByUserId'] as String?,
      communityAccessLevel: json['communityAccessLevel'] as String?,
      description: json['description'] as String?,
      communityTagId: json['communityTagId'] as String?,
      updatedOn: json['updatedOn'] as String?,
      updatedByUserId: json['updatedByUserId'] as String?,
      countOfPeopleJoined: json['countOfPeopleJoined'] as int?,
      countOfPostCreated: json['countOfPostCreated'] as int?,
      orgId: json['orgId'] ?? "",
      orgName: json['orgName'] ?? "",
      orgLogo: json['orgLogo'] ?? "",
      countOfPeopleLiked: json['countOfPeopleLiked'] as int?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'])
          : [],
      topicId: json['topicId'] as int?,
      topicName: json['topicName'] as String?,
      communityName: json['communityName'] as String?,
      communityId: json['communityId'] as String?,
      status: json['status'] as String?,
      imageUrl: json['imageUrl'] as String?,
      posterImageUrl: json['posterImageUrl'] ?? '',
      communityGuideLines: json['communityGuideLines'] ?? '',
      isUserJoined: json['isUserJoined'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdByUserId': createdByUserId,
      'communityAccessLevel': communityAccessLevel,
      'description': description,
      'communityTagId': communityTagId,
      'updatedOn': updatedOn,
      'updatedByUserId': updatedByUserId,
      'countOfPeopleJoined': countOfPeopleJoined,
      'countOfPostCreated': countOfPostCreated,
      'orgId': orgId,
      'countOfPeopleLiked': countOfPeopleLiked,
      'tags': tags,
      'topicId': topicId,
      'topicName': topicName,
      'communityName': communityName,
      'communityId': communityId,
      'status': status,
      'imageUrl': imageUrl,
      'posterImageUrl': posterImageUrl,
      'communityGuideLines': communityGuideLines,
      'isUserJoined': isUserJoined,
    };
  }
}

class Facets {
  final List<TopicFacet>? topicName;

  Facets({this.topicName});

  factory Facets.fromJson(Map<String, dynamic> json) {
    return Facets(
      topicName: json['topicName'] != null
          ? List<TopicFacet>.from(json['topicName'].map((x) => TopicFacet.fromJson(x)))
          : null,
    );
  }
}

class TopicFacet {
  final String? value;
  final int? count;

  TopicFacet({this.value, this.count});

  factory TopicFacet.fromJson(Map<String, dynamic> json) {
    return TopicFacet(
      value: json['value'],
      count: json['count'],
    );
  }
}

class AdditionalInfo {
  final String? orgname;
  final String? logo;
  final String? id;

  AdditionalInfo({this.orgname, this.logo, this.id});

  factory AdditionalInfo.fromJson(Map<String, dynamic> json) {
    return AdditionalInfo(
      orgname: json['orgname'] ?? "",
      logo: json['logo'] ?? "",
      id: json['id'] ?? "",
    );
  }
}


