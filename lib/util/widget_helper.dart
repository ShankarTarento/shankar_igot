import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class WidgetHelper {

  /// get competency card background color
  static Color getCompetencyAreaColor(String competencyName) {
    switch (competencyName.toLowerCase()) {
      case CompetencyAreas.behavioural:
        return AppColors.orangeShade1;
      case CompetencyAreas.domain:
        return AppColors.purpleShade1;
      default:
        return AppColors.pinkShade1;
    }
  }

  /// get competency image
  static String getCompetencyImageUrl(String competencyName) {
    switch (competencyName.toLowerCase()) {
      case CompetencyAreas.behavioural:
        return 'assets/img/behavioural_competency.svg';
      case CompetencyAreas.domain:
        return 'assets/img/domain_competency.svg';
      case CompetencyAreas.functional:
        return 'assets/img/functional_competency.svg';
      default:
        return 'assets/img/functional_competency.svg'; // Default image
    }
  }
}
