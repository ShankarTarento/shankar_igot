import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class GyaanKarmaYogiHelper {
  String checkContentType({required String mimeType}) {
    if (mimeType == EMimeTypes.youtubeLink ||
        mimeType == EMimeTypes.externalLink) {
      return "Youtube";
    } else if (mimeType == EMimeTypes.mp4) {
      return "Video";
    } else if (mimeType == EMimeTypes.pdf) {
      return "PDF";
    } else if (mimeType == EMimeTypes.mp3) {
      return "Audio";
    } else if (mimeType == EMimeTypes.collection) {
      return "Collection";
    } else {
      return mimeType;
    }
  }

  Widget checkContentTypeIcon({required String mimeType}) {
    if (mimeType == EMimeTypes.mp4 ||
        mimeType == EMimeTypes.externalLink ||
        mimeType == EMimeTypes.youtubeLink) {
      return SizedBox(
        width: 14.w,
        height: 14.w,
        child: SvgPicture.asset(
          'assets/img/play.svg',
          package: "igot_ui_components",
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
      );
    } else if (mimeType == EMimeTypes.pdf) {
      return SizedBox(
        width: 14.w,
        height: 14.w,
        child: SvgPicture.asset(
          'assets/img/pdf.svg',
          package: "igot_ui_components",
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
      );
    } else if (mimeType == EMimeTypes.mp3) {
      return SizedBox(
        width: 14.w,
        height: 14.w,
        child: SvgPicture.asset(
          'assets/img/audio.svg',
          colorFilter: const ColorFilter.mode(AppColors.appBarBackground, BlendMode.srcIn),
          package: "igot_ui_components",
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
      );
    } else if (mimeType == EMimeTypes.collection) {
      return SizedBox(
        width: 14.w,
        height: 14.w,
        child: SvgPicture.asset(
          'assets/img/collection_icon.svg',
          colorFilter: const ColorFilter.mode(AppColors.appBarBackground, BlendMode.srcIn),
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return SizedBox(
        width: 14.w,
        height: 14.w,
        child: Icon(Icons.error),
      );
    }
  }
}
