import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

import '../../mocks.mocks.dart';
import '../../utils/parent_widget_test_util.dart';

void main() {
  group('phone number not verified testing', () {
    late MockProfileRepository mockProfileRepository;
    setUpAll(() {
      mockProfileRepository = MockProfileRepository();
      // ProfileService() = mockProfileService;
      when(mockProfileRepository.generateMobileNumberOTP(any))
          .thenAnswer((_) async => '');
      when(mockProfileRepository.verifyMobileNumberOTP(any, any))
          .thenAnswer((_) async => '');
    });

    testWidgets(
        'Verify enter mobile number, send otp, and validate successfully',
        (WidgetTester tester) async {
      await tester.pumpWidget(ParentWidget.getParentWidget(Scaffold(
        body: PhoneNumberWidget(
          formKey: GlobalKey<FormState>(),
          mobileVerified: (bool value) {},
          isFocused: true,
          isMobileVerified: false,
          changeFocus: (String value) {},
          profileRepository: mockProfileRepository,
        ),
      )));
      await tester.pumpAndSettle();

      final BuildContext context =
          tester.element(find.byType(PhoneNumberWidget));
      final PhoneNumberWidgetState state =
          tester.state(find.byType(PhoneNumberWidget));
      await tester.pumpAndSettle();

      final mobileField = find.byKey(Key('Mobile'));
      final otpSendButton = find.byKey(Key('sendMobileOTP'));
      expect(mobileField, findsOneWidget);
      // Check invalid mobile number validation
      await tester.enterText(mobileField, '9999526');
      await tester.pump();
      final disabledOTPSendButton =
          await tester.widget<ElevatedButton>(otpSendButton);

      expect(
          find.text(AppLocalizations.of(context)!.mStaticPleaseAddValidNumber),
          findsOneWidget);
      expect(disabledOTPSendButton.onPressed, isNull);

      // Check invalid mobile number validation

      await tester.enterText(mobileField, '9999526123');
      await tester.pump();

      expect(
          find.text(AppLocalizations.of(context)!.mStaticPleaseAddValidNumber),
          findsNothing);

      final enabledOTPSendButton =
          await tester.widget<ElevatedButton>(otpSendButton);
      expect(enabledOTPSendButton.onPressed, isNotNull);
      final otpSendEnabledButton = find.byKey(Key('sendMobileOTP'));
      await tester.ensureVisible(otpSendEnabledButton);
      await tester.tap(otpSendEnabledButton);
      // enabledOTPSendButton.onPressed!();
      await tester.pumpAndSettle();
      verify(mockProfileRepository.generateMobileNumberOTP('9999526123'))
          .called(1);

      expect(find.text(AppLocalizations.of(context)!.mStaticOtpSentToMobile),
          findsOneWidget);
      expect(state.freezeMobileField, isTrue);
      final verifyOTPButton = find.byKey(Key('VerifyMobileOTP'));
      await tester.ensureVisible(verifyOTPButton);
      final otpField = find.byKey(Key('PhoneOTPField'));
      expect(otpField, findsOneWidget);
      await tester.enterText(otpField, '111111');
      await tester.tap(verifyOTPButton);
      await tester.pumpAndSettle();
      verify(mockProfileRepository.verifyMobileNumberOTP(
              '9999526123', '111111'))
          .called(1);
      verifyNever(
          mockProfileRepository.verifyMobileNumberOTP('9999526123', '222222'));
    });

    testWidgets('Edit phoneNumber before verification',
        (WidgetTester tester) async {
      await tester.pumpWidget(ParentWidget.getParentWidget(Scaffold(
        body: PhoneNumberWidget(
          formKey: GlobalKey<FormState>(),
          mobileVerified: (bool value) {},
          isFocused: true,
          isMobileVerified: false,
          changeFocus: (String value) {},
          profileRepository: mockProfileRepository,
        ),
      )));
      await tester.pumpAndSettle();
      final PhoneNumberWidgetState state =
          tester.state(find.byType(PhoneNumberWidget));
      await tester.pumpAndSettle();

      final mobileField = find.byKey(Key('Mobile'));
      final otpSendButton = find.byKey(Key('sendMobileOTP'));
      expect(mobileField, findsOneWidget);

      await tester.enterText(mobileField, '9999526123');
      await tester.pump();

      final enabledOTPSendButton =
          await tester.widget<ElevatedButton>(otpSendButton);
      expect(enabledOTPSendButton.onPressed, isNotNull);
      final otpSendEnabledButton = find.byKey(Key('sendMobileOTP'));
      await tester.ensureVisible(otpSendEnabledButton);
      await tester.tap(otpSendEnabledButton);
      // enabledOTPSendButton.onPressed!();
      await tester.pumpAndSettle();
      expect(state.freezeMobileField, isTrue);
      //Verify edit
      final editBtn = find.byKey(Key('EditButton'));
      await tester.ensureVisible(editBtn);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();
      expect(state.freezeMobileField, isFalse);
      expect(state.otpFocus.hasFocus, isFalse);
    });
  });

  group('phone number already verified testing', () {
    final testMobileNumber = '9999101010';
    Widget createInitalWidgetUnderTest() {
      return ScreenUtilInit(
        designSize: Size(DEFAULT_DESIGN_WIDTH, DEFAULT_DESIGN_HEIGHT),
        child: MaterialApp(
          home: Scaffold(
            body: PhoneNumberWidget(
              formKey: GlobalKey<FormState>(),
              mobileVerified: (bool value) {},
              isFocused: true,
              // profileRepository: mockProfileRepository,
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      );
    }

    Widget createUpdatedWidgetUnderTest() {
      return ScreenUtilInit(
        designSize: Size(DEFAULT_DESIGN_WIDTH, DEFAULT_DESIGN_HEIGHT),
        child: MaterialApp(
          home: Scaffold(
            body: PhoneNumberWidget(
              formKey: GlobalKey<FormState>(),
              mobileVerified: (bool value) {},
              isFocused: false,
              isMobileVerified: true,
              mobileNumber: testMobileNumber,
              // profileRepository: mockProfileRepository,
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
        ),
      );
    }

    testWidgets(
        'Verify already verified mobile number reflecting in fields and able to change number',
        (WidgetTester tester) async {
      await tester.pumpWidget(createInitalWidgetUnderTest());
      await tester.pumpAndSettle();
      //Update Widget

      await tester.pumpWidget(createUpdatedWidgetUnderTest());
      await tester.pumpAndSettle();

      // Get the TextEditingController from the widget
      final PhoneNumberWidgetState state =
          tester.state(find.byType(PhoneNumberWidget));
      await tester.pumpAndSettle();

      // Verify the value in the TextEditingController matches the test value
      expect(state.mobileNoController.text, equals(testMobileNumber));
      final changeNumberButton = find.byKey(Key('ChangeNumber'));
      expect(changeNumberButton, findsOneWidget);
      expect(state.isMobileNumberVerified, isTrue);
      // Initially, the focus should be on the mobileNumberFocus
      expect(state.mobileNumberFocus.hasFocus, isFalse);
      await tester.tap(changeNumberButton);
      await tester.pumpAndSettle();
      expect(state.isMobileNumberVerified, isFalse);
      // Now the focus should be on the mobileNumberFocus
      expect(state.mobileNumberFocus.hasFocus, isTrue);
    });
  });
}
