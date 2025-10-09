class AssessmentInfo {
  final String? name;
  final int? maxQuestions;
  final List<AssessmentChild> questions;
  final int? expectedDuration;
  final String primaryCategory;
  final String? objectType;
  final maxAssessmentRetakeAttempts;
  final String assessmentType;
  final String? description;
  final String showMarks;
  final String? errMessage;

  const AssessmentInfo(
      {this.name,
      this.maxQuestions,
      required this.questions,
      this.expectedDuration,
      required this.primaryCategory,
      this.objectType,
      this.maxAssessmentRetakeAttempts,
      required this.assessmentType,
      this.description,
      required this.showMarks,
      this.errMessage});

  factory AssessmentInfo.fromJson(Map<String, dynamic> json) {
    return AssessmentInfo(
        name: json['name'],
        maxQuestions: (json['maxQuestions'] as num?)?.toInt(),
        questions: json['children'] != null
            ? (json['children'] as List<dynamic>)
                .map((child) => AssessmentChild.fromJson(child))
                .toList()
            : [],
        expectedDuration: json["expectedDuration"] != null
            ? json["expectedDuration"].toInt()
            : 0,
        primaryCategory: json['primaryCategory'] ?? '',
        objectType: json['objectType'],
        maxAssessmentRetakeAttempts: json['maxAssessmentRetakeAttempts'],
        assessmentType: json['assessmentType'] ?? '',
        description: json['description'] ?? '',
        showMarks: json['showMarks'] ?? 'No',
        errMessage: null);
  }
}

class AssessmentChild {
  String parent;
  String identifier;
  String code;
  Map? sectionLevelDefinition;
  int maxQuestions;
  List<String> childNodes;
  int index;
  String mimeType;
  int expectedDuration;
  double minimumPassPercentage;
  String scoreCutoffType;
  String primaryCategory;
  String? contextCategory;
  String name;
  String? sectionType;
  String? additionalInstructions;
  String status;
  String? questionParagraph;
  List? childStatus;
  List? timeSpent;
  int? sectionalTimeTaken;
  bool? submitted;
  final String? objectType;

  AssessmentChild(
      {required this.parent,
      required this.identifier,
      required this.code,
      this.sectionLevelDefinition,
      required this.maxQuestions,
      required this.childNodes,
      required this.index,
      required this.mimeType,
      required this.expectedDuration,
      required this.minimumPassPercentage,
      required this.scoreCutoffType,
      required this.primaryCategory,
      this.contextCategory,
      required this.name,
      this.objectType,
      this.sectionType,
      required this.additionalInstructions,
      required this.status,
      this.questionParagraph,
      this.childStatus,
      this.timeSpent,
      this.sectionalTimeTaken,
      this.submitted});

  factory AssessmentChild.fromJson(Map<String, dynamic> json) =>
      AssessmentChild(
        parent: json["parent"],
        identifier: json["identifier"],
        code: json["code"],
        sectionLevelDefinition: json["sectionLevelDefinition"],
        maxQuestions: json["maxQuestions"].toInt(),
        childNodes: List<String>.from(json["childNodes"].map((x) => x)),
        index: json["index"] != null ? json["index"].toInt() : 0,
        mimeType: json["mimeType"],
        expectedDuration: json["expectedDuration"] != null
            ? json["expectedDuration"].toInt()
            : 0,
        minimumPassPercentage: json["minimumPassPercentage"] != null
            ? json["minimumPassPercentage"].toDouble()
            : 0,
        scoreCutoffType: json["scoreCutoffType"],
        primaryCategory: json["primaryCategory"],
        contextCategory: json["contextCategory"] ?? '',
        name: json["name"],
        sectionType: json["sectionType"],
        additionalInstructions: json["additionalInstructions"],
        status: json["status"],
        questionParagraph: json["questionParagraph"],
        childStatus: null,
        timeSpent: null,
        sectionalTimeTaken: null,
        submitted: null,
        objectType: json['objectType'],
      );
}
