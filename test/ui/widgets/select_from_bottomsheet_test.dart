import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/select_from_bottomsheet.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks.mocks.dart';
import '../../routes/navigation_observer.dart';
import '../../utils/parent_widget_test_util.dart';

void main() {
  testDesignation();

  testGroup();
}

void testGroup() {
  return group('Group', () {
    final TextEditingController controller = TextEditingController();
    late MockProfileRepository mockProfileRepository;
    final mockObserver = MockNavigatorObserver();
    setUp(() {
      mockProfileRepository = MockProfileRepository();
      when(mockProfileRepository.getGroups())
          .thenAnswer((_) async => <dynamic>['Group1', 'Group2']);
    });

    testWidgets('Validating group by selecting group',
        (WidgetTester tester) async {
      //Act
      await tester.pumpWidget(ParentWidget.getParentWidget(
          ChangeNotifierProvider<ProfileRepository>.value(
            value: mockProfileRepository,
            child: Scaffold(
              body: Builder(builder: (context) {
                return SelectFromBottomSheet(
                  controller: controller,
                  fieldName: EnglishLang.group,
                  callBack: () {},
                  parentContext: context,
                  isOrgBasedDesignation: true,
                  isFocused: true,
                  changeFocus: (value) {},
                );
              }),
            ),
          ),
          observer: mockObserver));
      await tester.pumpAndSettle();
      final String keyValue = 'FormField${EnglishLang.group}';
      final String ItemValue = 'OptionListView${EnglishLang.group}';

      //Assert
      await assertSelection(tester, keyValue, ItemValue, mockObserver);
    });
  });
}

void testDesignation() {
  return group('Designation', () {
    final TextEditingController controller = TextEditingController();
    late MockProfileRepository mockProfileRepository;
    final mockObserver = MockNavigatorObserver();
    setUp(() {
      mockProfileRepository = MockProfileRepository();
      when(mockProfileRepository.orgLevelDesignationsList)
          .thenReturn(['Manager', 'Developer', 'Designer']);
    });

    testWidgets('Validating designation by selecting designation',
        (WidgetTester tester) async {
      await tester.pumpWidget(ParentWidget.getParentWidget(
          ChangeNotifierProvider<ProfileRepository>.value(
            value: mockProfileRepository,
            child: Scaffold(
              body: Builder(builder: (context) {
                return SelectFromBottomSheet(
                  controller: controller,
                  fieldName: EnglishLang.designation,
                  callBack: () {},
                  parentContext: context,
                  isOrgBasedDesignation: true,
                  isFocused: true,
                  changeFocus: (value) {},
                );
              }),
            ),
          ),
          observer: mockObserver));
      await tester.pumpAndSettle();

      final String keyValue = 'FormField${EnglishLang.designation}';
      final String ItemValue = 'OptionListView${EnglishLang.designation}';

      await assertSelection(tester, keyValue, ItemValue, mockObserver);
    });
  });
}

Future<void> assertSelection(WidgetTester tester, String keyValue,
    String ItemValue, MockNavigatorObserver mockObserver) async {
  await tester.ensureVisible(find.byKey(Key(keyValue)));
  await tester.tap(find.byKey(Key(keyValue)));
  await tester.pumpAndSettle();
  final listItemOption = find.byKey(Key('OptionList')).first;
  await tester.ensureVisible(find.byKey(Key(ItemValue)));
  int routeLength = mockObserver.routes.length;

  await tester.tap(listItemOption);
  await tester.pumpAndSettle();
  // Now get the navigator
  expect(mockObserver.routes.length, routeLength - 1);
}
