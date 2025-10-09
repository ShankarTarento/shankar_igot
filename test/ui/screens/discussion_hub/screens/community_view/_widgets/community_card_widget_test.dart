import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_detail_view.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_card_widget.dart';

import '../../../../../../utils/test_helpers.dart';

void main() {
  late CommunityItemData communityItemModel;

  setUp(() {
    communityItemModel = CommunityItemData(
      communityId: 'community001',
      communityName: 'Tech Innovators',
      imageUrl: 'https://example.com/community_image.jpg',
      countOfPeopleJoined: 500,
      countOfPostCreated: 100,
      communityAccessLevel: 'Public',
    );
  });

  group('CommunityCardWidget Tests', () {
    testWidgets('Should display community name and image correctly', (WidgetTester tester) async {
      // Arrange: Set up the widget for testing
      await pumpWidgetWithLocalization(
        tester,
        CommunityCardWidget(
          communityItemModel: communityItemModel,
        ),
      );

      // Act: Pump the widget tree with specific durations
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Use tester.idle() to wait for all pending frames to be processed
      await tester.idle();

      // Assert: Verify community name and image
      expect(find.text('Tech Innovators'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('500 Members'), findsOneWidget);
      expect(find.text('100 Posts'), findsOneWidget);
    });

    testWidgets('Should display placeholder when imageUrl is null', (WidgetTester tester) async {
      // Arrange: Modify the model to have a null imageUrl
      communityItemModel = CommunityItemData(
        communityId: communityItemModel.communityId,
        communityName: communityItemModel.communityName,
        imageUrl: null,
        countOfPeopleJoined: communityItemModel.countOfPeopleJoined,
        countOfPostCreated: communityItemModel.countOfPostCreated,
        communityAccessLevel: communityItemModel.communityAccessLevel,
      );

      await pumpWidgetWithLocalization(
        tester,
        CommunityCardWidget(
          communityItemModel: communityItemModel,
        ),
      );

      // Act: Pump the widget tree with specific durations
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Use tester.idle() to wait for all pending frames to be processed
      await tester.idle();

      // Assert: Verify placeholder is displayed
      expect(find.text('TI'), findsOneWidget); // Assuming initials are displayed as placeholder
      expect(find.byType(Image), findsNothing); // No image should be rendered
    });

    testWidgets('Should navigate to CommunityDetailScreen on tap', (WidgetTester tester) async {
      // Arrange: Set up the widget for testing
      await pumpWidgetWithLocalization(
        tester,
        CommunityCardWidget(
          communityItemModel: communityItemModel,
        ),
      );

      // Act: Simulate a tap on the CommunityCardWidget
      await tester.tap(find.byType(CommunityCardWidget));
      await tester.pump(const Duration(milliseconds: 500)); // Pump with a specific duration
      await tester.pump(const Duration(milliseconds: 500)); // Pump again to ensure the navigation completes
      await tester.pump(const Duration(milliseconds: 500)); // Pump again to ensure the navigation completes

      // Use tester.idle() to wait for all pending frames to be processed
      await tester.idle();

      // Assert: Verify that the navigation occurred
      expect(find.byType(CommunityDetailView), findsOneWidget);
    });
  });
}