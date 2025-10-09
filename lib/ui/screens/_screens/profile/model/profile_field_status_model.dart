class ProfileFieldStatusModel {
  int lastUpdatedOn;
  String? wfId;
  String? group;
  String? designation;
  String? comment;
  String? currentStatus;
  String? name;

  ProfileFieldStatusModel(
      {required this.lastUpdatedOn,
      this.wfId,
      this.group,
      this.designation,
      this.comment,
      this.currentStatus,
      this.name});

  factory ProfileFieldStatusModel.fromJson(Map<String, dynamic> json) =>
      ProfileFieldStatusModel(
        lastUpdatedOn: json['lastUpdatedOn'] ?? 0,
        wfId: json['wfId'],
        group: json['group'],
        designation: json['designation'],
        comment: json['comment'],
        currentStatus: json['currentStatus'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'wfId': wfId,
        'group': group,
        'designation': designation,
        'comment': comment,
        'lastUpdatedOn': lastUpdatedOn == 0 ? null : lastUpdatedOn,
        'name': name,
      };
}
