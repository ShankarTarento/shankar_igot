import 'dart:convert';
import 'package:http/http.dart' show Response;
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:igot_http_service_helper/services/http_service.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart'
    show ApiTtl;
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';
import 'package:smartech_base/smartech_base.dart';
import '../../constants/_constants/api_endpoints.dart';
import '../../constants/_constants/storage_constants.dart';
import 'package:intl/intl.dart';

class SmartechService {
  static Smartech get _smartechInstance => Smartech();
  static Smartech get INSTANCE => _smartechInstance;
  static String emptyField = '';
  static String dobEmptyField = '0000-00-00 00:00:00';
  static String _actionDevice = 'Mobile';
  static String _dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static final _storage = FlutterSecureStorage();
  static final netcoreDisabledAtOrg = _netcoreDisabledAtOrg;
  static bool _netcoreDisabledAtOrg = false;

  static final SmartechService _singleton = SmartechService._internal();

  SmartechService._internal();

  factory SmartechService() {
    return _singleton;
  }

  static Future<void> checkIsNetcoreActive() async {
    try {
      var response = await getOrgDetails();
      _netcoreDisabledAtOrg =
          response['result']['response']['netcoreDisabled'] ?? false;
    } catch (_) {
      _netcoreDisabledAtOrg = false;
    }
  }

  static Future<dynamic> getOrgDetails() async {
    String? organisationId = await _storage.read(key: Storage.deptId);
    if (organisationId == null) return;
    Map data;
    data = {
      'request': {'organisationId': organisationId}
    };

    String url = ApiUrl.baseUrl + ApiUrl.getOrgRead;
    Response response = await HttpService.post(
        apiUri: Uri.parse(url),
        headers: NetworkHelper.plainHeader(),
        body: data,
        ttl: ApiTtl.getOrgDetails);
    return jsonDecode(response.body);
  }

  static getUserData(Profile userObj, int? karmaPoints) {
    return {
      SMTUserProfileKeys.email: "${userObj.primaryEmail.toString()}",
      SMTUserProfileKeys.mobile:
          "${(userObj.personalDetails['mobile'] ?? emptyField).toString()}",
      SMTUserProfileKeys.fullName: '${(userObj.firstName).toString()}',
      SMTUserProfileKeys.profileDesignation:
          "${(userObj.designation).toString()}",
      SMTUserProfileKeys.organisation: "${(userObj.department).toString()}",
      SMTUserProfileKeys.profileGroup: "${(userObj.group).toString()}",
      SMTUserProfileKeys.profileStatus:
          "${(userObj.profileStatus ?? emptyField).toString()}",
      SMTUserProfileKeys.motherTongue:
          "${(userObj.personalDetails['domicileMedium'] ?? emptyField).toString()}",
    };
  }

  static String getCurrentDateInIST() {
    DateTime now = DateTime.now().toUtc().add(Duration(hours: 5, minutes: 30));
    return DateFormat(_dateTimeFormat).format(now);
  }

  /// SMT update user profile
  static Future<void> updateUserProfile(
      {required Profile userObj, int? karmaPoints}) async {
    await _smartechInstance
        .updateUserProfile(getUserData(userObj, karmaPoints));

    ///  Identifying users, After user update we should set user identity
    await _smartechInstance.setUserIdentity(userObj.id.toString());
  }

  /// SMT user updates profile data
  static Future<void> updateUserDetails(
      {required Profile userObj,
      int? karmaPoints,
      required bool isTrackProfileUpdateEnabled}) async {
    /// SMT update user profile
    updateUserProfile(userObj: userObj, karmaPoints: karmaPoints);

    /// SMT Track profile update
    if (isTrackProfileUpdateEnabled) trackProfileUpdate();
  }

  /// SMT user updates profile data in patch
  static Future<void> updateUserPatchDetail(
      {required BuildContext context,
      required Map<String, dynamic> userPatchData,
      required String profileAttributeUpdated,
      required bool isTrackProfileUpdateEnabled}) async {
    String userId = await _storage.read(key: Storage.userId) ?? '';
    await _smartechInstance.updateUserProfile(userPatchData);
    await _smartechInstance.setUserIdentity(userId);

    /// Track profile update
    if (isTrackProfileUpdateEnabled) trackProfileUpdate();
  }

  /// SMT report user login
  static void reportLogin(String userId) {
    _smartechInstance.login(userId);
  }

