import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/backup_storage_data.dart';
import 'package:karmayogi_mobile/models/_models/login_user_details.dart';
import 'package:karmayogi_mobile/services/_services/local_notification_service.dart';
import 'package:karmayogi_mobile/signup.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';
import 'package:provider/provider.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../util/telemetry_repository.dart';
import './../../util/telemetry_db_helper.dart';
import 'learn_repository.dart';
import 'profile_repository.dart';

class LoginRespository with ChangeNotifier {
  Login? _loginDetails;
  Login? _parichayLoginDetails;
  LoginUser? _parichayLoginInfo;
  Wtoken? _wtokenDetails;

  FirebaseNotificationService firebaseNotificationService =
      FirebaseNotificationService();

  final _storage = FlutterSecureStorage();

  Future<dynamic> fetchOAuthTokens(String code) async {
    try {
      final loginInfo = await LoginService.doLogin(code);
      _loginDetails = Login.fromJson(loginInfo);
    } catch (_) {
      return _;
    }
    if (_loginDetails?.accessToken != null) {
      await _storage.write(
          key: Storage.authToken, value: _loginDetails?.accessToken);
      await _storage.write(
          key: Storage.refreshToken, value: _loginDetails?.refreshToken);

      if (_loginDetails != null) {
        Map<String, dynamic> decodedToken =
            JwtDecoder.decode(_loginDetails!.accessToken.toString());
        // print(decodedToken['sub']);
        String userId = decodedToken['sub'].split(':')[2];
        await _storage.write(key: Storage.userId, value: userId);
      }

      await getBasicUserInfo(_loginDetails?.accessToken);
    }

    return _loginDetails;
  }

  Future<dynamic> getBasicUserInfo(String? accessToken,
      {bool isParichayUser = false}) async {
    if (accessToken != null) {
      final basicUserInfo = await LoginService.getBasicUserInfo();

      final bool enableFirebaseNotification =
          AppConfiguration.homeConfigData?['enableFirebaseNotification'] ??
              true;

      _wtokenDetails = Wtoken.fromJson(basicUserInfo);

      // Unsubscribing all the topics for the firbase notification service
      if (enableFirebaseNotification) {
        await firebaseNotificationService.unsubscribeFromTopic();
      }
      if (_wtokenDetails != null) {
        await _storage.write(key: Storage.wid, value: _wtokenDetails!.wid);
        await _storage.write(
            key: Storage.userName, value: _wtokenDetails!.userName);
        await _storage.write(
            key: Storage.firstName, value: _wtokenDetails!.firstName);
        await _storage.write(
            key: Storage.lastName, value: _wtokenDetails!.lastName);
        await _storage.write(
            key: Storage.deptName, value: _wtokenDetails!.deptName);
        await _storage.write(
            key: Storage.deptId, value: _wtokenDetails!.deptId);
        await _storage.write(key: Storage.email, value: _wtokenDetails!.email);
        await _storage.write(
            key: Storage.designation, value: _wtokenDetails!.designation);
        await _storage.write(
            key: Storage.getStarted,
            value: _wtokenDetails!.showGetStarted.toString());
        await _storage.write(
            key: Storage.profileCompletionPercentage,
            value: _wtokenDetails!.profileCompletionPercentage.toString());
        await _storage.write(
            key: Storage.profileStatus,
            value: _wtokenDetails?.profileStatus.toString());
        await isParichayUser
            ? _storage.write(
                key: Storage.clientId, value: iGotClient.parichayClientId)
            : _storage.write(
                key: Storage.clientId, value: iGotClient.androidClientId);

        // Create session in NodeBB
        if (_wtokenDetails?.userName != '') {
          // print('NodeBB');
          Map nodebb = await LoginService.createNodeBBSession(
              _wtokenDetails!.userName,
              _wtokenDetails!.wid,
              _wtokenDetails!.firstName,
              _wtokenDetails!.lastName);
          // print('nodebb: ' + nodebb.toString());
          if (nodebb['nodebbUserId'] != null) {
            await _storage.write(
                key: Storage.nodebbAuthToken, value: nodebb['nodebbAuthToken']);
            await _storage.write(
                key: Storage.nodebbUserId,
                value: nodebb['nodebbUserId'].toString());
          }
          var telemetryRepository = TelemetryRepository();
          await telemetryRepository.generateTelemetryRequiredData();
          Map eventData = telemetryRepository.getStartTelemetryEvent(
              pageIdentifier: TelemetryPageIdentifier.homePageId,
              telemetryType: TelemetryMode.view,
              pageUri: TelemetryPageIdentifier.homePageId,
              env: TelemetryEnv.home);
          await telemetryRepository.insertEvent(eventData: eventData);
        }
        // Subscribing topics for firebase notification service
        if (enableFirebaseNotification) {
          await firebaseNotificationService.subscribeToTopic();
        }
      }
    }
  }

