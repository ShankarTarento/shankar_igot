import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/screens/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/parent_widget_test_util.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  testWidgets('SelfRegistration widget test', (WidgetTester tester) async {
    await tester.pumpWidget(ParentWidget.getParentWidget(SelfRegistration()));

    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(SelfRegistration));

    // Verify that the title is displayed
    expect(find.text(AppLocalizations.of(context)!.mRegisterWithQRorLink),
        findsOneWidget);

    // Verify that the link text field is present
    expect(find.byType(TextFormField), findsOneWidget);

    // Verify that the register button is initially disabled
    testRegisterButtonDisabled(tester);

    // Enter an invalid link and verify validation message
    await tester.enterText(find.byType(TextFormField), 'invalid_link');
    await tester.pump();
    // Verify that the register button is now enabled
    final enabledRegisterButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).first,
    );
    await testIncorrectLinkMessage(enabledRegisterButton, tester, context);

    // Enter a valid link and verify that the button is enabled
    await testValidLink(tester, enabledRegisterButton);
  });
}

Future<void> testValidLink(WidgetTester tester, ElevatedButton enabledRegisterButton) async {
  await tester.enterText(
      find.byType(TextFormField), ApiUrl.baseUrl + '/crp/123456789');
  await tester.pump(); // Rebuild the widget after the state has changed
  
  expect(enabledRegisterButton.onPressed, isNotNull);
}

Future<void> testIncorrectLinkMessage(ElevatedButton enabledRegisterButton, WidgetTester tester, BuildContext context) async {
  expect(enabledRegisterButton.onPressed, isNotNull);
  
  await tester.tap(find.byType(ElevatedButton).first);
  await tester.pump(); // Rebuild the widget after the state has changed
  
  expect(find.text(AppLocalizations.of(context)!.mRegisterIcorrectLinkFormat),
      findsOneWidget);
}

void testRegisterButtonDisabled(WidgetTester tester) {
  final registerButton = tester.widget<ElevatedButton>(
    find.byType(ElevatedButton).first,
  );
  expect(registerButton.onPressed, isNull);
}
