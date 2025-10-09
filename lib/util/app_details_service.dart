import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import '../constants/_constants/app_constants.dart';

enum AndroidStore { googlePlayStore, apkPure }

class AppVersionChecker {
  final String? currentVersion;
  final String? appId;
  final AndroidStore androidStore;

  AppVersionChecker({
    this.currentVersion,
    this.appId,
    this.androidStore = AndroidStore.googlePlayStore,
  });

  Future<AppCheckerResult> checkUpdate(context) async {
    final _currentVersion = APP_VERSION;
    final _packageName = Platform.isIOS ? IOS_BUNDLE_ID : ANDROID_BUNDLE_ID;

    if (Platform.isIOS) {
      return await _checkAppleStore(_currentVersion, _packageName);
    } else if (Platform.isAndroid) {
      final Map<AndroidStore, Future<AppCheckerResult> Function()>
          storeCheckMap = {
        AndroidStore.googlePlayStore: () =>
            _checkPlayStore(_currentVersion, _packageName),
        AndroidStore.apkPure: () =>
            throw UnimplementedError('APK Pure check is not implemented.'),
      };

      final checker = storeCheckMap[androidStore];

      return checker != null
          ? await checker()
          : AppCheckerResult(
              _currentVersion,
              null,
              '',
              'The selected Android store is not supported.',
              '',
            );
    } else {
      return AppCheckerResult(
        _currentVersion,
        null,
        '',
        'The target platform "${Platform.operatingSystem}" is not yet supported by this package.',
        '',
      );
    }
  }

  Future<AppCheckerResult> _checkAppleStore(
      String currentVersion, String bundleId) async {
    String errorMsg = '';
    String? newVersion;
    String? releaseNotes;
    String? url;

    try {
      final Map<String, dynamic>? result =
          await lookupByBundleId(bundleId, country: "IN");

      print(result);

      if (result == null || result.isEmpty) {
        errorMsg =
            "Can't find an app in the Apple Store with the id: $bundleId";
      } else {
        final List<dynamic> results = result['results'];
        if (results.isEmpty) {
          errorMsg =
              "Can't find an app in the Apple Store with the id: $bundleId";
        } else {
          newVersion = results[0]['version'];
          url = results[0]['trackViewUrl'];
          releaseNotes = results[0]['releaseNotes'];
        }
      }
    } catch (e) {
      errorMsg = "Error: $e";
    }

    return AppCheckerResult(
      currentVersion,
      newVersion,
      url ?? '',
      errorMsg,
      releaseNotes ?? '',
    );
  }

  Future<Map<String, dynamic>?> lookupByBundleId(String bundleId,
      {String country = 'US', bool useCacheBuster = true}) async {
    assert(bundleId.isNotEmpty);
    if (bundleId.isEmpty) {
      return null;
    }

    final url = lookupURLByBundleId(bundleId,
            country: country, useCacheBuster: useCacheBuster) ??
        '';

    try {
      final response = await http.get(Uri.parse(url));

      final decodedResults = _decodeResults(response.body);
      return decodedResults;
    } catch (e) {
      print('upgrader: lookupByBundleId exception: $e');
      return null;
    }
  }

  String? lookupURLByBundleId(String bundleId,
      {String country = 'US', bool useCacheBuster = true}) {
    if (bundleId.isEmpty) {
      return null;
    }

    return lookupURLByQSP(
        {'bundleId': bundleId, 'country': country.toUpperCase()},
        useCacheBuster: useCacheBuster);
  }

  String? lookupURLByQSP(Map<String, String> qsp,
      {bool useCacheBuster = true}) {
    if (qsp.isEmpty) {
      return null;
    }

    final parameters = <String>[];
    qsp.forEach((key, value) => parameters.add('$key=$value'));
    if (useCacheBuster) {
      parameters.add('_cb=${DateTime.now().microsecondsSinceEpoch.toString()}');
    }
    final finalParameters = parameters.join('&');

    return 'https://itunes.apple.com/lookup?$finalParameters';
  }

  Map<String, dynamic>? _decodeResults(String jsonResponse) {
    try {
      final decodedResults = json.decode(jsonResponse);
      return decodedResults;
    } catch (error) {
      print('upgrader: decodeResults error: $error');
    }
    return null;
  }
}

