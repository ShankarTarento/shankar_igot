import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_detail_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_about_widget.dart';
import '../../../../../../utils/parent_widget_test_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  late CommunityDetailModel communityDetailModel;

  setUp(() {
    communityDetailModel = CommunityDetailModel(
      communityName: 'Tech Innovators',
      description: 'A community for tech enthusiasts to discuss and innovate.',
      communityAccessLevel: 'Public',
      orgId: '12345',
      tags: ['technology', 'innovation', 'coding'],
      topicName: 'AI & Machine Learning',
      countOfPeopleJoined: 500,
      countOfPeopleLiked: 450,
      communityTagId: 'A1B2C3',
      posterImageUrl: 'https://example.com/poster.jpg',
      imageUrl: 'https://example.com/community_image.jpg',
      topicId: 1,
      communityGuideLines: 'Respect all members, no spam.',
      countOfPostCreated: 100,
      countOfAnswerPost: 50,
      createdByUserId: '123',
      updatedByUserId: '124',
      communityId: 'community001',
      status: 'Active',
      isUserJoinedCommunity: true,
    );
  });

  group('CommunityAboutWidget Tests', () {
    testWidgets('Should display community about section when description is provided', (WidgetTester tester) async {
      // Arrange: Set up the widget for testing
      await _pumpCommunityAboutWidget(tester, communityDetailModel);

      // Act: Let the widget settle
      await tester.pumpAndSettle();

      // Assert: Check for the sections
      final BuildContext context = tester.element(find.byType(CommunityAboutWidget));
      if ((communityDetailModel.description ?? '').isNotEmpty) {
        expect(find.text(AppLocalizations.of(context)!.mDiscussionAboutTheCommunity), findsOneWidget);
      }
      if ((communityDetailModel.communityGuideLines ?? '').isNotEmpty) {
        expect(find.text(AppLocalizations.of(context)!.mDiscussionCommunityGuidelines), findsOneWidget);
      }
      expect(find.text(AppLocalizations.of(context)!.mDiscussionCommunityStats), findsOneWidget);
      expect(find.text("${communityDetailModel.countOfPeopleLiked ?? 0} ${(communityDetailModel.countOfPeopleLiked == 1) ? AppLocalizations.of(context)!.mStaticLike : AppLocalizations.of(context)!.mStaticLikes}"), findsOneWidget);
      expect(find.text("${communityDetailModel.countOfAnswerPost ?? 0} ${(communityDetailModel.countOfAnswerPost == 1) ? AppLocalizations.of(context)!.mStaticComment : AppLocalizations.of(context)!.mStaticComments}"), findsOneWidget);
      expect(find.text("${communityDetailModel.countOfPeopleJoined ?? 0} ${(communityDetailModel.countOfPeopleJoined == 1) ? AppLocalizations.of(context)!.mDiscussionMember : AppLocalizations.of(context)!.mDiscussionMembers}"), findsOneWidget);
    });
  });
}

/// Helper function to set up the widget with given model
Future<void> _pumpCommunityAboutWidget(WidgetTester tester, CommunityDetailModel communityDetailModel) async {
  await tester.pumpWidget(ParentWidget.getParentWidget(
    CommunityAboutWidget(
      communityId: communityDetailModel.communityId ?? '',
      communityResponseData: communityDetailModel,
    ),
  ));
  await tester.pumpAndSettle();
}