import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../mocks.mocks.dart';
import '../../utils/parent_widget_test_util.dart';
import 'self_register_qrscanner_widget_test.mocks.dart';

class MockMethodChannel extends Mock implements MethodChannel {}

@GenerateMocks([QRViewController, ImagePicker])
void main() {
  late MockProfileRepository mockProfileRepository;
  setUpAll(() {
    // Initialize the mock repository before each test
    mockProfileRepository = MockProfileRepository();
  });
  testWidgets('Scan an invalid QR', (WidgetTester tester) async {
    await testInvalidQR(tester, mockProfileRepository);
  });

  testWidgets('Scan an invalid QR and reset to scan again',
      (WidgetTester tester) async {
    await testInvalidQRScanAndReset(tester, mockProfileRepository);
  });

  testWidgets('Scan an invalid QR with actual domain and format',
      (WidgetTester tester) async {
    await testInValidQRWithActualFormat(mockProfileRepository, tester);
  });

  testWidgets('Scan a valid QR', (WidgetTester tester) async {
    await testScanActualQR(tester);
  });

  testWidgets('Toggle torch', (WidgetTester tester) async {
    await testTorch(tester, mockProfileRepository);
  });

  testWidgets('Flip camera front and back', (WidgetTester tester) async {
    await testFlipCamera(tester, mockProfileRepository);
  });

  testWidgets(
      'Click on upload from gallery and check method call happening or not',
      (WidgetTester tester) async {
    await testQrUploadFromGallery(tester, mockProfileRepository);
  });
}

Future<void> testQrUploadFromGallery(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  //Arrange
  final mockImagePicker = MockImagePicker();
  when(mockImagePicker.pickImage(source: ImageSource.gallery)).thenAnswer(
    (_) async => XFile('fake_path/to/qr_image.png'),
  );

  //Define test widget
  await tester
      .pumpWidget(ParentWidget.getParentWidget(SelfRegisterQrscannerWidget(
    profileRepository: mockProfileRepository,
  )));

  // Act: Click to upload image from gallery
  await tester.tap(find.byKey(Key('UploadFromGallery')));
  await tester.pumpAndSettle();
}

Future<void> testFlipCamera(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  //Arrange
  final mockController = MockQRViewController();
  when(mockController.flipCamera()).thenAnswer((_) async => CameraFacing.front);

  //Define test widget
  await tester
      .pumpWidget(ParentWidget.getParentWidget(SelfRegisterQrscannerWidget(
    profileRepository: mockProfileRepository,
  )));
  await tester.pumpAndSettle();
  final SelfRegisterQrscannerWidgetState state =
      await tester.state(find.byType(SelfRegisterQrscannerWidget));
  state.qrViewController = mockController;

  // Act: Tap on camera icon to flip
  await tester.tap(find.byKey(Key('CameraIcon')));
  await tester.pumpAndSettle();

  // Assert: Check that camera flip called
  verify(mockController.flipCamera()).called(1);
}

Future<void> testTorch(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  //Arrange
  final mockController = MockQRViewController();

  //Define test widget
  await tester
      .pumpWidget(ParentWidget.getParentWidget(SelfRegisterQrscannerWidget(
    profileRepository: mockProfileRepository,
  )));
  await tester.pumpAndSettle();
  final SelfRegisterQrscannerWidgetState state =
      await tester.state(find.byType(SelfRegisterQrscannerWidget));
  state.qrViewController = mockController;

  // Act: Tap on torch to turn on
  await turnOnTorch(tester, state);

  // Act: Tap on torch to turn off
  await turnOffTorch(tester, state);

  // Act: Tap on torch to turn on
  await turnOnTorch(tester, state);
}

Future<void> testScanActualQR(WidgetTester tester) async {
  //Arrange

  final mockProfileRepository = MockProfileRepository();
  final mockController = MockQRViewController();
  String link = '${ApiUrl.baseUrl}/crp/123/123456789';

  // Simulate QR output
  simulateQrOutput(mockController, link);
  checkLinkValidity(mockProfileRepository, link, EnglishLang.linkActiveMessage);

  //Define test widget
  await tester.pumpWidget(ParentWidget.getParentWidget(
      SelfRegisterQrscannerWidget(profileRepository: mockProfileRepository)));
  await tester.pumpAndSettle();

  // Act: Simulate QRView creation
  final qrViewWidget = find.byType(QRView).evaluate().first.widget as QRView;
  qrViewWidget.onQRViewCreated(mockController);

  await tester.pumpAndSettle();
}

