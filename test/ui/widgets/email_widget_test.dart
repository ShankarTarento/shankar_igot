import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../mocks.mocks.dart';
import '../../utils/constants_test_util.dart';
import '../../utils/parent_widget_test_util.dart';

void main() {
  late MockProfileRepository mockProfileRepository;
  setUpAll(() {
    mockProfileRepository = MockProfileRepository();
  });

  group('Validate Email field', () {
    testWidgets('Validating invalid email field', (WidgetTester tester) async {
      testInvalidEmail(mockProfileRepository, tester);
    });

    testWidgets('Validating valid email field', (WidgetTester tester) async {
      testInvalidEmail(mockProfileRepository, tester);
    });
  });
  
}

Future<void> testValidEmail(
    MockProfileRepository mockProfileRepository, WidgetTester tester) async {
  //Arrange
  simulateGenerateAndVerifyEmailOTP(mockProfileRepository);
  //Act
  await setUpTestWidget(tester, mockProfileRepository);

  final BuildContext context = tester.element(find.byType(EmailWidget));
  //Assert
  await assertValidEmailAndTest(tester, context, mockProfileRepository);
}

Future<void> assertValidEmailAndTest(WidgetTester tester, BuildContext context,
    MockProfileRepository mockProfileRepository) async {
  final emailField = find.byKey(Key('Email'));
  final otpButton = find.byKey(Key('Email_OTP'));
  final verifyOtpField = find.byKey(Key('VerifyEmailOTP'));

  expect(emailField, findsOneWidget);

  //Valid email check
  await updateEmail(tester, emailField);
  expect(find.text(AppLocalizations.of(context)!.mRegistervalidEmail),
      findsNothing);
  final otpActiveButtton = tester.widget<ElevatedButton>(otpButton);

  await testEmailOTPSend(
      otpActiveButtton, tester, mockProfileRepository, context);

  await testOTPVerification(verifyOtpField, tester, mockProfileRepository);
}

Future<void> testOTPVerification(Finder verifyOtpField, WidgetTester tester,
    MockProfileRepository mockProfileRepository) async {
  //Check otp verify field visible
  expect(verifyOtpField, findsOneWidget);

  final otpVerifyButton = find.byKey(Key('VerifyOtpButton'));
  await tester.enterText(verifyOtpField, ConstantsTestUtil.otp);
  await tester.pump();

  // Act: Tap the button to trigger `onPressed` of verify OTP button
  await tester.ensureVisible(otpVerifyButton);
  await tester.tap(otpVerifyButton);
  await tester.pumpAndSettle();

  // Assert: Verify the OTP was successfully verified
  verify(mockProfileRepository.verifyEmailOTP(
          ConstantsTestUtil.validMail, ConstantsTestUtil.otp))
      .called(1);
}

Future<void> testEmailOTPSend(
    ElevatedButton otpActiveButtton,
    WidgetTester tester,
    MockProfileRepository mockProfileRepository,
    BuildContext context) async {
  //Check for Active OTP button
  expect(otpActiveButtton.onPressed, isNotNull);

  // Act: Tap the button to trigger `onPressed`
  otpActiveButtton.onPressed!();
  await tester.pumpAndSettle();
  // Assert: Verify the mock otp send method called
  verify(mockProfileRepository.generateEmailOTP(ConstantsTestUtil.validMail))
      .called(1);

  // Verify the state updates or SnackBar is displayed
  expect(find.text(AppLocalizations.of(context)!.mStaticOtpSentToEmail),
      findsOneWidget);
}

Future<void> testInvalidEmail(
    MockProfileRepository mockProfileRepository, WidgetTester tester) async {
  //Arrange
  simulateGenerateAndVerifyEmailOTP(mockProfileRepository);
  //Act
  await setUpTestWidget(tester, mockProfileRepository);

  final BuildContext context = tester.element(find.byType(EmailWidget));

  //Assert
  await testInvalidEmailWithWrongInput(tester, context);
}

Future<void> testInvalidEmailWithWrongInput(
    WidgetTester tester, BuildContext context) async {
  final emailField = find.byKey(Key('Email'));
  final otpButton = find.byKey(Key('Email_OTP'));
  final verifyOtpField = find.byKey(Key('VerifyEmailOTP'));
  final otpButtonDisabed = tester.widget<ElevatedButton>(otpButton);

  expect(emailField, findsOneWidget);
  //Invalid email check
  await emailWithoutDomain(tester, emailField, context);
  await emailWithRandomText(tester, emailField, context);
  //Check for inactive OTP button
  expect(otpButtonDisabed.onPressed, isNull);
  //Check otp verify field not visible
  expect(verifyOtpField, findsNothing);
}

Future<void> emailWithRandomText(
    WidgetTester tester, Finder emailField, BuildContext context) async {
  await tester.enterText(emailField, 'I am john@toe.com');
  await tester.pump();
  expect(find.text(AppLocalizations.of(context)!.mRegistervalidEmail),
      findsOneWidget);
}

Future<void> emailWithoutDomain(
    WidgetTester tester, Finder emailField, BuildContext context) async {
  await tester.enterText(emailField, 'john@toe');
  await tester.pump();
  expect(find.text(AppLocalizations.of(context)!.mRegistervalidEmail),
      findsOneWidget);
}

void simulateGenerateAndVerifyEmailOTP(
    MockProfileRepository mockProfileRepository) {
  when(mockProfileRepository.generateEmailOTP(any)).thenAnswer((_) async => '');

  when(mockProfileRepository.verifyEmailOTP(any, any))
      .thenAnswer((_) async => '');
}

Future<void> updateEmail(WidgetTester tester, Finder emailField) async {
  await tester.enterText(emailField, ConstantsTestUtil.validMail);
  await tester.pump();
}

Future<void> setUpTestWidget(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  await tester.pumpWidget(ParentWidget.getParentWidget(Scaffold(
      body: EmailWidget(
          isFocused: true,
          onSaved: (String? value) {},
          changeFocus: (String value) {},
          emailVerified: (bool value) {},
          name: 'test-name',
          mobileNumber: '1111111111',
          isMobileNumberVerified: false,
          getMobileNumber: () {},
          formKey: GlobalKey<FormState>(),
          profileRepository: mockProfileRepository))));
  await tester.pumpAndSettle();
}
