class NodalModel {
  String organization;
  String ministry;
  String nodalName;
  String nodalEmail;

  NodalModel({
    required this.organization,
    required this.ministry,
    required this.nodalName,
    required this.nodalEmail,
  });

  factory NodalModel.fromJson(Map<String, dynamic> json) => NodalModel(
        organization: json['Organization'] ?? '',
        ministry: json['Ministry'] ?? '',
        nodalName: json['Nodal Name'] ?? '',
        nodalEmail: json['Nodal Email'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'Organization': organization,
        'Ministry': ministry,
        'Nodal Name': nodalName,
        'Nodal Email': nodalEmail,
      };
}
