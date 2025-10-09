class OrgCustomFieldsData {
  final int customFieldsCount;
  final List<String> customFieldIds;
  final bool isPopUpEnabled;

  OrgCustomFieldsData({
    required this.customFieldsCount,
    required this.customFieldIds,
    required this.isPopUpEnabled,
  });

  factory OrgCustomFieldsData.fromJson(Map<String, dynamic> json) {
    return OrgCustomFieldsData(
      customFieldsCount: json['customFieldsCount'] ?? 0,
      customFieldIds: json['customFieldIds'] != null
          ? List<String>.from(json['customFieldIds'])
          : [],
      isPopUpEnabled: json['isPopupEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customFieldsCount': customFieldsCount,
      'customFieldIds': customFieldIds,
    };
  }
}
