import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../constants/index.dart';
import '../../../../../localization/index.dart';
import '../../../../../respositories/index.dart';
import '../../../../../services/_services/smartech_service.dart';
import '../../../../../services/index.dart';
import '../../../../../util/index.dart';
import '../../../../network_hub/constants/network_constants.dart';
import '../../../../pages/_pages/search/utils/search_helper.dart';
import '../model/district_model.dart';
import '../model/state_model.dart';

class ProfileTopSectionViewModel {
  static final ProfileTopSectionViewModel _instance =
      ProfileTopSectionViewModel._internal();
  factory ProfileTopSectionViewModel() {
    return _instance;
  }
  ProfileTopSectionViewModel._internal();
  ProfileRepository profileRepository = ProfileRepository();
  final _storage = FlutterSecureStorage();

  Future<File> memoryImageToFile(
      MemoryImage memoryImage, String fileName) async {
    // Get the bytes from the MemoryImage
    final Uint8List bytes = memoryImage.bytes;

    // Get the app's temporary directory or documents directory
    final Directory dir =
        await getTemporaryDirectory(); // or getApplicationDocumentsDirectory()
    final String path = '${dir.path}/$fileName';

    // Create the file and write the bytes
    final File file = File(path);
    await file.writeAsBytes(bytes);

    return file;
  }

  Future<String?> uploadImage(File selectedFile, BuildContext context) async {
    var response = await Provider.of<ProfileRepository>(context, listen: false)
        .profilePhotoUpdate(selectedFile);
    if (response.runtimeType == int) {
      return null;
    } else {
      SearchHelper().showOverlayMessage(
          AppLocalizations.of(context)!.mProfileSuccessfullyUploaded, context,
          duration: 3, bgColor: AppColors.positiveLight);
      String imageUrl = Helper.convertPortalImageUrl(response);
      Map profileData = {'profileImageUrl': imageUrl};
      await profileRepository.updateProfileDetails(profileData);
      await Provider.of<ProfileRepository>(context, listen: false)
          .getProfileDetailsById('');
      await _storage.write(key: Storage.profileImageUrl, value: imageUrl);
      return imageUrl;
    }
  }

