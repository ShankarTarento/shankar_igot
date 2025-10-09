import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImageMaxSizeInMB {
  static const int profileImage = 2;
  static const int profileBanner = 2;
}

class ImageFormat {
  static const List<String> profilePhoto = ['jpg', 'jpeg', 'png'];
  static const List<String> achievementPhoto = [
    'jpg',
    'jpeg',
    'png',
    'webP',
    'svg',
    'webp'
  ];
  static const List<String> profileBanner = [
    'jpg',
    'jpeg',
    'png',
    'svg',
    'webP',
    'webp'
  ];
}

class ProfilMenu {
  static const String editProfile = 'EditProfile';
  static const String transferRequest = 'TransferRequest';
  static const String withdrawRequest = 'WithdrawRequest';
  static const String settings = 'Settings';
  static const String signOut = 'SignOut';
  static List<Map<String, dynamic>> getMenuItems({required bool showWithdraw}) {
    return [
      {'index': 0, 'item': editProfile},
      {'index': 1, 'item': showWithdraw ? withdrawRequest : transferRequest},
      {'index': 2, 'item': settings},
      {'index': 3, 'item': signOut}
    ];
  }

  static String getMenuItemLabel(String name, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final menuMap = <String, String>{
      ProfilMenu.editProfile: localizations.mEditProfile,
      ProfilMenu.transferRequest: localizations.mProfileMakeTransferRequest,
      ProfilMenu.withdrawRequest: localizations.mProfileWithdrawTransferRequest,
      ProfilMenu.settings: localizations.mStaticSettings,
      ProfilMenu.signOut: localizations.mSettingSignOut
    };

    return menuMap[name] ?? '';
  }
}

class ProfileConstants {
  static const String notMyUser = "notMyUser";
  static const String currentUser = "currentUser";
  static const String networkUser = "networkUser";
  static const String customProfileTab = "customProfileTab";
}

class CadreConstants {
  static const List<String> centralDeputationCivilServicesId = [
    "cst-003"
  ];
}
