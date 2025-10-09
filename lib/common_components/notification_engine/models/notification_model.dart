class NotificationModel {
  final bool read;
  final String? role;
  final String subCategory;
  final String subType;
  final DateTime createdAt;
  final String notificationId;
  final String source;
  final String type;
  final Message message;
  final String category;

  NotificationModel({
    required this.read,
    this.role,
    required this.subCategory,
    required this.subType,
    required this.createdAt,
    required this.notificationId,
    required this.source,
    required this.type,
    required this.message,
    required this.category,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        read: json['read'] is bool ? json['read'] as bool : false,
        role: json['role'] is String ? json['role'] as String : null,
        subCategory: json['sub_category'] is String
            ? json['sub_category'] as String
            : 'UNKNOWN',
        subType:
            json['sub_type'] is String ? json['sub_type'] as String : 'UNKNOWN',
        createdAt: json['created_at'] is String
            ? DateTime.tryParse(json['created_at'] as String) ??
                DateTime.fromMillisecondsSinceEpoch(0)
            : DateTime.fromMillisecondsSinceEpoch(0),
        notificationId: json['notification_id'] is String
            ? json['notification_id'] as String
            : '',
        source: json['source'] is String ? json['source'] as String : '',
        type: json['type'] is String ? json['type'] as String : '',
        message: json['message'] is Map<String, dynamic>
            ? Message.fromJson(json['message'] as Map<String, dynamic>)
            : Message.empty(),
        category:
            json['category'] is String ? json['category'] as String : 'UNKNOWN',
      );
    } catch (e) {
      return NotificationModel(
        read: false,
        role: null,
        subCategory: 'UNKNOWN',
        subType: 'UNKNOWN',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        notificationId: '',
        source: '',
        type: '',
        message: Message.empty(),
        category: 'UNKNOWN',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'read': read,
      'role': role,
      'sub_category': subCategory,
      'sub_type': subType,
      'created_at': createdAt.toIso8601String(),
      'notification_id': notificationId,
      'source': source,
      'type': type,
      'message': message.toJson(),
      'category': category,
    };
  }

  NotificationModel copyWith({
    bool? read,
    String? role,
    String? subCategory,
    String? subType,
    DateTime? createdAt,
    String? notificationId,
    String? source,
    String? type,
    Message? message,
    String? category,
  }) {
    return NotificationModel(
      read: read ?? this.read,
      role: role ?? this.role,
      subCategory: subCategory ?? this.subCategory,
      subType: subType ?? this.subType,
      createdAt: createdAt ?? this.createdAt,
      notificationId: notificationId ?? this.notificationId,
      source: source ?? this.source,
      type: type ?? this.type,
      message: message ?? this.message,
      category: category ?? this.category,
    );
  }
}

class Message {
  final Data data;
  final String? title;
  final String body;

  Message({
    required this.data,
    required this.body,
    this.title,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      return Message(
        data: json['data'] is Map<String, dynamic>
            ? Data.fromJson(json['data'] as Map<String, dynamic>)
            : Data.empty(),
        body: json['body'] is String ? json['body'] as String : '',
        title: json['title'] is String ? json['title'] as String : null,
      );
    } catch (e) {
      return Message.empty();
    }
  }

  factory Message.empty() => Message(data: Data.empty(), body: '');

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'body': body,
    };
  }

  Message copyWith({
    Data? data,
    String? body,
  }) {
    return Message(
      data: data ?? this.data,
      body: body ?? this.body,
    );
  }
}

class Data {
  final String? communityId;
  final String? discussionId;
  final String? contentId;
  final String? commentId;
  final List<String>? courseIds;

  Data({
    this.communityId,
    this.discussionId,
    this.contentId,
    this.commentId,
    this.courseIds,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    try {
      return Data(
        communityId: json['communityId'] is String
            ? json['communityId'] as String
            : null,
        discussionId: json['discussionId'] is String
            ? json['discussionId'] as String
            : null,
        contentId: json['id'] is String ? json['id'] as String : null,
        commentId: json['commentId'] is String ? json['commentId'] as String : null,
        courseIds: json['course_ids'] is List
            ? (json['course_ids'] as List).map((e) => e as String).toList()
            : null,
      );
    } catch (e) {
      return Data.empty();
    }
  }

  factory Data.empty() => Data();

  Map<String, dynamic> toJson() {
    return {
      'communityId': communityId,
      'discussionId': discussionId,
      if (contentId != null) 'id': contentId,
      'commentId': commentId,
    };
  }

  Data copyWith({
    String? communityId,
    String? discussionId,
    String? contentId,
    String? commentId,
  }) {
    return Data(
      communityId: communityId ?? this.communityId,
      discussionId: discussionId ?? this.discussionId,
      contentId: contentId ?? this.contentId,
      commentId: contentId ?? this.commentId,
    );
  }
}

class NotificationSettingModel {
  bool? enabled;
  String? notificationType;

  NotificationSettingModel({
    this.enabled,
    this.notificationType,
  });

  factory NotificationSettingModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingModel(
      enabled: json['enabled'] ?? false,
      notificationType: json['notificationType'] ?? "",
    );
  }
}
