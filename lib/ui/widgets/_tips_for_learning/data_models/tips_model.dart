import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class TipsModel {
  MultiLingualText tip;
  final String id;
  final String imagePath;

  TipsModel({
    required this.tip,
    required this.id,
    required this.imagePath,
  });

  factory TipsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TipsModel(
      tip: MultiLingualText.fromJson(json['tip']),
      id: json['id'].toString(),
      imagePath: json['imagePath'] ?? '',
    );
  }
}
