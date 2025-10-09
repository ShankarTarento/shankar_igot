
class UserActionModel {
  final String? responseCode;
  final String? errMsg;
  final String? status;

  UserActionModel({
    this.responseCode,
    this.errMsg,
    this.status
  });

  factory UserActionModel.fromJson(Map<String, dynamic> json) {
    return UserActionModel(
        responseCode: json['responseCode'],
        errMsg: json['errMsg'],
        status: json['status']
    );
  }
}



