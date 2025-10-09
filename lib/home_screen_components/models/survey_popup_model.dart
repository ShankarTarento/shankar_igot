import 'package:karmayogi_mobile/home_screen_components/models/multilingual_model.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class SurveyPopup {
  final bool enabled;
  final SurveyData data;

  SurveyPopup({
    required this.enabled,
    required this.data,
  });

  factory SurveyPopup.fromJson(Map<String, dynamic> json) {
    return SurveyPopup(
      enabled: json['enabled'],
      data: SurveyData.fromJson(json['data']),
    );
  }
}

class SurveyData {
  final MultiLingualImageUrl imageUrl;
  final MultiLingualText btnTitle;
  final String surveyUrl;

  SurveyData({
    required this.btnTitle,
    required this.imageUrl,
    required this.surveyUrl,
  });

  factory SurveyData.fromJson(Map<String, dynamic> json) {
    return SurveyData(
      imageUrl: MultiLingualImageUrl.fromJson(json['imageUrl']),
      btnTitle: MultiLingualText.fromJson(json['btnTitle']),
      surveyUrl: json['surveyUrl'],
    );
  }
}
