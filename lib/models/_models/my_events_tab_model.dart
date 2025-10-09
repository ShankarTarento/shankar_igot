import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';

class MyEventsTabModel {
  MultiLingualText mLabel;
  String value;
  String nodataMsg;
  Request request;

  MyEventsTabModel({
    required this.mLabel,
    required this.value,
    required this.nodataMsg,
    required this.request,
  });

  factory MyEventsTabModel.fromJson(Map<String, dynamic> json) {
    return MyEventsTabModel(
      mLabel: MultiLingualText.fromJson(json['mLabel']),
      value: json['value'],
      nodataMsg: json['nodataMsg'],
      request: Request.fromJson(json['request']),
    );
  }
}

class Request {
  String apiUrl;
  Map<String, dynamic> myEventsRequest;

  Request({
    required this.apiUrl,
    required this.myEventsRequest,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      apiUrl: json['apiUrl'],
      myEventsRequest: json['myEvents'],
    );
  }
}
