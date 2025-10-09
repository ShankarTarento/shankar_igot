import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../constants/index.dart';
import '../../../../../localization/index.dart';
import '../model/profile_other_primary_details.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/index.dart';
import '../../../../../services/_services/smartech_service.dart';
import '../../../../../services/index.dart';
import '../../../../../util/index.dart';
import '../model/cadre_request_data_model.dart';

class ProfileOtherDetailsViewModel {
  static final ProfileOtherDetailsViewModel _instance =
      ProfileOtherDetailsViewModel._internal();
  factory ProfileOtherDetailsViewModel() {
    return _instance;
  }

  ProfileOtherDetailsViewModel._internal();

  static Future<void> saveAboutDetails({
    required BuildContext context,
    required aboutMe,
    required Function() callback,
  }) async {
    Map payload = {
      'employmentDetails': {
        'aboutme': '${aboutMe}',
      }
    };

    var response;
    try {
      response = await ProfileService().updateProfileDetails(payload);
      FocusManager.instance.primaryFocus!.unfocus();
      if ((response['params']['errmsg'] == null ||
          response['params']['errmsg'] == '') &&
          (response['params']['err'] == null ||
              response['params']['err'] == '')) {
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!.mProfileUpdatedSuccessfully,
            bgColor: AppColors.positiveLight);
        Provider.of<ProfileRepository>(context, listen: false)
            .getInReviewFields(forceUpdate: true);
        List<Profile>? _profileDetails =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
        callback();
        if (isNetcoreActive) {
          bool _isUpdateUserProfileEnabled =
          await Provider.of<LearnRepository>(context, listen: false)
              .isSmartechEventEnabled(
              eventName: SMTTrackEvents.userProfilePush,
              reload: false);
          if (_isUpdateUserProfileEnabled) {
            bool _isTrackProfileUpdateEnabled =
            await Provider.of<LearnRepository>(context, listen: false)
                .isSmartechEventEnabled(
                eventName: SMTTrackEvents.profileUpdate);
            SmartechService.updateUserDetails(
                userObj: _profileDetails.first,
                isTrackProfileUpdateEnabled: _isTrackProfileUpdateEnabled);
          }
        }
      } else {
        Helper.showSnackBarMessage(
            context: context,
            text: response['params']['errmsg'] != null
                ? response['params']['errmsg']
                : AppLocalizations.of(context)!.mProfileSaveProfileErrorText,
            bgColor: Theme.of(context).colorScheme.error);
      }
    } catch (err) {
      throw err;
    }
  }

  static Future<void> saveOtherPrimaryProfileDetails({
    required BuildContext context,
    required ProfileOtherPrimaryDetails profileOtherPrimaryDetails,
    required Function() callback,
  }) async {
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    Map payload = {};
    var editedPersonalDetails = getEdittedMandatoryPersonalDetails(
        profileDetails: profileDetails!,
        profileOtherPrimaryDetails: profileOtherPrimaryDetails);

    var editedEmploymentDetails = getEdittedEmploymentDetails(
        profileDetails: profileDetails,
        profileOtherPrimaryDetails: profileOtherPrimaryDetails);

    if (editedPersonalDetails.isNotEmpty) {
      payload['personalDetails'] = editedPersonalDetails;
    }

    if (editedEmploymentDetails.isNotEmpty) {
      payload['employmentDetails'] = editedEmploymentDetails;
    }

    ///Cadre started
    bool _isCadreDetailUpdated = false;
    if (profileOtherPrimaryDetails.cadreRequestData != null) {
      if ((profileOtherPrimaryDetails.cadreRequestData?.cadreEmployee ?? '')
              .toString()
              .toLowerCase() ==
          EnglishLang.yes.toLowerCase()) {
        var editedCadreDetails = getEdittedCadreDetails(
            profileDetails: profileDetails,
            cadreRequestData: profileOtherPrimaryDetails.cadreRequestData);
        if (editedCadreDetails.isNotEmpty) {
          payload['cadreDetails'] = editedCadreDetails;
          _isCadreDetailUpdated = true;
        }
      } else {
        payload['cadreDetails'] = {};
        _isCadreDetailUpdated = true;
      }
    }

    ///Cadre end

    var response;
    if (editedPersonalDetails.isNotEmpty ||
        editedEmploymentDetails.isNotEmpty ||
        _isCadreDetailUpdated) {
      try {
        response = await ProfileService().updateProfileDetails(payload);
        FocusManager.instance.primaryFocus!.unfocus();
        if ((response['params']['errmsg'] == null ||
                response['params']['errmsg'] == '') &&
            (response['params']['err'] == null ||
                response['params']['err'] == '')) {
          Helper.showSnackBarMessage(
              context: context,
              text: AppLocalizations.of(context)!.mProfileDetailsUpdated,
              bgColor: AppColors.positiveLight);
          Provider.of<ProfileRepository>(context, listen: false)
              .getInReviewFields(forceUpdate: true);
          List<Profile>? _profileDetails =
              await Provider.of<ProfileRepository>(context, listen: false)
                  .getProfileDetailsById('');
          callback();
          if (isNetcoreActive) {
            bool _isUpdateUserProfileEnabled =
                await Provider.of<LearnRepository>(context, listen: false)
                    .isSmartechEventEnabled(
                        eventName: SMTTrackEvents.userProfilePush,
                        reload: false);
            if (_isUpdateUserProfileEnabled) {
              bool _isTrackProfileUpdateEnabled =
                  await Provider.of<LearnRepository>(context, listen: false)
                      .isSmartechEventEnabled(
                          eventName: SMTTrackEvents.profileUpdate);
              SmartechService.updateUserDetails(
                  userObj: _profileDetails.first,
                  isTrackProfileUpdateEnabled: _isTrackProfileUpdateEnabled);
            }
          }
        } else {
          Helper.showSnackBarMessage(
              context: context,
              text: response['params']['errmsg'] != null
                  ? response['params']['errmsg']
                  : AppLocalizations.of(context)!.mProfileSaveProfileErrorText,
              bgColor: Theme.of(context).colorScheme.error);
        }
      } catch (err) {
        throw err;
      }
    }
  }

  static getEdittedMandatoryPersonalDetails(
      {required Profile profileDetails,
      required ProfileOtherPrimaryDetails profileOtherPrimaryDetails}) {
    dynamic fetchedPersonalDetails = profileDetails.personalDetails;
    var personalDetails = [
      // {
      //   'firstname': profileOtherPrimaryDetails.fullName,
      //   'isChanged':
      //       profileOtherPrimaryDetails.fullName != profileDetails.firstName
      // },
      {
        'dob': profileOtherPrimaryDetails.dob,
        'isChanged':
            profileOtherPrimaryDetails.dob != fetchedPersonalDetails['dob']
      },
      {
        'gender': profileOtherPrimaryDetails.gender,
        'isChanged': profileOtherPrimaryDetails.gender !=
            fetchedPersonalDetails['gender']
      },
      {
        'category': profileOtherPrimaryDetails.category,
        'isChanged': profileOtherPrimaryDetails.category !=
            fetchedPersonalDetails['category']
      },
      {
        'pincode': profileOtherPrimaryDetails.pinCode.toString(),
        'isChanged': profileOtherPrimaryDetails.pinCode.toString() !=
            fetchedPersonalDetails['pincode']
      },
      {
        'domicileMedium': profileOtherPrimaryDetails.motherTongue,
        'isChanged': (profileOtherPrimaryDetails.motherTongue != null &&
            profileOtherPrimaryDetails.motherTongue !=
                fetchedPersonalDetails['domicileMedium'])
      },
      {
        'phoneVerified': profileOtherPrimaryDetails.phoneVerified,
        'isChanged': (profileOtherPrimaryDetails.phoneVerified != null &&
            profileOtherPrimaryDetails.phoneVerified !=
                fetchedPersonalDetails['phoneVerified'])
      },
      {
        'primaryEmail': profileOtherPrimaryDetails.primaryEmail,
        'isChanged': (profileOtherPrimaryDetails.primaryEmail != null &&
            profileOtherPrimaryDetails.primaryEmail !=
                fetchedPersonalDetails['primaryEmail'])
      },
      {
        'mobile': profileOtherPrimaryDetails.mobile,
        'isChanged': (profileOtherPrimaryDetails.mobile != null &&
            profileOtherPrimaryDetails.mobile !=
                fetchedPersonalDetails['mobile'])
      }
    ];
    var edited = {};
    var editedPersonalDetails =
        personalDetails.where((data) => data['isChanged'] == true);

    editedPersonalDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    return edited;
  }

  static getEdittedCadreDetails(
      {required Profile profileDetails,
      required CadreRequestDataModel? cadreRequestData}) {
    dynamic cadreDetails = profileDetails.cadreDetails ?? {};
    var userCadreDetails = [
      {
        'civilServiceTypeId': cadreRequestData?.civilServiceTypeId ?? '',
        'isChanged': cadreRequestData?.civilServiceTypeId !=
            cadreDetails['civilServiceTypeId']
      },
      {
        'civilServiceType': cadreRequestData?.civilServiceType ?? '',
        'isChanged': cadreRequestData?.civilServiceType !=
            cadreDetails['civilServiceType']
      },
      {
        'civilServiceId': cadreRequestData?.civilServiceId ?? '',
        'isChanged':
            cadreRequestData?.civilServiceId != cadreDetails['civilServiceId']
      },
      {
        'civilServiceName': cadreRequestData?.civilServiceName ?? '',
        'isChanged': cadreRequestData?.civilServiceName !=
            cadreDetails['civilServiceName']
      },
      {
        'cadreId': cadreRequestData?.cadreId ?? '',
        'isChanged': cadreRequestData?.cadreId != cadreDetails['cadreId']
      },
      {
        'cadreName': cadreRequestData?.cadreName ?? '',
        'isChanged': cadreRequestData?.cadreName != cadreDetails['cadreName']
      },
      {
        'cadreBatch': cadreRequestData?.cadreBatch ?? '',
        'isChanged': cadreRequestData?.cadreBatch != cadreDetails['cadreBatch']
      },
      {
        'cadreControllingAuthorityName':
            cadreRequestData?.cadreControllingAuthorityName ?? '',
        'isChanged': cadreRequestData?.cadreControllingAuthorityName !=
            cadreDetails['cadreControllingAuthorityName']
      },
      {
        'isOnCentralDeputation': cadreRequestData?.isOnCentralDeputation ?? false,
        'isChanged': cadreRequestData?.isOnCentralDeputation != cadreDetails['isOnCentralDeputation']
      },
    ];
    var edited = {};
    var editedEmploymentDetails =
        userCadreDetails.where((data) => data['isChanged'] == true);

    if (editedEmploymentDetails.isNotEmpty) {
      userCadreDetails.forEach((element) {
        edited[element.entries.first.key] = element.entries.first.value;
      });
    }
    return edited;
  }

  static getEdittedEmploymentDetails(
      {required Profile profileDetails,
      required ProfileOtherPrimaryDetails profileOtherPrimaryDetails}) {
    dynamic employmentDetails = profileDetails.employmentDetails;
    var userEmploymentDetails = [
      {
        'employeeCode': profileOtherPrimaryDetails.employeeId,
        'isChanged': profileOtherPrimaryDetails.employeeId != employmentDetails['employeeCode'],
      },
      {
        'pinCode': profileOtherPrimaryDetails.pinCode.toString(),
        'isChanged': profileOtherPrimaryDetails.pinCode.toString() != employmentDetails['pinCode']
      },
    ];
    var edited = {};
    var editedEmploymentDetails =
        userEmploymentDetails.where((data) => data['isChanged'] == true);

    editedEmploymentDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    return edited;
  }
}
