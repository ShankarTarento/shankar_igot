class AchievementItem {
  final String title;
  final String issuedOrganisation;
  final String issuedDate;
  final String documentUrl;
  final String uploadedDocumentUrl;
  final String uploadedFileName;
  final String description;
  final String uuid;

  AchievementItem({
    required this.title,
    required this.issuedOrganisation,
    required this.issuedDate,
    required this.documentUrl,
    required this.uploadedDocumentUrl,
    required this.uploadedFileName,
    required this.description,
    required this.uuid,
  });

  factory AchievementItem.fromJson(Map<String, dynamic> json) {
    return AchievementItem(
      title: json['title'] ?? '',
      issuedOrganisation: json['issuedOrganisation'] ?? '',
      issuedDate: json['issuedDate'] ?? '',
      documentUrl: json['url'] ?? '',
      uploadedDocumentUrl: json['uploadedDocumentUrl'] ?? '',
      uploadedFileName: json['fileName'] ?? '',
      description: json['description'] ?? '',
      uuid: json['uuid'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'issuedOrganisation': issuedOrganisation,
      'issueDate': issuedDate,
      'url': documentUrl,
      'uploadedDocumentUrl': uploadedDocumentUrl,
      'fileName': uploadedFileName,
      'description': description,
      'uuid': uuid,
    };
  }
}
