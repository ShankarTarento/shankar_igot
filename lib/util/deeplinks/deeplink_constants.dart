import 'package:karmayogi_mobile/env/env.dart';

class DeeplinkConstants {
  static String baseUrl = Env.portalBaseUrl;

  static final String homePage = baseUrl + '/app/home-page';

  /// profile deeplinks
  static final String networkProfile = baseUrl + '/app/person-profile/';
  static final String profileDashboard = baseUrl + '/app/profile-dashboard';
  static final String profileMyActivities =
      baseUrl + '/app/profile-dashboard/my-activities';

  /// learn hub deeplinks

  static final String learnHubHome = baseUrl + '/app/learn-hub/home';
  static final String courseToc = baseUrl + '/app/learn-hub/toc/';
  static final String externalCourseToc = baseUrl + '/app/learn-hub/toc/ext/';

  // network hub deeplinks
  static final String eventHubHome = baseUrl + '/app/event-hub/home';
  static final String eventToc = baseUrl + '/app/event-hub/toc/';

  /// discussion hub deeplinks
  static final String discussionHubPage = baseUrl + '/app/discussion-forum-v2';
  static final String discussionAllCommunities =
      baseUrl + '/app/discussion-forum-v2/all-communities';
  static final String discussionMyCommunities =
      baseUrl + '/app/discussion-forum-v2/my-communities';
  static final String communityPage =
      baseUrl + '/app/discussion-forum-v2/community/';

  /// mdo channels deeplinks
  static final String allMdoChannels =
      baseUrl + '/app/learn/mdo-channels/all-channels';
  static final String mdoChannelPage = baseUrl + '/app/learn/mdo-channels/';

  /// provider microsite deeplinks
  static final String allProvidersMicrosite =
      baseUrl + '/app/learn/browse-by/provider/all-providers';
  static final String providerMicrosite =
      baseUrl + '/app/learn/browse-by/provider/';

  /// other deeplinks
  static final String surveyPage = baseUrl + "/surveyml/";
  static final String mentorship = baseUrl + "/mentorship";
  static final String customSelfRegistration = baseUrl + "/crp/";
  static final String loginAction =
      baseUrl + "/auth/realms/sunbird/login-actions/action-token";
}
