import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/app_details_service.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class AppUpgrader {
  static final _storage = FlutterSecureStorage();
  static AppCheckerResult? result;

  static void checkForUpdate({required BuildContext context}) async {

    if (AppConfiguration.appUpdateModel?.mandatoryUpdate?.enabled == false) return;
    if (!modeProdRelease) return;

    String? showAppUpgradePopup = await _storage.read(key: Storage.restrictAppUpgradePopup);
    String mandatoryAppUpdateVersion = Theme.of(context).platform == TargetPlatform.iOS
        ? AppConfiguration.appUpdateModel?.mandatoryUpdate?.mandatoryIosVersion ?? ""
        : AppConfiguration.appUpdateModel?.mandatoryUpdate?.mandatoryAndroidVersion ?? "";

    /// disable app update pop-up on non-prod builds
    if (showAppUpgradePopup == null || showAppUpgradePopup == 'false') {
      AppCheckerResult? result;
      try {
        result = await AppVersionChecker().checkUpdate(context);
      } catch (e) {
        debugPrint(e.toString());
      }
      if (result != null && result.canUpdate) {
        if (!isAppVersionUpToDate(mandatoryAppUpdateVersion, result.currentVersion)) {
          AppUpgrader().showUpdateDialog(
              context: context,
              appUrl: result.appURL,
              message:
              "A new version of iGOT Karmayogi is available! Version ${result.newVersion} is now available - currently you have ${result.currentVersion} ",
              title: AppConfiguration.appUpdateModel?.mandatoryUpdate?.title ?? "App Update Available",
              releaseNotes: result.releaseNotes);
        }
      }
    }
  }

  static bool isAppVersionUpToDate(String appVersion, String currentVersion) {
    List<int> appParts = appVersion.split('.').map(int.parse).toList();
    List<int> currentParts = currentVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (appParts[i] > currentParts[i]) {
        return false;
      }
      if (appParts[i] < currentParts[i]) {
        return true;
      }
    }
    return true;
  }

  AlertDialog _alertDialog(
      {required String title,
        required String message,
        bool enableIgnore = false,
        String? releaseNotes,
        required BuildContext context,
        required String playStoreUrl}) {
    Widget? notes;
    if (releaseNotes != null && releaseNotes.isNotEmpty) {
      notes = Padding(
        padding: const EdgeInsets.only(top: 15.0).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Release Notes:',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              releaseNotes,
              maxLines: 15,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBlue,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (notes != null) notes,
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Spacer(),
            Visibility(
              visible: enableIgnore,
              child: TextButton(
                child: Text(
                  'Ignore',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBlue
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SizedBox(
              height: 40.w,
              child: ElevatedButton(
                onPressed: () {
                  Helper.doLaunchUrl(url: playStoreUrl);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0).r,
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 8).r,
                ),
                child: Text(
                  AppConfiguration.appUpdateModel?.mandatoryUpdate?.buttonText ?? 'Update',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.appBarBackground
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  CupertinoAlertDialog _cupertinoAlertDialog({
    required String title,
    required String message,
    bool enableIgnore = false,
    String? releaseNotes,
    required BuildContext context,
    required String appStoreUrl,
  }) {
    Widget? notes;
    if (releaseNotes != null && releaseNotes.isNotEmpty) {
      notes = Padding(
        padding: const EdgeInsets.only(top: 15.0).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Release Notes:',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.start,
            ),
            Text(
              releaseNotes,
              maxLines: 14,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      );
    }

    return CupertinoAlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.darkBlue,
        ),
        textAlign: TextAlign.start,
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.start,
            ),
            if (notes != null) notes,
          ],
        ),
      ),
      actions: <Widget>[
        if (enableIgnore)
          CupertinoDialogAction(
            child: Text(
              'Ignore',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        CupertinoDialogAction(
          child:  Text(
            AppConfiguration.appUpdateModel?.mandatoryUpdate?.buttonText ?? 'Update',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue
            ),
          ),
          onPressed: () {
            Helper.doLaunchUrl(url: appStoreUrl);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void showUpdateDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String appUrl,
    String? releaseNotes,
  }) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return _cupertinoAlertDialog(
              enableIgnore: AppConfiguration.appUpdateModel?.mandatoryUpdate?.enableIgnore ?? false,
              title: title,
              message: message,
              appStoreUrl: appUrl,
              releaseNotes: releaseNotes ?? '',
              context: context);
        },
      );
    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            child: _alertDialog(
              enableIgnore: AppConfiguration.appUpdateModel?.mandatoryUpdate?.enableIgnore ?? false,
              title: title,
              message: message,
              releaseNotes: releaseNotes ?? '',
              context: context,
              playStoreUrl: appUrl,
            ),
          );
        },
      );
    }
  }
}
