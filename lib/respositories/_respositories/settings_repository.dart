import 'dart:io' show Platform;

import 'package:flutter/material.dart' show ChangeNotifier, WidgetsBinding;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SettingsRepository extends ChangeNotifier {
  final _storage = FlutterSecureStorage();
  
  bool _itsTablet = false;
  bool get itsTablet => _itsTablet;

  double fontSize = 1;

  static final SettingsRepository _singleton = SettingsRepository._internal();

  factory SettingsRepository() {
    return _singleton;
  }

  SettingsRepository._internal() {
    detectTablet();
  }

  void setFontSize({required double size}) {
    _storage.write(key: Storage.fontSize, value: size.toString());

    fontSize = size;
    notifyListeners();
  }

  void setDefaultFont() async {
    String? font = await _storage.read(key: Storage.fontSize);
    if (font != null) {
      fontSize = double.parse(font);
    } else {
      await _storage.write(key: Storage.fontSize, value: '1');

      fontSize = 1;
    }
    notifyListeners();
  }

  Future<void> detectTablet() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      _itsTablet = info.model.toLowerCase().contains("ipad");
    } else if (Platform.isAndroid) {
      final firstView = WidgetsBinding.instance.platformDispatcher.views.first;
      final logicalShortestSide =
          firstView.physicalSize.shortestSide / firstView.devicePixelRatio;
      _itsTablet = logicalShortestSide > 600;
    } //else {
      //do nothing, its false by default;
    //}
  }
}