  String formatDouble(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  String formatDesignationAndDepartment(
      {required String designation, required String department}) {
    if (designation.isNotEmpty && department.isNotEmpty) {
      return '$designation | $department';
    } else if (designation.isNotEmpty) {
      return designation;
    } else if (department.isNotEmpty) {
      return department;
    } else {
      return '';
    }
  }

  Future<double> imageSizeInMb(File imageFile) async {
    final bytes = imageFile.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;
    return mb;
  }

  bool isValidImageFormat(XFile file, List<String> fileFormat) {
    final ext = getFormat(file);
    return fileFormat.contains(ext);
  }

  String getFormat(XFile file) => file.path.split('.').last.toLowerCase();
  String getFileName(XFile file) =>
      file.path.split('/').last.split('.').first.replaceAll(' ', '');

  String? nameValidation(String? value, BuildContext context) {
    int errorCount = 0;
    String? firstError;

    // 1. Empty
    if (value == null || value.trim().isEmpty) {
      errorCount++;
      firstError ??= AppLocalizations.of(context)!.mProfileNameRequired;
    }

    if (value != null && value.trim().isNotEmpty) {
      // 2. Too short
      if (value.length < 2) {
        errorCount++;
        firstError ??=
            AppLocalizations.of(context)!.mStaticMinimumCharacterLength;
      }

      // 3. Contains numbers
      if (RegExpressions.numeric.hasMatch(value)) {
        errorCount++;
        firstError ??= AppLocalizations.of(context)!.mProfileNumbersNotAllowed;
      }

      // 4. Starts or ends with space
      if (RegExpressions.startAndEndWithSpace.hasMatch(value)) {
        errorCount++;
        firstError ??=
            AppLocalizations.of(context)!.mProfileNoSpaceInStartOrEnd;
      }

      // 5. Contains special characters (not allowed)
      if (RegExpressions.specialChar.hasMatch(value)) {
        errorCount++;
        firstError ??=
            AppLocalizations.of(context)!.mProfileNoSpecialCharacterAllowed;
      }

      // 6. Multiple consecutive spaces
      if (RegExpressions.multipleConsecutiveSpace.hasMatch(value)) {
        errorCount++;
        firstError ??= AppLocalizations.of(context)!.mStaticOnlyOneSpaceAllowed;
      }
    }
    if (errorCount >= 2) {
      return AppLocalizations.of(context)!.mProfileInvalidNameFormat;
    } else if (errorCount == 1) {
      return firstError;
    }

    return null;
  }

  Future<bool> addStateAndDistrict(
      String state, String district, BuildContext context) async {
    Map<String, dynamic> content = {'locationDetails': []};
    if (state.isNotEmpty) {
      if (content['locationDetails'].isEmpty) {
        content['locationDetails'].add({'state': state});
      } else {
        content['locationDetails'][0]['state'] = state;
      }
    }
    if (district.isNotEmpty) {
      if (content['locationDetails'].isEmpty) {
        content['locationDetails'].add({'district': district});
      } else {
        content['locationDetails'][0]['district'] = district;
      }
    }
    String response = await ProfileRepository().saveExtendedProfile(content);
    if (response.toLowerCase() == EnglishLang.ok.toLowerCase()) {
      SearchHelper().showOverlayMessage(
          AppLocalizations.of(context)!.mProfileAddedSuccessfully, context,
          duration: 3, bgColor: AppColors.positiveLight);
      return true;
    } else {
      SearchHelper().showOverlayMessage(response, context,
          duration: 3, bgColor: AppColors.negativeLight);
      return false;
    }
  }

  Future<bool> updateStateAndDistrict(
      String uuid, String state, String district, BuildContext context) async {
    Map<String, dynamic> content = {
      'locationDetails': [
        {
          'uuid': uuid,
        }
      ]
    };
    if (state.isNotEmpty) {
      content['locationDetails'][0]['state'] = state;
    }
    if (district.isNotEmpty) {
      content['locationDetails'][0]['district'] = district;
    }
    String response = await ProfileRepository().updateExtendedProfile(content);
    if (response.toLowerCase() == EnglishLang.ok.toLowerCase()) {
      return true;
    } else {
      SearchHelper().showOverlayMessage(response, context,
          duration: 3, bgColor: AppColors.negativeLight);
      return false;
    }
  }

  Future<bool> updateName(String fullName, BuildContext context) async {
    Map profileData = {
      'personalDetails': {'firstname': fullName}
    };
    final response = await ProfileService().updateProfileDetails(profileData);
    if ((response['params']['errmsg'] == null ||
            response['params']['errmsg'] == '') &&
        (response['params']['err'] == null ||
            response['params']['err'] == '')) {
      /** SMT User Profile update **/
      smtUpdateUserPatchDetail(context: context, fullName: fullName);
      await Provider.of<ProfileRepository>(context, listen: false)
          .getProfileDetailsById('');
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

  void smtUpdateUserPatchDetail(
      {required BuildContext context, required String fullName}) async {
    if (fullName.isNotEmpty) {
      try {
        if (isNetcoreActive) {
          bool _isUpdateUserProfileEnabled =
              await Provider.of<LearnRepository>(context, listen: false)
                  .isSmartechEventEnabled(
                      eventName: SMTTrackEvents.userProfilePush, reload: false);
          if (_isUpdateUserProfileEnabled) {
            bool _isTrackProfileUpdateEnabled =
                await Provider.of<LearnRepository>(context, listen: false)
                    .isSmartechEventEnabled(
                        eventName: SMTTrackEvents.profileUpdate);
            SmartechService.updateUserPatchDetail(
                context: context,
                profileAttributeUpdated: SMTUserProfileKeys.fullName,
                isTrackProfileUpdateEnabled: _isTrackProfileUpdateEnabled,
                userPatchData: {
                  SMTUserProfileKeys.fullName:
                      "${(fullName).toString().trim().toLowerCase()}"
                });
          }
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  List<String> getStateNames(List<StateModel> states) {
    return states.map((state) => state.stateName).toList();
  }

  List<String> getDistrictNames(
      List<DistrictModel> districtData, String state) {
    DistrictModel? dist;
    dist = districtData.cast<DistrictModel?>().firstWhere(
        (data) => data != null && data.stateName == state,
        orElse: () => null);
    return dist != null ? dist.districts : [];
  }

  Future<bool> deletePhoto(BuildContext context) async {
    Map profileData = {'profileImageUrl': ''};
    final response = await profileRepository.updateProfileDetails(profileData);
    if ((response['params']['errmsg'] == null ||
            response['params']['errmsg'] == '') &&
        (response['params']['err'] == null ||
            response['params']['err'] == '')) {
      await Provider.of<ProfileRepository>(context, listen: false)
          .getProfileDetailsById('');
      await _storage.write(key: Storage.profileImageUrl, value: '');
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

  /// Post connection request
  Future<bool> createConnectionRequest(
      {required BuildContext context,
      required String connectionId,
      required String userNameTo,
      required String userDepartmentTo}) async {
    try {
      Profile? profileDetails =
          Provider.of<ProfileRepository>(context, listen: false).profileDetails;
      var _response = await NetworkService.createConnectionRequest(
          connectionId,
          profileDetails?.firstName ?? '',
          profileDetails?.department ?? '',
          userNameTo,
          userDepartmentTo);
      if (_response['result']['message'] == 'Successful') {
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!.mStaticConnectionRequestSent,
            bgColor: AppColors.positiveLight);
        return true;
      } else {
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!.mStaticErrorMessage,
            bgColor: AppColors.negativeLight);
        return false;
      }
    } catch (err) {
      Helper.showSnackBarMessage(
          context: context,
          text: AppLocalizations.of(context)!.mStaticErrorMessage,
          bgColor: AppColors.negativeLight);
      return false;
    }
  }

  final Map<UserConnectionStatus, Widget Function()> connectionThumbMap = {
  UserConnectionStatus.Connect: () => Icon(
        Icons.person_add_alt_1_rounded,
        color: AppColors.darkBlue,
        size: 16.sp,
      ),
  UserConnectionStatus.Pending: () => Icon(
        Icons.watch_later_outlined,
        color: AppColors.darkBlue,
        size: 16.sp,
      ),
  UserConnectionStatus.Approved: () => SvgPicture.asset(
        "assets/img/person_connected.svg",
        height: 16.sp,
        width: 16.sp,
        colorFilter: ColorFilter.mode(
          AppColors.appBarBackground,
          BlendMode.srcIn,
        ),
      ),
};
}
