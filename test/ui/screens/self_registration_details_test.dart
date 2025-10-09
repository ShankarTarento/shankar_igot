import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/_models/register_organisation_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/ui/screens/index.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../mocks.mocks.dart';
import '../../utils/constants_test_util.dart';
import '../../utils/parent_widget_test_util.dart';

void sqfliteTestInit() {
  // Initialize ffi implementation
  sqfliteFfiInit();
  // Set global factory
  databaseFactory = databaseFactoryFfi;
}

void main() {
  // Initialize ffi implementation
  sqfliteFfiInit();
  // Set global factory, do not use isolate here
  databaseFactory = databaseFactoryFfiNoIsolate;
  late MockProfileRepository mockProfileRepository;
  setUp(() {
    mockProfileRepository = MockProfileRepository();
  });

  // Common mock setup
  void setupMockProfileRepository() {
    when(mockProfileRepository.getOrgFrameworkId(orgId: anyNamed(ConstantsTestUtil.orgId)))
        .thenAnswer(
      (_) async =>
          RegistrationLinkModel(orgId: 'test-org-id', orgName: 'Test Org'),
    );
    when(mockProfileRepository.getOrgBasedDesignations('test-org-id'))
        .thenAnswer(
      (_) async => ['Dean', 'Manager'],
    );
    when(mockProfileRepository.getOrganizationData('test-org-id')).thenAnswer(
      (_) async => OrganisationModel(),
    );
  }

  group(
      'Self registration details all fields empty and check sign up button is disabled',
      () {
    setUp(() {
      setupMockProfileRepository();
    });
    testWidgets('should fetch org data and display orgname on top',
        (WidgetTester tester) async {
      await testDiaplayOrgname(tester, mockProfileRepository);
    });

    testWidgets('Validating Fullname field', (WidgetTester tester) async {
      await testFullName(tester, mockProfileRepository);
    });

    testWidgets('Validating whatsapp consent', (WidgetTester tester) async {
      await testWhatsappConsent(tester, mockProfileRepository);
    });

    testWidgets(
        'Disable sign up if policy not agreed and all fields are not filled',
        (WidgetTester tester) async {
      await testPolicyAgreeCheckbox(tester, mockProfileRepository);
    });

    testWidgets('Successful sign up', (WidgetTester tester) async {
      await testSuccessfulSignUp(mockProfileRepository, tester);
    });
  });
}

Future<void> testSuccessfulSignUp(
    MockProfileRepository mockProfileRepository, WidgetTester tester) async {
  setupMockAPI(mockProfileRepository);

  await setUpTestWidget(tester, mockProfileRepository);
  final SelfRegistrationDetailsState state =
      tester.state(find.byType(SelfRegistrationDetails));

  final String groupKeyValue = 'FormField${EnglishLang.group}';
  final String designationKeyValue = 'FormField${EnglishLang.designation}';
  final String groupItemValue = 'OptionListView${EnglishLang.group}';
  final String designationItemValue =
      'OptionListView${EnglishLang.designation}';
  final nameField = find.descendant(
    of: find.byType(FullnameWidget),
    matching: find.byKey(Key('fullNameField')),
  );
  final emailField = find.descendant(
    of: find.byType(EmailWidget),
    matching: find.byKey(Key('Email')),
  );
  final phoneField = find.descendant(
      of: find.byType(PhoneNumberWidget), matching: find.byKey(Key('Mobile')));

  // Act
  // Fill out the form with valid data and agree policy
  await fillRegisterFormField(
      tester,
      nameField,
      emailField,
      phoneField,
      designationKeyValue,
      designationItemValue,
      groupKeyValue,
      groupItemValue,
      state);

  state.fieldFocusChange(EnglishLang.group);
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.byKey(Key('SignUp')));
  expect(find.byKey(Key('SignUp')), findsOneWidget);

  ElevatedButton signUpBtn =
      await tester.widget<ElevatedButton>(find.byKey(Key('SignUp')));
  expect(signUpBtn.enabled, true);
  await tester.tap(find.byKey(Key('SignUp')));
  await tester.pumpAndSettle();
}

