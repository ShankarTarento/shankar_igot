
class DeepLink {
  final String ?url;
  final String ?category;
  final rawDetails;

  const DeepLink(
      {required this.url, required this.category, this.rawDetails});

  factory DeepLink.fromJson(Map<String, dynamic> json) {
    return DeepLink(
        url: json['url'], category: json['category'], rawDetails: json);
  }

  static Map<String, String> toJson(DeepLink deepLink) =>
      {"url": deepLink.url.toString(), "category": deepLink.category.toString()};
}
