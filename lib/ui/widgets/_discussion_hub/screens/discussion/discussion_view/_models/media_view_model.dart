class MediaViewModel {
  bool? active;
  String? mediaUrl;
  String? title;
  String? type;

  MediaViewModel({
    this.active,
    this.mediaUrl,
    this.title,
    this.type,
  });

  MediaViewModel.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    mediaUrl = json['mediaUrl'];
    title = json['title'];
    type = json['type'];
  }
}