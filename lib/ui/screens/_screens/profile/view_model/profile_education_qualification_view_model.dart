import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../constants/index.dart';
import '../../../../../localization/index.dart';
import '../../../../pages/_pages/search/utils/search_helper.dart';
import '../model/education_qualification_item_model.dart';

class EducationQualificationViewModel {
  static final EducationQualificationViewModel _instance =
      EducationQualificationViewModel._internal();

  factory EducationQualificationViewModel() {
    return _instance;
  }

  EducationQualificationViewModel._internal();

  final ProfileRepository profileRepository = ProfileRepository();

  Future<List<String>> getDegreeList() async {
    return await profileRepository.getDegreeList();
  }

  Future<List<String>> getInstitutionList() async {
    return await profileRepository.getInstitutionList();
  }

  Future<int?> showYearPickerDialog(BuildContext parentContext,
      {int? selectedYear, DateTime? lastDate, DateTime? firstDate}) async {
    final now = DateTime.now();
    int? pickedYear = selectedYear ?? now.year;

    return showDialog<int>(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(parentContext)!.mProfileSelectYear),
          content: SizedBox(
            height: 300.w,
            width: 300.w,
            child: YearPicker(
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(DateTime.now().year),
              selectedDate: DateTime(pickedYear),
              onChanged: (DateTime dateTime) {
                Navigator.pop(context, dateTime.year);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> addEducation(BuildContext context,
      {required String degree,
      required String fieldOfStudy,
      required String instituteName,
      required String startYear,
      required String endYear}) async {
    if (degree.isEmpty ||
        fieldOfStudy.isEmpty ||
        instituteName.isEmpty ||
        startYear.isEmpty ||
        endYear.isEmpty) {
      SearchHelper().showOverlayMessage(
          AppLocalizations.of(context)!.mStaticPleaseFillAllMandatory, context,
          duration: 3);
    } else {
      Map<String, dynamic> content = {
        'educationalQualifications': [
          {
            'degree': degree,
            'fieldOfStudy': fieldOfStudy,
            'institutionName': instituteName,
            'startYear': startYear,
            'endYear': endYear
          }
        ]
      };
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

  Future<void> updateEducation(BuildContext context,
      {required String degree,
      required String fieldOfStudy,
      required String instituteName,
      required String startYear,
      required String endYear,
      required String uuid}) async {
    Map<String, dynamic> content = {
      'educationalQualifications': [
        {
          'uuid': uuid,
        }
      ]
    };
    if (degree.isNotEmpty) {
      content['educationalQualifications'][0]['degree'] = degree;
    }
    if (fieldOfStudy.isNotEmpty) {
      content['educationalQualifications'][0]['fieldOfStudy'] = fieldOfStudy;
    }
    if (instituteName.isNotEmpty) {
      content['educationalQualifications'][0]['institutionName'] =
          instituteName;
    }
    if (startYear.isNotEmpty) {
      content['educationalQualifications'][0]['startYear'] = startYear;
    }
    if (endYear.isNotEmpty) {
      content['educationalQualifications'][0]['endYear'] = endYear;
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

  Future<List<EducationalQualificationItem>> getExtendedEducationHistory(
      String? userId) async {
    return await profileRepository.getExtendedEducationHistory(userId);
  }

  Future<void> updateDegreeMasterList(String degree) async {
    await profileRepository.updateDegreeMasterList(degree);
  }

  Future<void> updateInstitutionMasterList(String institution) async {
    await profileRepository.updateInstitutionMasterList(institution);
  }
}
