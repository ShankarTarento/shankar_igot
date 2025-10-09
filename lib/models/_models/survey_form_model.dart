import 'package:karmayogi_mobile/feedback/constants.dart';

class FormDataModel {
  String refApi;
  String logicalGroupCode;
  String name;
  String fieldType;
  List<Value> values;
  List<Heading>? heading;
  int order;
  bool isRequired;
  bool notApplicable;

  FormDataModel({
    required this.refApi,
    required this.logicalGroupCode,
    required this.name,
    required this.fieldType,
    required this.values,
    required this.order,
    required this.isRequired,
    required this.notApplicable,
    this.heading,
  });

  // Method to convert JSON to Dart object
  factory FormDataModel.fromJson(Map<String, dynamic> json) {
    var valuesJson = json['values'] as List;
    List<Value> valuesList = [];
    List<Heading> heading = [];
    if (json['fieldType'] == QuestionType.heading) {
      heading = valuesJson.map((item) => Heading.fromJson(item)).toList();
    } else {
      valuesList = valuesJson.map((item) => Value.fromJson(item)).toList();
    }
    return FormDataModel(
        refApi: json['refApi'] as String,
        logicalGroupCode: json['logicalGroupCode'] as String,
        name: json['name'] as String,
        fieldType: json['fieldType'] as String,
        values: valuesList,
        order: json['order'] as int,
        isRequired: json['isRequired'] ?? false,
        notApplicable: json['notApplicable'] ?? false,
        heading: heading);
  }
}

class Value {
  String? key;
  String? value;

  Value({this.key, this.value});

  // Method to convert JSON to Dart object
  factory Value.fromJson(Map<String, dynamic> json) {
    return Value(
      key: json['key'],
      value: json['value'],
    );
  }
}

class Heading {
  String? heading;
  String? subHeading;

  Heading({this.heading, this.subHeading});

  factory Heading.fromJson(Map<String, dynamic> json) {
    return Heading(
      heading: json['heading'],
      subHeading: json['subHeading'],
    );
  }
}
