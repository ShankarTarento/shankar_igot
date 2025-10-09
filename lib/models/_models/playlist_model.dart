class PlayList {
  final String title;
  final List? childrens;
  final String description;
  final String playListKey;
  final String orgId;
  final String type;
  final String? imgUrl;

  PlayList(
      {required this.title,
      this.childrens,
      required this.description,
      required this.playListKey,
      required this.orgId,
      required this.type,
      this.imgUrl});

  factory PlayList.fromJson(Map<String, dynamic> json) {
    return PlayList(
        title: json['title'] ?? "",
        childrens: json['children'],
        description: json['description'] ?? "",
        playListKey: json['playListKey'],
        orgId: json['orgId'],
        type: json['type'],
        imgUrl: json['imgSource'] != null && json['imgSource'].isNotEmpty
            ? json['imgSource'].first
            : null);
  }
}
