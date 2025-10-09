import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/models/_models/browse_by_model.dart';

class LearnHubConstants {
  static final List<MultiLingualText> learnHubTabs = [
    MultiLingualText(id: "overview", enText: "Overview", hiText: "सारांश"),
    MultiLingualText(
        id: "yourLearning", enText: "Your Learning", hiText: "आपकी शिक्षा"),
    MultiLingualText(
        id: "exploreBy", enText: "Explore By", hiText: "के अनुसार खोजें")
  ];
}

// ignore: non_constant_identifier_names
List<BrowseBy> BROWSEBY({required BuildContext context}) => [
      BrowseBy(
          id: 1,
          title: AppLocalizations.of(context)!.mStaticExploreByCompetency,
          description: AppLocalizations.of(context)!.mStaticBrowseCompetency,
          comingSoon: false,
          svgImage: 'assets/img/browse-by-competency.svg',
          url: AppUrl.browseByCompetencyPage,
          telemetryId: TelemetryIdentifier.exploreByCompetency),
      BrowseBy(
          id: 2,
          title: AppLocalizations.of(context)!.mStaticExploreByProvider,
          description: AppLocalizations.of(context)!.mStaticBrowseProvider,
          comingSoon: false,
          svgImage: 'assets/img/browse-by-provider.svg',
          url: AppUrl.browseByAllProviderPage,
          telemetryId: TelemetryIdentifier.exploreByProvider),
      BrowseBy(
          id: 3,
          title: AppLocalizations.of(context)!.mStaticCuratedCollections,
          description:
              AppLocalizations.of(context)!.mStaticBrowseCuratedCollections,
          comingSoon: false,
          svgImage: 'assets/img/browse-by-provider.svg',
          url: AppUrl.curatedCollectionsPage,
          telemetryId: TelemetryIdentifier.curatedCollections),
      BrowseBy(
          id: 4,
          title: AppLocalizations.of(context)!.mCommonModeratedCourses,
          description:
              AppLocalizations.of(context)!.mStaticBrowseModeratedCourses,
          comingSoon: false,
          svgImage: 'assets/img/browse-by-topic.svg',
          url: AppUrl.moderatedCoursesPage,
          telemetryId: TelemetryIdentifier.moderatedCourses),
      BrowseBy(
          id: 6,
          title: AppLocalizations.of(context)!.mStaticChannels,
          description:
              AppLocalizations.of(context)!.mStaticExploreByAllChannels,
          comingSoon: false,
          svgImage: 'assets/img/browse-by-provider.svg',
          url: AppUrl.browseByAllChannel,
          telemetryId: TelemetryIdentifier.exploreByMdoChannel),
      BrowseBy(
          id: 5,
          title: AppLocalizations.of(context)!.mHomeKarmaPrograms,
          description:
              AppLocalizations.of(context)!.mLearnKarmaProgramDescription,
          comingSoon: false,
          svgImage: 'assets/img/browse-by-topic.svg',
          url: AppUrl.browseAllKarmaProgramsPage,
          telemetryId: 'karma-programs'),
    ];
