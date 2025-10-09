
class CoursePillsDataModel {
  String? label;
  String? value;
  String? mobValue;
  late bool computeDataOnClick;
  String? computeDataOnClickKey;
  late bool requestRequired;
  late bool showTabDataCount;
  int? maxWidgets;
  String? nodataMsg;

  CoursePillsDataModel(
      {
        this.label,
        this.value,
        this.mobValue,
        required this.computeDataOnClick,
        this.computeDataOnClickKey,
        required this.requestRequired,
        required this.showTabDataCount,
        this.maxWidgets,
        this.nodataMsg,
      });

  CoursePillsDataModel.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'] ;
    mobValue = json['mobValue'] ;
    computeDataOnClick = json['computeDataOnClick']??false;
    computeDataOnClickKey = json['computeDataOnClickKey'];
    requestRequired = json['requestRequired']??false;
    showTabDataCount = json['showTabDataCount']??false;
    maxWidgets = json['maxWidgets'];
    nodataMsg = json['nodataMsg'];
  }
}
