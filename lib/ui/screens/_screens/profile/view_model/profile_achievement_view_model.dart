import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';

import '../../../../../constants/index.dart';
import '../../../../../localization/index.dart';
import '../../../../../respositories/index.dart';
import '../../../../../util/index.dart';
import '../../../../pages/_pages/search/utils/search_helper.dart';
import '../../../../widgets/_discussion_hub/helper/discussion_const.dart';
import '../model/achievement_item_model.dart';

class ProfileAchievementViewModel {
  static final ProfileAchievementViewModel _instance =
      ProfileAchievementViewModel._internal();
  factory ProfileAchievementViewModel() {
    return _instance;
  }
  ProfileAchievementViewModel._internal();
  ProfileRepository profileRepository = ProfileRepository();

  Future<File?> getMedia(BuildContext context) async {
    XFile? media;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ImageFormat.achievementPhoto,
        compressionQuality: 50,
        allowMultiple: false,
      );
      if (result != null) {
        media = XFile(result.files.single.path!);
      }
    } catch (e) {
      Helper.showSnackBarMessage(
          context: context,
          text: AppLocalizations.of(context)?.mStaticErrorMessage ?? '',
          bgColor: AppColors.negativeLight);
    }

    /// If media is selected
    if (media != null) {
      final file = File(media.path);
      final fileSizeInBytes = await file.length();
      final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > maxMediaSizeInMB) {
        Helper.showSnackBarMessage(
          context: context,
          text:
              "${AppLocalizations.of(context)!.mDiscussionMediaSizeError(maxMediaSizeInMB)}",
          bgColor: AppColors.negativeLight,
        );
      } else {
        return File(media.path);
      }
    }
    return null;
  }

  Future<void> addAchievements(BuildContext context,
      {required String title,
      required String issuedOrganisation,
      required String issueDate,
      String? url,
      String? description,
      File? uploadedDocument}) async {
    if (title.isEmpty) {
      SearchHelper().showOverlayMessage(
          AppLocalizations.of(context)!.mStaticPleaseFillAllMandatory, context,
          duration: 3);
    } else {
      Map<String, dynamic> content = {
        'achievements': [
          {'title': title}
        ]
      };
      if (issuedOrganisation.isNotEmpty) {
        content['achievements'][0]['issuedOrganisation'] = issuedOrganisation;
      }
      if (issueDate.isNotEmpty) {
        content['achievements'][0]['issuedDate'] =
            issueDate.endsWith('Z') ? issueDate : '${issueDate}Z';
      }
      if (uploadedDocument != null) {
        Map<String, dynamic>? document =
            await uploadCertificate(uploadedDocument, context);
        if (document == null) {
          SearchHelper().showOverlayMessage(
              AppLocalizations.of(context)!.mStaticErrorMessage, context,
              duration: 3, bgColor: AppColors.negativeLight);
        } else {
          content['achievements'][0]['uploadedDocumentUrl'] = document['url'];
          content['achievements'][0]['fileName'] = document['name'];
        }
      }
      if (url != null) {
        content['achievements'][0]['url'] = url;
      }
      if (description != null) {
        content['achievements'][0]['description'] = description;
      }
      String response = await profileRepository.saveExtendedProfile(content);
      if (response.toLowerCase() == EnglishLang.ok.toLowerCase()) {
        SearchHelper().showOverlayMessage(
            AppLocalizations.of(context)!.mProfileAddedSuccessfully, context,
            duration: 3, bgColor: AppColors.positiveLight);
      } else {
        SearchHelper().showOverlayMessage(response, context,
            duration: 3, bgColor: AppColors.negativeLight);
      }
      Navigator.pop(context);
    }
  }

  Future<void> updateAchievements(BuildContext context,
      {required String title,
      required String issuedOrganisation,
      required String issueDate,
      required String uuid,
      String? url,
      String? description,
      File? uploadedDocument,
      String? uploadedDocumentUrl}) async {
    Map<String, dynamic> content = {
      'achievements': [
        {
          'uuid': uuid,
        }
      ]
    };
    if (title.isNotEmpty) {
      content['achievements'][0]['title'] = title;
    }
    if (issuedOrganisation.isNotEmpty) {
      content['achievements'][0]['issuedOrganisation'] = issuedOrganisation;
    }
    if (issueDate.isNotEmpty) {
      content['achievements'][0]['issuedDate'] =
          issueDate.endsWith('Z') ? issueDate : '${issueDate}Z';
    }
    if (uploadedDocument != null) {
      Map<String, dynamic>? document =
          await uploadCertificate(uploadedDocument, context);
      if (document == null) {
        SearchHelper().showOverlayMessage(
            AppLocalizations.of(context)!.mStaticErrorMessage, context,
            duration: 3, bgColor: AppColors.negativeLight);
      } else {
        content['achievements'][0]['uploadedDocumentUrl'] = document['url'];
        content['achievements'][0]['fileName'] = document['name'];
      }
    }
    if (uploadedDocumentUrl != null) {
      content['achievements'][0]['uploadedDocumentUrl'] = '';
      content['achievements'][0]['fileName'] = '';
    }
    if (url != null) {
      content['achievements'][0]['url'] = url;
    }
    if (description != null) {
      content['achievements'][0]['description'] = description;
    }
    String response = await profileRepository.updateExtendedProfile(content);
    if (response.toLowerCase() == EnglishLang.ok.toLowerCase()) {
      SearchHelper().showOverlayMessage(
          AppLocalizations.of(context)!.mProfileAddedSuccessfully, context,
          duration: 3, bgColor: AppColors.positiveLight);
    } else {
      SearchHelper().showOverlayMessage(response, context,
          duration: 3, bgColor: AppColors.negativeLight);
    }
    Navigator.pop(context);
  }

  Future<List<AchievementItem>> getExtendedAchievements(String? userId) async {
    return await profileRepository.getExtendedAchievements(userId);
  }

  Future<Map<String, dynamic>?> uploadCertificate(
      File selectedFile, BuildContext context) async {
    Map<String, dynamic>? response =
        await profileRepository.uploadAchievementCertificate(selectedFile);
    if (response != null) {
      return response;
    } else {
      return null;
    }
  }
}
