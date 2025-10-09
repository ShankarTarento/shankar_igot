class TranscriptionResponse {
  final String courseId;
  final String resourceId;
  final String artifactUrl;
  final List<SubtitleUrl> subtitleUrls;

  TranscriptionResponse({
    required this.courseId,
    required this.resourceId,
    required this.artifactUrl,
    required this.subtitleUrls,
  });

  factory TranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return TranscriptionResponse(
      courseId: json['course_id'] ?? "",
      resourceId: json['resource_id'],
      artifactUrl: json['artifact_url'],
      subtitleUrls: List<SubtitleUrl>.from(
        json['transcription_urls'].map((item) => SubtitleUrl.fromJson(item)),
      ),
    );
  }
  SubtitleUrl? getSubtitleBasedLocale(String locale) {
    for (var item in subtitleUrls) {
      if (item.language == locale) {
        return item;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'resource_id': resourceId,
      'artifact_url': artifactUrl,
      'transcription_urls': subtitleUrls.map((item) => item.toJson()).toList(),
    };
  }
}

class SubtitleUrl {
  final String type;
  final String language;
  final String uri;
  final String label;
  final String defaultLang;

  SubtitleUrl({
    required this.type,
    required this.language,
    required this.uri,
    required this.label,
    required this.defaultLang,
  });

  factory SubtitleUrl.fromJson(Map<String, dynamic> json) {
    return SubtitleUrl(
      type: json['type'],
      language: json['language'],
      uri: json['uri'],
      label: json['label'],
      defaultLang: json['default_lang'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'language': language,
      'uri': uri,
      'label': label,
      'default_lang': defaultLang,
    };
  }
}