Future<void> fillRegisterFormField(
    WidgetTester tester,
    Finder nameField,
    Finder emailField,
    Finder phoneField,
    String designationKeyValue,
    String designationItemValue,
    String groupKeyValue,
    String groupItemValue,
    SelfRegistrationDetailsState state) async {
  await updateName(tester, nameField);
  await updateEmail(tester, emailField);
  await updatePhoneNumber(tester, phoneField);
  await updateDesignation(tester, designationKeyValue, designationItemValue);
  await updateGroup(tester, groupKeyValue, groupItemValue);
  updateLocalVariables(state);
}

void setupMockAPI(MockProfileRepository mockProfileRepository) {
  when(mockProfileRepository.orgLevelDesignationsList)
      .thenReturn(['Manager', 'Developer', 'Designer']);
  when(mockProfileRepository.getGroups())
      .thenAnswer((_) async => <dynamic>['Group1', 'Group2']);
}

Future<void> testPolicyAgreeCheckbox(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  await setUpTestWidget(tester, mockProfileRepository);

  final SelfRegistrationDetailsState state =
      tester.state(find.byType(SelfRegistrationDetails));
  // Act
  // Fill out the form with valid data
  await tester.enterText(find.byKey(Key('fullNameField')), 'test');
  state.designationController.text = 'test designation';
  state.groupController.text = 'test group';
  state.isEmailVerified = true;
  state.isMobileVerified = true;
  state.fieldFocusChange(EnglishLang.group);
  await tester.pumpAndSettle();
  ElevatedButton signUpBtn =
      await tester.widget<ElevatedButton>(find.byKey(Key('SignUp')));
  expect(signUpBtn.enabled, true);

  //Assert: disagree policy and check sign up disabled
  await tester.ensureVisible(find.byKey(Key('AgreePolicy')));
  Checkbox checkBox =
      await tester.widget<Checkbox>(find.byKey(Key('AgreePolicy')));
  expect(checkBox.value, true);
  //Act : change checkbox value false
  checkBox = await testUpdatePolicyAgreeValue(tester, checkBox, false);
  signUpBtn = await testSignUpBtnEnabledOrNot(signUpBtn, tester, false);

  //Assert: Agree policy and check sign up enabled
  //Act : change checkbox value true
  checkBox = await testUpdatePolicyAgreeValue(tester, checkBox, true);
  signUpBtn = await testSignUpBtnEnabledOrNot(signUpBtn, tester, true);
}

Future<ElevatedButton> testSignUpBtnEnabledOrNot(
    ElevatedButton signUpBtn, WidgetTester tester, bool value) async {
  signUpBtn = await tester.widget<ElevatedButton>(find.byKey(Key('SignUp')));
  expect(signUpBtn.enabled, value);
  return signUpBtn;
}

Future<Checkbox> testUpdatePolicyAgreeValue(
    WidgetTester tester, Checkbox checkBox, bool value) async {
  await tester.tap(find.byKey(Key('AgreePolicy')));
  await tester.pumpAndSettle();
  checkBox = await tester.widget<Checkbox>(find.byKey(Key('AgreePolicy')));
  expect(checkBox.value, value);
  return checkBox;
}

Future<void> testWhatsappConsent(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  await setUpTestWidget(tester, mockProfileRepository);

  final SelfRegistrationDetailsState state =
      tester.state(find.byType(SelfRegistrationDetails));
  expect(state.isAllowWhatsappMessages, isFalse);
  // Ensure the Checkbox is visible
  await tester.ensureVisible(find.byKey(Key('WhatsappConsent')));

  // Simulate tapping the Checkbox
  await tester.tap(find.byKey(Key('WhatsappConsent')));
  await tester.pumpAndSettle();
  expect(state.isAllowWhatsappMessages, isTrue);
  // Assert: Verify the checkbox is now checked
  Checkbox checkbox = tester.widget(find.byKey(Key('WhatsappConsent')));
  expect(checkbox.value, true);

  // Ensure the Checkbox is visible
  await tester.ensureVisible(find.byKey(Key('WhatsappConsent')));
  // Act: Tap the checkbox again to toggle its value back
  await tester.tap(find.byKey(Key('WhatsappConsent')));
  await tester.pumpAndSettle();
  expect(state.isAllowWhatsappMessages, isFalse);
  // Assert: Verify the text field gained focus
  expect(state.focusDesignation, true);
}

