import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LearnMainTab {
  final String title;

  LearnMainTab({
    required this.title,
  });

  static List<LearnMainTab> items({required BuildContext context}) => [
        LearnMainTab(
          title: AppLocalizations.of(context)!.mLearnTabOverview,
        ),
        LearnMainTab(
          title: AppLocalizations.of(context)!.mLearnTabYourLearning,
        ),
        LearnMainTab(
          title: AppLocalizations.of(context)!.mTabExploreBy,
        ),
        LearnMainTab(
          title: AppLocalizations.of(context)!.mTabBites,
        ),
      ];
}
