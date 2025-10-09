class BannerData {
  final BannerImageUrl imageUrl;
  final String? redirectionUrl;

  BannerData({
    required this.imageUrl,
    this.redirectionUrl,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      imageUrl: BannerImageUrl.fromJson(json['imageUrl']),
      redirectionUrl: json['redirectionUrl'],
    );
  }
}

class BannerImageUrl {
  final String hiUrl;
  final String enUrl;

  BannerImageUrl({
    required this.hiUrl,
    required this.enUrl,
  });

  factory BannerImageUrl.fromJson(Map<String, dynamic> json) {
    return BannerImageUrl(
      hiUrl: json['hiUrl'],
      enUrl: json['enUrl'],
    );
  }

  String getImageUrl(String languageCode) {
    if (languageCode == 'hi') {
      return hiUrl;
    } else {
      return enUrl;
    }
  }
}
