class ContentStateModel {
  String? lastAccessTime;
  String contentId;
  String batchId;
  int completedCount;
  Map? progressdetails;
  double completionPercentage;
  int progress;
  int viewCount;
  String courseId;
  String collectionId;
  String? lastCompletedTime;
  int status;

  ContentStateModel({
    this.lastAccessTime,
    required this.contentId,
    required this.batchId,
    required this.completedCount,
    this.progressdetails,
    required this.completionPercentage,
    required this.progress,
    required this.viewCount,
    required this.courseId,
    required this.collectionId,
    this.lastCompletedTime,
    required this.status,
  });

  factory ContentStateModel.fromJson(Map<String, dynamic> json) =>
      ContentStateModel(
        lastAccessTime: json['lastAccessTime'],
        contentId: json['contentId']??'',
        batchId: json['batchId']??'',
        completedCount: json['completedCount'] ?? 0,
        progressdetails: json['progressdetails'],
        completionPercentage: json['completionPercentage'] ?? 0,
        progress: json['progress'],
        viewCount: json['viewCount'] ?? 0,
        courseId: json['courseId']??'',
        collectionId: json['collectionId']??'',
        lastCompletedTime: json['lastCompletedTime'],
        status: json['status'],
      );
}
