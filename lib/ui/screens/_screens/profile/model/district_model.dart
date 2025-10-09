class DistrictModel {
  final String stateName;
  final List<String> districts;

  DistrictModel({
    required this.stateName,
    required this.districts,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      stateName: json['stateName'],
      districts: List<String>.from(json['districts']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stateName': stateName,
      'districts': districts,
    };
  }
}
