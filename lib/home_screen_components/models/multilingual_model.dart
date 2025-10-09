import 'package:flutter/material.dart';

class MultiLingualImageUrl {
  final String hiUrl;
  final String enUrl;

  MultiLingualImageUrl({required this.enUrl, required this.hiUrl});

  factory MultiLingualImageUrl.fromJson(Map<String, dynamic> json) {
    return MultiLingualImageUrl(
      enUrl: json['enUrl'],
      hiUrl: json['hiUrl'],
    );
  }
  String getUrl(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);

    switch (myLocale.languageCode) {
      case 'hi':
        return hiUrl;
      default:
        return enUrl;
    }
  }
}
