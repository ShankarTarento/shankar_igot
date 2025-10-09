
class EventStateModel {
  final List<EventStateData>? events;

  EventStateModel({this.events});

  factory EventStateModel.fromJson(Map<String, dynamic> json) {
    return EventStateModel(
      events: (json['events'] as List)
          .map((eventJson) => EventStateData.fromJson(eventJson))
          .toList(),
    );
  }
}

class EventStateData {
  final int? lastAccessTime;
  final String? contentId;
  final String? contextId;
  final int? oldLastUpdatedTime;
  final String? batchId;
  final int? completedCount;
  final String? userId;
  final String? progressDetails;
  final double? completionPercentage;
  final int? oldLastCompletedTime;
  final int? progress;
  final int? lastUpdatedTime;
  final int? viewCount;
  final int? lastCompletedTime;
  final int? oldLastAccessTime;
  final int? status;

  EventStateData({
    this.lastAccessTime,
    this.contentId,
    this.contextId,
    this.oldLastUpdatedTime,
    this.batchId,
    this.completedCount,
    this.userId,
    this.progressDetails,
    this.completionPercentage,
    this.oldLastCompletedTime,
    this.progress,
    this.lastUpdatedTime,
    this.viewCount,
    this.lastCompletedTime,
    this.oldLastAccessTime,
    this.status,
  });

  factory EventStateData.fromJson(Map<String, dynamic> json) {
    return EventStateData(
      lastAccessTime: json['lastAccessTime'],
      contentId: json['contentId'],
      contextId: json['contextid'],
      oldLastUpdatedTime: json['oldLastUpdatedTime'],
      batchId: json['batchId'],
      completedCount: json['completedCount'],
      userId: json['userId'],
      progressDetails: json['progressdetails'],
      completionPercentage: json['completionPercentage'] != null ? json['completionPercentage'].toDouble() : null,
      oldLastCompletedTime: json['oldLastCompletedTime'],
      progress: json['progress'],
      lastUpdatedTime: json['lastUpdatedTime'],
      viewCount: json['viewCount'],
      lastCompletedTime: json['lastCompletedTime'],
      oldLastAccessTime: json['oldLastAccessTime'],
      status: json['status'],
    );
  }
}