String? iosReleaseNotes(Map<String, dynamic> response) {
  try {
    return response['results'][0]['releaseNotes'];
  } catch (e) {
    print('Error getting iOS release notes: $e');
    return null;
  }
}

Future<AppCheckerResult> _checkPlayStore(
    String currentVersion, String packageName) async {
  String errorMsg = '';
  String? newVersion;
  String? releaseNotes;
  String? url;

  final uri =
      Uri.https('play.google.com', '/store/apps/details', {'id': packageName});

  try {
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      errorMsg =
          "Can't find an app in the Google Play Store with the id: $packageName";
    } else {
      releaseNotes = getReleaseNotes(parse(response.body));
      newVersion = RegExp(r',\[\[\["([0-9,\.]*)"]],')
              .firstMatch(response.body)
              ?.group(1) ??
          '';
      url = uri.toString();
    }
  } catch (e) {
    errorMsg = "$e";
  }
  return AppCheckerResult(
    currentVersion,
    newVersion,
    url ?? '',
    errorMsg,
    releaseNotes ?? '',
  );
}

String getReleaseNotes(Document response) {
  try {
    final sectionElements = response.getElementsByClassName('W4P4ne');
    final releaseNotesElement = sectionElements.firstWhere(
        (elm) => elm.querySelector('.wSaTQd')?.text == 'What\'s New',
        orElse: () => sectionElements[0]);

    Element? rawReleaseNotes =
        releaseNotesElement.querySelector('.PHBdkd')?.querySelector('.DWPxHb');
    String innerHtml = rawReleaseNotes?.innerHtml ?? '';
    return multilineReleaseNotes(innerHtml, rawReleaseNotes);
  } catch (e) {
    print('Error getting release notes: $e');
    return redesignedReleaseNotes(response) ?? '';
  }
}

String? redesignedReleaseNotes(Document response) {
  try {
    final sectionElements =
        response.querySelectorAll('[itemprop="description"]');
    Element rawReleaseNotes =
        sectionElements.isNotEmpty ? sectionElements.last : Element.tag('div');
    String innerHtml = rawReleaseNotes.innerHtml;
    return multilineReleaseNotes(innerHtml, rawReleaseNotes);
  } catch (e) {
    print('Error getting redesigned release notes: $e');
    return null;
  }
}

String multilineReleaseNotes(String innerHtml, Element? rawReleaseNotes) {
  try {
    final releaseNotesSpan = RegExp(r'>(.*?)</span>');
    String releaseNotes = releaseNotesSpan.hasMatch(innerHtml)
        ? releaseNotesSpan.firstMatch(innerHtml)?.group(1) ?? ''
        : rawReleaseNotes != null
            ? rawReleaseNotes.text
            : '';
    return releaseNotes.replaceAll('<br>', '\n');
  } catch (e) {
    print('Error processing multiline release notes: $e');
    return rawReleaseNotes != null ? rawReleaseNotes.text : '';
  }
}

class AppCheckerResult {
  final String currentVersion;
  final String? newVersion;
  final String appURL;
  final String errorMessage;
  final String releaseNotes;

  AppCheckerResult(
    this.currentVersion,
    this.newVersion,
    this.appURL,
    this.errorMessage,
    this.releaseNotes,
  );

  bool get canUpdate =>
      _shouldUpdate(currentVersion, newVersion ?? currentVersion);

  bool _shouldUpdate(String versionA, String versionB) {
    final versionNumbersA =
        versionA.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final versionNumbersB =
        versionB.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final maxSize = math.max(versionNumbersA.length, versionNumbersB.length);

    for (int i = 0; i < maxSize; i++) {
      final numA = i < versionNumbersA.length ? versionNumbersA[i] : 0;
      final numB = i < versionNumbersB.length ? versionNumbersB[i] : 0;

      if (numA > numB) return false;
      if (numA < numB) return true;
    }
    return false;
  }

  @override
  String toString() {
    return "Current Version: $currentVersion\nNew Version: $newVersion\nApp URL: $appURL\nCan Update: $canUpdate\nError: $errorMessage";
  }
}
