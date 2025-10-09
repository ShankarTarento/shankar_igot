import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class InformationCardModel {
  final String? backgroundColor;
  final MultiLingualText? title;
  final MultiLingualText? content;
  final MultiLingualText? btnTitle;
  final String? imageUrl;
  final String? surveyUrl;

  InformationCardModel({
    this.backgroundColor,
    this.title,
    this.content,
    this.btnTitle,
    this.imageUrl,
    this.surveyUrl,
  });

  factory InformationCardModel.fromJson(Map<String, dynamic> json) {
    return InformationCardModel(
      backgroundColor: json['backgroundColor'],
      title: MultiLingualText.fromJson(json['title']),
      content: MultiLingualText.fromJson(json['content']),
      btnTitle: MultiLingualText.fromJson(json['btnTitle']),
      imageUrl: json['imageUrl'],
      surveyUrl: json['surveyUrl'],
    );
  }
}
