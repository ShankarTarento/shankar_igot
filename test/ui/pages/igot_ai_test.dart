import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/home_page/my_space/igot_ai.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import '../../mocks.mocks.dart';
import '../../utils/constants_test_util.dart';
import '../../utils/parent_widget_test_util.dart';
import 'igot_ai_test.mocks.dart';

@GenerateMocks([IgotAIRepository])
void main() {
  late MockIgotAIRepository mockIgotAIRepository;
  late MockLearnRepository mockLearnRepository;
  late MockClient mockClient;
  setUp(() {
    mockIgotAIRepository = MockIgotAIRepository();
    mockLearnRepository = MockLearnRepository();
    mockClient = MockClient();
  });
  group('show courses recommended by AI', () {
    testWidgets('Show course cards in UI', (WidgetTester tester) async {
      await showCourseCards(
          mockIgotAIRepository, mockLearnRepository, tester, mockClient);
    });
  });
}

Future<void> showCourseCards(
    MockIgotAIRepository mockIgotAIRepository,
    MockLearnRepository mockLearnRepository,
    WidgetTester tester,
    MockClient mockClient) async {
  when(mockClient.get(
    Uri.parse(ApiUrl.baseUrl + '/assets/images/sakshamAI/ai-icon.svg'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response(
      '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">'
      '<rect width="100" height="100" style="fill:blue;" />'
      '</svg>',
      200));
  when(mockClient.get(
    Uri.parse(ApiUrl.baseUrl + '/assets/images/sakshamAI/ai-icon-success.svg'),
    headers: anyNamed('headers'),
  )).thenAnswer((_) async => http.Response(
      '<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">'
      '<rect width="100" height="100" style="fill:blue;" />'
      '</svg>',
      200));
  when(mockIgotAIRepository.generateRecommendation())
      .thenAnswer((_) async => ConstantsTestUtil.recomendationId);
  when(mockIgotAIRepository.getAIRecommentationWithFeedbackDoId(
          id: ConstantsTestUtil.recomendationId))
      .thenAnswer((_) async => {
            'doIdList': ConstantsTestUtil.doIdList,
            'nonRelevantDoIdList': ['test-id-2']
          });
  when(mockLearnRepository.getRecommendationWithDoId(['test-id-1'],
          relevantDoId: anyNamed('relevantDoId'), pointToProd: true))
      .thenAnswer((_) async => [ConstantsTestUtil.courseList.first]);
  await setUpTestWidget(tester,
      mockIgotAIRepository: mockIgotAIRepository,
      mockLearnRepository: mockLearnRepository,
      mockClient: mockClient);
  // expect(find.byKey(ValueKey('${KeyConstants.igotAICourseCardView}0')),
  //     findsOneWidget);
}

Future<void> setUpTestWidget(WidgetTester tester,
    {MockIgotAIRepository? mockIgotAIRepository,
    MockLearnRepository? mockLearnRepository,
    MockClient? mockClient}) async {
  await tester.pumpWidget(ParentWidget.getParentWidget(Scaffold(
      body: IgotAI(
          shareFeedbackCardVisibility: ValueNotifier(false),
          igotAIRepository: mockIgotAIRepository,
          learnRepository: mockLearnRepository,
          client: mockClient))));
  await tester.pumpAndSettle();
}

IgotAIState getState(WidgetTester tester) {
  final state = tester.state<IgotAIState>(
    find.byType(IgotAI),
  );
  return state;
}
