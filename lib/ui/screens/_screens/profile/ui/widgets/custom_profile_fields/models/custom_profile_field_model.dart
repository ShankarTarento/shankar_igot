class CustomField {
  final String name;
  final String? description;
  final String type;
  final bool isMandatory;
  final bool isEnabled;
  final bool isActive;
  final String attributeName;
  final String organisationId;
  final String customFieldId;
  final String createdBy;
  final DateTime createdOn;
  final String updatedBy;
  final DateTime updatedOn;
  final String? validation;
  final List<CustomFieldData>? customFieldData;
  final List<CustomFieldData>? reversedOrderCustomFieldData;

  CustomField({
    required this.name,
    this.description,
    required this.type,
    required this.isMandatory,
    required this.isEnabled,
    required this.isActive,
    required this.attributeName,
    required this.organisationId,
    required this.customFieldId,
    required this.createdBy,
    required this.createdOn,
    required this.updatedBy,
    required this.updatedOn,
    this.validation,
    this.customFieldData,
    this.reversedOrderCustomFieldData,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      name: json['name'],
      description: json['description'],
      type: json['type'],
      isMandatory: json['isMandatory'],
      isEnabled: json['isEnabled'],
      isActive: json['isActive'],
      attributeName: json['attributeName'],
      organisationId: json['organisationId'],
      customFieldId: json['customFieldId'],
      createdBy: json['createdBy'],
      createdOn: DateTime.parse(json['createdOn']),
      updatedBy: json['updatedBy'],
      updatedOn: DateTime.parse(json['updatedOn']),
      validation: json['validation'],
      customFieldData: (json['customFieldData'] as List?)
          ?.map((e) => CustomFieldData.fromJson(e))
          .toList(),
      reversedOrderCustomFieldData:
          (json['reversedOrderCustomFieldData'] as List?)
              ?.map((e) => CustomFieldData.fromJson(e))
              .toList(),
    );
  }
}

class CustomFieldData {
  final String fieldName;
  final String fieldValue;
  final String? fieldAttribute;
  final String? parentFieldName;
  final String? parentFieldValue;
  final List<CustomFieldData> fieldValues;

  CustomFieldData({
    required this.fieldName,
    required this.fieldValue,
    this.fieldAttribute,
    this.parentFieldName,
    this.parentFieldValue,
    required this.fieldValues,
  });

  factory CustomFieldData.fromJson(Map<String, dynamic> json) {
    return CustomFieldData(
      fieldName: json['fieldName'],
      fieldValue: json['fieldValue'],
      fieldAttribute: json['fieldAttribute'],
      parentFieldName: json['parentFieldName'],
      parentFieldValue: json['parentFieldValue'],
      fieldValues: (json['fieldValues'] as List)
          .map((e) => CustomFieldData.fromJson(e))
          .toList(),
    );
  }
}