  /// SMT Track profile update event
  static Future<void> trackProfileUpdate() async {
    var payload = {
      SMTGenericKeys.actionTime: getCurrentDateInIST(),
      SMTGenericKeys.actionDevice: _actionDevice,
    };
    await _smartechInstance.trackEvent(SMTTrackEvents.profileUpdate, payload);
  }

  /// SMT Track user signIn event
  static Future<void> trackUserSignIn(Profile userObj) async {
    var payload = {
      SMTGenericKeys.actionTime: getCurrentDateInIST(),
      SMTGenericKeys.actionDevice: _actionDevice,
    };
    await _smartechInstance.trackEvent(SMTTrackEvents.userSignin, payload);
  }

  /// SMT Track content view event
  static Future<void> trackCourseView({
    required String courseCategory,
    required String courseName,
    required String image,
    required String contentUrl,
    required String doId,
    required int? courseDuration,
    required int learningPathContent,
    required String provider,
    double? courseRating,
    int? numberOfCourseRating,
  }) async {
    var payload = {
      SMTGenericKeys.actionTime: getCurrentDateInIST(),
      SMTGenericKeys.actionDevice: _actionDevice,
      SMTCourseKeys.contentName: courseName,
      SMTCourseKeys.contentCategory: courseCategory,
      SMTCourseKeys.contentId: doId,
      SMTCourseKeys.contentImage: image,
      SMTCourseKeys.contentUrl: contentUrl,
      SMTCourseKeys.contentDuration: courseDuration,
      if (courseRating != null) SMTCourseKeys.contentRating: courseRating,
      if (numberOfCourseRating != null)
        SMTCourseKeys.noUsersRated: numberOfCourseRating,
      SMTCourseKeys.learningPathContent: learningPathContent,
      SMTCourseKeys.contentProviderName: provider,
    };
    _smartechInstance.trackEvent(SMTTrackEvents.contentView, payload);
  }

  /// SMT Track content enroll
  static Future<void> trackCourseEnrolled({
    required String courseCategory,
    required String courseName,
    required String image,
    required String contentUrl,
    required String doId,
    required int courseDuration,
    required int learningPathContent,
    required String provider,
    double? courseRating,
    int? numberOfCourseRating,
  }) async {
    var payload = {
      SMTGenericKeys.actionTime: getCurrentDateInIST(),
      SMTGenericKeys.actionDevice: _actionDevice,
      SMTCourseKeys.contentName: courseName,
      SMTCourseKeys.contentCategory: courseCategory,
      SMTCourseKeys.contentId: doId,
      SMTCourseKeys.contentImage: image,
      SMTCourseKeys.contentUrl: contentUrl,
      SMTCourseKeys.contentDuration: courseDuration,
      if (courseRating != null) SMTCourseKeys.contentRating: courseRating,
      if (numberOfCourseRating != null)
        SMTCourseKeys.noUsersRated: numberOfCourseRating,
      SMTCourseKeys.learningPathContent: learningPathContent,
      SMTCourseKeys.contentProviderName: provider,
    };
    _smartechInstance.trackEvent(SMTTrackEvents.contentEnrolment, payload);
  }

  /// SMT Track content completion
  static Future<void> trackCourseCompleted({
    required String courseCategory,
    required String courseName,
    required String image,
    required String contentUrl,
    required String doId,
    required int courseDuration,
    required int learningPathContent,
    required String provider,
    double? courseRating,
    int? numberOfCourseRating,
  }) async {
    var payload = {
      SMTGenericKeys.actionTime: getCurrentDateInIST(),
      SMTGenericKeys.actionDevice: _actionDevice,
      SMTCourseKeys.contentName: courseName,
      SMTCourseKeys.contentCategory: courseCategory,
      SMTCourseKeys.contentId: doId,
      SMTCourseKeys.contentImage: image,
      SMTCourseKeys.contentUrl: contentUrl,
      SMTCourseKeys.contentDuration: courseDuration,
      if (courseRating != null) SMTCourseKeys.contentRating: courseRating,
      if (numberOfCourseRating != null)
        SMTCourseKeys.noUsersRated: numberOfCourseRating,
      SMTCourseKeys.learningPathContent: learningPathContent,
      SMTCourseKeys.contentProviderName: provider,
    };
    _smartechInstance.trackEvent(SMTTrackEvents.contentCompletion, payload);
  }

