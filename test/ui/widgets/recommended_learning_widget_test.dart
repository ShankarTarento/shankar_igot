import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
  testTabCount();
  testonTapOnCourseCard();
}

void testonTapOnCourseCard() {
  return group('test navigation to TOC', () {
    testTapOnAvailableCourseCard();
    testTapOnInprogressCoursecard();
    testTapOnCompletedCourseCard();
  });
}

void testTapOnCompletedCourseCard() {
  return testWidgets('Check whether tap on completed course routing to TOC',
      (WidgetTester tester) async {
    await setUpTestWidget(tester,
        available: [], inprogress: [], completed: ConstantsTestUtil.courseList);
    // Locate the widget
    final state = tester.state<RecommendedLearningWidgetState>(
      find.byType(RecommendedLearningWidget),
    );

    await tapOnCourseCard(state, tester);
  });
}

void testTapOnInprogressCoursecard() {
  return testWidgets('Check whether tap on inprogress course routing to TOC',
      (WidgetTester tester) async {
    await setUpTestWidget(tester,
        available: [], inprogress: ConstantsTestUtil.courseList, completed: []);
    // Locate the widget
    final state = tester.state<RecommendedLearningWidgetState>(
      find.byType(RecommendedLearningWidget),
    );

    await tapOnCourseCard(state, tester);
  });
}

Future<void> tapOnCourseCard(
    RecommendedLearningWidgetState state, WidgetTester tester) async {
  final courseCard =
      find.byKey(Key('courseCard${ConstantsTestUtil.courseList.first.id}'));
  expect(courseCard, findsOneWidget);
  await tester.tap(courseCard);
}

void testTapOnAvailableCourseCard() {
  return testWidgets('Check whether tap on available course routing to TOC',
      (WidgetTester tester) async {
    await setUpTestWidget(tester,
        available: ConstantsTestUtil.courseList, inprogress: [], completed: []);
    // Locate the widget
    final state = tester.state<RecommendedLearningWidgetState>(
      find.byType(RecommendedLearningWidget),
    );

    await tapOnCourseCard(state, tester);
  });
}

void testTabCount() {
  return group('Validate tab count', () {
    testEmptyCouseList();
    testNoneOfTheCourseEnrolled();

    testAllRecommendedCouseEnrolledWithInprogressOrCompleted();

    testAllCoursesEnrolledAndCompleted();
    testAllCategoriesOfCourseAvailable();
  });
}

void testAllCategoriesOfCourseAvailable() {
  testWidgets(
      'Check tab count is 3 if available, inprogress and completed course list is not empty',
      (WidgetTester tester) async {
    await setUpTestWidget(tester,
        available: ConstantsTestUtil.courseList,
        inprogress: ConstantsTestUtil.courseList,
        completed: ConstantsTestUtil.courseList);
    // Locate the widget
    final state = tester.state<RecommendedLearningWidgetState>(
      find.byType(RecommendedLearningWidget),
    );

    // Verify TabController length
    expect(state.tabController.length, 3);
  });
}

void testAllCoursesEnrolledAndCompleted() {
  testWidgets(
      'Check tab count is 1 with only completed course list is not empty and initial index is 0',
      (WidgetTester tester) async {
    await setUpTestWidget(tester,
        available: [], inprogress: [], completed: ConstantsTestUtil.courseList);
    // Locate the widget
    final state = tester.state<RecommendedLearningWidgetState>(
      find.byType(RecommendedLearningWidget),
    );

    // Verify TabController length
    expect(state.tabController.length, 1);
    expect(state.tabController.index, 0);
  });
}

void testAllRecommendedCouseEnrolledWithInprogressOrCompleted() {
  testWidgets(
      'Check tab count is 2 with available Course empty and initial index is 0',
      (WidgetTester tester) async {
    await setUpTestWidget(tester,
        available: [],
        inprogress: ConstantsTestUtil.courseList,
        completed: ConstantsTestUtil.courseList);
    // Locate the widget
    final state = tester.state<RecommendedLearningWidgetState>(
      find.byType(RecommendedLearningWidget),
    );

    // Verify TabController length
    expect(state.tabController.length, 2);
    expect(state.tabController.index, 0);
  });
}

void testNoneOfTheCourseEnrolled() {
  testWidgets('Check tab count is 1 only one list contais courses',
      (WidgetTester tester) async {
    await setUpTestWidget(tester,
        available: ConstantsTestUtil.courseList, inprogress: [], completed: []);
    // Locate the widget
    final state = tester.state<RecommendedLearningWidgetState>(
      find.byType(RecommendedLearningWidget),
    );

    // Verify TabController length
    expect(state.tabController.length, 1);
  });
}

void testEmptyCouseList() {
  testWidgets(
      'Check tab count is zero if available, inprogress and completed course list is empty',
      (WidgetTester tester) async {
    await setUpTestWidget(tester, available: [], inprogress: [], completed: []);
    // Locate the widget
    final state = tester.state<RecommendedLearningWidgetState>(
      find.byType(RecommendedLearningWidget),
    );

    // Verify TabController length
    expect(state.tabController.length, 0);
  });
}

Future<void> setUpTestWidget(WidgetTester tester,
    {required List<Course> available,
    required List<Course> inprogress,
    required List<Course> completed}) async {
  await tester.pumpWidget(
      ParentWidget.getParentWidget(Scaffold(body: Builder(builder: (context) {
    return RecommendedLearningWidget(
        availableCourses: available,
        inprogressCourses: inprogress,
        completedCourses: completed,
        parentContext: context);
  }))));
  await tester.pumpAndSettle();
}
