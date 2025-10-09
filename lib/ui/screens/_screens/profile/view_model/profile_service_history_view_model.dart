import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../../constants/index.dart';
import '../../../../../localization/index.dart';
import '../../../../../models/_models/register_organisation_model.dart';
import '../../../../../respositories/index.dart';
import '../../../../pages/_pages/search/utils/search_helper.dart';
import '../model/designation_model.dart';
import '../model/service_history_model.dart';

class ProfileServiceHistoryViewModel {
  static final ProfileServiceHistoryViewModel _instance =
      ProfileServiceHistoryViewModel._internal();
  factory ProfileServiceHistoryViewModel() {
    return _instance;
  }
  ProfileServiceHistoryViewModel._internal();

  final ProfileRepository profileRepository = ProfileRepository();

  Future<List<OrganisationModel>> getOrganizationsList(
      {required int offset, String query = ''}) async {
    List<OrganisationModel> ministryList = [];
    final response =
        await profileRepository.getOrgMasterList(offset: offset, query: query);
    ministryList = response;
    return ministryList;
  }

  Future<DateTime?> selectDate(BuildContext context,
      {DateTime? selectedDate, DateTime? startDate, DateTime? endDate}) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: startDate ?? DateTime(1900),
      lastDate: endDate ?? DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.darkBlue,
              onPrimary: AppColors.appBarBackground,
              onSurface: AppColors.darkBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.darkBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }

  List<String> getOrgNames(List<OrganisationModel> orgs) {
    List<String?> list = orgs.map((org) => org.name).toList();
    list.removeWhere((item) => item == null);
    return list.cast<String>();
  }

  Future<List<String>> getDesignationByOrgName(
      List<String> orgIdList, int offset,
      {String query = ''}) async {
    List<DesignationModel> designations =
        await profileRepository.getOrgBasedDesignationList(
            orgIdList: orgIdList, offset: offset, query: query);
    return getDesignationsNames(designations);
  }

  List<String> getDesignationsNames(List<DesignationModel> desg) {
    List<String?> list = desg.map((item) => item.name).toList();
    list.removeWhere((item) => item == null);
    return list.cast<String>();
  }

  OrganisationModel? getOrgByName(
      List<OrganisationModel> orgDataList, String orgName) {
    OrganisationModel? orgData = orgDataList
        .cast<OrganisationModel?>()
        .firstWhere((item) => item != null && item.name == orgName,
            orElse: () => null);
    return orgData;
  }

  Future<void> addServiceHistory(BuildContext context,
      {required String orgName,
      required String designation,
      required String state,
      required String district,
      required String startDate,
      required String orgLogo,
      String? endDate,
      String? description,
      String? currentlyWorking}) async {
    if (orgName.isEmpty || designation.isEmpty) {
      SearchHelper().showOverlayMessage(
          AppLocalizations.of(context)!.mStaticPleaseFillAllMandatory, context,
          duration: 3);
    } else {
      Map<String, dynamic> content = {
        'serviceHistory': [
          {'orgName': orgName, 'designation': designation}
        ]
      };
      if (state.isNotEmpty) {
        content['serviceHistory'][0]['orgState'] = state;
      }
      if (district.isNotEmpty) {
        content['serviceHistory'][0]['orgDistrict'] = district;
      }
      if (startDate.isNotEmpty) {
        content['serviceHistory'][0]['startDate'] =
            startDate.endsWith('Z') ? startDate : '${startDate}Z';
      }
      if (endDate != null && endDate.isNotEmpty) {
        content['serviceHistory'][0]['endDate'] =
            endDate.endsWith('Z') ? endDate : '${endDate}Z';
      }
      if (description != null && description.isNotEmpty) {
        content['serviceHistory'][0]['description'] = description;
      }
      if (currentlyWorking != null) {
        content['serviceHistory'][0]['currentlyWorking'] = currentlyWorking;
      }
      if (orgLogo.isNotEmpty) {
        content['serviceHistory'][0]['orgLogo'] = orgLogo;
      }
      String response = await ProfileRepository().saveExtendedProfile(content);
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

  Future<void> updateServiceHistory(BuildContext context,
      {required String orgName,
      required String designation,
      required String state,
      required String district,
      required String startDate,
      required String uuid,
      required String orgLogo,
      String? endDate,
      String? currentlyWorking,
      String? description}) async {
    Map<String, dynamic> content = {
      'serviceHistory': [
        {'uuid': uuid}
      ]
    };
    if (orgName.isNotEmpty) {
      content['serviceHistory'][0]['orgName'] = orgName;
    }
    if (designation.isNotEmpty) {
      content['serviceHistory'][0]['designation'] = designation;
    }
    if (state.isNotEmpty) {
      content['serviceHistory'][0]['orgState'] = state;
    }
    if (district.isNotEmpty || state.isNotEmpty) {
      content['serviceHistory'][0]['orgDistrict'] = district;
    }
    if (startDate.isNotEmpty) {
      content['serviceHistory'][0]['startDate'] =
          startDate.endsWith('Z') ? startDate : '${startDate}Z';
    }
    if ((endDate != null && endDate.isNotEmpty)) {
      content['serviceHistory'][0]['endDate'] =
          endDate.endsWith('Z') ? endDate : '${endDate}Z';
    }
    if (currentlyWorking != null) {
      content['serviceHistory'][0]['currentlyWorking'] = currentlyWorking;
      if (currentlyWorking == 'true') {
        content['serviceHistory'][0]['endDate'] = '';
      }
    }
    if (description != null) {
      content['serviceHistory'][0]['description'] = description;
    }
    if (orgLogo.isNotEmpty) {
      content['serviceHistory'][0]['orgLogo'] = orgLogo;
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

  Future<List<ServiceHistoryModel>> getExtendedServiceHistory(
      String? userId) async {
    return await profileRepository.getExtendedServiceHistory(userId);
  }

  String formatDuration(ServiceHistoryModel service, BuildContext context) {
    if (service.startDate.isEmpty) return '';

    final start = DateTime.tryParse(service.startDate);
    DateTime? end;

    final isCurrentlyWorking = service.currentlyWorking == 'true';

    // If no endDate and not currently working, just show start date
    if ((service.endDate.isEmpty) && (!isCurrentlyWorking)) {
      if (start == null) return '';
      final dateFormat = DateFormat('MMM yyyy');
      return dateFormat.format(start);
    }

    if ((service.endDate.isEmpty) && isCurrentlyWorking) {
      end = DateTime.now();
    } else if (service.endDate.isNotEmpty) {
      end = DateTime.tryParse(service.endDate);
    }

    if (start == null) return '';

    // Format dates
    final dateFormat = DateFormat('MMM yyyy');
    final startStr = dateFormat.format(start);
    final endStr = end != null
        ? (isCurrentlyWorking
            ? AppLocalizations.of(context)!.mStaticPresent
            : dateFormat.format(end))
        : '';

    // Duration calculation
    final effectiveEnd = end ?? DateTime.now();
    int years = effectiveEnd.year - start.year;
    int months = effectiveEnd.month - start.month;
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    // Only show years (rounded down)
    String durationStr = years > 0
        ? '$years ${years > 1 ? AppLocalizations.of(context)!.mSearchYears : AppLocalizations.of(context)!.mYear}'
        : (months > 0
            ? '$months ${months > 1 ? AppLocalizations.of(context)!.mStaticMonths : AppLocalizations.of(context)!.mMicroSiteMonth}'
            : '');

    return '$startStr ${endStr.isNotEmpty ? '- $endStr' : ''} ${endStr.isNotEmpty ? '- $durationStr' : ''}';
  }

  String buildOrgLocation(ServiceHistoryModel service) {
    final parts = [
      service.orgName.trim(),
      service.orgDistrict.trim(),
      service.orgState.trim(),
    ].where((e) => e.isNotEmpty).toList();

    return parts.join(', ');
  }

  bool isDateChanged(DateTime? newDate, String oldDate) {
    return (newDate != null &&
        (oldDate.isEmpty ||
            DateTime.parse(oldDate).toUtc() != newDate.toUtc()));
  }
}
