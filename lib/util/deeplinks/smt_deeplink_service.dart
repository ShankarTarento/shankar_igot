import 'dart:async';
import 'dart:io';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'deeplink_service.dart';

class SMTDeeplinkService {
  /// Private constructor to prevent multiple instances
  SMTDeeplinkService._privateConstructor();

  /// Static instance of the service
  static final SMTDeeplinkService instance = SMTDeeplinkService._privateConstructor();

  final StreamController<bool> _streamController =
      StreamController<bool>.broadcast();

  Stream<bool> get stream => _streamController.stream;

  void emitEvent(bool isEventReceived) {
    _streamController.sink.add(isEventReceived);
  }

  void dispose() {
    _streamController.close();
  }

  Future<void> initSMTAppLink(
      {required String smtDeeplinkSource,
      required String deeplink,
      Map<dynamic, dynamic>? smtPayload,
      Map<dynamic, dynamic>? smtCustomPayload}) async {
    if (deeplink.isNotEmpty) {

      /// process the deep link
      await DeeplinkService().processDeeplink(url: deeplink.toString(), isColdState: true);

      /// emit event only for inAppMessage source on iOS platform
      if (Platform.isIOS) {
        if (smtDeeplinkSource == BroadCastEvent.InAppMessage) {
          emitEvent(true);
        }
      }
    }
  }
}
