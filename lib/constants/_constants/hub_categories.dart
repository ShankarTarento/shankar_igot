// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import '../../models/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<Hub> HUBS({required BuildContext context}) => [
      Hub(
          id: 1,
          title: AppLocalizations.of(context)!.mStaticLearn,
          description: AppLocalizations.of(context)!.mStaticLearnSubtitle,
          icon: Icons.school_rounded,
          iconColor: AppColors.darkBlue,
          comingSoon: false,
          url: AppUrl.learningHub,
          svgIcon: 'assets/img/learn_active.svg',
          svg: true,
          telemetryId: TelemetryIdentifier.learn),
      Hub(
          id: 2,
          title: AppLocalizations.of(context)!.mStaticDiscuss,
          description: AppLocalizations.of(context)!.mStaticDiscussSubtitle,
          icon: Icons.forum,
          iconColor: AppColors.darkBlue,
          comingSoon: false,
          url: AppUrl.discussionHub,
          svgIcon: 'assets/img/discuss_icon.svg',
          svg: true,
          telemetryId: TelemetryIdentifier.discuss),
      Hub(
          id: 3,
          title: AppLocalizations.of(context)!.mAmritGyaanKoshTitle,
          description:
              AppLocalizations.of(context)!.mStaticKnowledgeResourcesSubtitle,
          icon: Icons.menu_book,
          iconColor: AppColors.darkBlue,
          comingSoon: false,
          url: AppUrl.knowledgeResourcesPage,
          svgIcon: '',
          svg: false,
          telemetryId: TelemetryIdentifier.amritGyaanKosh),
      Hub(
          id: 4,
          title: AppLocalizations.of(context)!.mStaticEvents,
          description: AppLocalizations.of(context)!.mStaticEventsSubtitle,
          icon: Icons.extension_rounded,
          iconColor: AppColors.darkBlue,
          comingSoon: false,
          url: AppUrl.eventsHub,
          svgIcon: 'assets/img/events_icon.svg',
          svg: true,
          telemetryId: 'events'),
      Hub(
          id: 5,
          title: AppLocalizations.of(context)!.mStaticNetwork,
          description: AppLocalizations.of(context)!.mStaticNetworkSubtitle,
          icon: Icons.supervisor_account,
          iconColor: AppColors.darkBlue,
          comingSoon: false,
          url: AppUrl.networkHub,
          svgIcon: 'assets/img/network_icon.svg',
          svg: true,
          telemetryId: TelemetryIdentifier.network),
    ];

List<Hub> DO_MORE({required BuildContext context}) => [
      Hub(
          id: 1,
          title: AppLocalizations.of(context)!.mStaticlearningHistory,
          description: AppLocalizations.of(context)!.mStaticCheckPassbook,
          icon: Icons.menu_book_rounded,
          iconColor: Color.fromRGBO(0, 0, 0, 0.6),
          comingSoon: false,
          url: AppUrl.competencyPassbookPage,
          svgIcon: 'assets/img/competency_passbook.svg',
          svgColor: Color.fromRGBO(0, 0, 0, 0.6),
          svg: true,
          telemetryId: 'learning-history'),
      Hub(
          id: 2,
          title: AppLocalizations.of(context)!.mExploreDiscoverMentors,
          description:
              AppLocalizations.of(context)!.mExploreDiscoverMentorsDescription,
          icon: Icons.people_alt,
          iconColor: Color.fromRGBO(0, 0, 0, 0.6),
          comingSoon: false,
          url: '',
          svgIcon: 'assets/img/network_icon.svg',
          svg: false,
          externalUrl: ApiUrl.mentorshipUrl,
          telemetryId: 'discover-mentors',
          enabled: AppConfiguration.mentorshipEnabled),
      Hub(
          id: 3,
          title: 'Other Resources',
          description: 'Other Resources',
          icon: Icons.settings,
          iconColor: Color.fromRGBO(0, 0, 0, 0.6),
          comingSoon: false,
          url: AppUrl.knowledgeResourcesPage,
          svgIcon: '',
          svg: false,
          telemetryId: 'settings'),
      Hub(
          id: 4,
          title: AppLocalizations.of(context)!.mStaticSettings,
          description: AppLocalizations.of(context)!.mStaticSettingsSubtitle,
          icon: Icons.settings,
          iconColor: Color.fromRGBO(0, 0, 0, 0.6),
          comingSoon: false,
          url: AppUrl.settingsPage,
          svgIcon: '',
          svg: false,
          telemetryId: 'settings'),
    ];

List<Hub> COMING_SOON({required BuildContext context}) => [
      Hub(
          id: 1,
          title: AppLocalizations.of(context)!.mStaticCareers,
          description: AppLocalizations.of(context)!.mStaticCareersSubtitle,
          icon: Icons.business_center_rounded,
          iconColor: AppColors.darkBlue,
          comingSoon: true,
          url: AppUrl.careersHub,
          svgIcon: 'assets/img/career_icon.svg',
          svg: true,
          telemetryId: 'career'),
      Hub(
          id: 2,
          title: AppLocalizations.of(context)!.mLearnCourseCompetency,
          description:
              AppLocalizations.of(context)!.mStaticCompetenciesSubtitle,
          icon: Icons.extension_rounded,
          iconColor: AppColors.darkBlue,
          comingSoon: true,
          url: AppUrl.competencyHub,
          svgIcon: 'assets/img/competency_icon.svg',
          svg: true,
          telemetryId: 'competency'),
    ];
