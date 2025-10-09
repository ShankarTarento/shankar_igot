// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:karmayogi_mobile/constants/index.dart';
// import 'package:karmayogi_mobile/models/index.dart';
// import 'package:karmayogi_mobile/ui/pages/_pages/home_page/my_space/my_space.dart';
// import 'package:mockito/mockito.dart';
// import 'package:http/http.dart' as http;

// import '../../mocks.mocks.dart';
// import '../../utils/constants_test_util.dart';
// import '../../utils/parent_widget_test_util.dart';

// void main() {
//   late MockProfileRepository mockProfileRepository;
//   late MockLearnRepository mockLearnRepository;
//   late MockClient mockClient;
//   setUp(() {
//     mockProfileRepository = MockProfileRepository();
//     mockLearnRepository = MockLearnRepository();
//     mockClient = MockClient();
//   });

//   group('Hide myspace if no igot plans and recommended learning', () {
//     testWidgets('Check no courses in iGot plans and recommended learning',
//         (WidgetTester tester) async {
//       await testNoIgotPlanNoRecommendedLearning(
//           mockProfileRepository, tester, mockLearnRepository, mockClient);
//     });
//     testWidgets(
//         'Check no courses in iGot plans but recommended learning having courses, So display one tab',
//         (WidgetTester tester) async {
//       await testNoiGotPlanButRecommendedLearningAvailable(
//           mockProfileRepository, mockLearnRepository, tester, mockClient);
//     });

//     testWidgets(
//         'Check no courses in recommended learning, but iGot plans having courses, So display one tab',
//         (WidgetTester tester) async {
//       await testNoRecommendedLearningOnlyiGotPlanAvailable(
//           mockProfileRepository, tester, mockLearnRepository, mockClient);
//     });
//     testWidgets(
//         'Check recommended learning and my iGot plans are available, and getRecommendedCourse and composite search API called once',
//         (WidgetTester tester) async {
//       await testBothiGotPlanAndRecommendedLearningAvailable(
//           mockProfileRepository, mockLearnRepository, tester, mockClient);
//     });
//   });
// }

// Future<void> testBothiGotPlanAndRecommendedLearningAvailable(
//     MockProfileRepository mockProfileRepository,
//     MockLearnRepository mockLearnRepository,
//     WidgetTester tester,
//     MockClient mockClient) async {
//   when(mockProfileRepository.getRecommendedCourse())
//       .thenAnswer((_) async => ConstantsTestUtil.doIdList);
//   when(mockLearnRepository
//           .getRecommendationWithDoId(ConstantsTestUtil.doIdList))
//       .thenAnswer((_) async => ConstantsTestUtil.courseList);
//   when(mockClient.get(
//     Uri.parse(ApiUrl.baseUrl + '/assets/images/sakshamAI/ai-icon.svg'),
//     headers: anyNamed('headers'),
//   )).thenAnswer((_) async => http.Response(
//       '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">'
//       '<rect width="100" height="100" style="fill:blue;" />'
//       '</svg>',
//       200));

//   when(mockLearnRepository.getCourseEnrollDetailsByIds(
//     courseIds: anyNamed('courseIds'),
//     checkforCBPEnddate: anyNamed('checkforCBPEnddate'),
//   )).thenAnswer((_) async => []);

//   await setUpTestWidget(tester,
//       mockProfileRepository: mockProfileRepository,
//       mockLearnRepository: mockLearnRepository,
//       mockClient: mockClient,
//       cbpCourseData: CbPlanModel(count: 1, content: [
//         Content(
//             id: 'id_1',
//             userType: 'user_type',
//             endDate: 'date',
//             contentList: [ConstantsTestUtil.courseList.first])
//       ]));
//   MySpaceState state = getState(tester);
//   verify(mockProfileRepository.getRecommendedCourse()).called(1);
//   verify(mockLearnRepository.getRecommendationWithDoId(any)).called(1);
//   expect(state.tabController!.length, 3);
// }

// Future<void> testNoRecommendedLearningOnlyiGotPlanAvailable(
//     MockProfileRepository mockProfileRepository,
//     WidgetTester tester,
//     MockLearnRepository mockLearnRepository,
//     MockClient mockClient) async {
//   when(mockProfileRepository.getRecommendedCourse())
//       .thenAnswer((_) async => []);

