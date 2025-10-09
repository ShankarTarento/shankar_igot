import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/blended_program_user_form/constants/survey_form_constants.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:provider/provider.dart';

class BlendedProgramFormServices {
  Future<bool> submitProfileSurveyForm(
      {required Batch batch,
      Profile? updatedProfileData,
      String? designation,
      required BuildContext context,
      required String courseId}) async {
    List bpEnrolMandatoryProfileFields =
        batch.batchAttributes!.raw['bpEnrolMandatoryProfileFields'] ?? [];
    Profile? profileDetails = updatedProfileData ??
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    Map<String, dynamic> submit = {};

    for (var data in bpEnrolMandatoryProfileFields) {
      dynamic value;
      switch (data['displayName']) {
        case SurveyFormConstants.name:
          value = profileDetails?.firstName;
          break;

        case SurveyFormConstants.organisation:
          break;

        case SurveyFormConstants.group:
          value = profileDetails?.group;
          break;

        case SurveyFormConstants.designation:
          value = designation ?? profileDetails?.designation;
          break;

        case SurveyFormConstants.employeeId:
          value = profileDetails?.employmentDetails?['employeeCode'];
          break;

        case SurveyFormConstants.email:
          value = profileDetails?.personalDetails['primaryEmail'];
          break;

        case SurveyFormConstants.mobileNumber:
          value = profileDetails?.personalDetails['mobile'];
          break;

        case SurveyFormConstants.gender:
          value = profileDetails?.personalDetails['gender'];
          break;

        case SurveyFormConstants.dateOfBirth:
          value = (profileDetails?.personalDetails['dob'] != null &&
                  profileDetails?.personalDetails['dob'] != '')
              ? _convertDateSafe(profileDetails?.personalDetails['dob']!)
              : null;
          break;

        case SurveyFormConstants.motherTongue:
          value = profileDetails?.personalDetails['domicileMedium'];
          break;

        case SurveyFormConstants.category:
          value = profileDetails?.personalDetails['category'];
          break;

        case SurveyFormConstants.officePinCode:
          value = profileDetails?.employmentDetails?['pinCode'];
          break;

        case SurveyFormConstants.ehrmsId:
          value = profileDetails?.ehrmsId;
          break;

        case SurveyFormConstants.dateOfRetirement:
          value = profileDetails?.employmentDetails?['retirementDate'];
          break;

        case SurveyFormConstants.cadreEmployee:
          value = profileDetails?.cadreDetails?['civilServiceType'] != null
              ? true
              : false;
          break;

        case SurveyFormConstants.typeOfService:
          value = profileDetails?.cadreDetails?['civilServiceType'];
          break;

        case SurveyFormConstants.service:
          value = profileDetails?.cadreDetails?['civilServiceName'];
          break;

        case SurveyFormConstants.cadre:
          value = profileDetails?.cadreDetails?['cadreName'];
          break;

        case SurveyFormConstants.cadreBatch:
          value = profileDetails?.cadreDetails?['cadreBatch'];
          break;

        case SurveyFormConstants.cadreControllingAuthorityName:
          value =
              profileDetails?.cadreDetails?['cadreControllingAuthorityName'];
          break;

        default:
          debugPrint("Unknown display name========= ${data['displayName']}");
      }

      // Only add if value is not null, not empty, and not 'N/A'
      if (value != null &&
          value.toString().trim().isNotEmpty &&
          value != 'N/A') {
        submit[data['displayName']] = value;
      }
    }

    String? response = await LearnService().submitProfileSurveyForm(
      courseId: courseId,
      dataObject: submit,
      formId: batch.batchAttributes?.raw['profileSurveyId'] ?? "",
    );
    debugPrint(" profileFormStatus====== $response");
    debugPrint("$submit");
    if (response != null && response.toLowerCase() == 'success') {
      return true;
    } else {
      return false;
    }
  }

  String _convertDateSafe(String date) {
    try {
      return DateTimeHelper.convertDateFormat(
        date,
        desiredFormat: DateFormatString.yyyyMMdd,
        inputFormat: DateFormatString.ddMMyyyy,
      );
    } catch (e) {
      return 'N/A';
    }
  }
}
