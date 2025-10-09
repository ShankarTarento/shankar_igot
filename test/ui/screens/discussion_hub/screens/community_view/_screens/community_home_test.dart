import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_topics_carousel_widget_skeleton.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_home.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/user_community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'community_home_test.mocks.dart';

@GenerateMocks([DiscussionRepository])
void main() {
  // Disable Provider's "subtype of Listenable" check for the whole suite
  Provider.debugCheckInvalidValueType = null;

  late MockDiscussionRepository mockRepo;

  setUp(() {
    mockRepo = MockDiscussionRepository();
  });

  group('CommunityHome Widget Tests', () {
    testWidgets('shows skeleton while loading joined communities', (WidgetTester tester) async {
          // Simulate a delayed response
          when(mockRepo.getUserJoinedCommunities()).thenAnswer((_) async {
              await Future.delayed(const Duration(seconds: 1));
              return <UserCommunityIdData>[];
            },
          );

          await _pumpCommunityHome(tester, mockRepo);
          // await pumpWidgetWithLocalizationAndProvider(
          //   tester,
          //   const CommunityHome(),
          //   providerValue: mockRepo,
          // );

          // First frame -> skeleton visible
          expect(find.byType(CommunityTopicsCarouselWidgetSkeleton), findsOneWidget);

          // Wait for the Future.delayed to complete
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Skeleton should disappear
          expect(find.byType(CommunityTopicsCarouselWidgetSkeleton), findsNothing);
        });
  });
}

Future<void> _pumpCommunityHome(WidgetTester tester, DiscussionRepository repo,) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: false,
        useInheritedMediaQuery: false,
        child: Provider<DiscussionRepository>.value(
          value: repo,
          child: const CommunityHome(),
        ),
      ),
    ),
  );
}