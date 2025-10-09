import 'dart:convert';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_sector_model.dart';
import 'package:karmayogi_mobile/models/_models/reference_nodes.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../ui/pages/_pages/toc/model/language_map_model.dart';
import '../index.dart';

class Course {
  final String id;
  final String appIcon;
  final String name;
  final String description;
  final String? duration;
  final String? programDuration;
  final double rating;
  final String creatorIcon;
  final String creatorLogo;
  final String source;
  final int? completedOn;
  final List additionalTags;
  final List<CompetencyPassbook>? competenciesV5;
  String? endDate;
  String? startDate;
  final List<dynamic>? createdFor;
  final String? isVerifiedKarmayogi;
  AssesmentBatch? assesmentBatch;
  final raw;
  int? completionPercentage;
  final String courseCategory;
  final String primaryCategory;
  final bool cumulativeTracking;
  final List leafNodes;
  final String? learningMode;
  final String instructions;
  late List<Batch>? batches;
  final String wfSurveyLink;
  final String? lastUpdatedOn;
  final String? createdOn;
  List issuedCertificates;
  String? batchId;
  final String contentId;
  final Batch? batch;
  final String? lastReadContentId;
  final String? redirectUrl;
  final bool isExternalCourse;
  final String? objectives;
  final String? externalId;
  final String? recent_language;
  ContentPartner? contentPartner;
  final String status;
  bool? isRelevant;
  final String licence;
  final String language;
  final int compatibilityLevel;
  final List<SectorDetails> sectorDetails;
  final LanguageMapV1 languageMap;
  CourseHierarchyModel? preEnrolmentResources;
  List<ReferenceNode>? referenceNodes;
  bool isApar = false;
  final String contextLockingType;

  Course(
      {required this.id,
      required this.appIcon,
      required this.name,
      required this.description,
      required this.duration,
      required this.programDuration,
      this.completionPercentage,
      required this.creatorIcon,
      required this.rating,
      required this.creatorLogo,
      required this.source,
      required this.additionalTags,
      this.competenciesV5,
      this.endDate,
      this.startDate,
      this.createdFor,
      this.raw,
      this.completedOn,
      this.assesmentBatch,
      this.isVerifiedKarmayogi,
      required this.courseCategory,
      required this.primaryCategory,
      required this.cumulativeTracking,
      required this.leafNodes,
      this.learningMode,
      required this.instructions,
      this.batches,
      required this.wfSurveyLink,
      this.lastUpdatedOn,
      this.createdOn,
      required this.issuedCertificates,
      this.batchId,
      required this.contentId,
      this.batch,
      this.lastReadContentId,
      this.redirectUrl,
      required this.isExternalCourse,
      this.objectives,
      this.externalId,
      this.recent_language,
      this.contentPartner,
      required this.status,
      this.isRelevant,
      required this.licence,
      required this.language,
      required this.compatibilityLevel,
      required this.sectorDetails,
      required this.languageMap,
      this.preEnrolmentResources,
      this.referenceNodes,
      // required this.isApar,
      required this.contextLockingType});

