
class CommentActionModel {
  final String? responseCode;
  final String? errMsg;
  final String? status;

  CommentActionModel({
    this.responseCode,
    this.errMsg,
    this.status
  });

  factory CommentActionModel.fromJson(Map<String, dynamic> json) {
    return CommentActionModel(
        responseCode: json['responseCode'],
        errMsg: json['errMsg'],
        status: json['status']
    );
  }
}



