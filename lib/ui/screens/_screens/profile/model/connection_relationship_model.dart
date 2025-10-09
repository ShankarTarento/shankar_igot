class ConnectionRelationshipModel {
  final String? createdAt;
  final String? status;

  ConnectionRelationshipModel({
    this.createdAt,
    this.status
  });

  factory ConnectionRelationshipModel.fromJson(Map<String, dynamic> json) {
    return ConnectionRelationshipModel(
      createdAt: json['createdAt']??'',
        status: json['status']??''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'status': status,
    };
  }
}