  /// SMT Track event view
  static Future<void> trackEventView({
    required String eventCategory,
    required String eventName,
    required String eventId,
    required String eventImage,
    required String eventUrl,
    required int eventDuration,
    required String eventProviderName,
  }) async {
    var payload = {
      SMTGenericKeys.actionTime: getCurrentDateInIST(),
      SMTGenericKeys.actionDevice: _actionDevice,
      SMTEventKeys.eventName: eventName,
      SMTEventKeys.eventCategory: eventCategory,
      SMTEventKeys.eventId: eventId,
      SMTEventKeys.eventImage: eventImage,
      SMTEventKeys.eventUrl: eventUrl,
      if (eventDuration != 0) SMTEventKeys.eventDuration: eventDuration,
      SMTEventKeys.eventProviderName: eventProviderName,
    };
    _smartechInstance.trackEvent(SMTTrackEvents.eventView, payload);
  }

  /// SMT Track event enroll
  static Future<void> trackEventEnroll({
    required String eventCategory,
    required String eventName,
    required String eventId,
    required String eventImage,
    required String eventUrl,
    required int eventDuration,
    required String eventProviderName,
  }) async {
    var payload = {
      SMTGenericKeys.actionTime: getCurrentDateInIST(),
      SMTGenericKeys.actionDevice: _actionDevice,
      SMTEventKeys.eventName: eventName,
      SMTEventKeys.eventCategory: eventCategory,
      SMTEventKeys.eventId: eventId,
      SMTEventKeys.eventImage: eventImage,
      SMTEventKeys.eventUrl: eventUrl,
      SMTEventKeys.eventDuration: eventDuration,
      SMTEventKeys.eventProviderName: eventProviderName,
    };
    _smartechInstance.trackEvent(SMTTrackEvents.eventEnrolment, payload);
  }

  /// SMT Track event completion
  static Future<void> trackEventCompletion({
    required String eventCategory,
    required String eventName,
    required String eventId,
    required String eventImage,
    required String eventUrl,
    required int eventDuration,
    required String eventProviderName,
  }) async {
    var payload = {
      SMTGenericKeys.actionTime: getCurrentDateInIST(),
      SMTGenericKeys.actionDevice: _actionDevice,
      SMTEventKeys.eventName: eventName,
      SMTEventKeys.eventCategory: eventCategory,
      SMTEventKeys.eventId: eventId,
      SMTEventKeys.eventImage: eventImage,
      SMTEventKeys.eventUrl: eventUrl,
      SMTEventKeys.eventDuration: eventDuration,
      SMTEventKeys.eventProviderName: eventProviderName,
    };
    _smartechInstance.trackEvent(SMTTrackEvents.eventCompletion, payload);
  }
}

class SMTUserProfileKeys {
  static const String email = 'email';
  static const String mobile = 'mobile';
  static const String fullName = 'full_name';
  static const String gender = 'gender';
  static const String profileDesignation = 'profile_designation';
  static const String organisation = 'organisation';
  static const String noOfKarmaPoints = 'no_of_karma_points';
  static const String profilePhoto = 'profile_photo';
  static const String profileGroup = 'profile_group';
  static const String profileStatus = 'profile_status';
  static const String motherTongue = 'mother_tongue';
}

class SMTTrackEvents {
  static const String profileUpdate = 'profile_update';
  static const String contentView = 'content_view';
  static const String contentEnrolment = 'content_enrolment';
  static const String contentCompletion = 'content_completion';
  static const String userSignin = 'user_signin';
  static const String eventView = 'event_view';
  static const String eventEnrolment = 'event_enrolment';
  static const String eventCompletion = 'event_completion';
  static const String userProfilePush = 'user_profile_push';
}

class SMTGenericKeys {
  static const String actionTime = 'action_time';
  static const String actionDevice = 'action_device';
}

class SMTCourseKeys {
  static const String contentName = 'content_name';
  static const String contentCategory = 'content_category';
  static const String contentId = 'content_id';
  static const String contentImage = 'content_image';
  static const String contentUrl = 'content_url';
  static const String contentDuration = 'content_duration';
  static const String contentRating = 'content_rating';
  static const String noUsersRated = 'no_users_rated';
  static const String learningPathContent = 'learning_path_content';
  static const String contentProviderName = 'content_provider_name';
}

class SMTEventKeys {
  static const String eventName = 'event_name';
  static const String eventCategory = 'event_category';
  static const String eventId = 'event_id';
  static const String eventImage = 'event_image';
  static const String eventUrl = 'event_url';
  static const String eventDuration = 'event_duration';
  static const String eventRating = 'event_rating';
  static const String noUsersRated = 'no_users_rated';
  static const String eventProviderName = 'event_provider_name';
}
