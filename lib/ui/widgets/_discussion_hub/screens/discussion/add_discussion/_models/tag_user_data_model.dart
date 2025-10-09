class TagUserDataModel {
  String? firstName;
  String? userName;
  String? maskedEmail;
  String? userId;

  TagUserDataModel({
    this.firstName,
    this.userName,
    this.maskedEmail,
    this.userId,
  });

  factory TagUserDataModel.fromJson(Map<String, dynamic> json) {
    return TagUserDataModel(
      firstName: json['firstName'],
      userName: json['userName'],
      maskedEmail: json['maskedEmail'],
      userId: json['userId'],
    );
  }
}
