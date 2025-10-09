class DesignationModel {
  final String identifier;
  final String name;
  final String objectType;

  DesignationModel({
    required this.identifier,
    required this.name,
    required this.objectType,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      identifier: json['identifier']??'',
      name: json['name']??'',
      objectType: json['objectType']??'',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'name': name,
      'objectType': objectType,
    };
  }
}