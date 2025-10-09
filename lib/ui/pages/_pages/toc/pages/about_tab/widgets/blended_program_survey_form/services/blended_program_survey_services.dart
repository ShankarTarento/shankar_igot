import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';

import 'package:karmayogi_mobile/feedback/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BlendedProgramSurveyServices {
  String? generalValidator(
      {String? value,
      required bool isRequired,
      required String fieldType,
      required BuildContext context}) {
    if (isRequired && (value == null || value.isEmpty)) {
      return AppLocalizations.of(context)!.mThisFieldIsRequired;
    }
    String type = fieldType.replaceAll(' ', '').toLowerCase();

    switch (type) {
      case QuestionType.email:
        if ((value != null && value.isNotEmpty)) {
          final emailRegex = RegExpressions.validEmail;

          if (!emailRegex.hasMatch(value)) {
            return AppLocalizations.of(context)!.mStaticEmailValidationText;
          }
        }
        break;

      case QuestionType.phoneNumber:
        if ((value != null && value.isNotEmpty)) {
          final mobileRegex = RegExpressions.validPhone;
          if (!mobileRegex.hasMatch(value)) {
            return AppLocalizations.of(context)!
                .mProfileMobileNumberLengthError;
          }
        }
        break;

      case QuestionType.text || QuestionType.textarea || QuestionType.numeric:
        if ((value == null || value.isEmpty)) {
          return AppLocalizations.of(context)!.mThisFieldIsRequired;
        }

        break;
      case QuestionType.dropdown ||
            QuestionType.radio ||
            QuestionType.checkbox ||
            QuestionType.rating ||
            QuestionType.date:
        if ((value != null && value.isNotEmpty)) {
          return AppLocalizations.of(context)!.mSelectAnOption;
        }
        break;

      default:
        print(type);
        return AppLocalizations.of(context)!.mThisFieldIsRequired;
    }

    return null;
  }
}
