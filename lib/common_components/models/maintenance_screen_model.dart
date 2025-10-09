import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class ServerUnderMaintenance {
  final bool enabled;
  final MultiLingualText greet;
  final MultiLingualText title;
  final MultiLingualText subTitle;
  final MultiLingualText description;
  final MultiLingualText? thumbnailTitle;
  final List<Thumbnail>? thumbnails;

  ServerUnderMaintenance({
    required this.enabled,
    required this.greet,
    required this.title,
    required this.subTitle,
    required this.description,
    this.thumbnailTitle,
    this.thumbnails,
  });

  factory ServerUnderMaintenance.fromJson(Map<String, dynamic> json) {
    return ServerUnderMaintenance(
      enabled: json['enabled'],
      greet: MultiLingualText.fromJson(json['greet']),
      title: MultiLingualText.fromJson(json['title']),
      subTitle: MultiLingualText.fromJson(json['subTitle']),
      description: MultiLingualText.fromJson(json['description']),
      thumbnailTitle: MultiLingualText.fromJson(json['thumbnailTitle']),
      thumbnails: (json['thumbnails'] as List)
          .map((thumbnailJson) => Thumbnail.fromJson(thumbnailJson))
          .toList(),
    );
  }
}

class Thumbnail {
  final String image;
  final String redirectionUrl;
  final MultiLingualText title;

  Thumbnail({
    required this.image,
    required this.redirectionUrl,
    required this.title,
  });

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      image: json['image'],
      redirectionUrl: json['redirectionUrl'],
      title: MultiLingualText.fromJson(json['title']),
    );
  }
}
