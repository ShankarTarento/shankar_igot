import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/util/routes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../mocks.mocks.dart';
import '../routes/navigation_observer.dart';

class ParentWidget {
  late MockProfileRepository mockProfileRepository;
  late MockLearnRepository mockLearnRepository;

  static void initializeProvider() {}

  static Widget getParentWidget(Widget childWidget,
      {MockNavigatorObserver? observer}) {
    final mockObserver = observer ?? MockNavigatorObserver();
    initializeProvider();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileRepository>.value(
            value: MockProfileRepository()),
        ChangeNotifierProvider<LearnRepository>.value(
            value: MockLearnRepository())
      ],
      child: ScreenUtilInit(
        designSize: Size(DEFAULT_DESIGN_WIDTH, DEFAULT_DESIGN_HEIGHT),
        child: MaterialApp(
          home: childWidget,
          navigatorObservers: [mockObserver],
          onGenerateRoute: Routes.generateRoute,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      ),
    );
  }
}
