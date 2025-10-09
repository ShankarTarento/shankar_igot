class BrowseBy {
  final int id;
  final String title;
  final String description;
  final bool comingSoon;
  final String svgImage;
  final String url;
  final String telemetryId;

  const BrowseBy(
      {required this.id,
      required this.title,
      required this.description,
      required this.comingSoon,
      required this.svgImage,
      required this.url,
      required this.telemetryId});
}
