import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/index.dart';

class AiTutorType {
  final String title;
  final String subTitle;
  final String socketUrl;
  final String telemetrySubType;

  AiTutorType(
      {required this.title,
      required this.subTitle,
      required this.socketUrl,
      required this.telemetrySubType});

  static List<AiTutorType> getAiTutorTypes(BuildContext context) {
    return [
      AiTutorType(
        title: AppLocalizations.of(context)!.mNone,
        subTitle: AppLocalizations.of(context)!.mLearnWithNaturalQueryProvess,
        socketUrl: SocketUrl.socketUrl,
        telemetrySubType: TelemetrySubType.none,
      ),
      AiTutorType(
          title: AppLocalizations.of(context)!.mSocratic,
          subTitle: AppLocalizations.of(context)!
              .mExploreIdeasThroughThoughtfulQuestions,
          socketUrl: SocketUrl.socraticSocketUrl,
          telemetrySubType: TelemetrySubType.socratic),
      AiTutorType(
          title: AppLocalizations.of(context)!.mStoryTelling,
          subTitle: AppLocalizations.of(context)!.mStoryTellingDescription,
          socketUrl: SocketUrl.storyTelling,
          telemetrySubType: TelemetrySubType.storyTelling),
    ];
  }
}
