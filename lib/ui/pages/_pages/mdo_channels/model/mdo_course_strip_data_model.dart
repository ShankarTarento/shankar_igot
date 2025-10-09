import 'course_pills_data_model.dart';

class MdoStripsDataModel {
  List<StripsData>? strips;

  MdoStripsDataModel({this.strips});

  MdoStripsDataModel.fromJson(Map<String, dynamic> json) {
    if (json['strips'] != null && json['strips'] is List) {
      strips = <StripsData>[];
      (json['strips'] as List).forEach((v) {
        if (v is Map<String, dynamic>) {
          strips?.add(StripsData.fromJson(v));
        }
      });
    }
  }
}

class StripsData {
  List<CoursePillsDataModel>? tabs;

  StripsData({this.tabs});

  StripsData.fromJson(Map<String, dynamic> json) {
    if (json['tabs'] != null && json['tabs'] is List) {
      tabs = <CoursePillsDataModel>[];
      (json['tabs'] as List).forEach((v) {
        if (v is Map<String, dynamic>) {
          tabs?.add(CoursePillsDataModel.fromJson(v));
        }
      });
    }
  }
}
