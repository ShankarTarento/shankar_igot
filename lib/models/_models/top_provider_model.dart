import 'dart:convert';

TopProviderModel topProviderModelFromJson(String str) =>
    TopProviderModel.fromJson(json.decode(str));

String topProviderModelToJson(TopProviderModel data) =>
    json.encode(data.toJson());

class TopProviderModel {
  String ?orgId;
  String ?clientImageUrl;
  String ?clientName;

  TopProviderModel({
    this.orgId,
    this.clientImageUrl,
    this.clientName,
  });

  factory TopProviderModel.fromJson(Map<String, dynamic> json) =>
      TopProviderModel(
          orgId: json["orgId"],
          clientImageUrl: json["clientImageUrl"],
          clientName: json["clientName"]);

  Map<String, dynamic> toJson() =>
      {
        "orgId": orgId,
        "clientImageUrl": clientImageUrl,
        "clientName": clientName
      };
}
