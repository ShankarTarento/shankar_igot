class EventBatchModel {
  final String? batchId;
  final String? name;
  final String? description;
  final String? createdBy;
  final String? createdDate;
  final String? startDate;
  final String? endDate;
  final String? enrollmentType;
  final int? status;

  EventBatchModel({
    this.batchId,
    this.name,
    this.description,
    this.createdBy,
    this.createdDate,
    this.startDate,
    this.endDate,
    this.enrollmentType,
    this.status,
  });

  factory EventBatchModel.fromJson(Map<String, dynamic> json) {
    return EventBatchModel(
      batchId: json['batchId'],
      name: json['name'],
      description: json['description'],
      createdBy: json['createdBy'],
      createdDate: json['createdDate'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      enrollmentType: json['enrollmentType'],
      status: json['status'],
    );
  }
}