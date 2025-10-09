import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetencyTab {
  final String title;

  CompetencyTab({
    required this.title,
  });

  static List<CompetencyTab> items({required BuildContext context}) => [
        CompetencyTab(
          title: AppLocalizations.of(context)!.mTabYourCompetencies,
        ),
        CompetencyTab(
          title: AppLocalizations.of(context)!.mTabAllCompetencies,
        ),
        // CompetencyTab(
        //   title: EnglishLang.desiredCompetencies,
        // ),
      ];
}
