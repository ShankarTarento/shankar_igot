import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetencyTypesTab {
  final String title;

  CompetencyTypesTab({
    required this.title,
  });

  static List<CompetencyTypesTab> items({required BuildContext context}) => [
        // CompetencyTypesTab(
        //   title: EnglishLang.acquiredByYou,
        // ),
        // CompetencyTypesTab(
        //   title: EnglishLang.desired,
        // ),
        CompetencyTypesTab(
          title: AppLocalizations.of(context)!.mStaticRecommendedFromFrac,
        ),
        CompetencyTypesTab(
          title: AppLocalizations.of(context)!.mStaticRecommendedFromWAT,
        ),
        CompetencyTypesTab(
          title: AppLocalizations.of(context)!.mStaticAddedByYou,
        ),
      ];
}
