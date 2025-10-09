import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/models/_models/event_detailv2_model.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/login_error_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../localization/index.dart';
import '../models/_models/event_model.dart';
import '../models/_models/nodal_model.dart';
import '../models/index.dart';
import '../respositories/index.dart';
import '../ui/widgets/self_registration/nodal_list_widget.dart';
import './../constants/index.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import 'package:device_calendar/device_calendar.dart' as dc;

class Helper {
  final dc.DeviceCalendarPlugin _deviceCalendarPlugin =
      dc.DeviceCalendarPlugin();

  static bool get itsProdRelease =>
      APP_ENVIRONMENT == Environment.prod && kReleaseMode;
  static String getInitials(String name) {
    final _whitespaceRE = RegExp(r"\s+");
    String cleanupWhitespace(String input) =>
        input.replaceAll(_whitespaceRE, " ");
    name = cleanupWhitespace(name);
    if (name.trim().isNotEmpty) {
      return name
          .trim()
          .split(' ')
          .map((l) => l[0])
          .take(2)
          .join()
          .toUpperCase();
    } else {
      return '';
    }
  }

  static String getInitialsNew(String name) {
    String shortCode = 'UN';
    if (name != '') {
      name = name.trim();
      name = name.replaceAll(RegExp(r'\s+'), ' ');
      List temp = name.split(' ');
      if (temp.length > 1) {
        shortCode = temp[0][0].toUpperCase() + temp[1][0].toUpperCase();
      } else if (temp[0] != '') {
        // shortCode = temp[0][0].toUpperCase() + temp[0][1].toUpperCase();
        shortCode = temp[0][0].toUpperCase();
      }
    }
    return shortCode;
  }

  static int calculateProfilePercent(profile) {
    double count = 30;
    if (profile.education.length != 0 &&
        (profile.education[0]['nameOfInstitute'] != '' ||
            profile.education[0]['nameOfQualification'] != '')) {
      count += 23;
    }
    if (profile.department != '' && profile.department != null) {
      count += 11.43;
    }
    if (profile.personalDetails['nationality'] != '' &&
        profile.personalDetails['nationality'] != null) {
      count += 11.43;
    }
    if (profile.photo != '' && profile.photo != null) {
      count += 11.43;
    }
    if (profile.designation != '' && profile.designation != null) {
      count += 11.43;
    }
    if (profile.skills != null) {
      if (profile.skills['additionalSkills'] != '' &&
          profile.skills['additionalSkills'] != null) {
        count += 11.43;
      }
    }
    if (profile.interests != null) {
      if (profile.interests['hobbies'] != null) {
        if (profile.interests['hobbies'].length > 0) {
          count += 11.43;
        }
      }
    }
    if (count > 100) {
      count = 100;
    }
    return count.round();
  }

  static capitalize(String s) {
    if (s.trim().isNotEmpty && (s[0] != '')) {
      return s[0].toUpperCase() + s.substring(1).toLowerCase();
    } else
      return s;
  }

  static capitalizeFirstLetter(String s) {
    if (s.trim().isNotEmpty && (s[0] != '')) {
      return s[0].toUpperCase() + s.substring(1);
    } else
      return s;
  }

  static getByteImage(base64Image) {
    dynamic _bytes = base64.decode(base64Image.split(',').last);
    return _bytes;
  }

  static getFileName(String url) {
    File file = new File(url);
    String fullFileName = file.path.split('/').last;
    List fileName = fullFileName.split('.');
    return fileName[0];
  }

  static getFileExtension(String url) {
    File file = new File(url);
    String fullFileName = file.path.split('/').last;
    List fileName = fullFileName.split('.');
    return fileName[fileName.length - 1];
  }

  static bool isSessionLive(SessionDetailV2 session) {
    try {
      DateTime sessionDate = DateTime.parse(session.startDate);
      TimeOfDay startTime =
          DateTimeHelper.getTimeIn24HourFormat(session.startTime);
      DateTime sessionStartEndTime = DateTime(
          sessionDate.year,
          sessionDate.month,
          sessionDate.day,
          startTime.hour +
              (int.parse((session.sessionDuration).split('hr')[0])) +
              AttendenceMarking.bufferHour,
          startTime.minute);
      final bool isLive = (DateTime.now().isBefore(sessionStartEndTime));
      return isLive;
    } catch (e) {
      return false;
    }
  }

