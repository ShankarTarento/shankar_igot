class EventFilterModel {
  final MultiLingualFilterModel title;
  bool isSelected;

  EventFilterModel({required this.title, this.isSelected = false});

  factory EventFilterModel.fromJson(Map<String, dynamic> json) {
    return EventFilterModel(
      title: MultiLingualFilterModel.fromJson(json['title']),
      isSelected: json['isSelected'] ?? false,
    );
  }
}

class MultiLingualFilterModel {
  final String id;
  final String text;

  MultiLingualFilterModel({required this.id, required this.text});

  factory MultiLingualFilterModel.fromJson(Map<String, dynamic> json) {
    return MultiLingualFilterModel(
      id: json['name'],
      text: json['name'],
    );
  }
}