  factory Course.fromJson(Map<String, dynamic> json, {String? endDate}) {
    List<CompetencyPassbook> parseCompetencies(Map<String, dynamic> json) {
      List<CompetencyPassbook> competencies = [];

      if (json['identifier'] == null) {
        return competencies;
      }
      if (AppConfiguration().useCompetencyv6 &&
          json['competencies_v6'] != null) {
        if (json['competencies_v6'].runtimeType == String) {
          json['competencies_v6'] = jsonDecode(json['competencies_v6']);
        }
        for (var x in json['competencies_v6']) {
          competencies.add(CompetencyPassbook.fromJson(
            json: x,
            courseId: json['identifier'],
            useCompetencyv6: true,
          ));
        }
      } else if (json['competencies_v5'] != null) {
        for (var x in json['competencies_v5']) {
          competencies.add(CompetencyPassbook.fromJson(
            json: x,
            courseId: json['identifier'],
            useCompetencyv6: false,
          ));
        }
      }

      return competencies;
    }

    final String courseType = getCourseCategory(json);

    return Course(
      id: json['identifier'] != null
          ? json['identifier']
          : json['content'] != null && json['content']!['identifier'] != null
              ? json['content']!['identifier']
              : json['courseId'] != null
                  ? json['courseId']
                  : '',
      appIcon: json['posterImage'] != null
          ? Helper.convertToPortalUrl(json['posterImage'])
          : json['content'] != null && json['content']['posterImage'] != null
              ? Helper.convertToPortalUrl(json['content']['posterImage'])
              : (json['appIcon'] != null ? json['appIcon'] : ''),
      name: json['name'] ?? json['courseName'] ?? json['content']['name'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] != null
          ? json['duration'].toString()
          : ((json['content'] != null && json['content']['duration'] != null)
              ? json['content']['duration']
              : null),
      programDuration: json['programDuration'] != null
          ? json['programDuration'].toString()
          : null,
      rating: json['avgRating'] != null ? json['avgRating'].toDouble() : 0.0,
      creatorIcon: json['creatorIcon'] ?? '',
      creatorLogo: json['creatorLogo'] != null
          ? Helper.convertToPortalUrl(json['creatorLogo'])
          :json['content'] != null &&
                  json['content']['creatorLogo'] != null
              ? Helper.convertImageUrl(json['content']['creatorLogo'])
          : (json['contentPartner'] != null &&
                  json['contentPartner']['link'] != null
              ? json['contentPartner']['link']
              : ''),
      source: json['source'] != null
          ? json['source'].toString()
          : ((json['content'] != null &&
                  json['content']['organisation'] != null)
              ? json['content']['organisation'].first
              : (json['organisation'] != null &&
                      json['organisation'].isNotEmpty)
                  ? json['organisation'].first
                  : ((json['contentPartner'] != null &&
                          json['contentPartner']['contentPartnerName'] != null)
                      ? json['contentPartner']['contentPartnerName']
                      : 'Karmayogi Bharat')) as String,
      additionalTags: json['additionalTags'] ?? [],
      competenciesV5: parseCompetencies(json),
      endDate: endDate != null
          ? endDate
          : json['endDate'] != null
              ? json['endDate']
              : null,
      startDate: json['startDate'] != null ? json['startDate'] : null,
      createdFor: json['createdFor'] != null ? json['createdFor'] : null,
      completedOn: json['completedOn'] != null ? json['completedOn'] : null,
      completionPercentage: json['completionPercentage'] != null
          ? json['completionPercentage']
          : null,
      isVerifiedKarmayogi: json['secureSettings'] != null
          ? json['secureSettings']['isVerifiedKarmayogi']
          : null,
      courseCategory: courseType,
      primaryCategory: json['primaryCategory'] != null
          ? json['primaryCategory']
          : json['content'] != null && json['content']['primaryCategory'] != null
              ? json['content']['primaryCategory']
              : '',
      cumulativeTracking: PrimaryCategory.programCategoriesList
          .contains(courseType.toLowerCase()),
      leafNodes: json['leafNodes'] ?? [],
      learningMode: json['learningMode'],
      instructions: json['instructions'] ?? '',
      batches: json['batches'] != null
          ? List<Batch>.from(json['batches'].map((x) => Batch.fromJson(x)))
          : json['content'] != null && json['content']['batches'] != null
              ? List<Batch>.from(
                  json['content']['batches'].map((x) => Batch.fromJson(x)))
              : null,
      wfSurveyLink: json['wfSurveyLink'] ?? '',
      lastUpdatedOn: json['lastUpdatedOn'],
      createdOn: json['createdOn'],
      issuedCertificates: json['issuedCertificates'] ?? [],
      batchId: json['batchId'],
      contentId: json['contentId'] ?? '',
      batch: json['batch'] != null ? Batch.fromJson(json['batch']) : null,
      lastReadContentId: json['lastReadContentId'],
      redirectUrl: json['redirectUrl'],
      isExternalCourse: json['redirectUrl'] != null ? true : false,
      objectives: json['objectives'],
      externalId: json['externalId'],
      recent_language: json['recent_language'],
      raw: json,
      contentPartner: (json['contentPartner'] != null)
          ? ContentPartner.fromJson(json['contentPartner'])
          : null,
      status: json['status'].toString(),
      licence: (json['content'] != null && json['content']['license'] != null)
          ? json['content']['license']
          : '',
      language: json['language'] != null && json['language'].isNotEmpty
          ? json['language'].first
          : '',
      compatibilityLevel: json['compatibilityLevel']??0,
      sectorDetails: json['sectorDetails_v1'] != null
          ? List<SectorDetails>.from(json['sectorDetails_v1']
              .map((x) => SectorDetails.fromJson(x))).toList()
          : [],
      languageMap:
          json['content'] != null && json['content']['languageMapV1'] != null
              ? LanguageMapV1.fromJson(json['content']['languageMapV1'])
              : LanguageMapV1.fromJson(json['languageMapV1']),
      preEnrolmentResources: (json['preEnrolmentResources'] != null)
          ? CourseHierarchyModel.fromJson(
              {'children': json['preEnrolmentResources']})
          : null,
      referenceNodes: json['referenceNodes'] != null
          ? List<ReferenceNode>.from(json['referenceNodes'].runtimeType ==
                  String
              ? jsonDecode(json['referenceNodes'])
                  .map((x) => ReferenceNode.fromJson(x))
              : json['referenceNodes'].map((x) => ReferenceNode.fromJson(x)))
          : null,
      // isApar: json['isApar'] ?? false,
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

  List<AssesmentBatch> getBatches() {
    List data = raw['batches'];
    List<AssesmentBatch> batches = [];

    for (var i in data) {
      batches.add(AssesmentBatch.fromJson(i));
    }

    return batches;
  }

  bool get isNotEmpty => id != '';
}

class AssesmentBatch {
  String? identifier;
  dynamic batchAttributes;
  String? endDate;
  String? createdBy;
  String? name;
  String? batchId;
  String? enrollmentType;
  String? startDate;
  int? status;
  List createdFor;
  String? startTime;
  String? endTime;

  AssesmentBatch(
      {this.identifier,
      this.batchAttributes,
      this.endDate,
      this.createdBy,
      this.name,
      this.batchId,
      this.enrollmentType,
      this.startDate,
      this.status,
      this.startTime,
      this.endTime,
      required this.createdFor});

  factory AssesmentBatch.fromJson(Map<String, dynamic> json) {
    return AssesmentBatch(
        identifier: json['identifier'],
        batchAttributes: json['batchAttributes'],
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate']).toLocal().toString()
            : null,
        createdBy: json['createdBy'],
        name: json['name'],
        batchId: json['batchId'],
        enrollmentType: json['enrollmentType'],
        createdFor: json['createdFor'] ?? [],
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate']).toLocal().toString()
            : null,
        status: json['status'],
        startTime: json['startTime'] ?? '',
        endTime: json['endTime'] ?? '');
  }
}

class ContentPartner {
  String? id;
  String? link;
  String? partnerCode;
  String? contentPartnerName;

  ContentPartner({
    this.id,
    this.link,
    this.partnerCode,
    this.contentPartnerName,
  });

  factory ContentPartner.fromJson(Map<String, dynamic> json) {
    return ContentPartner(
      id: json['id'],
      link: json['link'],
      partnerCode: json['partnerCode'],
      contentPartnerName: json['contentPartnerName'] ?? '',
    );
  }
}
