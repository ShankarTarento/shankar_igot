import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../mocks.mocks.dart';
import '../../utils/constants_test_util.dart';
import '../../utils/parent_widget_test_util.dart';
import 'designation_update_card_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockProfileRepository mockProfileRepository;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockClient mockClient;
  setUp(() {
    mockProfileRepository = MockProfileRepository();
    mockSecureStorage = MockFlutterSecureStorage();
    mockClient = MockClient();
  });
  group('Designation update card hidden when designation is updated', () {
    testWidgets(
        'Test already approved designation is in master list and designation card is hidden',
        (WidgetTester tester) async {
      await hideCardForApprovedMasterDesignation(
          mockProfileRepository, mockSecureStorage, tester, mockClient);
    });
    testWidgets(
        'Test update designation from card and designation card should hide once after update',
        (WidgetTester tester) async {
      await updateDesignationCardAndHide(
          mockProfileRepository, mockSecureStorage, mockClient, tester);
    });
  });
  group('Designation update card visible cases', () {
    setUp(() {
      simulateGetOrgFrameworkId(
          mockProfileRepository,
          ['Accountant', 'Clerk', 'Manager', 'CEO', 'Director'],
          mockSecureStorage,
          mockClient);
    });
    testWidgets(
        'Test the existing designation is not in master list and designation card is visible',
        (WidgetTester tester) async {
      await showCardForMissingdesignationInMasterButApproved(
          mockProfileRepository, mockSecureStorage, mockClient, tester);
    });
    testWidgets(
        'Show rejected designation in a card if it\'s in the master list and follows an approved one',
        (WidgetTester tester) async {
      await showCardForRejectedDesignation(
          mockProfileRepository, mockSecureStorage, mockClient, tester);
    });
  });
}

Future<void> updateDesignationCardAndHide(
    MockProfileRepository mockProfileRepository,
    MockFlutterSecureStorage mockSecureStorage,
    MockClient mockClient,
    WidgetTester tester) async {
  //Arrange
  simulateupdateDesignationApiCalls(
      mockProfileRepository, mockSecureStorage, mockClient);

  //Act
  await setUpTestWidget(tester, mockProfileRepository, mockSecureStorage,
      mockClient: mockClient);
  final DesignationUpdateCardState state =
      await tester.state(find.byType(DesignationUpdateCard));
  await tester.pump(Duration(milliseconds: 500));
  await tester.pumpAndSettle();

  // Assert
  verify(mockProfileRepository.getOrgFrameworkId(
          orgId: anyNamed(ConstantsTestUtil.orgId)))
      .called(1);
  verify(mockProfileRepository
          .getOrgBasedDesignations(ConstantsTestUtil.orgFrameworkId))
      .called(1);
  expect(state.designationController.text, '');
  expect(state.showReminderCard, isTrue);
  //Update designation controller
  state.designationController.text = 'Clerk';
  await tester.pump();
  expect(
      find.byKey(Key(KeyConstants.homeDesignationUpdateBtn)), findsOneWidget);
  final updateBtn = find.byKey(Key(KeyConstants.homeDesignationUpdateBtn));
  await tester.tap(updateBtn);
  await tester.pump();
}

void simulateupdateDesignationApiCalls(
    MockProfileRepository mockProfileRepository,
    MockFlutterSecureStorage mockSecureStorage,
    MockClient mockClient) {
  simulateGetOrgFrameworkId(
      mockProfileRepository,
      ['Accountant', 'Clerk', 'Manager', 'CEO', 'Director'],
      mockSecureStorage,
      mockClient);
  fetchFieldList(mockProfileRepository, approvedList: [
    {
      'lastUpdatedOn': '2025-01-01T12:00:00Z',
      'currentStatus': EnglishLang.approved,
      'wfId': 'test-wfid',
      'designation': 'test_department'
    }
  ], rejectedList: [
    {
      'lastUpdatedOn': '2025-01-02T12:00:00Z',
      'currentStatus': EnglishLang.rejected,
      'wfId': 'test-wfid',
      'designation': 'rejected_department'
    }
  ]);
}

Future<void> showCardForRejectedDesignation(
    MockProfileRepository mockProfileRepository,
    MockFlutterSecureStorage mockSecureStorage,
    MockClient mockClient,
    WidgetTester tester) async {
  fetchFieldList(mockProfileRepository, approvedList: [
    {
      'lastUpdatedOn': '2025-01-01T12:00:00Z',
      'currentStatus': EnglishLang.approved,
      'wfId': 'test-wfid',
      'designation': 'test_department'
    }
  ], rejectedList: [
    {
      'lastUpdatedOn': '2025-01-02T12:00:00Z',
      'currentStatus': EnglishLang.rejected,
      'wfId': 'test-wfid',
      'designation': 'rejected_department'
    }
  ]);

  await setUpTestWidget(tester, mockProfileRepository, mockSecureStorage,
      mockClient: mockClient);
  final DesignationUpdateCardState state =
      await tester.state(find.byType(DesignationUpdateCard));
  await tester.pump(Duration(milliseconds: 500));
  await tester.pumpAndSettle();

  verify(mockProfileRepository.getOrgFrameworkId(
          orgId: anyNamed(ConstantsTestUtil.orgId)))
      .called(1);
  verify(mockProfileRepository
          .getOrgBasedDesignations(ConstantsTestUtil.orgFrameworkId))
      .called(1);
  expect(state.designationController.text, '');
  expect(state.showReminderCard, isTrue);
}

