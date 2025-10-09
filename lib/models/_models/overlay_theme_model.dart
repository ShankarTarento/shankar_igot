import 'dart:convert';

OverlayThemeModel overrideThemeChangesFromJson(String str) =>
    OverlayThemeModel.fromJson(json.decode(str));

class OverlayThemeModel {
  final bool? isEnabled;
  final String? logoUrl;
  final String? logoText;
  final List<dynamic>? backgroundColors;

  OverlayThemeModel({
    this.isEnabled,
    this.logoUrl,
    this.logoText,
    this.backgroundColors,
  });
  factory OverlayThemeModel.fromJson(Map<String, dynamic> json) =>
      OverlayThemeModel(
        isEnabled: json["isEnabled"] ?? false,
        logoUrl: json["logoUrl"],
        logoText: json["logoText"],
        backgroundColors: json["backgroundColors"] ?? [],
      );
  factory OverlayThemeModel.defaultData() => OverlayThemeModel(
        isEnabled: false,
        logoUrl: '/assets/instances/eagle/app_logos/mobile_animation_file.json',
        logoText: '78th Independence Day',
        backgroundColors: ["0xffF8DACE", "0xffFFFFFF", "0xffCBEED2"],
      );
  factory OverlayThemeModel.sampleData() => OverlayThemeModel(
          isEnabled: true,
          logoUrl: 'assets/animations/mobile_animation_file.json',
          logoText: '75th Republic Day',
          backgroundColors: [
            '0XFFF8DACE',
            '0XFFFFFFFF',
            '0XFFCBEED2',
          ]);
}
