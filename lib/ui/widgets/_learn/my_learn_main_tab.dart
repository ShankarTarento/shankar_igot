import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyLearnMainTab {
  final String title;

  MyLearnMainTab({
    required this.title,
  });

  static List<MyLearnMainTab> items({required BuildContext context}) => [
        MyLearnMainTab(title: AppLocalizations.of(context)!.mStaticContents
            ),
        MyLearnMainTab(
          title: AppLocalizations.of(context)!.mCommonEvents,
        )
      ];
}

class MyLearnContentsTab {
  final String title;

  MyLearnContentsTab({
    required this.title,
  });

  static List<MyLearnContentsTab> items({required BuildContext context}) => [
        MyLearnContentsTab(
            title: AppLocalizations.of(context)!.mStaticInprogress),
        MyLearnContentsTab(
          title: AppLocalizations.of(context)!.mStaticCompleted,
        )
      ];
}

class MyLearnEventsTab {
  final String title;

  MyLearnEventsTab({
    required this.title,
  });

  static List<MyLearnEventsTab> items({required BuildContext context}) => [
        MyLearnEventsTab(
            title: AppLocalizations.of(context)!.mStaticInprogress),
        MyLearnEventsTab(
          title: AppLocalizations.of(context)!.mStaticCompleted,
        )
      ];
}
