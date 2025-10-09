import 'comment_data_model.dart';

class CommentTreeData {
  final List<CommentDataModel>? comments;
  final String? entityId;
  final String? workflow;
  final String? entityType;

  CommentTreeData({
    this.comments,
    this.entityId,
    this.workflow,
    this.entityType,
  });

  factory CommentTreeData.fromJson(Map<String, dynamic> json) {
    return CommentTreeData(
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => CommentDataModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      entityId: json['entityId'] ?? '',
      workflow: json['workflow'] ?? '',
      entityType: json['entityType'] ?? '',
    );
  }
}
