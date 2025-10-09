import 'package:karmayogi_mobile/ui/pages/_pages/toc/model/progress_model.dart';

class NavigationModel {
  int index;
  String? moduleName;
  String? mimeType;
  String identifier;
  String? name;
  String? parent;
  String parentCourseId;
  String? artifactUrl;
  String? contentId;
  String currentProgress;
  double completionPercentage;
  int status;
  String? moduleDuration;
  String? courseDuration;
  String? duration;
  String? parentBatchId;
  String primaryCategory;
  String? maxQuestions;
  String language;
  int? compatibilityLevel;
  String? courseName;
  String? streamingUrl;
  int spentTime;
  String? initFile;
  bool isLocked;
  bool? isMandatory;

  NavigationModel(
      {required this.index,
      this.moduleName,
      this.mimeType,
      required this.identifier,
      this.name,
      this.parent,
      required this.parentCourseId,
      this.artifactUrl,
      this.contentId,
      required this.currentProgress,
      required this.completionPercentage,
      required this.status,
      this.moduleDuration,
      this.duration,
      this.parentBatchId,
      required this.primaryCategory,
      this.maxQuestions,
      required this.language,
      this.compatibilityLevel,
      this.courseName,
      this.courseDuration,
      this.streamingUrl,
      required this.spentTime,
      this.initFile,
      required this.isLocked,
      this.isMandatory});

  factory NavigationModel.fromJson(Map<String, dynamic> json,
          {required int index,
          int? childIndex,
          String? parentBatchId,
          bool hasChildren = false,
          String? courseName,
          bool isCourse = false,
          String? parentCourseId,
          ProgressModel? progress,
          bool? isLocked,
          bool? isMandatory,
          String? language}) =>
      NavigationModel(
          index: index,
          moduleName: isCourse ? null : json['name'],
          mimeType: hasChildren
              ? json['children']![childIndex]['mimeType']
              : json['mimeType'],
          identifier: hasChildren
              ? json['children']![childIndex]['identifier']
              : json['identifier'],
          name: hasChildren
              ? json['children']![childIndex]['name']
              : json['name'],
          parent: json['parent'],
          parentCourseId:
              parentCourseId ?? json['parent'] ?? json['identifier'],
          artifactUrl: hasChildren
              ? json['children']![childIndex]['artifactUrl']
              : json['artifactUrl'],
          contentId: hasChildren
              ? json['children']![childIndex]['identifier']
              : json['identifier'],
          currentProgress: progress != null ? progress.currentProgress : '0',
          completionPercentage:
              progress != null ? progress.completionPercentage : 0,
          status: progress != null ? progress.status : 0,
          moduleDuration: !isCourse ? json['duration'] : null,
          duration: hasChildren
              ? json['children']![childIndex]['duration']
              : json['duration'],
          parentBatchId: parentBatchId,
          primaryCategory: hasChildren
              ? json['children']![childIndex]['primaryCategory']
              : json['primaryCategory'] ?? '',
          maxQuestions: hasChildren
              ? json['children']![childIndex]['maxQuestions'].toString()
              : json['maxQuestions'].toString(),
          language: language ?? '',
          compatibilityLevel: hasChildren
              ? json['children']![childIndex]['compatibilityLevel']
              : json['compatibilityLevel'],
          courseName: courseName,
          courseDuration: json['duration'],
          streamingUrl: hasChildren
              ? json['children']![childIndex]['streamingUrl']
              : null,
          spentTime: progress != null ? progress.spentTime : 0,
          initFile:
              hasChildren ? json['children']![childIndex]['initFile'] : null,
          isLocked: isLocked ?? false,
          isMandatory: isMandatory);

  NavigationModel copy({
    int? index,
    String? moduleName,
    String? mimeType,
    String? identifier,
    String? name,
    String? parent,
    String? parentCourseId,
    String? artifactUrl,
    String? contentId,
    String? currentProgress,
    double? completionPercentage,
    int? status,
    String? moduleDuration,
    String? courseDuration,
    String? duration,
    String? parentBatchId,
    String? primaryCategory,
    String? maxQuestions,
    String? language,
    int? compatibilityLevel,
    String? courseName,
    String? streamingUrl,
    int? spentTime,
    String? initFile,
    bool? isLocked,
  }) {
    return NavigationModel(
      index: index ?? this.index,
      moduleName: moduleName ?? this.moduleName,
      mimeType: mimeType ?? this.mimeType,
      identifier: identifier ?? this.identifier,
      name: name ?? this.name,
      parent: parent ?? this.parent,
      parentCourseId: parentCourseId ?? this.parentCourseId,
      artifactUrl: artifactUrl ?? this.artifactUrl,
      contentId: contentId ?? this.contentId,
      currentProgress: currentProgress ?? this.currentProgress,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      status: status ?? this.status,
      moduleDuration: moduleDuration ?? this.moduleDuration,
      courseDuration: courseDuration ?? this.courseDuration,
      duration: duration ?? this.duration,
      parentBatchId: parentBatchId ?? this.parentBatchId,
      primaryCategory: primaryCategory ?? this.primaryCategory,
      maxQuestions: maxQuestions ?? this.maxQuestions,
      language: language ?? this.language,
      compatibilityLevel: compatibilityLevel ?? this.compatibilityLevel,
      courseName: courseName ?? this.courseName,
      streamingUrl: streamingUrl ?? this.streamingUrl,
      spentTime: spentTime ?? this.spentTime,
      initFile: initFile ?? this.initFile,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
