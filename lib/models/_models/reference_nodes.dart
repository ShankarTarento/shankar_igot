class ReferenceNode {
  String name;
  String identifier;
  String? resourceCategory;
  String? primaryCategory;
  List<String>? languageCode;
  String? downloadUrl;
  bool? isExternal;
  String? contentType;
  List<String>? language;
  String artifactUrl;

  ReferenceNode({
    required this.name,
    required this.identifier,
    this.resourceCategory,
    this.primaryCategory,
    this.languageCode,
    this.downloadUrl,
    this.isExternal,
    this.contentType,
    this.language,
    required this.artifactUrl,
  });

  // Factory constructor to handle JSON parsing
  factory ReferenceNode.fromJson(Map<String, dynamic> json) {
    return ReferenceNode(
      name: json['name'],
      identifier: json['identifier'],
      resourceCategory: json['resourceCategory'],
      primaryCategory: json['primaryCategory'],
      languageCode: json['languageCode'] != null
          ? List<String>.from(json['languageCode'])
          : null,
      downloadUrl: json['downloadUrl'],
      isExternal: json['isExternal'],
      contentType: json['contentType'],
      language:
          json['language'] != null ? List<String>.from(json['language']) : null,
      artifactUrl: json['artifactUrl'],
    );
  }
}
