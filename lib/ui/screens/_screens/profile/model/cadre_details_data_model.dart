
class CadreDetailsDataModel {
  int? version;
  CivilServiceTypeData? civilServiceType;

  CadreDetailsDataModel(
      {this.civilServiceType, this.version});

  CadreDetailsDataModel.fromJson(Map<String, dynamic> json) {
    version =  json['version'];
    civilServiceType = CivilServiceTypeData.fromJson(json['civilServiceType']);
  }
}

class CivilServiceTypeData {
  String? name;
  String? displayName;
  List<CivilServiceTypeListData>? civilServiceTypeList;

  CivilServiceTypeData(
      {this.civilServiceTypeList, this.name, this.displayName});

  CivilServiceTypeData.fromJson(Map<String, dynamic> json) {
    name =  json['name'];
    displayName =  json['displayName'];
    if (json['civilServiceTypeList'] != null) {
      civilServiceTypeList = <CivilServiceTypeListData>[];
      json['civilServiceTypeList'].forEach((v) {
        civilServiceTypeList?.add(CivilServiceTypeListData.fromJson(v));
      });
    }
  }
}

class CivilServiceTypeListData {
  String? id;
  String? name;
  String? displayName;
  List<ServiceListData>? serviceList;

  CivilServiceTypeListData(
      {this.id, this.name, this.displayName, this.serviceList});

  CivilServiceTypeListData.fromJson(Map<String, dynamic> json) {
    id =  json['id'];
    name =  json['name'];
    displayName =  json['displayName'];
    if (json['serviceList'] != null) {
      serviceList = <ServiceListData>[];
      json['serviceList'].forEach((v) {
        serviceList?.add(ServiceListData.fromJson(v));
      });
    }
  }
}

class ServiceListData {
  String? id;
  String? name;
  String? displayName;
  String? cadreControllingAuthority;
  int? startBatchYear;
  int? endBatchYear;
  List<int>? exclusionYearList;
  List<CadreListData>? cadreList;

  ServiceListData(
      {this.cadreList, this.id, this.name, this.displayName, this.cadreControllingAuthority, this.startBatchYear, this.endBatchYear, this.exclusionYearList});

  ServiceListData.fromJson(Map<String, dynamic> json) {
    id =  json['id'];
    name =  json['name'];
    displayName =  json['displayName'];
    cadreControllingAuthority =  json['cadreControllingAuthority'];
    startBatchYear =  json['commonBatchStartYear'];
    endBatchYear =  json['commonBatchEndYear'];
    if (json['commonBatchExclusionYearList'] != null) {
      exclusionYearList = List<int>.from(json['commonBatchExclusionYearList']);
    }
    if (json['cadreList'] != null) {
      cadreList = <CadreListData>[];
      json['cadreList'].forEach((v) {
        cadreList?.add(CadreListData.fromJson(v));
      });
    }
  }
}

class CadreListData {
  String? id;
  String? name;
  int? startBatchYear;
  int? endBatchYear;
  List<int>? exclusionYearList;

  CadreListData(
      {this.id, this.name, this.startBatchYear, this.endBatchYear, this.exclusionYearList});

  CadreListData.fromJson(Map<String, dynamic> json) {
    id =  json['id'];
    name =  json['name'];
    startBatchYear =  json['startBatchYear'];
    endBatchYear =  json['endBatchYear'];
    if (json['exculsionYearList'] != null) {
      exclusionYearList = List<int>.from(json['exculsionYearList']);
    }
  }
}

class ExclusionYearListData {
  String? id;
  String? name;

  ExclusionYearListData(
      {this.id, this.name});

  ExclusionYearListData.fromJson(Map<String, dynamic> json) {
    id =  json['id'];
    name =  json['name'];
  }
}
