class CommunityBannerModel {
  bool? active;
  String? imageUrl;
  String? title;
  String? id;

  CommunityBannerModel({
    this.active,
    this.imageUrl,
    this.title,
    this.id,
  });

  CommunityBannerModel.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    imageUrl = json['imageUrl'];
    title = json['title'];
    id = json['id'];
  }
}