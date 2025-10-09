class LocationItemModel {
  final String state;
  final String district;
  final String? uuid;

  LocationItemModel({required this.state, required this.district, this.uuid});

  factory LocationItemModel.fromJson(Map<String, dynamic> json) {
    return LocationItemModel(
        state: json['state'] ?? '',
        district: json['district'] ?? '',
        uuid: json['uuid']);
  }
}
