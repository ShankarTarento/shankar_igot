import 'package:flutter/material.dart';

class MultiLingualText {
  final String id;
  final String hiText;
  final String enText;

  MultiLingualText(
      {required this.id, required this.enText, required this.hiText});

  factory MultiLingualText.fromJson(Map<String, dynamic> json) {
    return MultiLingualText(
      id: json['id'],
      enText: json['enText'],
      hiText: json['hiText'],
    );
  }
  String getText(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);

    switch (myLocale.languageCode) {
      case 'hi':
        return hiText;
      default:
        return enText;
    }
  }
}
