import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:scan/scan.dart' show Scan, ScanController;

import '../../../constants/index.dart';
import '../../../localization/index.dart';
import '../../../models/index.dart';
import '../../../respositories/index.dart';
import '../../../util/index.dart';
import '../_scanner/widget/qr_error_dialog.dart';

class SelfRegisterQrscannerWidget extends StatefulWidget {
  final ProfileRepository profileRepository;

  SelfRegisterQrscannerWidget({super.key, ProfileRepository? profileRepository})
      : profileRepository = profileRepository ?? ProfileRepository();
  @override
  State<SelfRegisterQrscannerWidget> createState() =>
      SelfRegisterQrscannerWidgetState();
}

class SelfRegisterQrscannerWidgetState
    extends State<SelfRegisterQrscannerWidget> {
  QRViewController? qrViewController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool errorDialogShown = false;
  final ImagePicker _picker = ImagePicker();
  ScanController controller = ScanController();
  bool isFlashOn = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 350.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            key: Key('SelfRegisterQRBack'),
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context)!.mRegisterScanQRToRegister,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: AppColors.greys87),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            // To ensure the Scanner view is properly sizes after rotation
            // we need to listen for Flutter SizeChanged notification and update controller
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                  borderColor: AppColors.negativeLight,
                  borderRadius: 10,
                  borderLength: 50,
                  borderWidth: 10,
                  cutOutSize: scanArea),
              onPermissionSet: (ctrl, p) =>
                  (BuildContext context, QRViewController ctrl, bool p) {
                log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
                if (!p) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('no Permission')),
                  );
                }
              },
            ),
          ),
          Positioned(
              bottom: 1.0.sh / 4.3,
              left: 0,
              right: 0,
              child: InkWell(
                key: Key('UploadFromGallery'),
                onTap: () async {
                  await pickImage();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 24.w,
                      color: AppColors.appBarBackground,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                        AppLocalizations.of(context)!
                            .mSelfReistrationUploadFromGallery,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall!
                            .copyWith(fontSize: 14))
                  ],
                ),
              )),
          Positioned(
            bottom: 60,
            right: 40,
            child: Row(
              children: [
                InkWell(
                    key: Key('TorchIcon'),
                    onTap: () => toggleTorch(),
                    child: Icon(
                      isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: AppColors.appBarBackground,
                    )),
                SizedBox(width: 24),
                InkWell(
                    key: Key('CameraIcon'),
                    onTap: () => toggleCamera(),
                    child: const Icon(Icons.flip_camera_android,
                        color: AppColors.appBarBackground)),
              ],
            ),
          )
          // showBottomSheet(context, ""),
        ],
      ),
    );
  }

  bool _isValidQR(String code) {
    final regex = RegExpressions.registrationLink;
    return (regex.hasMatch(code) && code.startsWith(ApiUrl.baseUrl));
  }

  void showErrorDialog() {
    errorDialogShown
        ? const SizedBox.shrink()
        : showDialog(
            barrierDismissible: false,
            context: context,
            builder: (contxt) => QrErrorDialog(
                  key: Key('errorDialg'),
                  contxt: context,
                  alertDialogContext: contxt,
                  message: AppLocalizations.of(context)!.mRegisterScanCorrectQR,
                  resetError: () => resetError(),
                ));
  }

  void setError() {
    errorDialogShown = true;
    qrViewController?.stopCamera();
  }

  void resetError() {
    errorDialogShown = false;
    if (Platform.isAndroid) {
      qrViewController?.pauseCamera();
    }
    qrViewController?.resumeCamera();
    setState(() {});
  }

  void toggleCamera() {
    if (qrViewController != null) {
      setState(() {
        qrViewController!.flipCamera();
      });
    }
  }

  void toggleTorch() {
    if (qrViewController != null) {
      setState(() {
        qrViewController!.toggleFlash();
        isFlashOn = !isFlashOn;
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    qrViewController = controller;

    controller.scannedDataStream.listen((barcode) async {
      if (_isProcessing || barcode.code == null) return;

      _isProcessing = true;

      try {
        // Pause camera immediately
        await controller.pauseCamera();

        if (_isValidQR(barcode.code!)) {
          String linkValidationMessage =
              await ProfileRepository().getRegisterLinkValidated(barcode.code!);

          if (linkValidationMessage.toLowerCase() ==
              EnglishLang.linkActiveMessage.toLowerCase()) {
            String? orgId = Helper.extractOrgIdFromString(barcode.code!);
            if (orgId != null) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppUrl.registrationDetails,
                ModalRoute.withName(AppUrl.selfRegister),
                arguments: RegistrationLinkModel(
                  orgId: orgId,
                  link: barcode.code,
                ),
              );
            }
          } else {
            await Helper.verifyLinkAndShowMessage(
                linkValidationMessage, context);
          }
        } else {
          showErrorDialog();
          setError();
        }
      } catch (e) {
        showErrorDialog();
        setError();
      } finally {
        await controller.resumeCamera();
        _isProcessing = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? result = await Scan.parse(pickedFile.path);
      print(result);
      if (result != null && _isValidQR(result)) {
        String linkValidationMessage =
            await ProfileRepository().getRegisterLinkValidated(result);
        if (linkValidationMessage.toLowerCase() ==
            EnglishLang.linkActiveMessage.toLowerCase()) {
          String? orgId = Helper.extractOrgIdFromString(result);
          if (orgId != null) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                AppUrl.registrationDetails,
                ModalRoute.withName(AppUrl.selfRegister),
                arguments: RegistrationLinkModel(orgId: orgId, link: result));
          }
        } else {
          Helper.verifyLinkAndShowMessage(linkValidationMessage, context);
        }
      } else {
        showErrorDialog();
        setError();
      }
    }
  }

  // Scan QR code from image
}
