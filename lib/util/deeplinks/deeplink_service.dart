import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/all_channel/browse_by_all_channel.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/mdo_channel_screen.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/screen/all_provider_screen/browse_by_all_provider.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/screen/microsite_screen/ati_cti_microsites_screen.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/network/network_profile.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_home.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/deeplinks/deeplink_constants.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/in_app_webview_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/index.dart';
import '../../localization/index.dart';
import '../../models/_arguments/course_toc_model.dart';
import '../../models/_models/deeplink_model.dart';
import '../../models/index.dart';
import '../../ui/screens/_screens/profile/ui/pages/profile_dashboard.dart';
import '../../update_password.dart';

class DeeplinkService {
  final _storage = FlutterSecureStorage();

  Future<void> initAppLink(
      {required BuildContext context,
      StreamSubscription<Uri>? linkSubscription}) async {
    AppLinks _appLinks = AppLinks();

    /// Check initial link if app was in cold state (terminated)
    final appLink = await _appLinks.getLatestLink();

    if (appLink != null) {
      await processDeeplink(
          context: context, url: appLink.toString(), isColdState: true);
    }

    /// Handle link when app is in warm state (front or background)
    linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      await processDeeplink(
          context: context, url: uri.toString(), isColdState: false);
    });
  }

  Future<void> processDeeplink(
      {BuildContext? context,
      required String url,
      required bool isColdState,
      bool enableLaunch = false}) async {
    String? deepLinkUrl;
    String? category;
    String? token = await _storage.read(key: Storage.authToken);
    if (url.startsWith(DeeplinkConstants.loginAction)) {
      if (context == null) return;
      await _handleLoginAction(context, url);
      return;
    }
    // Survey deeplink handling
    if (url.startsWith(DeeplinkConstants.surveyPage)) {
      if (isColdState) {
        deepLinkUrl = url;
        category = AppUrl.survey;
      } else if (token != null && !JwtDecoder.isExpired(token)) {
        if (context == null) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => InAppWebViewPage(
            url: url,
            parentContext: context,
            isSurvey: true,
          ),
        ));
        return;
      }
    } else if (url.startsWith(DeeplinkConstants.homePage)) {
      deepLinkUrl = url;
      category = AppUrl.homePage;
    }

    ///
    /// profile deeplinks

    else if (url.startsWith(DeeplinkConstants.profileMyActivities)) {
      deepLinkUrl = url;
      category = AppUrl.profileMyActivity;
    } else if (url.startsWith(DeeplinkConstants.networkProfile)) {
      deepLinkUrl = url;
      category = AppUrl.networkProfilePage;
    } else if (url.startsWith(DeeplinkConstants.profileDashboard)) {
      deepLinkUrl = url;
      category = AppUrl.profileDashboard;
    }

    ///
    /// learn hub deeplinks

    else if (url.startsWith(DeeplinkConstants.learnHubHome)) {
      deepLinkUrl = url;
      category = AppUrl.learningHub;
    } else if (url.startsWith(DeeplinkConstants.courseToc)) {
      deepLinkUrl = url;
      category = url.startsWith(DeeplinkConstants.externalCourseToc)
          ? AppUrl.externalCourseTocPage
          : AppUrl.courseTocPage;
    }

    ///
    /// event hub deeplinks

    else if (url.startsWith(DeeplinkConstants.eventHubHome)) {
      deepLinkUrl = url;
      category = AppUrl.eventsHub;
    } else if (url.startsWith(DeeplinkConstants.eventToc)) {
      deepLinkUrl = url;
      category = AppUrl.eventDetails;
    }

    ///
    ///discussion hub deeplinks
    else if (url.startsWith(DeeplinkConstants.discussionAllCommunities)) {
      deepLinkUrl = url;
      category = AppUrl.discussionAllCommunities;
    } else if (url.startsWith(DeeplinkConstants.discussionMyCommunities)) {
      deepLinkUrl = url;
      category = AppUrl.discussionMyCommunities;
    } else if (url.startsWith(DeeplinkConstants.communityPage)) {
      deepLinkUrl = url;
      category = AppUrl.communityPage;
    } else if (url.startsWith(DeeplinkConstants.discussionHubPage)) {
      deepLinkUrl = url;
      category = AppUrl.discussionHub;
    }

    ///
    ///mdo channels deeplinks
    else if (url.startsWith(DeeplinkConstants.allMdoChannels)) {
      deepLinkUrl = url;
      category = AppUrl.allMdoChannelScreen;
    } else if (url.startsWith(DeeplinkConstants.mdoChannelPage)) {
      deepLinkUrl = url;
      category = AppUrl.mdoChannelScreen;
    }

    ///
    ///provider microsite deeplinks

    else if (url.startsWith(DeeplinkConstants.allProvidersMicrosite)) {
      deepLinkUrl = url;
      category = AppUrl.browseByAllProviderPage;
    } else if (url.startsWith(DeeplinkConstants.providerMicrosite)) {
      deepLinkUrl = url;
      category = AppUrl.viewProvider;
    }

    ///
    ///other deeplinks
    else if (url.startsWith(DeeplinkConstants.mentorship)) {
      deepLinkUrl = url;
      category = AppUrl.mentorProfile;
    } else if (url.startsWith(DeeplinkConstants.customSelfRegistration)) {
      deepLinkUrl = url;
      category = AppUrl.customSelfRegistration;
    } else {
      if (enableLaunch) {
        await launchUrl(Uri.parse(url));
      }
      return;
    }

    ///Store deeplink payload for further processing
    if (deepLinkUrl != null && category != null) {
      DeepLink deepLinkPayload = DeepLink(url: deepLinkUrl, category: category);
      await _storage.write(
          key: Storage.deepLinkPayload,
          value: jsonEncode(DeepLink.toJson(deepLinkPayload)));
    }
  }

  Future<void> performDeepLinking(BuildContext context) async {
    final deepLinkData = await _storage.read(key: Storage.deepLinkPayload);
    bool isProtectedUser = await isLoginProtected();
    if (deepLinkData != null) {
      DeepLink deepLink = DeepLink.fromJson(jsonDecode(deepLinkData));

      if (deepLink.url != null && deepLink.url!.isNotEmpty) {
        switch (deepLink.category) {
          case AppUrl.survey:
            handleSurveyDeeplink(isProtectedUser, context, deepLink);
            break;

          case AppUrl.homePage:
            handleHomeDeeplink(isProtectedUser, context, deepLink);
            break;

          case AppUrl.profileDashboard:
            await handleMyProfileDeeplink(isProtectedUser, context, deepLink);
            break;
          case AppUrl.networkProfilePage:
            await handleNetworkProfileDeeplink(
                isProtectedUser, context, deepLink);
            break;
          case AppUrl.profileMyActivity:
            await handleMyProfileMyActivityDeeplink(
                isProtectedUser, context, deepLink);
            break;

          case AppUrl.learningHub:
            handleLearnHubDeeplink(isProtectedUser, deepLink, context);
            break;
          case AppUrl.courseTocPage:
            handleTocDeeplink(isProtectedUser, deepLink, context);
            break;
          case AppUrl.externalCourseTocPage:
            handleExternalTocDeeplink(isProtectedUser, deepLink, context);
            break;

          case AppUrl.eventDetails || AppUrl.eventsHub:
            handleEventDeeplink(isProtectedUser, deepLink, context);
            break;

          case AppUrl.communityPage:
            await handleCommunityDeeplink(isProtectedUser, deepLink, context);
            break;
          case AppUrl.discussionHub:
            await handleDiscussHubDeeplink(
                isProtectedUser, deepLink, context, 0);
            break;
          case AppUrl.discussionAllCommunities:
            await handleDiscussHubDeeplink(
                isProtectedUser, deepLink, context, 1);

            break;
          case AppUrl.discussionMyCommunities:
            await handleDiscussHubDeeplink(
                isProtectedUser, deepLink, context, 2);

            break;

          case AppUrl.allMdoChannelScreen || AppUrl.mdoChannelScreen:
            await handleMdoChannelDeeplink(isProtectedUser, context, deepLink);

            break;

          case AppUrl.browseByAllProviderPage || AppUrl.viewProvider:
            handleProvidersDeeplink(isProtectedUser, context, deepLink);
            break;

          case AppUrl.customSelfRegistration:
            await handleCustomSelfRegistrationDeeplink(
                isProtectedUser, context, deepLink);
            break;

          case AppUrl.mentorProfile:
            handleMentorProfileDeeplink(isProtectedUser, context, deepLink);
            break;
          default:
            handleHomeDeeplink(isProtectedUser, context, deepLink);
        }
      }
    }
  }

  void handleHomeDeeplink(
      bool isProtectedUser, BuildContext context, DeepLink deepLink) {
    if (isProtectedUser) {
      Navigator.push(context, FadeRoute(page: CustomTabs()));
      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  Future<void> handleMdoChannelDeeplink(
      bool isProtectedUser, BuildContext context, DeepLink deepLink) async {
    if (isProtectedUser) {
      String? mdoId = Helper.getMdoId(deepLink.url!);
      String? mdoName = Helper.getMdoName(deepLink.url!);

      if (mdoId != "" && mdoName != "") {
        Navigator.of(context).push(FadeRoute(
            page: MdoChannelScreen(
          channelName: mdoName,
          orgId: mdoId,
        )));
      } else {
        Map<String, dynamic>? data = AppConfiguration.homeConfigData;
        String? orgBookmarkId = Helper.getid(data?['mdoChannelMobile']);
        Navigator.push(
          context,
          FadeRoute(page: BrowseByAllChannel(orgBookmarkId: orgBookmarkId)),
        );
      }
      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  Future<void> handleProvidersDeeplink(
      bool isProtectedUser, BuildContext context, DeepLink deepLink) async {
    if (isProtectedUser) {
      String? providerId = Helper.getProviderId(deepLink.url!);
      String? providerName = Helper.getProviderName(deepLink.url!);

      if (providerId != "" && providerName != "") {
        Navigator.push(
          context,
          FadeRoute(
              page: AtiCtiMicroSitesScreen(
            providerName: providerName,
            orgId: providerId,
          )),
        );
      } else {
        Navigator.push(
          context,
          FadeRoute(page: BrowseByAllProvider()),
        );
      }
      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  Future<void> handleMyProfileDeeplink(
      bool isProtectedUser, BuildContext context, DeepLink deepLink) async {
    if (isProtectedUser) {
      String profileType;
      try {
        if (await ProfileHelper().isRestrictedUser()) {
          profileType = ProfileConstants.notMyUser;
        } else if (await ProfileHelper.checkCustomProfileFields()) {
          profileType = ProfileConstants.customProfileTab;
        } else {
          profileType = ProfileConstants.currentUser;
        }
      } catch (_) {
        profileType = ProfileConstants.currentUser;
      }
      Navigator.of(context).push(FadeRoute(
          page: ProfileDashboard(
        type: profileType,
      )));
      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  Future<void> handleMyProfileMyActivityDeeplink(
      bool isProtectedUser, BuildContext context, DeepLink deepLink) async {
    if (isProtectedUser) {
      String profileType;
      try {
        if (await ProfileHelper().isRestrictedUser()) {
          profileType = ProfileConstants.notMyUser;
        } else if (await ProfileHelper.checkCustomProfileFields()) {
          profileType = ProfileConstants.customProfileTab;
        } else {
          profileType = ProfileConstants.currentUser;
        }
      } catch (_) {
        profileType = ProfileConstants.currentUser;
      }
      Navigator.of(context).push(FadeRoute(
          page: ProfileDashboard(
        type: profileType,
        showMyActivity: true,
      )));
      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  Future<void> handleNetworkProfileDeeplink(
      bool isProtectedUser, BuildContext context, DeepLink deepLink) async {
    if (isProtectedUser) {
      String? userId = await Helper.getUserId(deepLink.url!);
      if (userId != "") {
        Navigator.of(context).push(FadeRoute(
            page: NetworkProfile(
          profileId: userId,
          connectionStatus: UserConnectionStatus.Connect,
        )));
      } else {
        Navigator.push(
          context,
          FadeRoute(page: NetworkHubV2()),
        );
      }
      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  Future<void> handleCustomSelfRegistrationDeeplink(
      bool isProtectedUser, BuildContext context, DeepLink deepLink) async {
    if (isProtectedUser) {
      Helper.showToastMessage(context,
          message: AppLocalizations.of(context)!.mRegisterAlreadyLoggedIn);
    } else {
      String? orgId = Helper.extractOrgIdFromString(deepLink.url!);
      String linkValidationMessage =
          await ProfileRepository().getRegisterLinkValidated(deepLink.url!);

      if (linkValidationMessage.toLowerCase() ==
          EnglishLang.linkActiveMessage.toLowerCase()) {
        Navigator.pushNamed(context, AppUrl.registrationDetails,
            arguments: RegistrationLinkModel(orgId: orgId, link: deepLink.url));
      } else {
        Helper.verifyLinkAndShowMessage(linkValidationMessage, context);
      }
    }
    deleteDeeplinkPayload();
  }

  void handleEventDeeplink(
      bool isProtectedUser, DeepLink deepLink, BuildContext context) {
    if (isProtectedUser) {
      String? eventId = Helper.extractDoIdFromString(deepLink.url!);
      if (eventId != null) {
        Navigator.of(context)
            .push(FadeRoute(page: EventsDetailsScreenv2(eventId: eventId)));
      } else {
        Navigator.pushNamed(context, AppUrl.eventsHub);
      }

      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  void handleMentorProfileDeeplink(
      bool isProtectedUser, BuildContext context, DeepLink deepLink) {
    if (isProtectedUser) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => InAppWebViewPage(
          url: deepLink.url.toString(),
          parentContext: context,
        ),
      ));
      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  void handleLearnHubDeeplink(
      bool isProtectedUser, DeepLink deepLink, BuildContext context) {
    if (isProtectedUser) {
      Navigator.pushNamed(context, AppUrl.learningHub);
      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  void handleTocDeeplink(
      bool isProtectedUser, DeepLink deepLink, BuildContext context) {
    if (isProtectedUser) {
      String? courseId = Helper.extractDoIdFromString(deepLink.url!);
      if (courseId != null) {
        Navigator.pushNamed(
          context,
          AppUrl.courseTocPage,
          arguments: CourseTocModel(courseId: courseId),
        );
      } else {
        Navigator.pushNamed(context, AppUrl.learningHub);
      }
      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  void handleSurveyDeeplink(
      bool isProtectedUser, BuildContext context, DeepLink deepLink) {
    if (isProtectedUser) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => InAppWebViewPage(
          url: deepLink.url.toString(),
          isSurvey: true,
          parentContext: context,
        ),
      ));
    } else {
      routeToLogin(context);
    }
  }

  void routeToLogin(BuildContext context) {
    Navigator.of(context).pushNamed(AppUrl.loginPage);
  }

  Future<void> deleteDeeplinkPayload() async {
    await _storage.delete(key: Storage.deepLinkPayload);
  }

  Future<bool> isLoginProtected() async {
    String? code = await _storage.read(key: Storage.code);
    String? parichayCode = await _storage.read(key: Storage.parichayCode);
    String? parichayToken = await _storage.read(key: Storage.parichayAuthToken);
    String? token = await _storage.read(key: Storage.authToken);
    return ((code != null && token != null) ||
        (parichayCode != null && (parichayToken != null && token != null)));
  }

  Future<void> handleCommunityDeeplink(
      bool isProtectedUser, DeepLink deepLink, BuildContext context) async {
    if (isProtectedUser) {
      String? communityId =
          DiscussionHelper.extractCommunityIdFromString(deepLink.url ?? '');
      if (communityId != null) {
        Navigator.pushNamed(
          context,
          AppUrl.communityPage,
          arguments: communityId,
        );
      } else {
        Navigator.pushNamed(context, AppUrl.discussionHub);
      }
      await deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  Future<void> handleDiscussHubDeeplink(bool isProtectedUser, DeepLink deepLink,
      BuildContext context, int index) async {
    if (isProtectedUser) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityHome(
              defaultTabIndex: index,
            ),
          ));
      await deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  void handleExternalTocDeeplink(
      bool isProtectedUser, DeepLink deepLink, BuildContext context) {
    if (isProtectedUser) {
      String? courseId =
          Helper.extractExternalCourseDoIdFromString(deepLink.url!);
      if (courseId != null) {
        Future.delayed(Duration.zero, () {
          Navigator.pushNamed(
            context,
            AppUrl.externalCourseTocPage,
            arguments: CourseTocModel(
                courseId: courseId,
                contentType: PrimaryCategory.externalCourse),
          );
        });
      } else {
        Navigator.pushNamed(context, AppUrl.learningHub);
      }
      deleteDeeplinkPayload();
    } else {
      routeToLogin(context);
    }
  }

  Future<void> _handleLoginAction(BuildContext context, String url) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => UpdatePassword(
          initialUrl: url,
        ),
      ),
    );
  }
}
