import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'parent_widget_test_util.dart';

/// Generic helper function to pump a widget with localization and screen utilities
Future<void> pumpWidgetWithLocalization(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ParentWidget.getParentWidget(child),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

/// Generic helper function to pump a widget with localization, screen utilities, and a provider
Future<void> pumpWidgetWithLocalizationAndProvider<T>(WidgetTester tester, Widget child, {
  required T providerValue,
    }) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: false,
        useInheritedMediaQuery: false,
        child: Provider<T>.value(
          value: providerValue,
          child: child,
        ),
      ),
    ),
  );
}