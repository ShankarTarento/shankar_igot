import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/search/ui/widgets/search_category_section.dart';
// import 'package:karmayogi_mobile/ui/pages/_pages/search/utils/search_filter_params.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../utils/parent_widget_test_util.dart';

void sqfliteTestInit() {
  // Initialize ffi implementation
  sqfliteFfiInit();
  // Set global factory
  databaseFactory = databaseFactoryFfi;
}

void main() {
  //  Initialize ffi implementation
  sqfliteFfiInit();
  // Set global factory, do not use isolate here
  databaseFactory = databaseFactoryFfiNoIsolate;
  group('Search screen without result', () {
    testWidgets('Check is categories are displayed in the screen',
        (WidgetTester tester) async {
      await testCategorySectionVisibility(tester);
    });
    // testWidgets('Check is category selection change',
    //     (WidgetTester tester) async {
    //   await testCategorySelection(tester);
    // });
  });

  group('Search screen show result screen on category changes', () {
    // testWidgets(
    //     'Check Courses are showing in result screen if tap on course category',
    //     (WidgetTester tester) async {
    //   await testCoursesCard(tester);
    // });
    // testWidgets(
    //     'Check Events are showing in result screen if tap on events category',
    //     (WidgetTester tester) async {
    //   await testEventsCard(tester);
    // });
  });

  group('Test on textfield', () {
    testWidgets('Check Result Screen shows on submit of textfield',
        (WidgetTester tester) async {
      await testKeyboardSubmit(tester);
    });
    testWidgets('Check close button shows when start typing on textfield',
        (WidgetTester tester) async {
      await testCloseIconVisible(tester);
    });
    testWidgets('Check close button hide when textfield is Empty',
        (WidgetTester tester) async {
      await testCloseIconHidden(tester);
    });
  });
}

Future<void> testCategorySectionVisibility(WidgetTester tester) async {
  // Set up the widget
  await setUpTestWidget(tester);
  expect(find.byType(SearchCategorySection), findsOneWidget);
}

// Future<void> testCategorySelection(WidgetTester tester) async {
//   // Set up the widget
//   await setUpTestWidget(tester);
//   SearchPageState state = getState(tester);
//   final BuildContext context = tester.element(find.byType(SearchPage));
//   final String categoryText = SearchCategoryData.filterParams(
//           context: context)[state.selectedCategoryIndex ?? 0]
//       .tabName;
//   expect(find.text(categoryText), findsAtLeast(1));
//   // Tap on the events category
//   await tester.tap(find.text(AppLocalizations.of(context)!.mStaticEvents));
//   await tester.pumpAndSettle();
//   final int tabIndex = SearchCategoryData.filterParams(context: context)
//       .indexWhere((filter) =>
//           filter.tabName == AppLocalizations.of(context)!.mStaticEvents);
//   // Verify 'Events' category is now selected
//   expect(
//       state.selectedCategoryIndex,
//       equals(SearchCategoryData.filterParams(context: context)[tabIndex]
//           .tabIndex));
// }

// Future<void> testCoursesCard(WidgetTester tester) async {
//   // Set up the widget
//   await setUpTestWidget(tester);
//   SearchPageState state = getState(tester);
//   final BuildContext context = tester.element(find.byType(SearchPage));

//   // Tap on the course category
//   await tester.tap(find.text(AppLocalizations.of(context)!.mCourses));
//   await tester.pumpAndSettle();
//   final int tabIndex = SearchCategoryData.filterParams(context: context)
//       .indexWhere(
//           (filter) => filter.tabName == AppLocalizations.of(context)!.mCourses);
//   // Verify 'Courses' category is now selected
//   expect(
//       state.selectedCategoryIndex,
//       equals(SearchCategoryData.filterParams(context: context)[tabIndex]
//           .tabIndex));
//   // Verify keyboard is hidden
//   expect(
//       MediaQuery.of(tester.element(find.byType(TextField))).viewInsets.bottom,
//       0);
// }

// Future<void> testEventsCard(WidgetTester tester) async {
//   // Set up the widget
//   await setUpTestWidget(tester);
//   SearchPageState state = getState(tester);
//   final BuildContext context = tester.element(find.byType(SearchPage));

//   // Tap on the events category
//   await tester.tap(find.text(AppLocalizations.of(context)!.mStaticEvents));
//   await tester.pumpAndSettle();
//   final int tabIndex = SearchCategoryData.filterParams(context: context)
//       .indexWhere((filter) =>
//           filter.tabName == AppLocalizations.of(context)!.mStaticEvents);
//   // Verify 'events' category is now selected
//   expect(
//       state.selectedCategoryIndex,
//       equals(SearchCategoryData.filterParams(context: context)[tabIndex]
//           .tabIndex));
//   // Verify keyboard is hidden
//   expect(
//       MediaQuery.of(tester.element(find.byType(TextField))).viewInsets.bottom,
//       0);
//   expect(find.byType(SearchResultPage), findsOneWidget);
// }

Future<void> testKeyboardSubmit(WidgetTester tester) async {
  // Set up the widget
  await setUpTestWidget(tester);

  // Enter text into the TextField
  await tester.enterText(find.byType(TextField), 'Name');

  // Simulate pressing the submit button (Done)
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
  expect(find.byType(SearchResultPage), findsOneWidget);
}

Future<void> testCloseIconVisible(WidgetTester tester) async {
  // Set up the widget
  await setUpTestWidget(tester);

  // Enter text into the TextField
  await tester.enterText(find.byType(TextField), 'N');
  await tester.pumpAndSettle();

  expect(find.byKey(Key(KeyConstants.searchFieldClose)), findsOneWidget);
}

Future<void> testCloseIconHidden(WidgetTester tester) async {
  // Set up the widget
  await setUpTestWidget(tester);

  // Enter text into the TextField
  await tester.enterText(find.byType(TextField), '');
  await tester.pumpAndSettle();

  expect(find.byKey(Key(KeyConstants.searchFieldClose)), findsNothing);

  // Enter text into the TextField
  await tester.enterText(find.byType(TextField), 'N');
  await tester.pumpAndSettle();

  expect(find.byKey(Key(KeyConstants.searchFieldClose)), findsOneWidget);

  await tester.tap(find.byKey(Key(KeyConstants.searchFieldClose)));
  await tester.pumpAndSettle();
  expect(find.byKey(Key(KeyConstants.searchFieldClose)), findsNothing);
}

SearchPageState getState(WidgetTester tester) {
  final state = tester.state<SearchPageState>(
    find.byType(SearchPage),
  );
  return state;
}

Future<void> setUpTestWidget(
  WidgetTester tester,
) async {
  await tester
      .pumpWidget(ParentWidget.getParentWidget(Scaffold(body: SearchPage())));
  await tester.pumpAndSettle();
}
