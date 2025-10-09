import '../../../../../models/_models/assessment_info_model.dart';

class AssessmentResponseDataModel {
  final List<dynamic> questionSet;
  final AssessmentInfo? assessmentInfo;
  final Map<String, dynamic>? retakeInfo;
  final dynamic assessmentResponse;

  AssessmentResponseDataModel(
      {required this.questionSet,
      this.assessmentInfo,
      this.retakeInfo,
      this.assessmentResponse});

  factory AssessmentResponseDataModel.fromJson(Map<String, dynamic> json) {
    return AssessmentResponseDataModel(
        assessmentInfo: AssessmentInfo.fromJson(json['assessmentInfo']),
        questionSet: json['questionSet'] ?? [],
        retakeInfo: json['retakeInfo'],
        assessmentResponse: json['assessmentResponse']);
  }
}
