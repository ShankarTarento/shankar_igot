import 'dart:convert';

import 'package:karmayogi_mobile/models/_models/competency_passbook_model.dart';
import 'package:karmayogi_mobile/util/app_config.dart';

class CommunityDetailModel {
  final String? communityName;
  final String? description;
  final String? communityAccessLevel;
  final String? orgId;
  final List<String>? tags;
  final String? topicName;
  final int? countOfPeopleJoined;
  final int? countOfPeopleLiked;
  final String? communityTagId;
  final String? posterImageUrl;
  final String? imageUrl;
  final int? topicId;
  final String? communityGuideLines;
  final int? countOfPostCreated;
  final int? countOfAnswerPost;
  final String? createdByUserId;
  final String? updatedByUserId;
  final String? communityId;
  final String? status;
  bool? isUserJoinedCommunity;
  final List<CompetencyPassbook>? competenciesV5;

  CommunityDetailModel({
    this.communityName,
    this.description,
    this.communityAccessLevel,
    this.orgId,
    this.tags,
    this.topicName,
    this.countOfPeopleJoined,
    this.countOfPeopleLiked,
    this.communityTagId,
    this.posterImageUrl,
    this.imageUrl,
    this.topicId,
    this.communityGuideLines,
    this.countOfPostCreated,
    this.countOfAnswerPost,
    this.createdByUserId,
    this.updatedByUserId,
    this.communityId,
    this.status,
    this.isUserJoinedCommunity,
    this.competenciesV5,
  });

  factory CommunityDetailModel.fromJson(Map<String, dynamic> json) {
    List<CompetencyPassbook> parseCompetencies(Map<String, dynamic> json) {
      List<CompetencyPassbook> competencies = [];

      if (json['communityId'] == null) {
        return competencies;
      }
      if (AppConfiguration().useCompetencyv6 &&
          json["competencies_v6"] != null) {
        if (json['competencies_v6'].runtimeType == String) {
          json['competencies_v6'] = jsonDecode(json['competencies_v6']);
        }
        for (var x in json["competencies_v6"]) {
          competencies.add(CompetencyPassbook.fromJson(
            json: x,
            courseId: json['communityId'],
            useCompetencyv6: true,
          ));
        }
      } else if (json["competencies_v5"] != null) {
        for (var x in json["competencies_v5"]) {
          competencies.add(CompetencyPassbook.fromJson(
            json: x,
            courseId: json['communityId'],
            useCompetencyv6: false,
          ));
        }
      }

      return competencies;
    }

    return CommunityDetailModel(
      communityName: json['communityName'] as String?,
      description: json['description'] as String?,
      communityAccessLevel: json['communityAccessLevel'] as String?,
      orgId: json['orgId'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      topicName: json['topicName'] as String?,
      countOfPeopleJoined: json['countOfPeopleJoined'] as int?,
      countOfPeopleLiked: json['countOfPeopleLiked'] as int?,
      communityTagId: json['communityTagId'] as String?,
      posterImageUrl: json['posterImageUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      topicId: json['topicId'] as int?,
      communityGuideLines: json['communityGuideLines'] as String?,
      countOfPostCreated: json['countOfPostCreated'] as int?,
      countOfAnswerPost: json['countOfAnswerPost'] as int?,
      createdByUserId: json['createdByUserId'] as String?,
      updatedByUserId: json['updatedByUserId'] as String?,
      communityId: json['communityId'] as String?,
      status: json['status'] as String?,
      isUserJoinedCommunity: json['isUserJoinedCommunity'] ?? false,
      competenciesV5: parseCompetencies(json),
    );
  }
}