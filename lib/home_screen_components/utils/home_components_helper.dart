import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/models/survey_popup_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/settings_repository.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/deeplinks/smt_deeplink_service.dart';
import 'package:provider/provider.dart';

class HomeComponentsHelper {
  final _storage = FlutterSecureStorage();

  Future<void> getSurveyPopUp(BuildContext context) async {
    Map? data = AppConfiguration.homeConfigData;
    SurveyPopup? surveyPopup;
    try {
      if (data != null) {
        surveyPopup = SurveyPopup.fromJson(data['surveyPopup']);
      }
    } catch (e) {
      debugPrint("error in survey popup");
    }
    if (surveyPopup == null) return;
    if (surveyPopup.enabled) {
      bool itsTablet =
          Provider.of<SettingsRepository>(context, listen: false).itsTablet;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (bool, result) async {
              _storage.write(key: Storage.enableSurveyPopUp, value: "false");
            },
            child: Scaffold(
              backgroundColor:
                  AppColors.appBarBackground.withValues(alpha: 0.3),
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _storage.write(
                              key: Storage.enableSurveyPopUp, value: "false");
                        },
                        icon: CircleAvatar(
                          backgroundColor: AppColors.appBarBackground,
                          radius: 15.r,
                          child: Icon(
                            Icons.close,
                            color: AppColors.greys87,
                            weight: 700,
                            size: 26.sp,
                          ),
                        ),
                      ),
                    ),
                    surveyPopup?.data.imageUrl != null
                        ? ImageWidget(
                            imageUrl: ApiUrl.baseUrl +
                                '/' +
                                surveyPopup!.data.imageUrl.getUrl(context),
                            height: 460.w,
                            width: 1.sw,
                            boxFit: BoxFit.contain,
                            enableImageCache: false,
                          )
                        : SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.only(
                              left: 16.0, right: 16, bottom: 50)
                          .r,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              fixedSize:
                                  Size(itsTablet ? (0.5).sw : 1.sw, 40.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0).r,
                              ),
                              backgroundColor: AppColors.orangeTourText),
                          onPressed: () async {
                            _storage.write(
                                key: Storage.enableSurveyPopUp, value: "false");
                            Platform.isIOS
                                ? await SMTDeeplinkService.instance
                                    .initSMTAppLink(
                                    smtDeeplinkSource:
                                        BroadCastEvent.InAppMessage,
                                    deeplink: surveyPopup!.data.surveyUrl,
                                  )
                                : Helper.doLaunchUrl(
                                    url: surveyPopup!.data.surveyUrl,
                                  );
                            Navigator.pop(context);
                          },
                          child: Text(
                            surveyPopup!.data.btnTitle.getText(context),
                            style: GoogleFonts.lato(
                              color: AppColors.appBarBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
