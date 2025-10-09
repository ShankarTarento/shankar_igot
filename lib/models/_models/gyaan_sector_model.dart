class SectorDetails {
  final String sectorId;
  final String subSectorName;
  final String sectorName;
  final String subSectorId;

  SectorDetails({
    required this.sectorId,
    required this.subSectorName,
    required this.sectorName,
    required this.subSectorId,
  });

  factory SectorDetails.fromJson(Map<String, dynamic> json) {
    return SectorDetails(
      sectorId: json['sectorId']??'',
      subSectorName: json['subSectorName']??'',
      sectorName: json['sectorName']??'',
      subSectorId: json['subSectorId']??'',
    );
  }
}
