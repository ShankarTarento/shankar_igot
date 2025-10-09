class CustomProfileData {
  final String customFieldId;
  final String attributeName;
  final String type;
  final String? value;
  final List<AttributeValue>? values;

  CustomProfileData({
    required this.customFieldId,
    required this.attributeName,
    required this.type,
    this.value,
    this.values,
  });

  factory CustomProfileData.fromJson(Map<String, dynamic> json) {
    return CustomProfileData(
      customFieldId: json['customFieldId'],
      attributeName: json['attributeName'],
      type: json['type'],
      value: json['value'],
      values: json['values'] != null
          ? (json['values'] as List)
              .map((v) => AttributeValue.fromJson(v))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'customFieldId': customFieldId,
        'attributeName': attributeName,
        'type': type,
        if (value != null) 'value': value,
        if (values != null) 'values': values!.map((v) => v.toJson()).toList(),
      };
}

class AttributeValue {
  final String attributeName;
  final String value;
  final int level;

  AttributeValue({
    required this.attributeName,
    required this.value,
    required this.level,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) {
    return AttributeValue(
      attributeName: json['attributeName'],
      value: json['value'],
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() => {
        'attributeName': attributeName,
        'value': value,
        'level': level,
      };
}
