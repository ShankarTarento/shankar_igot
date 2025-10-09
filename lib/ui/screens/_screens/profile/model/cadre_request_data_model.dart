
class CadreRequestDataModel {
  final String? cadreEmployee;
  final String? civilServiceTypeId;
  final String? civilServiceType;
  final String? civilServiceId;
  final String? civilServiceName;
  final String? cadreId;
  final String? cadreName;
  final int? cadreBatch;
  final String? cadreControllingAuthorityName;
  final bool? isOnCentralDeputation;

  const CadreRequestDataModel({
    this.cadreEmployee,
    this.civilServiceTypeId,
    this.civilServiceType,
    this.civilServiceId,
    this.civilServiceName,
    this.cadreId,
    this.cadreName,
    this.cadreBatch,
    this.cadreControllingAuthorityName,
    this.isOnCentralDeputation,
  });

  factory CadreRequestDataModel.fromJson(Map<String, dynamic> json) {
    return CadreRequestDataModel(
        cadreEmployee: json['cadreEmployee'],
      civilServiceTypeId: json['civilServiceTypeId'],
      civilServiceType: json['civilServiceType'],
      civilServiceId: json['civilServiceId'],
      civilServiceName: json['civilServiceName'],
      cadreId: json['cadreId'],
      cadreName: json['cadreName'],
      cadreBatch: json['cadreBatch'],
      cadreControllingAuthorityName: json['cadreControllingAuthorityName'],
      isOnCentralDeputation: json['isOnCentralDeputation'],
    );
  }
}
