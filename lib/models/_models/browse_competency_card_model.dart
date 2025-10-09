import 'package:karmayogi_mobile/util/app_config.dart';

class BrowseCompetencyCardModel {
  final String? id;
  final String name;
  final String? description;
  final String? type;
  final String competencyType;
  final String competencyArea;
  final int? count;
  final String? status;
  final String? source;
  final rawDetails;

  BrowseCompetencyCardModel({
    this.id,
    required this.name,
    this.description,
    this.type,
    required this.competencyType,
    this.count,
    required this.competencyArea,
    this.status,
    this.rawDetails,
    this.source,
  });

  factory BrowseCompetencyCardModel.fromJson(Map<String, dynamic> json) {
    return AppConfiguration().useCompetencyv6
        ? BrowseCompetencyCardModel(
            competencyArea: json['name'],
            competencyType: json['name'],
            name: 'name',
            count: json['count'],
            description: json['description'],
            id: json['identifier'],
            rawDetails: json,
            source: json['source'],
            status: json['status'],
            type: json['type'])
        : BrowseCompetencyCardModel(
            id: json['id'],
            name: json['name'] ?? "",
            type: json['type'],
            description: json['description'],
            competencyType: json['competencyType'] != null
                ? json['competencyType']
                : json['additionalProperties'] != null
                    ? json['additionalProperties']['competencyType']
                    : '',
            count: json['contentCount'],
            competencyArea: json['competencyArea'] != null
                ? json['competencyArea']
                : json['additionalProperties'] != null
                    ? json['additionalProperties']['competencyArea']
                    : '',
            status: json['status'],
            source: json['source'],
            rawDetails: json,
          );
  }
}