  //For Parichay
  Future<dynamic> fetchParichayToken(
    String code,
    context,
  ) async {
    try {
      final loginInfo = await LoginService.doParichayLogin(code, context);
      _parichayLoginDetails = Login.fromJson(loginInfo);
    } catch (_) {
      return _;
    }
    if (_parichayLoginDetails!.accessToken != null) {
      await _storage.write(
          key: Storage.parichayAuthToken,
          value: _parichayLoginDetails!.accessToken);
      await _storage.write(
          key: Storage.parichayRefreshToken,
          value: _parichayLoginDetails!.refreshToken);

      //getting parichay user info
      final basicParichayUserInfo = await LoginService.getParichayUserInfo();
      _parichayLoginInfo = LoginUser.fromJson(basicParichayUserInfo);

      if (_parichayLoginInfo?.loginId != null) {
        //getting user details from iGOT
        final userDetails = await LoginService.getUserDetailsByEmailId(
            _parichayLoginInfo!.loginId);

        bool isFirstTimeUser = false;

        if (userDetails['params']['errmsg'] == null ||
            userDetails['params']['errmsg'] == '') {
          if (userDetails['result']['response']['count'] == 0) {
            await Helper.showSnackBarMessage(
                context: context,
                text: EnglishLang.userNotExistMsg,
                bgColor: AppColors.negativeLight);
            try {
              await LoginService.doSignUp(_parichayLoginInfo);
              isFirstTimeUser = true;
            } catch (e) {
              Helper.showErrorScreen(context, EnglishLang.userNotExistMsg);
            }
          } else {
            if (userDetails['result']['response']['content'][0]['rootOrgId']
                        .toString() !=
                    '' &&
                userDetails['result']['response']['content'][0]['rootOrgId']
                        .toString() ==
                    X_CHANNEL_ID) {
              isFirstTimeUser = true;
            }
          }

          //calling keycloak api
          final loginInfo = await LoginService.getKeyCloakToken(
              _parichayLoginInfo!.loginId, context);
          _loginDetails = Login.fromJson(loginInfo);

          await _storage.write(
              key: Storage.authToken, value: _loginDetails!.accessToken);
          await _storage.write(
              key: Storage.refreshToken, value: _loginDetails!.refreshToken);

          if (isFirstTimeUser) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => SignUpPage(
                  parichayLoginInfo: _parichayLoginInfo,
                  isParichayUser: true,
                ),
              ),
            );
          } else {
            if (_loginDetails!.accessToken != null) {
              Map<String, dynamic> decodedToken =
                  JwtDecoder.decode(_loginDetails!.accessToken.toString());
              // print(decodedToken['sub']);
              String userId = decodedToken['sub'].split(':')[2];
              await _storage.write(key: Storage.userId, value: userId);

              await getBasicUserInfo(_loginDetails!.accessToken,
                  isParichayUser: true);
              return Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => CustomTabs(
                      customIndex: 0, token: _loginDetails!.accessToken),
                ),
              );
            }
          }
        }
      } else {
        await Helper.showErrorScreen(context, EnglishLang.loginIdMissingMsg);
      }
    }
  }

  Future<void> doLogout(BuildContext context) async {
    String? parichayToken = await _storage.read(key: Storage.parichayAuthToken);
    // print('Parichay token: $parichayToken');

    String? userId = await TelemetryRepository().getUserId();
    // await HttpService.deleteAllApiData();
    if (userId != null) {
      await TelemetryDbHelper.triggerEvents(userId, forceTrigger: true);
    }
    try {
      final keyCloakLogoutResponse = await LogoutService.doKeyCloakLogout();
      if (keyCloakLogoutResponse == 204) {
        if (parichayToken != null) {
          await LogoutService.doParichayLogout();
        }
      }
    } catch (e) {
      throw e;
    } finally {
      Provider.of<LearnRepository>(context, listen: false).clearCbplan();
      await _clearData();
      // Clear profileDetails in ProfileRepository
      Provider.of<ProfileRepository>(context, listen: false)
          .clearProfileDetails();
      await Navigator.pushNamedAndRemoveUntil(
          context, AppUrl.onboardingScreen, (r) => false);
    }
  }

  Future<void> _clearData() async {
    final cookieManager = WebViewCookieManager();
    cookieManager.clearCookies();
    List<BackupStorageData> backupStorageData = await readBackupData();
    await _storage.deleteAll();
    await _storage.write(key: Storage.isUserOnboarded, value: 'false');
    await restoreBackupData(backupStorageData);
  }

  Future<List<BackupStorageData>> readBackupData() async {
    String? faqSelectedLanguage =
        await _storage.read(key: Storage.faqSelectedLanguage);
    String? selectedAppLanguage =
        await _storage.read(key: Storage.selectedAppLanguage);
    String? lastTriggeredTime =
        await _storage.read(key: Storage.lastTriggeredTime);

    final isAppOpened = await _storage.read(
      key: Storage.isAppOpened,
    );
    final totalClaps = await _storage.read(
      key: Storage.totalClaps,
    );
    final appFontSize = await _storage.read(
      key: Storage.fontSize,
    );
    final isAppReviewPopupTriggered =
        await _storage.read(key: Storage.isAppReviewPopupTriggered);

    List<BackupStorageData> backupStorageData = [
      BackupStorageData(
        key: Storage.faqSelectedLanguage,
        value: faqSelectedLanguage,
      ),
      BackupStorageData(
        key: Storage.selectedAppLanguage,
        value: selectedAppLanguage,
      ),
      BackupStorageData(
        key: Storage.isAppOpened,
        value: isAppOpened,
      ),
      BackupStorageData(
        key: Storage.lastTriggeredTime,
        value: lastTriggeredTime,
      ),
      BackupStorageData(
        key: Storage.totalClaps,
        value: totalClaps,
      ),
      BackupStorageData(
        key: Storage.fontSize,
        value: appFontSize,
      ),
      BackupStorageData(
        key: Storage.isAppReviewPopupTriggered,
        value: isAppReviewPopupTriggered,
      )
    ];

    return backupStorageData;
  }

  Future<void> restoreBackupData(
      List<BackupStorageData> backupStorageData) async {
    backupStorageData.forEach((element) async {
      await _storage.write(key: element.key, value: element.value);
    });
  }

  Future<bool> updateToken() async {
    var response = await LoginService.getNewToken();
    if (response.statusCode == 200) {
      Map convertedResponse = json.decode(response.body);
      if (convertedResponse['access_token'] != null) {
        await _storage.write(
            key: Storage.authToken, value: convertedResponse['access_token']);
      }
      if (convertedResponse['refresh_token'] != null) {
        await _storage.write(
            key: Storage.refreshToken,
            value: convertedResponse['refresh_token']);
      }
      return true;
    }
    return false;
  }
}
