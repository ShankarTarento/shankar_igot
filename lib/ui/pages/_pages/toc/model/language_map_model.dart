import '../util/toc_constants.dart';

class LanguageContent {
  final String id;
  final String name;
  final bool isBaseLanguage;
  bool selectedLanguage;
  final String status;

  LanguageContent({
    required this.id,
    required this.name,
    required this.isBaseLanguage,
    required this.selectedLanguage,
    required this.status,
  });

  factory LanguageContent.fromJson(Map<String, dynamic> json, String key) {
    return LanguageContent(
        id: json['id'],
        name: key,
        isBaseLanguage: json['isBaseLanguage'] != null
            ? json['isBaseLanguage']
            : json['isBaseLang'] != null
                ? json['isBaseLang']
                : false,
        status: json['status'],
        selectedLanguage: json['isBaseLanguage'] != null
            ? json['isBaseLanguage']
            : json['isBaseLang'] != null
                ? json['isBaseLang']
                : false);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isBaseLanguage': isBaseLanguage,
      'status': status,
    };
  }
}

class LanguageMapV1 {
  final Map<String, LanguageContent> languages;

  LanguageMapV1({required this.languages});
  static const masterLanguagesArray = [
    {'name': "English", 'value': "English"},
    {'name': "ಕನ್ನಡ (Kannada)", 'value': "Kannada"},
    {'name': "తెలుగు (Telugu)", 'value': "Telugu"},
    {'name': "தமிழ் (Tamil)", 'value': "Tamil"},
    {'name': "മലയാളം (Malayalam)", 'value': "Malayalam"},
    {'name': "हिंदी (Hindi)", 'value': "Hindi"},
    {'name': "অসমীয়া (Assamese)", 'value': "Assamese"},
    {'name': "বাংলা (Bengali)", 'value': "Bengali"},
    {'name': "ગુજરાતી (Gujarati)", 'value': "Gujarati"},
    {'name': "मराठी (Marathi)", 'value': "Marathi"},
    {'name': "ଓଡିଆ (Odia)", 'value': "Odia"},
    {'name': "ਪੰਜਾਬੀ (Punjabi)", 'value': "Punjabi"},
    {'name': "कोंकणी (Konkani)", 'value': "Konkani"},
    {'name': "बड़ो (Bodo)", 'value': "Bodo"},
    {'name': "डोगरी (Dogri)", 'value': "Dogri"},
    {'name': "كشميري / कश्मीरी (Kashmiri)", 'value': "Kashmiri"},
    {'name': "मैथिली (Maithili)", 'value': "Maithili"},
    {'name': "মৈতৈলোন্  (Manipuri )", 'value': "Manipuri"},
    {'name': "नेपाली (Nepali)", 'value': "Nepali"},
    {'name': "संस्कृतम् (Sanskrit)", 'value': "Sanskrit"},
    {'name': "ᱥᱟᱱᱛᱟᱲᱤ (Santali)", 'value': "Santali"},
    {'name': "سنڌي / सिंधी (Sindhi)", 'value': "Sindhi"},
    {'name': "اُردُو (Urdu)", 'value': "Urdu"}
  ];

  static String getLanguageDisplayName(String inputValue) {
    try {
      final match = masterLanguagesArray.firstWhere(
        (lang) => lang['value']!.toLowerCase() == inputValue.toLowerCase(),
        orElse: () => {},
      );

      return match.isNotEmpty
          ? match['name'] != null
              ? match['name']!
              : inputValue
          : inputValue;
    } catch (e) {
      return inputValue;
    }
  }

  static String? getValueFromDisplayName(String displayName) {
    final match = LanguageMapV1.masterLanguagesArray.firstWhere(
      (lang) => lang['name'] == displayName,
      orElse: () => {},
    );
    return match.isNotEmpty ? match['value'] : null;
  }

  factory LanguageMapV1.fromJson(Map<String, dynamic>? json) {
    final Map<String, LanguageContent> parsedLanguages = {};

    if (json != null) {
      json.forEach((key, value) {
        final status =
            TocPublishStatus.fromString(value?['status']?.toString());
        if (status == TocPublishStatus.live) {
          String displayName = getLanguageDisplayName(key);
          parsedLanguages[displayName] = LanguageContent.fromJson(value, key);
        }
      });
    }

    return LanguageMapV1(languages: parsedLanguages);
  }

  Map<String, dynamic> toJson() {
    return languages.map((key, value) => MapEntry(key, value.toJson()));
  }

  static LanguageMapV1 copyLanguageMap(LanguageMapV1 original) {
    // Deep copy the languages map
    final copiedLanguages =
        Map<String, LanguageContent>.from(original.languages);
    return LanguageMapV1(languages: copiedLanguages);
  }
}