Future<void> testInValidQRWithActualFormat(
    MockProfileRepository mockProfileRepository, WidgetTester tester) async {
  //Arrange
  final mockController = MockQRViewController();
  String link = '${ApiUrl.baseUrl}/crp/123/123456789';

  simulateQrOutput(mockController, link);
  checkLinkValidity(
      mockProfileRepository, link, EnglishLang.linkUniquecodeInactive);
  //Define test widget
  await tester
      .pumpWidget(ParentWidget.getParentWidget(SelfRegisterQrscannerWidget(
    profileRepository: mockProfileRepository,
  )));
  await tester.pumpAndSettle();

  // Act: Simulate QRView creation
  final qrViewWidget = find.byType(QRView).evaluate().first.widget as QRView;
  qrViewWidget.onQRViewCreated(mockController);

  await tester.pumpAndSettle();

  // Assert: Check that the bottom sheet with support message is shown
  expect(find.byKey(Key('IvalidLinkMeassage')), findsOneWidget);
}

Future<void> testInvalidQRScanAndReset(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  //Arrange
  final mockController = MockQRViewController();
  String link = 'https://test.com/crp/123/123456789';

  simulateQrOutput(mockController, link);
  //Define test widget
  await tester
      .pumpWidget(ParentWidget.getParentWidget(SelfRegisterQrscannerWidget(
    profileRepository: mockProfileRepository,
  )));
  await tester.pumpAndSettle();

  // Act: Simulate QRView creation
  final qrViewWidget = find.byType(QRView).evaluate().first.widget as QRView;
  qrViewWidget.onQRViewCreated(mockController);

  await tester.pumpAndSettle();

  // Assert: Check that the error dialog is shown
  expect(find.byKey(Key('errorDialg')), findsOneWidget);

  // Tap on scan again
  await clickToScanAgain(tester);

  // Assert: Check that the error dialog is shown
  expect(find.byKey(Key('errorDialg')), findsNothing);
}

Future<void> testInvalidQR(
    WidgetTester tester, MockProfileRepository mockProfileRepository) async {
  //Arrange
  final mockController = MockQRViewController();
  String link = 'https://test.com/crp/123/123456789';

  simulateQrOutput(mockController, link);
  //Define test widget
  await tester
      .pumpWidget(ParentWidget.getParentWidget(SelfRegisterQrscannerWidget(
    profileRepository: mockProfileRepository,
  )));
  await tester.pumpAndSettle();

  // Act: Simulate QRView creation
  final qrViewWidget = find.byType(QRView).evaluate().first.widget as QRView;
  qrViewWidget.onQRViewCreated(mockController);

  await tester.pumpAndSettle();

  // Assert: Check that the error dialog is shown
  expect(find.byKey(Key('errorDialg')), findsOneWidget);
}

Future<void> clickToScanAgain(WidgetTester tester) async {
  await tester.tap(find.byKey(Key('reset scanner')));
  await tester.pumpAndSettle();
}

Future<void> turnOffTorch(
    WidgetTester tester, SelfRegisterQrscannerWidgetState state) async {
  await tester.tap(find.byKey(Key('TorchIcon')));
  await tester.pumpAndSettle();

  // Assert: Check that flash is off
  expect(state.isFlashOn, isFalse);
}

Future<void> turnOnTorch(
    WidgetTester tester, SelfRegisterQrscannerWidgetState state) async {
  // Act: Tap on torch to turn on
  await tester.tap(find.byKey(Key('TorchIcon')));
  await tester.pumpAndSettle();

  // Assert: Check that flash is on
  expect(state.isFlashOn, isTrue);
}

void simulateQrOutput(MockQRViewController mockController, String link) {
  when(mockController.scannedDataStream).thenAnswer(
      (_) => Stream.value(Barcode(link, BarcodeFormat.qrcode, [1, 2, 3])));
}

void checkLinkValidity(
    MockProfileRepository mockProfileRepository, String link, String result) {
  when(mockProfileRepository.getRegisterLinkValidated(link))
      .thenAnswer((_) async => result);
}
