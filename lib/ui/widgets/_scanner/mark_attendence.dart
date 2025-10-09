import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/qr_scanner_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
// import 'package:karmayogi_mobile/ui/widgets/_scanner/qr_scanner.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import 'widget/attendence_marked_widget.dart';
import 'widget/flash_light_widget.dart';
import 'widget/qr_error_dialog.dart';

class MarkAttendence extends StatefulWidget {
  final String? id;
  final String courseId;
  final List<Map<String, dynamic>> sessionIds;
  final String batchId;
  final Function() onAttendanceMarked;

  const MarkAttendence({
    Key? key,
    this.id,
    required this.courseId,
    required this.sessionIds,
    required this.batchId,
    required this.onAttendanceMarked,
  }) : super(key: key);

  @override
  State<MarkAttendence> createState() => _MarkAttendenceState();
}

class _MarkAttendenceState extends State<MarkAttendence> {
  bool isAttendenceMarked = false;
  bool errorDialogShown = false;
  late ScannerModel model;
  bool attendanceStatus = false;
  late Barcode result;
  QRViewController? _qrViewController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  ValueNotifier<bool> _showFlashLightStatus = ValueNotifier(false);

  // MobileScannerController cameraController = MobileScannerController(
  //   detectionSpeed: DetectionSpeed.normal,
  //   facing: CameraFacing.back,
  //   torchEnabled: false,
  // );
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _qrViewController?.pauseCamera();
    }
    _qrViewController?.resumeCamera();
    _setFlashLightStatus();
  }

  _setFlashLightStatus() async {
    final status = await _qrViewController!.getFlashStatus();
    _showFlashLightStatus.value = status!;
  }

  bool isValidQR(String sessionId, String batchId) {
    return (widget.sessionIds
            .any((session) => session.values.contains(sessionId)) &&
        batchId == widget.batchId);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> dispose() async {
    await _qrViewController?.stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppLocalizations.of(context)!.mStaticScanAndMarkAttendence,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(letterSpacing: 0.12.r, height: 1.5.w),
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
              onQRViewCreated: (QRViewController controller) {
                setState(() {
                  _qrViewController = controller;
                });
                controller.scannedDataStream.listen((barcode) async {
                  setState(() {
                    result = barcode;
                  });
                  try {
                    // final List<Barcode> barcodes = capture.barcodes;
                    model = scannerModelFromJson(barcode.code ?? '');
                    if (isValidQR(model.sessionId, model.batchId)) {
                      attendanceStatus = false;
                      widget.sessionIds.forEach((session) {
                        if (session['sessionId'] == model.sessionId &&
                            session['status']) {
                          attendanceStatus = true;
                        }
                      });
                      if (!attendanceStatus) {
                        isAttendenceMarked = await _updateContentProgress();
                      } else {
                        isAttendenceMarked = true;
                      }
                      setState(() {});
                    } else {
                      showErrorDialog();
                      setError();
                    }
                  } catch (e) {
                    showErrorDialog();
                    setError();
                  }
                });
              },
              overlay: QrScannerOverlayShape(
                  borderColor: AppColors.mandatoryRed,
                  borderRadius: 10,
                  borderLength: 30,
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
            // child: MobileScanner(
            //   overlay: Stack(
            //     children: [
            //       Container(
            //         decoration: ShapeDecoration(
            //           shape: QrScannerOverlayShape(
            //             borderColor: AppColors.primaryThree,
            //             borderRadius: 33,
            //             borderLength: 120,
            //             borderWidth: 8,
            //             cutOutSize: 220,
            //           ),
            //         ),
            //       )
            //     ],
            //   ),
            //   controller: _qrViewController,
            //   onDetect: (capture) async {
            //     try {
            //       final List<Barcode> barcodes = capture.barcodes;
            //       for (final barcode in barcodes) {
            //         model = scannerModelFromJson(barcode.code);
            //         if (isValidQR(model.sessionId, model.batchId)) {
            //           attendanceStatus = false;
            //           widget.sessionIds.forEach((session) {
            //             if (session['sessionId'] == model.sessionId &&
            //                 session['status']) {
            //               attendanceStatus = true;
            //             }
            //           });
            //           if (!attendanceStatus) {
            //             isAttendenceMarked = await _updateContentProgress();
            //           } else {
            //             isAttendenceMarked = true;
            //           }
            //           setState(() {});
            //         } else {
            //           showErrorDialog();
            //           setError();
            //         }
            //       }
            //     } catch (e) {
            //       showErrorDialog();
            //       setError();
            //     }
            //   },
            // ),
          ),
          showBottomSheet(context, ""),
        ],
      ),
    );
  }

  Widget showBottomSheet(BuildContext context, String submittedDateTime) {
    if (errorDialogShown) return const SizedBox.shrink();
    return Positioned(
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.appBarBackground,
            borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30), topRight: Radius.circular(30))
                .r,
          ),
          height: isAttendenceMarked ? 200.w : 80.w,
          width: 1.sw,
          child: isAttendenceMarked
              ? attendanceStatus
                  ? ShowMarkedAttendenceWidget(
                      message: AppLocalizations.of(context)!
                          .mStaticAttendanceAlreadyMarked,
                      dateAndTime: submittedDateTime,
                    )
                  : ShowMarkedAttendenceWidget(
                      message: AppLocalizations.of(context)!
                          .mStaticScannerSuccesfuly,
                      dateAndTime: submittedDateTime,
                    )
              : ValueListenableBuilder<bool>(
                  valueListenable: _showFlashLightStatus,
                  builder: (context, showFlashLightStatus, child) {
                    return ShowFlashLightWidget(showFlashLightStatus, () async {
                      await _qrViewController!.toggleFlash();
                    });
                  },
                ),
        ));
  }

  void showErrorDialog() {
    errorDialogShown
        ? const SizedBox.shrink()
        : showDialog(
            barrierDismissible: false,
            context: context,
            builder: (contxt) => QrErrorDialog(
                  contxt: context,
                  alertDialogContext: contxt,
                  message: AppLocalizations.of(context)!.mStaticInvalidQRDesc,
                  resetError: () => resetError,
                ));
  }

  void setError() {
    errorDialogShown = true;
    isAttendenceMarked = false;
    _qrViewController?.stopCamera();
  }

  void resetError() {
    errorDialogShown = false;
    isAttendenceMarked = false;
    if (Platform.isAndroid) {
      _qrViewController?.pauseCamera();
    }
    _qrViewController?.resumeCamera();
    setState(() {});
  }

  Future<bool> _updateContentProgress() async {
    final LearnService learnService = LearnService();
    String courseId = widget.courseId;
    String batchId = model.batchId;
    String contentId = model.sessionId;
    int status = 2;
    double completionPercentage = 100.0;
    var response = await learnService.markAttendance(
        courseId, batchId, contentId, status, completionPercentage);
    if (response['responseCode'] == 'OK') {
      widget.onAttendanceMarked();
    }
    return response['responseCode'] == 'OK';
  }
}
