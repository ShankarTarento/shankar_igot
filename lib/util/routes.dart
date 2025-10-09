import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/common_components/view_all_courses/view_all_courses.dart';
import 'package:karmayogi_mobile/landing_page.dart';
import 'package:karmayogi_mobile/models/_models/playlist_model.dart';
import 'package:karmayogi_mobile/ui/learn_hub/learn_hub.dart';
import 'package:karmayogi_mobile/ui/learn_hub/screens/explore_by/screens/browse_by_provider.dart';
import 'package:karmayogi_mobile/ui/learn_hub/screens/explore_by/screens/explore_by_competency_screen.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/karma_programs/karma_program_details.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/all_channel/browse_by_all_channel.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/external_course_toc.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/competency_passbook_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/competency_passbook_tabbed_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/competency_theme_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/onboarding_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/settings_screen/models/settings_request_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_detail_view.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_home.dart';
import '../models/_arguments/index.dart';
import '../models/_models/competency_data_model.dart';
import '../models/index.dart';
import '../oAuth2_login.dart';
import '../signup.dart';
import '../ui/pages/_pages/gyaan_karmayogi_v2/gyaan_karmayogi_v2.dart';
import '../ui/pages/_pages/learn/karma_programs/browse_all_karma_programs.dart';
import '../ui/pages/_pages/learn/karma_programs/karma_programs_detailsv2.dart';
import '../ui/pages/_pages/microsites/screen/all_provider_screen/browse_by_all_provider.dart';
import '../ui/pages/_pages/search/ui/screens/explore_content.dart';
import '../ui/screens/_screens/events_hub.dart';
import '../ui/screens/_screens/profile/model/profile_dashboard_arg_model.dart';
import '../ui/screens/_screens/profile/ui/pages/profile_dashboard.dart';
import '../ui/screens/_screens/recommended_learning_showall_screen.dart';
import '../ui/widgets/index.dart';
import './../ui/pages/index.dart';
import './../ui/screens/index.dart';
import './../constants/index.dart';
import './faderoute.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    try {
      // final Map<String, dynamic> args = routeSettings.arguments;

      switch (routeSettings.name) {
        case AppUrl.onboardingScreen:
          return MaterialPageRoute(
              settings: routeSettings, builder: (_) => OnboardingScreen());

        case AppUrl.loginPage:
          return FadeRoute(page: OAuth2Login(), routeName: AppUrl.loginPage);

        case AppUrl.profileDashboard || AppUrl.profilePage:
          final ProfileDashboardArgModel? arg = routeSettings.arguments != null
              ? routeSettings.arguments as ProfileDashboardArgModel
              : null;

          final String? userId = arg != null ? arg.userId : null;

          final profileParentAction =
              arg != null ? arg.profileParentAction : null;
          final bool showMyActivity = arg != null ? arg.showMyActivity : false;
          return FadeRoute(
              page: ProfileDashboard(
                  userId: userId,
                  type: arg?.type ?? ProfileConstants.currentUser,
                  profileParentAction: profileParentAction,
                  showMyActivity: showMyActivity),
              routeName: AppUrl.profileDashboard);

        case HomePage.route:
          return MaterialPageRoute(
              settings: routeSettings, builder: (_) => HomePage());

        case AppUrl.discussionHub:
          return FadeRoute(
              page: CommunityHome(), routeName: AppUrl.discussionHub);

        case AppUrl.browseByCompetencyPage:
          return FadeRoute(
              page: BrowseByCompetency(),
              routeName: AppUrl.browseByCompetencyPage);

        case AppUrl.browseByAllProviderPage:
          return FadeRoute(
              page: BrowseByAllProvider(),
              routeName: AppUrl.browseByAllProviderPage);

        case AppUrl.browseByAllChannel:
          final String orgBookmarkId = routeSettings.arguments as String;
          return FadeRoute(
              page: BrowseByAllChannel(orgBookmarkId: orgBookmarkId),
              routeName: AppUrl.browseByAllChannel);
        case AppUrl.moderatedCoursesPage:
          return FadeRoute(
            page: ViewAllCourses(
                courseStripData: ContentStripModel.fromMap(
              {
                "type": "courseStrip",
                "enabled": true,
                "enableTheme": false,
                "backgroundColor": "0xffffffff",
                "telemetryPrimaryCategory": "courses",
                "telemetrySubType": "moderated-program",
                "telemetryIdentifier": "card-content",
                "title": {
                  "hiText": "मॉडरेटेड कोर्स",
                  "enText": "Moderated Courses",
                  "id": "moderatedCourses"
                },
                "toolTipMessage": {
                  "hiText": "30 मिनट के भीतर सीखना",
                  "enText":
                      "Moderated Programs and Moderated Assessments for you",
                  "id": "moderatedProgramTooltip"
                },
                "apiUrl": "/api/composite/v4/search",
                "request": {
                  "request": {
                    "query": "",
                    "filters": {
                      "courseCategory": [
                        "moderated course",
                        "moderated program",
                        "moderated assessment"
                      ],
                      "contentType": ["course"],
                      "status": ["Live"],
                      "identifier": []
                    },
                    "sort_by": {"lastUpdatedOn": "desc"},
                    "facets": ["mimeType"],
                    "limit": 20,
                    "offset": 0
                  }
                }
              },
            )),
          );

        case AppUrl.browseAllKarmaProgramsPage:
          return FadeRoute(
              page: BrowseAllKarmaPrograms(),
              routeName: AppUrl.browseAllKarmaProgramsPage);

        case AppUrl.learningHub:
          return FadeRoute(
            page: LearnHub(),
            routeName: AppUrl.learningHub,
          );

        case AppUrl.networkHub:
          return FadeRoute(
            page: NetworkHubV2(),
            routeName: AppUrl.networkHub,
          );
        case AppUrl.curatedCollectionsPage:
          return FadeRoute(
              page: BrowseByProvider(
                isCollections: true,
              ),
              routeName: AppUrl.browseByTopicPage);

        case AppUrl.eventsHub:
          return FadeRoute(page: EventsHub(), routeName: AppUrl.eventsHub);

        case AppUrl.knowledgeResourcesPage:
          return FadeRoute(page: GyaanKarmayogiV2());

        case AppUrl.competencyPassbookPage:
          return FadeRoute(page: CompetencyPassbookScreen());

        case AppUrl.competencyPassbookThemePage:
          return MaterialPageRoute(
              settings: routeSettings,
              builder: (_) => CompetencyThemeScreen(
                    competencyTheme: CompetencyTheme(),
                  ));

        case AppUrl.competencyPassbookTabbedPage:
          return MaterialPageRoute(
              settings: routeSettings,
              builder: (_) => CompetencyPassbookTabbedScreen(competency: {}));

        case SettingsScreen.route:
          final args = routeSettings.arguments;
          final settingsArgs =
              args is SettingsRequestModel ? args : SettingsRequestModel();
          return FadeRoute(
            page: SettingsScreen(
              notMyUser: settingsArgs.notMyUser,
              popTillFirst: settingsArgs.popTillFirst,
            ),
          );

        case AppUrl.courseTocPage:
          final CourseTocModel arguments =
              routeSettings.arguments as CourseTocModel;

          return FadeRoute(
              page: CourseTocPage(
                arguments: arguments,
              ),
              routeName: AppUrl.courseTocPage);

        case AppUrl.externalCourseTocPage:
          final CourseTocModel arguments =
              routeSettings.arguments as CourseTocModel;
          return FadeRoute(
              page: ExternalCourseTOC(
                contentId: arguments.courseId,
                externalId: arguments.externalId,
                contentType: arguments.contentType,
                tagCommentId: arguments.tagCommentId,
              ),
              routeName: AppUrl.externalCourseTocPage);

        case AppUrl.tocPlayer:
          final TocPlayerModel arguments =
              routeSettings.arguments as TocPlayerModel;
          return FadeRoute(
              page: TocPlayerScreen(arguments: arguments),
              routeName: AppUrl.courseTocPage);

        case AppUrl.karmaProgramDetails:
          final PlayList arguments = routeSettings.arguments as PlayList;
          return FadeRoute(
              page: KarmaProgramDetails(karmaProgram: arguments),
              routeName: AppUrl.karmaProgramDetails);
        case AppUrl.karmaProgramDetailsv2:
          final PlayList arguments = routeSettings.arguments as PlayList;
          return FadeRoute(
              page: KarmaProgramDetailsv2(karmaProgram: arguments),
              routeName: AppUrl.karmaProgramDetailsv2);
        case AppUrl.eventDetails:
          final String eventId = routeSettings.arguments as String;
          return FadeRoute(
              page: EventsDetailsScreenv2(
                eventId: eventId,
              ),
              routeName: AppUrl.eventDetails);
        case AppUrl.recommendedLearning:
          final RecommendedLearningModel arguments =
              routeSettings.arguments as RecommendedLearningModel;
          return FadeRoute(
              page: RecommendedLearningShowallScreen(arguments: arguments),
              routeName: AppUrl.karmaProgramDetailsv2);

        case AppUrl.registrationDetails:
          final RegistrationLinkModel arguments =
              routeSettings.arguments as RegistrationLinkModel;
          return FadeRoute(
            page: SelfRegistrationDetails(arguments: arguments),
            routeName: AppUrl.registrationDetails,
          );
        case AppUrl.registrationQRScanner:
          return FadeRoute(
            page: SelfRegisterQrscannerWidget(),
            routeName: AppUrl.registrationQRScanner,
          );
        case AppUrl.selfRegister:
          return FadeRoute(
            page: SelfRegistration(),
            routeName: AppUrl.selfRegister,
          );
        case AppUrl.signUp:
          return FadeRoute(page: SignUpPage(), routeName: AppUrl.signUp);
        case AppUrl.communityPage:
          final String communityId = routeSettings.arguments as String;
          return FadeRoute(
              page: CommunityDetailView(
                communityId: communityId,
              ),
              routeName: AppUrl.communityPage);
        case AppUrl.exploreContent:
          return FadeRoute(
              page: ExploreContent(), routeName: AppUrl.exploreContent);
        case AppUrl.karmapointOverview:
          return FadeRoute(
            page: KarmaPointOverview(),
            routeName: AppUrl.karmapointOverview,
          );
        default:
          return FadeRoute(page: LandingPage());
      }
    } catch (_) {
      return FadeRoute(page: LandingPage());
    }
  }

  static Route<dynamic> errorRoute(RouteSettings routeSettings) {
    return MaterialPageRoute(
        settings: routeSettings, builder: (_) => ErrorPage());
  }
}