  // static bool isTokenExpired(String token) {
  //   // print('isTokenExpired...');
  //   bool isTokenExpired = JwtDecoder.isExpired(token);
  //   if (isTokenExpired) {
  //     Provider.of<LoginRespository>(navigatorKey.currentContext!, listen: false)
  //         .doLogout(navigatorKey.currentContext!);
  //   }
  //   return isTokenExpired;
  // }

  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  static showErrorScreen(context, String errorMsg, {int? statusCode}) {
    return Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginErrorPage(
          errorText: errorMsg,
          isHtmlErrorPage: statusCode == 401,
        ),
      ),
    );
  }

  static showErrorPopup(context, String errorMsg, {int? statusCode}) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Unable to fetch the data',
            style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                letterSpacing: 0.12,
                height: 1.5)),
        content: Text(
          'Please try after sometime',
          style: GoogleFonts.lato(
              color: AppColors.greys87,
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              letterSpacing: 0.25,
              height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8).w,
        actions: <Widget>[
          Container(
            width: 87.w,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryThree,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.mStaticOk,
                style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.appBarBackground,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static convertToPortalUrl(String s) {
    String cleaned = s.replaceAll("http://", "https://");
    return cleaned.replaceAll(Env.baseUrl, Env.portalBaseUrl);
  }

  /// replaces all HTTP occurances to HTTPS, passing replaceFirst to true will only update first occurance
  static upgradeToHttps(String uri, {bool replaceFirst = false}) {
    String secureUri = replaceFirst
        ? uri.replaceFirst("http://", "https://")
        : uri.replaceAll("http://", "https://");
    return secureUri;
  }

  static upgradeGoogleAPI(String uri) {
    String updatedUri = uri.replaceFirst(
        'https://storage.googleapis.com/igotprod',
        '${ApiUrl.baseUrl}${Env.cdnBucket}');
    return updatedUri;
  }

  static String convertImageUrl(String? url, {bool pointToProd = false}) {
    if (url != null) {
      if (url.contains('thumbnails/generated')) {
        return url;
      }
      String cleaned = url.replaceAll("http://", "https://");
      List urlParts = cleaned.split('/content');
      return (pointToProd ? 'https://portal.igotkarmayogi.gov.in' : Env.host) +
          '/' +
          Env.bucket +
          '/content' +
          urlParts.last;
    }
    return '';
  }

  static convertPortalImageUrl(String? url) {
    String? splitValue;
    if (url != null) {
      if (APP_ENVIRONMENT == Environment.dev) {
        splitValue = EnvironmentValues.igot.name;
      } else if (APP_ENVIRONMENT == Environment.qa) {
        splitValue = EnvironmentValues.igotqa.name;
      } else if (APP_ENVIRONMENT == Environment.uat) {
        splitValue = EnvironmentValues.igotuat.name;
      } else if (APP_ENVIRONMENT == Environment.prod) {
        splitValue = EnvironmentValues.igotprod.name;
      }
      List urlParts = (url.contains(splitValue!))
          ? url.split(splitValue)
          : url.split(EnvironmentValues.igot.name);
      return Env.host + Env.bucket + urlParts.last;
    }
  }

  static extractIntegerOnly(String s) {
    String result = s.replaceAll(new RegExp(r'[^0-9]'), '');
    return int.parse(result[0]);
  }

  static getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory(APP_DOWNLOAD_FOLDER);
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      }
    } catch (err) {
      throw "Cannot get download folder path";
    }
    return directory?.path;
  }

  static getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    return appDocumentsPath;
  }

  static generateRandomString() {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890-';
    Random _rnd = Random();

    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String randomString = getRandomString(16);
    return randomString;
  }

  String capitalizeFirstCharacter(String word) {
    if (word.isEmpty) return word;
    return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
  }

  static String capitalizeEachWordFirstCharacter(String word) {
    String formattedText = word
        .split(' ')
        .map((element) => textToTitleCase(element))
        .toList()
        .join(' ');
    return formattedText;
  }

  static String textToTitleCase(String text) {
    if (text.length > 1) {
      return text[0].toUpperCase() + text.substring(1);
    } else if (text.length == 1) {
      return text[0].toUpperCase();
    }
    return '';
  }

  static int getRandomNumber({required int range}) {
    Random random = new Random();
    return random.nextInt(range);
  }

  static Future<String?> networkImageToBase64(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    final bytes = response.bodyBytes;
    return base64Encode(bytes);
  }

  static getFormattedTopic(List<String> topics) {
    return topics.join('_');
  }

  static showSnackBarMessage(
      {required BuildContext context,
      required String? text,
      int? durationInSec,
      required Color? bgColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: durationInSec ?? 2),
        content: Text(text ?? "",
            style: GoogleFonts.lato(
              color: AppColors.appBarBackground,
            )),
        backgroundColor: bgColor,
      ),
    );
  }

  static Future<void> doLaunchUrl(
      {required String url,
      LaunchMode mode = LaunchMode.platformDefault}) async {
    if (Platform.isIOS) {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: mode);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      await launchUrl(
        Uri.parse(url),
        mode: mode,
      );
    }
  }

  static String getLinkedlnUrlToShareCertificate(String certificateId) {
    return ApiUrl.linkedlnUrlToShareCertificate
        .replaceAll('#certId', certificateId);
  }

  static String numberWithSuffix(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  static String generateCdnUri(String? artifactUri) {
    if (artifactUri == null) return '';
    try {
      var chunk = artifactUri.split('/');
      String host = Env.cdnHost;
      String bucket = Env.cdnBucket;
      var newChunk = host.split('/');
      var newLink = [];
      for (var i = 0; i < chunk.length; i += 1) {
        if (i == 2 || i == 0) {
          newLink.add(newChunk[i]);
        } else if (i == 3) {
          newLink.add(bucket.substring(1));
        } else {
          newLink.add(chunk[i]);
        }
      }
      String newUrl = newLink.join('/');
      return newUrl;
    } catch (e) {
      return artifactUri;
    }
  }

  static Future<Locale> getLocale() async {
    final _storage = FlutterSecureStorage();
    String? selectedAppLanguage =
        await _storage.read(key: Storage.selectedAppLanguage);
    Locale _locale;

    if (selectedAppLanguage == null) {
      final String deviceLocale =
          Platform.localeName.split('_').first.toString();
      switch (deviceLocale) {
        case AppLocale.hindi:
          _locale = Locale(AppLocale.hindi);
          break;

        case AppLocale.marathi:
          _locale = Locale(AppLocale.marathi);
          break;

        case AppLocale.tamil:
          _locale = Locale(AppLocale.tamil);
          break;

        case AppLocale.assamese:
          _locale = Locale(AppLocale.assamese);
          break;

        case AppLocale.bengali:
          _locale = Locale(AppLocale.bengali);
          break;

        case AppLocale.telugu:
          _locale = Locale(AppLocale.telugu);
          break;

        case AppLocale.kannada:
          _locale = Locale(AppLocale.kannada);
          break;

        case AppLocale.malaylam:
          _locale = Locale(AppLocale.malaylam);
          break;

        case AppLocale.gujarati:
          _locale = Locale(AppLocale.gujarati);
          break;

        case AppLocale.oriya:
          _locale = Locale(AppLocale.oriya);
          break;

        case AppLocale.punjabi:
          _locale = Locale(AppLocale.punjabi);
          break;

        default:
          _locale = Locale(AppLocale.english);
      }
    } else {
      _locale = Locale(jsonDecode(selectedAppLanguage)['value']);
    }
    return _locale;
  }

  static String getProviderName(String url) {
    RegExp regExp = RegExp(r'provider/([^/]+)/');
    var match = regExp.firstMatch(url);

    return match?.group(1) ?? '';
  }

  static String getProviderId(String url) {
    RegExp regExp = RegExp(r'provider/[^/]+/([^/]+)/');
    var match = regExp.firstMatch(url);

    return match?.group(1) ?? '';
  }

  static String decodeHtmlEntities(String? htmlString) {
    if (htmlString == null || htmlString == '')
      return '';
    else
      return htmlString
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&apos;', "'")
          .replaceAll('&amp;', '&')
          .replaceAll('&nbsp;', ' ');
  }

  static String? extractDoIdFromString(String url) {
    final regex = RegExp(r'do_\d+');
    final match = regex.firstMatch(url);
    if (match != null) {
      return match.group(0) ?? '';
    } else {
      return null;
    }
  }

  static String? extractExternalCourseDoIdFromString(String url) {
    final regex = RegExp(r'ext_\d+');
    final match = regex.firstMatch(url);
    if (match != null) {
      return match.group(0) ?? '';
    } else {
      return null;
    }
  }

  static String getMdoName(String url) {
    RegExp regExp = RegExp(r'mdo-channels/([^/]+)/');
    var match = regExp.firstMatch(url);

    return match?.group(1) ?? '';
  }

  static String getMdoId(String url) {
    RegExp regExp = RegExp(r'mdo-channels/[^/]+/([^/]+)/');
    var match = regExp.firstMatch(url);

    return match?.group(1) ?? '';
  }

  static String getUserId(String url) {
    RegExp regExp = RegExp(r'person-profile/([a-zA-Z0-9\-]{10,})($|#)');
    var match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  static dynamic handleNumber(dynamic number) {
    if (number is double && number == number.toInt()) {
      return number.toInt();
    }
    return number;
  }

  static bool isHtml(String text) {
    return RegExpressions.htmlValidator.hasMatch(text);
  }

  static void showToastMessage(BuildContext context,
      {String? title, String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Column(
      children: [
        Text(title ?? ''),
        Text(
          message ?? '',
          textAlign: TextAlign.center,
        ),
      ],
    )));
  }

  bool checkAllBatchEndDateOver(course) {
    bool batchstatus = true;
    if (course['batches'] != null) {
      course['batches'].forEach((batch) {
        if (batchstatus == true) {
          if (batch['endDate'] != null) {
            if (DateTime.parse(batch['endDate']).isAfter(DateTime.now()) ||
                (DateTimeHelper.getDateTimeInFormat(batch['endDate']) ==
                    (DateTimeHelper.getDateTimeInFormat(
                        DateTime.now().toString())))) {
              batchstatus = false;
            }
          }
        }
      });
    }
    return batchstatus;
  }

  static String getImageExtension(String url) {
    return url.substring(url.length - 3);
  }

  static String getid(dynamic data) {
    String id = '';
    if (data != null) {
      if (APP_ENVIRONMENT == Environment.dev) {
        if (data['dev'] != null) {
          id = data['dev']['id'];
        }
      } else if (APP_ENVIRONMENT == Environment.qa) {
        if (data['qa'] != null) {
          id = data['qa']['id'];
        }
      } else if (APP_ENVIRONMENT == Environment.uat) {
        if (data['uat'] != null) {
          id = data['uat']['id'];
        }
      } else if (APP_ENVIRONMENT == Environment.prod) {
        if (data['prod'] != null) {
          id = data['prod']['id'];
        }
      }
    }
    return id;
  }

  static bool isMdoChannelEnabled(dynamic data) {
    bool isEnabled = false;
    if (data != null) {
      if (APP_ENVIRONMENT == Environment.dev) {
        if (data['dev'] != null) {
          isEnabled = data['dev']['active'];
        }
      } else if (APP_ENVIRONMENT == Environment.qa) {
        if (data['qa'] != null) {
          isEnabled = data['qa']['active'];
        }
      } else if (APP_ENVIRONMENT == Environment.uat) {
        if (data['uat'] != null) {
          isEnabled = data['uat']['active'];
        }
      } else if (APP_ENVIRONMENT == Environment.prod) {
        if (data['prod'] != null) {
          isEnabled = data['prod']['active'];
        }
      }
    }
    return isEnabled;
  }

  static String? extractOrgIdFromString(String url) {
    RegExp regex = RegExpressions.extractOrgIdFromRegisterLink;
    Match? match = regex.firstMatch(url);

    if (match != null) {
      return match.group(1) ?? '';
    } else {
      return null;
    }
  }

  static bool isEventLive(
      {required String startDate,
      required String endDate,
      required String startTime,
      required String endTime}) {
    try {
      int timestampNow = DateTime.now().millisecondsSinceEpoch;

      String start = startDate + ' ' + formatTime(startTime);
      DateTime eventstartDate = DateTime.parse(start);
      int timestampStartEvent = eventstartDate.microsecondsSinceEpoch;
      double eventStartTime = timestampStartEvent / 1000;

      String expiry = endDate + ' ' + formatTime(endTime);
      DateTime expireDate = DateTime.parse(expiry);
      int timestampExpireEvent = expireDate.microsecondsSinceEpoch;
      double eventExpireTime = timestampExpireEvent / 1000;

      return timestampNow <= eventExpireTime && timestampNow >= eventStartTime;
    } catch (e) {
      debugPrint("Error checking if event is live: $e");
      return false;
    }
  }

  static bool isEventCompleted(Event event) {
    int timestampNow = DateTime.now().millisecondsSinceEpoch;
    String expiry = event.endDate + ' ' + formatTime(event.endTime);
    DateTime expireDate = DateTime.parse(expiry);
    int timestampExpireEvent = expireDate.microsecondsSinceEpoch;
    double eventExpireTime = timestampExpireEvent / 1000;

    return timestampNow > eventExpireTime;
  }

  static formatTime(time) {
    return time.substring(0, 5);
  }

  static bool isValidRegistrationLink(String code) {
    final regex = RegExpressions.registrationLink;
    if (regex.hasMatch(code) && code.startsWith(ApiUrl.baseUrl)) {
      return true;
    } else {
      return false;
    }
  }

  static convertGCPImageUrl(String? url) {
    String? splitValue;
    if (url != null) {
      splitValue = '${APP_ENVIRONMENT.split('.env.').last}/';
      if (url.contains(splitValue)) {
        List urlParts = url.split(splitValue);
        return Env.host + Env.bucket + '/' + urlParts.last;
      }
      return url;
    }
  }

  static Color hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0x')));
  }

  static Future<bool> mailTo(String mailId) async {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: mailId,
    );

    return await launchUrl(Uri.parse(_emailLaunchUri.toString()));
  }

  static Future<void> registrationClosed(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32.0),
                  topRight: Radius.circular(32.0))
              .r,
        ),
        builder: (contxt) {
          return Container(
            padding: EdgeInsets.fromLTRB(24, 40, 24, 80).r,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 1.0.sw,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24).r,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 0.69.sw,
                          child: Text(
                              AppLocalizations.of(context)!
                                  .mSelfRegisterRegistrationClosed,
                              maxLines: 2,
                              style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.sp,
                                  letterSpacing: 0.25)),
                        ),
                        Container(
                          padding: EdgeInsets.all(2).r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.greys60,
                          ),
                          child: InkWell(
                              onTap: () {
                                Navigator.of(contxt).pop();
                              },
                              child: Icon(Icons.close,
                                  size: 24.sp,
                                  color: AppColors.appBarBackground)),
                        )
                      ],
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!
                      .mSelfRegisterRegistrationClosedDescription,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton(
                  onPressed: () async {
                    List<NodalModel> nodalUsers =
                        await ProfileRepository().getNodalUser();
                    await showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.appBarBackground,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: AppColors.grey08),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ).r,
                        ),
                        builder: (context) => SafeArea(
                              child: Container(
                                height: 0.85.sh,
                                child: NodalListWidget(nodalList: nodalUsers),
                              ),
                            ));
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4).r,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.mStaticClickHere,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: AppColors.appBarBackground)),
                )
              ],
            ),
          );
        });
  }

  static Future<void> verifyLinkAndShowMessage(
      String linkValidationMessage, BuildContext context) async {
    if (linkValidationMessage.toLowerCase() ==
            EnglishLang.linkUniquecodeInactive.toLowerCase() ||
        linkValidationMessage.toLowerCase() ==
            EnglishLang.linkWithInvalidOrg.toLowerCase()) {
      Helper.showToastMessage(context, message: linkValidationMessage);
    } else {
      await Helper.registrationClosed(context);
    }
  }

  static String extractEmailDomain(String email) {
    if (email.contains('@')) {
      return email.split('@').last;
    }
    return '';
  }

  static List<Event> getSortedEvents({required List<Event> events}) {
    List<Event> sortedEvents = [];
    List<Event> liveEvents = [];
    List<Event> completedEvents = [];
    List<Event> upcomingEvents = [];

    for (var event in events) {
      if (getEventStatus(
              endDate: event.endDate.toString(),
              endTime: event.endTime.toString(),
              startDate: event.startDate.toString(),
              startTime: event.startTime.toString()) ==
          EnglishLang.started) {
        liveEvents.add(event);
      } else if (getEventStatus(
              endDate: event.endDate.toString(),
              endTime: event.endTime.toString(),
              startDate: event.startDate.toString(),
              startTime: event.startTime.toString()) ==
          EnglishLang.notStarted) {
        upcomingEvents.add(event);
      } else if (getEventStatus(
              endDate: event.endDate.toString(),
              endTime: event.endTime.toString(),
              startDate: event.startDate.toString(),
              startTime: event.startTime.toString()) ==
          EnglishLang.completed) {
        completedEvents.add(event);
      }
    }

    sortedEvents.addAll(sortList(listOfEvents: liveEvents) +
        sortList(listOfEvents: upcomingEvents) +
        sortList(listOfEvents: completedEvents, ascending: false));
    return sortedEvents;
  }

  static String getEventStatus(
      {required String startDate,
      required String endDate,
      required String startTime,
      required String endTime}) {
    try {
      int timestampNow = DateTime.now().millisecondsSinceEpoch;

      // Combining date and time for start event
      String start = startDate + ' ' + formatTime(startTime);
      DateTime eventStartDate = DateTime.parse(start);
      int timestampStartEvent = eventStartDate.microsecondsSinceEpoch;
      double eventStartTime = timestampStartEvent / 1000;

      // Combining date and time for end event
      String expiry = endDate + ' ' + formatTime(endTime);
      DateTime expireDate = DateTime.parse(expiry);
      int timestampExpireEvent = expireDate.microsecondsSinceEpoch;
      double eventExpireTime = timestampExpireEvent / 1000;

      // Checking event status
      if (timestampNow > eventExpireTime) {
        return EnglishLang.completed;
      } else if (timestampNow <= eventExpireTime &&
          timestampNow >= eventStartTime) {
        return EnglishLang.started;
      } else {
        return EnglishLang.notStarted;
      }
    } catch (e) {
      print("Error in getEventStatus: $e");
      return "Error in processing event status";
    }
  }

  static List<Event> sortList(
      {required List<Event> listOfEvents, bool ascending = true}) {
    listOfEvents.sort((a, b) {
      String startA = '${a.startDate} ${formatTime(a.startTime)}';
      String startB = '${b.startDate} ${formatTime(b.startTime)}';

      DateTime dateA = DateTime.parse(startA);
      DateTime dateB = DateTime.parse(startB);

      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    return listOfEvents;
  }

  static String formatEventDateTime(String date, String timeWithZone) {
    try {
      String combinedDateTime = date + ' ' + Helper.formatTime(timeWithZone);

      DateTime dateTime = DateTime.parse(combinedDateTime);

      return DateFormat(IntentType.dateFormat7).format(dateTime);
    } catch (e) {
      return "";
    }
  }

  static String getDuration({required int durationInMinutes}) {
    if (durationInMinutes < 60) {
      return '${durationInMinutes} min${durationInMinutes == 1 ? '' : 's'}';
    } else {
      int hours = durationInMinutes ~/ 60;
      int minutes = durationInMinutes % 60;

      String hoursText = '$hours hr';
      String minutesText =
          minutes > 0 ? ' ${minutes} min${minutes == 1 ? '' : 's'}' : '';

      hoursText += hours == 1 ? '' : 's';

      return hoursText + minutesText;
    }
  }

//functions to add event to calendar
  Future<bool> requestCalendarPermissions() async {
    dc.Result<bool> permissionStatus =
        await _deviceCalendarPlugin.hasPermissions();
    if (permissionStatus.data != null && !permissionStatus.data!) {
      permissionStatus = await _deviceCalendarPlugin.requestPermissions();
    }
    return permissionStatus.data!;
  }

  Future<void> addEventToCalendar(
      {required BuildContext context, required EventDetailV2 event}) async {
    if (!await requestCalendarPermissions()) {
      debugPrint("Calendar permission not granted.");
      return;
    }

    var calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess ||
        calendarsResult.data == null ||
        calendarsResult.data!.isEmpty) {
      debugPrint("No calendars found");
      return;
    }

    dc.Calendar? calendar =
        calendarsResult.data!.cast<dc.Calendar?>().firstWhere(
              (cal) => cal != null && !cal.isReadOnly!,
              orElse: () => null,
            );
    if (calendar == null) {
      debugPrint("No writable calendar found.");
      return;
    }

    dc.TZDateTime startTime = tz.TZDateTime.from(
        DateTime.parse(
            event.startDate + ' ' + Helper.formatTime(event.startTime)),
        tz.local);
    dc.TZDateTime endTime = tz.TZDateTime.from(
        DateTime.parse(event.endDate + ' ' + Helper.formatTime(event.endTime)),
        tz.local);

    dc.Event calendarEvent = dc.Event(
      calendar.id,
      title: event.name,
      description:
          'Click here to join this event ${ApiUrl.baseUrl}/app/event-hub/home/${event.identifier}?batchId=${event.batches?[0].batchId}',
      start: startTime,
      end: endTime,
      reminders: [dc.Reminder(minutes: 10)],
    );

    var result = await _deviceCalendarPlugin.createOrUpdateEvent(calendarEvent);
    if (result?.isSuccess ?? false) {
      Helper.showSnackBarMessage(
          context: context,
          text: "Event added to calendar successfully",
          bgColor: AppColors.darkBlue);
    } else {
      debugPrint(
          'Failed to add event to calendar: ${result?.errors ?? "Unknown error"}');
    }
  }

  static void showSnackbarWithCloseIcon(BuildContext context, String message,
      {Color backgroundColor = AppColors.positiveLight}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16).r,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 16).r,
            decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8).r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_rounded,
                        size: 24.sp, color: AppColors.appBarBackground),
                    SizedBox(width: 4.w),
                    Text(message,
                        style: Theme.of(context).textTheme.displaySmall),
                  ],
                ),
                SizedBox(
                  width: 30.w,
                  child: IconButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                      icon: Icon(Icons.close,
                          size: 24.sp, color: AppColors.appBarBackground)),
                )
              ],
            ),
          )),
    );
  }

  static String getEventStatusBasedOnDate({required Event event}) {
    try {
      DateTime startDate = DateTime.parse(event.startDate);

      DateTime expireDate = DateTime.parse(event.endDate);

      DateTime now = DateTime.now();
      DateTime currentDate = DateTime(now.year, now.month, now.day);

      if (startDate == currentDate) {
        return EnglishLang.today;
      }

      if (currentDate.isAfter(expireDate)) {
        return EnglishLang.past;
      }

      if (currentDate.isBefore(startDate)) {
        return EnglishLang.upcoming;
      }
    } catch (e) {
      debugPrint("--------$e");
      return "";
    }
    return "";
  }

  static DateTime trimDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static int getTimeDiff(String date1, String date2) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date2))))
        .inDays;
  }

  static bool checkUniqueCourse(Course newItem, List<Course> allCourses) {
    bool isUnique = true;
    if (allCourses.isNotEmpty) {
      for (Course element in allCourses) {
        if (element.id == newItem.id) {
          if (getTimeDiff(element.endDate!, newItem.endDate!) < 0) {
            allCourses.remove(element);
            break;
          } else {
            isUnique = false;
          }
        }
      }
    }
    return isUnique;
  }

  static List<String> filterDoIds(List<Course> list) {
    List<String> doIdList = [];
    list.forEach((data) {
      if (data.courseCategory == PrimaryCategory.multilingualCourse) {
        String? id = getBaseCourseId(data);
        if (id != null) {
          doIdList.add(id);
        }
      } else {
        doIdList.add(data.id);
      }
    });
    return doIdList;
  }

  static bool invertYesNo(String input) {
    if (input.toLowerCase() == EnglishLang.yes.toLowerCase()) {
      return true;
    } else if (input.toLowerCase() == EnglishLang.no.toLowerCase()) {
      return false;
    } else {
      return false;
    }
  }

  static String? getBaseCourseId(Course data) {
    if (data.languageMap.languages.isNotEmpty) {
      for (final language in data.languageMap.languages.entries) {
        if (language.value.isBaseLanguage) {
          return language.value.id;
        }
      }
    }
    return null;
  }

  static String decodeEmailPlaceholders(String email) {
    String updatedEmail = email.replaceAll('[at]', '@');
    updatedEmail = updatedEmail.replaceAll('[dot]', '.');
    return updatedEmail;
  }
}
