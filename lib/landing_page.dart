import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_badge/flutter_native_badge.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:karmayogi_mobile/igot_app.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/route_observer.dart';
import 'package:karmayogi_mobile/services/_services/local_notification_service.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/onboarding_screen.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/profile_dashboard.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import 'package:karmayogi_mobile/ui/screens/maintenance_screen/maintenance_screen.dart';
import 'package:karmayogi_mobile/ui/screens/maintenance_screen/maintenance_screen_repository.dart';
import 'package:karmayogi_mobile/ui/theme/theme_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/error_page.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/deeplinks/deeplink_service.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/routes.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_upgrader.dart';
import 'constants/_constants/log_constants.dart';
import 'constants/index.dart';
import 'models/_models/deeplink_model.dart';
import 'respositories/index.dart';
import 'ui/screens/_screens/profile/utils/profile_helper.dart';
import 'ui/skeleton/pages/landing_page_skeleton.dart';
import 'util/app_navigator_observer.dart';

class LandingPage extends StatefulWidget {
  final bool isFromUpdateScreen;
  const LandingPage({Key? key, this.isFromUpdateScreen = false})
      : super(key: key);
  @override
  _LandingPageState createState() => _LandingPageState();
  Future<void> setLocale(BuildContext context, Locale newLocale) async {
    _LandingPageState? state =
        context.findAncestorStateOfType<_LandingPageState>();
    state?.setLocale(newLocale);
  }
}

