class ProgressModel {
  double completionPercentage;
  int spentTime;
  String currentProgress;
  int status;

  ProgressModel(
      {required this.completionPercentage,
      required this.spentTime,
      required this.currentProgress,
      required this.status});

  factory ProgressModel.fromJson(Map<String, dynamic> json) => ProgressModel(
      completionPercentage: json['completionPercentage'],
      spentTime: json['spentTime'] ?? 0,
      currentProgress: json['currentProgress'] ?? '0',
      status: json['status'] ?? 0);
}