//   when(mockClient.get(
//     Uri.parse(ApiUrl.baseUrl + '/assets/images/sakshamAI/ai-icon.svg'),
//     headers: anyNamed('headers'),
//   )).thenAnswer((_) async => http.Response(
//       '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">'
//       '<rect width="100" height="100" style="fill:blue;" />'
//       '</svg>',
//       200));

//   when(mockLearnRepository.getCourseEnrollDetailsByIds(
//     courseIds: anyNamed('courseIds'),
//     checkforCBPEnddate: anyNamed('checkforCBPEnddate'),
//   )).thenAnswer((_) async => []);

//   await setUpTestWidget(tester,
//       mockProfileRepository: mockProfileRepository,
//       mockClient: mockClient,
//       mockLearnRepository: mockLearnRepository,
//       cbpCourseData: CbPlanModel(count: 1, content: [
//         Content(
//             id: 'id_1',
//             userType: 'user_type',
//             endDate: 'date',
//             contentList: ConstantsTestUtil.courseList)
//       ]));
//   MySpaceState state = getState(tester);
//   verifyNever(mockLearnRepository.getRecommendationWithDoId(any));
//   expect(state.tabController!.length, 2);
// }

// Future<void> testNoiGotPlanButRecommendedLearningAvailable(
//     MockProfileRepository mockProfileRepository,
//     MockLearnRepository mockLearnRepository,
//     WidgetTester tester,
//     MockClient mockClient) async {
//   when(mockProfileRepository.getRecommendedCourse())
//       .thenAnswer((_) async => ConstantsTestUtil.doIdList);
//   when(mockLearnRepository
//           .getRecommendationWithDoId(ConstantsTestUtil.doIdList))
//       .thenAnswer((_) async => ConstantsTestUtil.courseList);
//   when(mockClient.get(
//     Uri.parse(ApiUrl.baseUrl + '/assets/images/sakshamAI/ai-icon.svg'),
//     headers: anyNamed('headers'),
//   )).thenAnswer((_) async => http.Response(
//       '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">'
//       '<rect width="100" height="100" style="fill:blue;" />'
//       '</svg>',
//       200));
//   await setUpTestWidget(tester,
//       mockProfileRepository: mockProfileRepository,
//       mockLearnRepository: mockLearnRepository,
//       mockClient: mockClient);
//   MySpaceState state = getState(tester);
//   expect(state.tabController!.length, 2);
// }

// Future<void> testNoIgotPlanNoRecommendedLearning(
//     MockProfileRepository mockProfileRepository,
//     WidgetTester tester,
//     MockLearnRepository mockLearnRepository,
//     MockClient mockClient) async {
//   // Mock response
//   when(mockProfileRepository.getRecommendedCourse())
//       .thenAnswer((_) async => []);
//   when(mockClient.get(
//     Uri.parse(ApiUrl.baseUrl + '/assets/images/sakshamAI/ai-icon.svg'),
//     headers: anyNamed('headers'),
//   )).thenAnswer((_) async => http.Response(
//       '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">'
//       '<rect width="100" height="100" style="fill:blue;" />'
//       '</svg>',
//       200));

//   // Set up the widget
//   await setUpTestWidget(tester,
//       mockProfileRepository: mockProfileRepository,
//       mockLearnRepository: mockLearnRepository,
//       mockClient: mockClient);
//   MySpaceState state = getState(tester);
//   expect(state.tabController!.length, 1);
// }

// MySpaceState getState(WidgetTester tester) {
//   final state = tester.state<MySpaceState>(
//     find.byType(MySpace),
//   );
//   return state;
// }

// Future<void> setUpTestWidget(WidgetTester tester,
//     {MockProfileRepository? mockProfileRepository,
//     MockLearnRepository? mockLearnRepository,
//     CbPlanModel? cbpCourseData,
//     MockClient? mockClient}) async {
//   await tester.pumpWidget(ParentWidget.getParentWidget(Scaffold(
//       body: MySpace(
//           cbpCourseData: cbpCourseData,
//           profileRepository: mockProfileRepository,
//           learnRepository: mockLearnRepository,
//           isRecommendedLearningHidden: false,
//           client: mockClient))));
//   await tester.pumpAndSettle();
// }
