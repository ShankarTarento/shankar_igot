import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/models/_models/telemetry_event_model.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:unique_identifier/unique_identifier.dart';
import '../localization/index.dart';
import './../constants/index.dart';

class TelemetryRepository {
  String? _userSessionId;
  String? get userSessionId => _userSessionId;
  String? _deviceIdentifier;
  String? get deviceIdentifier => _deviceIdentifier;
  String _userId = EnglishLang.anonymousUser;
  String get userId => _userId;
  String _departmentId = '';
  String get departmentId => _departmentId;
  final _storage = FlutterSecureStorage();
  static final TelemetryRepository _singleTon = TelemetryRepository._internal();

  TelemetryRepository._internal();
  factory TelemetryRepository() {
    return _singleTon;
  }

  Future<void> generateTelemetryRequiredData() async {
    await generateUserSessionId(isAppStarted: true);
    await getDeviceIdentifier();
    await getUserId();
    await getUserDeptId();
    // log('UserSessionId: $userSessionId, DeviceIdentifier: $deviceIdentifier, UserId: $userId, UserDeptId: $departmentId');
  }

  Future<String> generateUserSessionId({bool isAppStarted = false}) async {
    String? sessionId = await _storage.read(key: Storage.sessionId);
    if (sessionId == null || isAppStarted) {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String hash = md5.convert(utf8.encode(timestamp)).toString();
      _storage.write(key: Storage.sessionId, value: hash);
      _userSessionId = hash;
      // notifyListeners();
      return hash;
    } else {
      _userSessionId = sessionId;
      // notifyListeners();
      return sessionId;
    }
  }

  Future<String?> getUserId({bool isPublic = false}) async {
    String? userId = !isPublic ? await _storage.read(key: Storage.wid) : null;
    _userId = userId ?? '';
    return userId;
  }

  getUserNodeBbUid() async {
    String? nodebbUserId = await _storage.read(key: Storage.nodebbUserId);
    return nodebbUserId;
  }

  Future<String?> getUserDeptId({bool isPublic = false}) async {
    String? deptId =
        !isPublic ? await _storage.read(key: Storage.deptId) : null;
    _departmentId = deptId ?? '';
    // notifyListeners();
    return deptId;
  }

  Future<String> getDeviceIdentifier() async {
    String? identifier;
    try {
      identifier = await UniqueIdentifier.serial;
    } on PlatformException {
      identifier = 'Failed to get Unique Identifier';
    }
    identifier = sha256.convert(utf8.encode(identifier!)).toString();
    _storage.write(key: Storage.deviceIdentifier, value: identifier);
    _deviceIdentifier = identifier;
    // notifyListeners();
    return identifier;
  }

  static generateMessageId() {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String hash = md5.convert(utf8.encode(timestamp)).toString();
    return hash;
  }

  getStartTelemetryEvent(
      {required String pageIdentifier,
      required String telemetryType,
      required String pageUri,
      required String env,
      String? objectId,
      String? objectType,
      bool isPublic = false,
      String? l1}) {
    String messageIdentifier = generateMessageId();
    Map eventData = {
      'eid': TelemetryEvent.start,
      'ets': DateTime.now().millisecondsSinceEpoch,
      'ver': TELEMETRY_EVENT_VERSION,
      'mid': '${TelemetryEvent.start}:$messageIdentifier',
      'actor': {
        'id': userId,
        'type': isPublic ? EnglishLang.anonymousUser : 'User'
      },
      'context': {
        'channel': departmentId,
        'pdata': {
          'id': TELEMETRY_PDATA_ID,
          'ver': APP_VERSION,
          'pid': TELEMETRY_PDATA_PID
        },
        'env': env,
        'sid': userSessionId,
        'did': deviceIdentifier,
        'cdata': []
      },
      'object': {
        'id': objectId,
        'type': objectType,
        'rollup': l1 != null ? {'l1': l1} : {}
      },
      'tags': [],
      'edata': {
        'type': telemetryType,
        'mode': telemetryType == TelemetryType.player
            ? TelemetryMode.play
            : TelemetryMode.view,
        'pageid': pageIdentifier,
      }
    };
    return eventData;
  }

  getEndTelemetryEvent(
      {required String pageIdentifier,
      required int duration,
      required String telemetryType,
      required String pageUri,
      required Map rollup,
      required String env,
      String? objectId,
      String? objectType,
      bool isPublic = false,
      String? l1}) {
    String messageIdentifier = generateMessageId();
    Map eventData = {
      'eid': TelemetryEvent.end,
      'ets': DateTime.now().millisecondsSinceEpoch,
      'ver': TELEMETRY_EVENT_VERSION,
      'mid': '${TelemetryEvent.end}:$messageIdentifier',
      'actor': {
        'id': userId,
        'type': isPublic ? EnglishLang.anonymousUser : 'User'
      },
      'context': {
        'channel': departmentId,
        'pdata': {
          'id': TELEMETRY_PDATA_ID,
          'ver': APP_VERSION,
          'pid': TELEMETRY_PDATA_PID
        },
        'env': env,
        'sid': userSessionId,
        'did': deviceIdentifier,
        'cdata': [],
      },
      'object': {
        'id': objectId,
        'type': objectType,
        'rollup': l1 != null ? {'l1': l1} : {}
      },
      'tags': [],
      'edata': {
        'type': telemetryType,
        'mode': telemetryType == TelemetryType.player
            ? TelemetryMode.play
            : TelemetryMode.view,
        'pageid': pageIdentifier,
        'duration': duration
      }
    };
    return eventData;
  }

