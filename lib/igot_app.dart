import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/landing_page.dart';
import 'package:karmayogi_mobile/respositories/_respositories/settings_repository.dart';
import 'package:karmayogi_mobile/splash_screen.dart';
import 'package:karmayogi_mobile/util/debug_widget.dart';
import 'package:provider/provider.dart';
import 'constants/_constants/app_constants.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class IGotApp extends StatefulWidget {
  const IGotApp({
    Key? key,
  }) : super(key: key);

  @override
  State<IGotApp> createState() => _IGotAppState();
}

class _IGotAppState extends State<IGotApp> {
  bool get notProdRelease => !modeProdRelease;
  @override
  void initState() {
    Provider.of<SettingsRepository>(context, listen: false).setDefaultFont();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsRepository>(builder: (context, settings, _) {
      final fontScale = settings.fontSize;
      final itsTablet = settings.itsTablet;

      final textScale = MediaQuery.of(context).textScaler.clamp(
            maxScaleFactor: fontScale,
            minScaleFactor: fontScale,
          );
      return ScreenUtilInit(
        designSize: Size(itsTablet ? IPAD_DESIGN_WIDTH : DEFAULT_DESIGN_WIDTH,
            itsTablet ? IPAD_DESIGN_HEIGHT : DEFAULT_DESIGN_HEIGHT * fontScale),
        minTextAdapt: true,
        splitScreenMode: true,
        rebuildFactor: (old, data) => false,
        builder: (_, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (context, widget) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: textScale),
                child: notProdRelease
                    ? DebugWidget(
                        widget: widget!,
                      )
                    : widget!,
              );
            },
            home: const _SplashWidget(),
            routes: <String, WidgetBuilder>{
              AppUrl.landingPage: (BuildContext context) => LandingPage(
                    isFromUpdateScreen: false,
                  ),
            },
          );
        },
      );
    });
  }
}

class _SplashWidget extends StatelessWidget {
  const _SplashWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 1000,
      splashIconSize: double.infinity,
      splashTransition: SplashTransition.fadeTransition,
      splash: const SplashScreen(),
      nextScreen: const LandingPage(),
    );
  }
}
