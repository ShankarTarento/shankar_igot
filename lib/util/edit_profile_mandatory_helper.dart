import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/_models/registration_group_model.dart';
import 'package:karmayogi_mobile/models/_models/verifiable_details_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/services/_services/registration_service.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_field_status_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditProfileMandatoryHelper {
  final RegistrationService registrationService = RegistrationService();
  static List<String> genderRadio = [
    EnglishLang.male,
    EnglishLang.female,
    EnglishLang.others
  ];

  static List categoryRadio = [
    EnglishLang.general,
    EnglishLang.obc,
    EnglishLang.sc,
    EnglishLang.st
  ];

  static List cadreRadio = [
    Helper.capitalize(EnglishLang.yes),
    Helper.capitalize(EnglishLang.no),
  ];

  static Future<List<String>> getNationalities(context) async {
    List<Nationality> nationalities =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getNationalities();
    List<String> countryCodes = [];
    nationalities.map((item) => item.country.toString()).toList();
    countryCodes = nationalities
        .map((item) => item.countryCode.toString())
        .toSet()
        .toList();
    countryCodes.sort();
    return countryCodes;
  }

  static String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return '$minutesStr:$secondsStr';
    }

    return '$hoursStr:$minutesStr:$secondsStr';
  }

  Future<List<RegistrationGroup>> getGroups(context) async {
    List<dynamic> listData =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getGroups();

    int index = 0;
    List<RegistrationGroup> groups = [];
    listData.forEach((item) {
      //UAT input for removing others from list of groups
      if (!item.toString().toLowerCase().contains('others')) {
        groups.insert(index, RegistrationGroup(name: item));
        index++;
      }
    });
    return groups;
  }

  Future<List<dynamic>> getDesignations(
    context,int offset, String query
  ) async {
    List<dynamic> designations =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getDesignations(offset, query);

    List<dynamic> designationList =
        designations.map((item) => item.toString()).toList();

    return designationList;
  }

  static void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  static Future<String> saveVerifiableProfileDetails(
      {required BuildContext context,
      VerifiableDetails? verifiableDetails,
      bool isUpdateDesignation = false,
      ProfileRepository? profileRepository}) async {
    Profile? profileDetails =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    List<ProfileFieldStatusModel> approvedFields =
        Provider.of<ProfileRepository>(context, listen: false).approvedFields;
    Map payload;
    var editedProfessionalDetails = isUpdateDesignation
        ? getUpdatedDesignation(
            profileDetails: profileDetails!,
            verifiableDetails: verifiableDetails!,
            approvedFields: approvedFields)
        : getEdittedMandatoryProfessionalDetails(
            profileDetails: profileDetails!,
            verifiableDetails: verifiableDetails!,
            approvedFields: approvedFields);

    payload = {
      'professionalDetails': [editedProfessionalDetails]
    };

    var response;
    try {
      final ProfileRepository profileRepo =
          profileRepository ?? ProfileRepository();
      response = await profileRepo.updateProfileDetails(payload);
      FocusManager.instance.primaryFocus!.unfocus();
      if ((response['params']['errmsg'] == null ||
              response['params']['errmsg'] == '') &&
          (response['params']['err'] == null ||
              response['params']['err'] == '')) {
        Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!.mProfileRequestSentSuccessMsg,
            bgColor: AppColors.positiveLight);
        await Provider.of<ProfileRepository>(context, listen: false)
            .getInReviewFields(forceUpdate: true);
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
        return EnglishLang.success;
      } else {
        Helper.showSnackBarMessage(
            context: context,
            text: response['params']['errmsg'] != null
                ? response['params']['errmsg']
                : AppLocalizations.of(context)!.mProfileSaveProfileErrorText,
            bgColor: Theme.of(context).colorScheme.error);
        return EnglishLang.failed;
      }
    } catch (err) {
      return EnglishLang.failed;
    }
  }

  static Future submitProfileTransferRequest(
      {required BuildContext context,
      required VerifiableDetails verifiableDetails,
      required BuildContext currentContext}) async {
    Map payload = {
      "professionalDetails": [
        {
          "name": verifiableDetails.organisation,
          "designation": verifiableDetails.position,
          "group": verifiableDetails.group
        }
      ]
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
            text:
                AppLocalizations.of(context)!.mProfileTransferRequestSuccessMsg,
            bgColor: AppColors.positiveLight);
        Navigator.of(currentContext).pop();
        Provider.of<ProfileRepository>(context, listen: false)
            .getInReviewFields(forceUpdate: true);
        Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
      } else {
        Helper.showSnackBarMessage(
            context: context,
            text: response['params']['errmsg'] != null
                ? response['params']['errmsg']
                : AppLocalizations.of(context)!.mProfileSaveProfileErrorText,
            bgColor: Theme.of(context).colorScheme.error);
      }
    } catch (err) {
      return err;
    }
  }

  static getEdittedMandatoryProfessionalDetails(
      {required Profile profileDetails,
      required VerifiableDetails verifiableDetails,
      required List<ProfileFieldStatusModel> approvedFields}) {
    var professionalDetails = [
      {
        'designation': verifiableDetails.position,
        'isChanged': verifiableDetails.position !=
            (approvedFields.firstWhere((element) => element.designation != null,
                orElse: () => ProfileFieldStatusModel(lastUpdatedOn: 0)
            ).designation ?? profileDetails.designation),
      },
      {
        'group': verifiableDetails.group,
        'isChanged': verifiableDetails.group !=
            (approvedFields.firstWhere((element) => element.group != null,
                orElse: () => ProfileFieldStatusModel(lastUpdatedOn: 0)
            ).group ?? profileDetails.group),
      },
    ];
    var edited = {};
    var editedProfessionalDetails =
        professionalDetails.where((data) => data['isChanged'] == true);

    editedProfessionalDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    return edited;
  }

  //Update designation only
  static getUpdatedDesignation(
      {required Profile profileDetails,
      required VerifiableDetails verifiableDetails,
      required List<dynamic> approvedFields}) {
    var professionalDetails = [
      {
        'designation': verifiableDetails.position,
        'isChanged': (verifiableDetails.position !=
            ((approvedFields.isNotEmpty &&
                    approvedFields
                        .where((element) => element.containsKey('designation'))
                        .isNotEmpty)
                ? approvedFields
                    .where((element) => element.containsKey('designation'))
                    .first['designation']
                : profileDetails.designation))
      }
    ];
    var edited = {};
    var editedProfessionalDetails =
        professionalDetails.where((data) => data['isChanged'] == true);

    editedProfessionalDetails.forEach((element) {
      edited[element.entries.first.key] = element.entries.first.value;
    });
    return edited;
  }
}
