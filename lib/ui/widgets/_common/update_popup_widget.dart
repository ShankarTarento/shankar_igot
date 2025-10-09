import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../respositories/index.dart';
import '../../../services/index.dart';
import '../index.dart';

class UpdatePopupWidget extends StatelessWidget {
  final String? popupMessage;
  final bool isUpdateProfile;
  final String? buttonText;
  final BuildContext ctx;

  UpdatePopupWidget(
      {super.key,
      this.popupMessage,
      this.isUpdateProfile = false,
      this.buttonText,
      required this.ctx});

  final _storage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 70, left: 16, right: 16).r,
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(vertical: 16).r,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.0).r,
            ),
            content: Container(
              padding: EdgeInsets.fromLTRB(0, 8, 16, 8).r,
              // height: 64,
              decoration: BoxDecoration(
                  color: AppColors.orangeLightShade,
                  borderRadius: BorderRadius.circular(6).r,
                  border: Border.all(color: AppColors.orangeTourText)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            _storage.write(
                                key: Storage.showReminder,
                                value: EnglishLang.no);
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 16, 0, 16),
                            child: Icon(
                              Icons.close,
                              color: AppColors.grey40,
                              size: 22.sp,
                            ),
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/img/phone_update.svg',
                          height: 58.w,
                          width: 54.w,
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: !isUpdateProfile ? 8 : 4,
                              right: 4,
                            ).r,
                            child: Wrap(
                              children: [
                                TitleRegularGrey60(
                                  popupMessage ??
                                      (!isUpdateProfile
                                          ? AppLocalizations.of(ctx)!
                                              .mStaticUpdatePhoneNumber
                                          : AppLocalizations.of(ctx)!
                                              .mStaticUpdateProfile),
                                  color: AppColors.greys87,
                                  maxLines: 2,
                                  fontSize: 14.sp,
                                ),
                                Visibility(
                                  visible: popupMessage != null,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8).r,
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            Navigator.of(context).pop();
                                            Navigator.pushNamed(ctx,
                                                AppUrl.profileDashboard);
                                            await _setMessageViewedStatus();
                                          },
                                          child: TitleBoldWidget(
                                              buttonText ?? '',
                                              color: AppColors.darkBlue,
                                              maxLines: 2,
                                              fontSize: 14.sp),
                                        ),
                                        TitleRegularGrey60(
                                          AppLocalizations.of(ctx)!
                                              .mHomeToSeeChanges,
                                          color: AppColors.greys87,
                                          maxLines: 2,
                                          fontSize: 14.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: popupMessage == null,
                    child: Container(
                      width: 95.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(63).w),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          minimumSize: Size.fromHeight(45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(63).r,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await Provider.of<InAppReviewRespository>(ctx,
                                  listen: false)
                              .setOtherPopupVisibleStatus(false);
                          Navigator.pushNamed(ctx, AppUrl.profileDashboard);
                        },
                        child: Text(
                          buttonText ?? AppLocalizations.of(ctx)!.mCommonUpdate,
                          style: TextStyle(
                              fontSize: 12.sp,
                              // overflow: TextOverflow.ellipsis,
                              color: AppColors.avatarText,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _setMessageViewedStatus() async {
    Map payLoad = {
      "additionalProperties": {"isProfileUpdatedMsgViewed": true}
    };
    await ProfileService().updateProfileDetails(payLoad);
  }
}
