import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompatibilityDialog extends StatefulWidget {
  final Function closeCallback;

  const CompatibilityDialog({super.key, required this.closeCallback});

  @override
  _CompatibilityDialogState createState() => _CompatibilityDialogState();
}

class _CompatibilityDialogState extends State<CompatibilityDialog> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context);
          widget.closeCallback();
        }
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 56, bottom: 56, left: 8, right: 8).w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12).r,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey16),
                    borderRadius:
                        BorderRadius.all(const Radius.circular(12.0).r),
                    color: AppColors.appBarBackground),
                child: _buildLayout(),
              ),
            ),
          ),
          _appbarView(),
        ],
      ),
    );
  }

  Widget _buildLayout() {
    return Container(
      height: 1.sh,
      margin: EdgeInsets.only(top: 16).r,
      decoration: BoxDecoration(color: AppColors.appBarBackground),
      alignment: Alignment.center,
      child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(AppLocalizations.of(context)!.mCompatibilityTitle,
                    style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontWeight: FontWeight.w700,
                      fontSize: 16.sp,
                    )),
                SizedBox(
                  height: 12.w,
                ),
                Text(
                  AppLocalizations.of(context)!.mCompatibilityDescription,
                  style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 12.w,
                ),
                ElevatedButton(
                    onPressed: () {
                      launchURL(
                        url: Platform.isAndroid
                            ? ApiUrl.androidUrl
                            : ApiUrl.iOSUrl,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeTourText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50).r,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.mStaticUpdateApp,
                          style: GoogleFonts.lato(
                              color: AppColors.appBarBackground,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Icon(
                          Icons.file_download_outlined,
                          size: 20.sp,
                        )
                      ],
                    ))
              ],
            ),
          )),
    );
  }

  Widget _appbarView() {
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8).r,
      child: Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () async {
              Navigator.of(context).pop();
              widget.closeCallback();
            },
            child: Container(
              alignment: Alignment.center,
              height: 36.w,
              width: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey84,
              ),
              child: Icon(
                Icons.close,
                color: AppColors.whiteGradientOne,
                size: 16.sp,
              ),
            ),
          )),
    );
  }

  void launchURL({required String url, BuildContext? context}) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw AppLocalizations.of(context!)!.mStaticErrorMessage;
    }
  }
}