  getImpressionTelemetryEvent(
      {required String pageIdentifier,
      required String telemetryType,
      required String pageUri,
      required String env,
      String? objectId,
      String? objectType,
      bool isPublic = false,
      String? subType}) {
    String messageIdentifier = generateMessageId();
    Map eventData = {
      'eid': TelemetryEvent.impression,
      'ets': DateTime.now().millisecondsSinceEpoch,
      'ver': TELEMETRY_EVENT_VERSION,
      'mid': '${TelemetryEvent.impression}:$messageIdentifier',
      'actor': {
        'id': userId,
        'type': isPublic ? EnglishLang.anonymousUser : 'User'
      },
      'context': {
        'channel': departmentId,
        'pdata': {
          'id': TELEMETRY_PDATA_ID,
          'ver': APP_VERSION,
          'pid': TELEMETRY_PDATA_PID
        },
        'env': env,
        'sid': userSessionId,
        'did': deviceIdentifier,
        'cdata': []
      },
      'object': {'id': objectId, 'type': objectType},
      'tags': [],
      'edata': {
        'type': telemetryType,
        'pageid': pageIdentifier,
        'uri': pageUri,
        'subtype': subType
      }
    };
    return eventData;
  }

  getInteractTelemetryEvent(
      {required String pageIdentifier,
      required String contentId,
      String? subType,
      required String env,
      String? objectType,
      bool isPublic = false,
      String clickId = '',
      String? targetId,
      String? targetType,
      String? pageUri}) {
    // log('UserSessionId: $userSessionId, DeviceIdentifier: $deviceIdentifier, UserId: $userId, UserDeptId: $departmentId');
    String messageIdentifier = generateMessageId();
    Map eventData = {
      'eid': TelemetryEvent.interact,
      'ets': DateTime.now().millisecondsSinceEpoch,
      'ver': TELEMETRY_EVENT_VERSION,
      'mid': '${TelemetryEvent.interact}:$messageIdentifier',
      'actor': {
        'id': _userId,
        'type': isPublic ? EnglishLang.anonymousUser : 'User'
      },
      'context': {
        'channel': departmentId,
        'pdata': {
          'id': TELEMETRY_PDATA_ID,
          'ver': APP_VERSION,
          'pid': TELEMETRY_PDATA_PID
        },
        'env': env,
        'sid': _userSessionId,
        'did': _deviceIdentifier,
        'cdata': []
      },
      'object': (contentId.isNotEmpty) &&
              (objectType != null && objectType.isNotEmpty)
          ? {'id': contentId, 'type': objectType}
          : null,
      'tags': [],
      'edata': getInteractTelemetryEdata(
          clickId: clickId.isNotEmpty ? clickId : contentId,
          subType: subType,
          pageIdentifier: pageIdentifier,
          targetId: targetId,
          targetType: targetType,
          pageUri: pageUri)
    };
    return eventData;
  }

  Map<String, Object?> getInteractTelemetryEdata(
      {required String clickId,
      String? subType,
      required String pageIdentifier,
      String? targetId,
      String? targetType,
      String? pageUri}) {
    return targetId != null && targetType != null
        ? {
            'id': clickId,
            'type': 'click',
            'subtype': subType,
            'pageid': pageIdentifier,
            'target': {'id': targetId, 'ver': APP_VERSION, 'type': targetType}
          }
        : {
            'id': clickId,
            'type': 'click',
            'subtype': subType,
            'pageid': pageIdentifier,
            'uri': pageUri
          };
  }

  Future<void> insertEvent(
      {required Map eventData, bool isPublic = false}) async {
    var telemetryEventData =
        TelemetryEventModel(userId: userId, eventData: eventData);
    await TelemetryDbHelper.insertEvent(telemetryEventData.toMap(),
        isPublic: isPublic);
  }

  // static getAuditTelemetryEvent(
  //   String deviceIdentifier,
  //   String userId,
  //   String departmentId,
  //   String userSessionId,
  //   String messageIdentifier,
  // ) {
  //   Map eventData = {
  //     'eid': TelemetryEvent.audit,
  //     'ets': DateTime.now().millisecondsSinceEpoch,
  //     'ver': APP_VERSION,
  //     'mid': '${TelemetryEvent.audit}:$messageIdentifier',
  //     'actor': {'id': userId, 'type': 'User'},
  //     'context': {
  //       'channel': departmentId,
  //       'pdata': {
  //         'id': TELEMETRY_PDATA_ID,
  //         'ver': APP_VERSION,
  //         'pid': TELEMETRY_PDATA_PID
  //       },
  //       'env': TelemetryPageIdentifier.home,
  //       'sid': userSessionId,
  //       'did': deviceIdentifier,
  //       // 'did': '4f4b7baafbd8b0d8919a3a2848473be4',
  //       'cdata': [],
  //       'rollup': {}
  //     },
  //     'object': {
  //       'ver': APP_VERSION,
  //       'id': TelemetryPageIdentifier.home // True here
  //     },
  //     'tags': [],
  //     'edata': {
  //       'type': TelemetryType.page,
  //       'pageid': TelemetryPageIdentifier.home,
  //       'uri': TelemetryPageIdentifier.home
  //     }
  //   };
  //   // print('eventData: $eventData');
  //   return eventData;
  // }
}