Future<void> testFullName(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  //Act
  await setUpTestWidget(tester, mockProfileRepository);

  final BuildContext context =
      tester.element(find.byType(SelfRegistrationDetails));

  final fullNameField = find.byKey(Key('fullNameField'));
  expect(fullNameField, findsOneWidget);
  //Check any special charachers are there in name
  await tester.enterText(fullNameField, 'John@Toe');
  await tester.pump();
  expect(find.text(AppLocalizations.of(context)!.mRegisterfullNameWitoutSp),
      findsOneWidget);
  //Check valid name is not throwing any exceptions
  await tester.enterText(fullNameField, 'John Toe');
  await tester.pump();
  expect(find.text(AppLocalizations.of(context)!.mRegisterfullNameWitoutSp),
      findsNothing);
}

Future<void> testDiaplayOrgname(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  // Act
  await setUpTestWidget(tester, mockProfileRepository);

  final BuildContext context =
      tester.element(find.byType(SelfRegistrationDetails));
  final richTextFinder = find.byWidgetPredicate(
    (widget) =>
        widget is RichText &&
        widget.text.toPlainText() ==
            AppLocalizations.of(context)!.mRegisterRegisterFor + ' Test Org',
  );
  await tester
      .ensureVisible(find.text(AppLocalizations.of(context)!.mStaticSignUp));
  await tester.tap(find.text(AppLocalizations.of(context)!.mStaticSignUp));
  await tester.pump();

  // Assert
  expect(richTextFinder, findsOneWidget);
}

void updateLocalVariables(SelfRegistrationDetailsState state) {
  state.designationController.text = 'test designation';
  state.groupController.text = 'test group';
  state.isEmailVerified = true;
  state.isMobileVerified = true;
}

Future<void> updatePhoneNumber(WidgetTester tester, Finder phoneField) async {
  await tester.enterText(phoneField, ConstantsTestUtil.validPhone);
  await tester.pump();
}

Future<void> updateEmail(WidgetTester tester, Finder emailField) async {
  await tester.enterText(emailField, ConstantsTestUtil.validMail);
  await tester.pump();
}

Future<void> updateName(WidgetTester tester, Finder nameField) async {
  await tester.enterText(nameField, 'test');
  await tester.pump();
}

Future<void> updateGroup(
    WidgetTester tester, String groupKeyValue, String groupItemValue) async {
  await tester.ensureVisible(find.byKey(Key(groupKeyValue)));
  await tester.tap(find.byKey(Key(groupKeyValue)));
  await tester.pumpAndSettle();
  final listGroup = find.byKey(Key('OptionList')).first;
  await tester.ensureVisible(find.byKey(Key(groupItemValue)));

  await tester.tap(listGroup);
  await tester.pumpAndSettle();
}

Future<void> updateDesignation(WidgetTester tester, String designationKeyValue,
    String designationItemValue) async {
  await tester.ensureVisible(find.byKey(Key(designationKeyValue)));
  await tester.tap(find.byKey(Key(designationKeyValue)));
  await tester.pumpAndSettle();
  final listItemOption = find.byKey(Key('OptionList')).first;
  await tester.ensureVisible(find.byKey(Key(designationItemValue)));
  await tester.tap(listItemOption);
  await tester.pumpAndSettle();
}

Future<void> setUpTestWidget(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  await tester.pumpWidget(ParentWidget.getParentWidget(
      ChangeNotifierProvider<ProfileRepository>.value(
    value: mockProfileRepository,
    child: SelfRegistrationDetails(
        arguments:
            RegistrationLinkModel(orgId: 'test-org-id', link: 'test-link')),
  )));
  await tester.pumpAndSettle();
}