void setErrorBuilder() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return ErrorPage();
  };
}

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver {
  final _storage = FlutterSecureStorage();

  String? _parichayCode;
  String? _parichayToken;
  String? _token;
  StreamSubscription<Uri>? _linkSubscription;
  Locale? _locale;
  String? orgId;
  ValueNotifier<bool> showLoader = ValueNotifier<bool>(true);
  bool showDeeplinkMesage = false;

  late Future<String?> _validateSessionFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    /// Set up error builder
    setErrorBuilder();

    /// Perform essential initializations
    _getSessionId();
    restoreLocaleSelection();

    ///To get the Unique Identifier of the app
    _initUniqueIdentifierState();

    setSharePreferenceData();

    //checking token to access the app
    _validateSessionFuture = _checkCode();

    /// Schedule other tasks to run after the initial frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleFirebaseLocalNotification();
      if (!widget.isFromUpdateScreen) {
        handleDeepLink();
      }
      _updateNotificationCount();
      // Check for updates after the app has rendered
      AppUpgrader.checkForUpdate(context: context);
    });
  }

  /// Deeplink handling Start
  Future<void> handleDeepLink() async {
    await _initAppLinks();
    _performDeepLinking();
  }

  _performDeepLinking() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final deepLinkData = await _storage.read(key: Storage.deepLinkPayload);
      if (deepLinkData != null) {
        DeepLink deepLink = DeepLink.fromJson(jsonDecode(deepLinkData));
        if (deepLink.url != null && deepLink.url!.isNotEmpty) {
          await setUpDeeplink(navigatorKey.currentState!.overlay!.context,
              AppUrl.registrationDetails);
        }
      }
      showLoader.value = false;
    });
  }

  Future<void> setUpDeeplink(BuildContext context, String deeplinkRoute) async {
    final previousRoute = AppNavigatorObserver.instance.getLastRouteName();

    if (previousRoute != deeplinkRoute) {
      await DeeplinkService().performDeepLinking(context);
    }
  }

  /// Deeplink handling end

  void setSharePreferenceData() {
    _storage.write(key: Storage.enableLearnerTip, value: "true");
    _storage.write(key: Storage.enableHomeSurvey, value: "true");
    _storage.write(key: Storage.enableSurveyPopUp, value: "true");
    _storage.write(key: Storage.showAppUpateStrip, value: "true");
    //Setting the reminder option for profile update nudge to be functional
    _storage.write(key: Storage.showReminder, value: EnglishLang.no);
  }

  restoreLocaleSelection() async {
    _locale = await Helper.getLocale();
  }

  _handleFirebaseLocalNotification() async {
    if (Platform.isIOS) {
      FirebaseNotificationService().foregroundMessage();
    }
    await FirebaseNotificationService().handleMessage();
  }

  Future<void> _initAppLinks() async {
    await DeeplinkService()
        .initAppLink(context: context, linkSubscription: _linkSubscription);
  }

  Future<String?> _checkCode() async {
    try {
      String? token = await _storage.read(key: Storage.authToken);

      if (token == null) return null;

      final Duration remainingTime = JwtDecoder.getRemainingTime(token);
      // Buffer time in hours before token expiration to trigger an update the token
      // This is set to 4 hours, you can adjust it as needed
      final bufferHours = 4;

      if (remainingTime.inHours < bufferHours) {
        bool isTokenUpdated =
            await Provider.of<LoginRespository>(context, listen: false)
                .updateToken();
        if (isTokenUpdated) {
          token = await _storage.read(key: Storage.authToken);
        } else {
          await AppLogger.INSTANCE.logEvent(
            LogConstants.EventTokenUpdateFailed,
            parameters: {
              'token': token,
              'time': DateTime.now().toIso8601String(),
            },
          );
          await Provider.of<LoginRespository>(context, listen: false)
              .doLogout(context);
          return null;
        }
      }
      _token = token;
      return token;
    } catch (e) {
      await Provider.of<LoginRespository>(context, listen: false)
          .doLogout(context);
      return null;
    }
  }

  Future<void> _initUniqueIdentifierState() async {
    String identifier;
    try {
      identifier = await UniqueIdentifier.serial.toString();
    } on PlatformException {
      identifier = 'Failed to get Unique Identifier';
    }

    if (!mounted) return;

    identifier = sha256.convert(utf8.encode(identifier)).toString();
    _storage.write(key: Storage.deviceIdentifier, value: identifier);
  }

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      DeeplinkService().deleteDeeplinkPayload();
    } else if (state == AppLifecycleState.resumed) {
      await _updateNotificationCount();
      AppUpgrader.checkForUpdate(context: context);
    }
  }

  @override
  void dispose() {
    DeeplinkService().deleteDeeplinkPayload();
    _linkSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<Widget> _buildHomeWidget() async {
    if (MaintenanceScreenRepository.serverUnderMaintenance) {
      return const MaintenanceScreen();
    }

    ValueListenableBuilder<bool>(
      valueListenable: showLoader,
      builder: (context, value, child) {
        return value ? const LandingPageSkeletonPage() : child!;
      },
      child: const SizedBox.shrink(),
    );

    final hasValidToken = (_token != null) ||
        (_parichayCode != null && _parichayToken != null && _token != null);

    if (hasValidToken) {
      if (await ProfileHelper().isRestrictedUser()) {
        return ProfileDashboard(type: ProfileConstants.notMyUser);
      } else if (await ProfileHelper.checkCustomProfileFields()) {
        return ProfileDashboard(type: ProfileConstants.customProfileTab);
      }

      return Consumer<AppConfiguration>(
        builder: (context, config, child) {
          if (AppConfiguration.homeConfigData == null ||
              AppConfiguration.homeConfigData!.isEmpty) {
            return const LandingPageSkeletonPage();
          }
          return const CustomTabs(customIndex: 0);
        },
      );
    }

    return ShowCaseWidget(
      builder: (context) => const OnboardingScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ChatbotRepository(),
        child: MaterialApp(
          title: APP_NAME,
          theme: igotlightTheme(),
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          navigatorObservers: [AppNavigatorObserver.instance, routeObserver],
          onGenerateRoute: Routes.generateRoute,
          onUnknownRoute: Routes.errorRoute,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: _locale,
          scaffoldMessengerKey: scaffoldMessengerKey,
          initialRoute: '/',
          onGenerateInitialRoutes: (String initialRouteName) {
            return [MaterialPageRoute(builder: (_) => _buildWidget())];
          },
          routes: <String, WidgetBuilder>{
            '/': (context) => _buildWidget(),
          },
        ));
  }

  Widget _buildWidget() {
    return FutureBuilder(
        future: _validateSessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LandingPageSkeletonPage();
          }
          return FutureBuilder<Widget>(
            future: _buildHomeWidget(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LandingPageSkeletonPage();
              } else if (snapshot.data != null) {
                return snapshot.data!;
              } else {
                return SizedBox();
              }
            },
          );
        });
  }

  void _getSessionId() async {
    var telemetryRepository = TelemetryRepository();
    await telemetryRepository.generateUserSessionId(isAppStarted: true);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _updateNotificationCount() async {
    //This function is specific to iOS only
    if (Platform.isAndroid) return;
    try {
      int badgeCount = await FlutterNativeBadge.getBadgeCount();
      if (Platform.isIOS && badgeCount > 0) {
        await FlutterNativeBadge.clearBadgeCount(requestPermission: true);
      }
    } catch (e) {
      //log('Error $e');
    }
    return;
  }
}
