class RegistrationLinkModel {
  final String? orgId;
  final String? orgName;
  final String? orgLogo;
  final String? link;

  RegistrationLinkModel({
    this.orgId,
    this.orgName,
    this.orgLogo,
    this.link
  });

  factory RegistrationLinkModel.fromJson(Map<String, dynamic> json) =>
      RegistrationLinkModel(
        orgId: json['orgId'] ?? json['frameworkid'],
        orgName: json['orgName'],
        orgLogo: json['logo'],
        link: json['link']
      );
}
