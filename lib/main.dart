import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/respositories/index.dart';

import 'package:karmayogi_mobile/services/_services/local_notification_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/my_events/repository/my_events_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karmayogi_services.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/repository/public_profile_dashboard_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/repository/transcript_repository.dart';

import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/settings_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/comment_section/repositories/comment_repository.dart';

import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/deeplinks/smt_deeplink_service.dart';
import 'package:provider/provider.dart';
import 'package:smartech_base/smartech_base.dart';
import 'firebase_options.dart';
import 'igot_app.dart';
import 'respositories/_respositories/tab_state_repository.dart';
import 'ui/pages/_pages/toc/view_model/course_toc_view_model.dart';
import 'ui/widgets/_learn/cbp/cbp_filters.dart';
import 'ui/widgets/_learn/competency/competency_filter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  // uncomment to Initialize Hive and open a box
  // final dir = await getApplicationDocumentsDirectory();
  // await HiveService.init(
  //     hiveBoxPath: dir.path, boxName: HiveConstants.hiveBoxName);

  await initFirebase();
  reportAppLaunch();
  reportAppCrashAnalytics();
  await initFirebaseNotificationService();
  initConfig();
  await netcoreDeeplink();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: MyEventsRepository()),
    ChangeNotifierProvider.value(value: LoginRespository()),
    ChangeNotifierProvider.value(value: DiscussRepository()),
    ChangeNotifierProvider.value(value: CategoryRepository()),
    ChangeNotifierProvider.value(value: NetworkRespository()),
    ChangeNotifierProvider.value(value: LearnRepository()),
    ChangeNotifierProvider.value(value: CompetencyRepository()),
    ChangeNotifierProvider.value(value: ProfileRepository()),
    ChangeNotifierProvider.value(value: EventRepository()),
    ChangeNotifierProvider.value(value: ChatbotRepository()),
    ChangeNotifierProvider.value(value: NpsRepository()),
    ChangeNotifierProvider.value(value: LandingPageRepository()),
    ChangeNotifierProvider.value(value: InAppReviewRespository()),
    ChangeNotifierProvider.value(value: CommentRepository()),
    ChangeNotifierProvider.value(value: SettingsRepository()),
    ChangeNotifierProvider.value(value: TocServices()),
    ChangeNotifierProvider.value(value: GyaanKarmayogiServicesV2()),
    ChangeNotifierProvider.value(value: CBPFilter()),
    ChangeNotifierProvider.value(value: CompetencyFilter()),
    ChangeNotifierProvider.value(value: DiscussionRepository()),
    ChangeNotifierProvider.value(value: AppConfiguration()),
    ChangeNotifierProvider.value(value: TabStateRepository()),
    ChangeNotifierProvider.value(value: PublicProfileDashboardRepository()),
    ChangeNotifierProvider.value(value: TranscriptRepository()),
    ChangeNotifierProvider.value(value: CourseTocViewModel()),
  ], child: const IGotApp()));
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
      name: 'IGOT', options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> initFirebaseNotificationService() async {
  final _storage = FlutterSecureStorage();
  Future.microtask(() async {
    await _storage.write(key: Storage.restrictAppUpgradePopup, value: "true");
    try {
      await FirebaseNotificationService().initialize();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await FirebaseNotificationService.getDeviceTokenToSendNotification();
    } catch (e) {
    } finally {
      await _storage.write(
          key: Storage.restrictAppUpgradePopup, value: "false");
    }
  });
  return;
}

Future<void> initConfig() async {
  try {
    await AppConfiguration().getCompetencyConfig();
  } catch (e) {
    debugPrint(e.toString());
  }
  await AppConfiguration().getHomeConfig(reload: true);
}

void reportAppCrashAnalytics() {
  //To report only production app crashlytics in firebase
  if (modeProdRelease) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
}

void reportAppLaunch() {
  //To report only production app analytics in firebase
  if (modeProdRelease) {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    FirebaseAnalyticsObserver(analytics: analytics);
    analytics.logAppOpen();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await initFirebase();
  return;
}

Future<void> _initAppLinks(
    {required String smtDeeplinkSource,
    required String deeplink,
    Map<dynamic, dynamic>? smtPayload,
    Map<dynamic, dynamic>? smtCustomPayload}) async {
  await SMTDeeplinkService.instance.initSMTAppLink(
      smtDeeplinkSource: smtDeeplinkSource,
      deeplink: deeplink,
      smtPayload: smtPayload,
      smtCustomPayload: smtCustomPayload);
}

Future<void> netcoreDeeplink() async {
  if (modeProdRelease) {
    Smartech().onHandleDeeplink((String? smtDeeplinkSource,
        String? smtDeeplink,
        Map<dynamic, dynamic>? smtPayload,
        Map<dynamic, dynamic>? smtCustomPayload) async {
      _initAppLinks(
          smtDeeplinkSource: smtDeeplinkSource ?? BroadCastEvent.Default,
          deeplink: smtDeeplink ?? '',
          smtPayload: smtPayload,
          smtCustomPayload: smtCustomPayload);
    });
  }
}