Future<void> showCardForMissingdesignationInMasterButApproved(
    MockProfileRepository mockProfileRepository,
    MockFlutterSecureStorage mockSecureStorage,
    MockClient mockClient,
    WidgetTester tester) async {
  fetchFieldList(mockProfileRepository, approvedList: [
    {
      'lastUpdatedOn': '2025-01-01T12:00:00Z',
      'currentStatus': EnglishLang.approved,
      'wfId': 'test-wfid',
      'designation': 'test_department'
    }
  ]);

  await setUpTestWidget(tester, mockProfileRepository, mockSecureStorage,
      mockClient: mockClient);
  final DesignationUpdateCardState state =
      await tester.state(find.byType(DesignationUpdateCard));
  await tester.pump(Duration(milliseconds: 500));
  await tester.pumpAndSettle();

  verify(mockProfileRepository.getOrgFrameworkId(
          orgId: anyNamed(ConstantsTestUtil.orgId)))
      .called(1);
  verify(mockProfileRepository
          .getOrgBasedDesignations(ConstantsTestUtil.orgFrameworkId))
      .called(1);
  expect(state.designationController.text, '');
  expect(state.showReminderCard, isTrue);
}

Future<void> hideCardForApprovedMasterDesignation(
    MockProfileRepository mockProfileRepository,
    MockFlutterSecureStorage mockSecureStorage,
    WidgetTester tester,
    MockClient mockClient) async {
  // Simulate the organization framework ID retrieval
  simulateGetOrgFrameworkId(
      mockProfileRepository,
      ['Accountant', 'Clerk', 'Manager', 'CEO', 'Director', 'test_department'],
      mockSecureStorage,
      mockClient);
  fetchFieldList(mockProfileRepository, approvedList: [
    {
      'lastUpdatedOn': '2025-01-01T12:00:00Z',
      'currentStatus': EnglishLang.approved,
      'wfId': 'test-wfid',
      'designation': 'test_department'
    }
  ]);

  // Set up the test widget
  await setUpTestWidget(tester, mockProfileRepository, mockSecureStorage);

  await tester.pump(Duration(milliseconds: 500));

  // Get the state of the DesignationUpdateCard
  final DesignationUpdateCardState state =
      tester.state(find.byType(DesignationUpdateCard));

  // Check the expected outcome
  expect(state.showReminderCard, isFalse);
}

void simulateGetOrgFrameworkId(
    MockProfileRepository mockProfileRepository,
    List<String> designationList,
    MockFlutterSecureStorage mockStorage,
    MockClient mockClient) {
  when(mockStorage.read(key: anyNamed('key')))
      .thenAnswer((_) async => 'test_value');
  when(mockProfileRepository.getOrgFrameworkId(
          orgId: anyNamed(ConstantsTestUtil.orgId)))
      .thenAnswer((_) async =>
          RegistrationLinkModel(orgId: ConstantsTestUtil.orgFrameworkId));
  when(mockProfileRepository
          .getOrgBasedDesignations(ConstantsTestUtil.orgFrameworkId))
      .thenAnswer((_) async => designationList);
  // when(mockProfileRepository.profileDetails).thenReturn(Profile(
  //     firstName: 'test-name',middleName: '',surname:'',
  //     personalDetails: {},
  //     primaryEmail: ConstantsTestUtil.validMail,
  //     department: ConstantsTestUtil.department,
  //     profileDesignationStatus: 'VERIFIED',
  //     rawDetails: {}));
  when(mockClient.get(
    Uri.parse(ApiUrl.baseUrl + '/test_image_url'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response(
      '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">'
      '<rect width="100" height="100" style="fill:blue;" />'
      '</svg>',
      200));
  when(mockProfileRepository.updateProfileDetails(any))
      .thenAnswer((_) async => {
            'response': {
              'params': {'errmsg': null, 'err': null}
            }
          });
}

void fetchFieldList(MockProfileRepository mockProfileRepository,
    {List<Map<String, dynamic>>? approvedList,
    List<Map<String, dynamic>>? rejectedList,
    List<Map<String, dynamic>>? inReviewList}) {
  // when(mockProfileRepository.inReview).thenReturn(inReviewList ?? []);
  // when(mockProfileRepository.rejectedFields).thenReturn(rejectedList ?? []);
  // when(mockProfileRepository.approvedFields).thenReturn(approvedList ?? []);
}

Future<void> setUpTestWidget(
    WidgetTester tester,
    MockProfileRepository mockProfileRepository,
    MockFlutterSecureStorage mockSecureStorage,
    {MockClient? mockClient}) async {
  await tester.pumpWidget(ParentWidget.getParentWidget(
      ChangeNotifierProvider<ProfileRepository>.value(
          value: mockProfileRepository,
          child: DesignationUpdateCard(
              designationConfig: {
                'imageUrlMobile': '/test_image_url',
                'header': ConstantsTestUtil.header,
                'buttonText': ConstantsTestUtil.submit,
                'hintTextMobile': ConstantsTestUtil.hintText,
              },
              profileRepository: mockProfileRepository,
              storage: mockSecureStorage,
              client: mockClient))));
  await tester.pumpAndSettle();
}
