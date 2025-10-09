import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../constants/index.dart';
import '../../../../../respositories/index.dart';
import '../../../../../util/index.dart';

class ProfileBannerViewModel {
  static final ProfileBannerViewModel _instance =
      ProfileBannerViewModel._internal();
  factory ProfileBannerViewModel() {
    return _instance;
  }
  ProfileBannerViewModel._internal();
  final ProfileRepository profileRepository = ProfileRepository();

  Future<File> memoryImageToFile(
      MemoryImage memoryImage, String filename) async {
    // Get the bytes from the MemoryImage
    final bytes = memoryImage.bytes;

    // Get a directory to save the file (e.g., temporary directory)
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');

    // Write the bytes to the file
    await file.writeAsBytes(bytes);

    return file;
  }

  Future<String?> uploadBanner(File selectedFile, BuildContext context) async {
    var response = await profileRepository.uploadProfileBanner(selectedFile);
    if (response != null) {
      Helper.showSnackBarMessage(
          context: context,
          text: AppLocalizations.of(context)!.mProfileUploadedSuccessfully,
          bgColor: AppColors.positiveLight);
      String imageUrl = Helper.convertPortalImageUrl(response);
      Map profileData = {'profileBannerUrl': imageUrl};
      await profileRepository.updateProfileDetails(profileData);
      return imageUrl;
    } else {
      return null;
    }
  }

  Future<bool> deleteBanner(BuildContext context) async {
    Map profileData = {'profileBannerUrl': ''};
    final response = await profileRepository.updateProfileDetails(profileData);
    if ((response['params']['errmsg'] == null ||
            response['params']['errmsg'] == '') &&
        (response['params']['err'] == null ||
            response['params']['err'] == '')) {
              Helper.showSnackBarMessage(
          context: context,
          text: AppLocalizations.of(context)!.mDiscussionDeletedText,
          bgColor: AppColors.positiveLight);
      return true;
    } else {
      Helper.showSnackBarMessage(
          context: context,
          text: response['params']['errmsg'] != null
              ? response['params']['errmsg']
              : AppLocalizations.of(context)!.mProfileSaveProfileErrorText,
          bgColor: Theme.of(context).colorScheme.error);
      return false;
    }
  }
}
