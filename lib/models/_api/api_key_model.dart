
class ApiObj {
  String url;
  Map<String, dynamic> body;
  ApiObj({required this.url, this.body = const {}});

  factory ApiObj.fromJson(Map<String, dynamic> json) => ApiObj(
        url: json["url"],
        body: json["body"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "body": body,
      };
}
