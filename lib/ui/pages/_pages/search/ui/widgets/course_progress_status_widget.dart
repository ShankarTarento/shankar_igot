import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../respositories/index.dart';
import '../../../../../../util/index.dart';
import '../../../../../widgets/index.dart';

class CourseProgressStatusWidget extends StatefulWidget {
  final double completionPercentage;
  final List<dynamic> issuedCertificates;
  final String name;
  final String? courseId;
  final String? courseCategory;
  final String? batchId;
  final LearnRepository learnRepository;

  CourseProgressStatusWidget(
      {super.key,
      required this.completionPercentage,
      required this.issuedCertificates,
      required this.name,
      this.courseId,
      this.courseCategory,
      this.batchId,
      LearnRepository? learnRepository})
      : learnRepository = learnRepository ?? LearnRepository();

  @override
  State<CourseProgressStatusWidget> createState() =>
      _CourseProgressStatusWidgetState();
}

class _CourseProgressStatusWidgetState
    extends State<CourseProgressStatusWidget> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return widget.completionPercentage < 100
        ? Container(
            width: 0.3.sw,
            margin: EdgeInsets.only(top: 16).r,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4).r,
            decoration: BoxDecoration(
                color: AppColors.darkBlue16,
                borderRadius: BorderRadius.circular(6).r),
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context)!.mSearchInprogress,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontSize: 10.sp),
            ))
        : InkWell(
            onTap: () async {
              if (isLoading) return;
              setState(() {
                isLoading = true;
              });
              String? certificateId = widget.issuedCertificates.length > 0
                  ? (widget.issuedCertificates.length > 1
                      ? widget.issuedCertificates[1]['identifier']
                      : widget.issuedCertificates[0]['identifier'])
                  : null;
              String? base64CertificateImage =
                  await _getCompletionCertificate(certificateId);
              if (base64CertificateImage != null) {
                await _saveAsPdf(base64CertificateImage);
              } else {
                isLoading = false;
                Helper.showSnackBarMessage(
                    context: context,
                    text:
                        "${AppLocalizations.of(context)?.mStaticCertificateDownloadError}",
                    bgColor: AppColors.negativeLight);
              }
            },
            child: Container(
                width: 0.3.sw,
                margin: EdgeInsets.only(top: 16).r,
                padding: EdgeInsets.all(4).r,
                decoration: BoxDecoration(
                    color: AppColors.positiveLight.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6).r),
                child: isLoading
                    ? SizedBox(
                        height: 24.w,
                        width: 24.w,
                        child: PageLoader(
                          strokeWidth: 2.0,
                          isLightTheme: false,
                        ))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_download_outlined,
                            color: AppColors.positiveLight,
                            size: 20.sp,
                          ),
                          Container(
                            width: 0.15.sw,
                            margin: EdgeInsets.only(left: 4).r,
                            child: Text(
                              Helper.capitalizeEachWordFirstCharacter(
                                  AppLocalizations.of(context)!
                                      .mStaticDownloadCertificate),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                      fontSize: 10.sp,
                                      color: AppColors.positiveLight),
                            ),
                          ),
                        ],
                      )),
          );
  }

  Future<String?> _getCompletionCertificate(String? certificateId) async {
    final isInDynamicCertProgramCategoriesList = PrimaryCategory
        .dynamicCertProgramCategoriesList
        .contains((widget.courseCategory ?? '').toLowerCase());

    String? certificate;

    if (isInDynamicCertProgramCategoriesList) {
      certificate = await widget.learnRepository
          .getCourseCompletionDynamicCertificate(
              widget.courseId ?? '', widget.batchId ?? '');
    } else if (certificateId != null) {
      certificate = await widget.learnRepository
          .getCourseCompletionCertificate(certificateId);
    }
    return certificate;
  }

  Future<void> _saveAsPdf(String base64CertificateImage) async {
    String nameOfCourse = widget.name;
    nameOfCourse = nameOfCourse.replaceAll(RegExpressions.specialChar, '');
    if (nameOfCourse.length > 20) {
      nameOfCourse = nameOfCourse..substring(0, 20);
    }
    String fileName =
        '$nameOfCourse-' + DateTime.now().millisecondsSinceEpoch.toString();

    String path = await Helper.getDownloadPath();
    await Directory('$path').create(recursive: true);

    try {
      Permission _permision = Permission.storage;
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          _permision = Permission.photos;
        }
      }

      if (await Helper.requestPermission(_permision)) {
        final certificate = await widget.learnRepository
            .downloadCompletionCertificate(base64CertificateImage);

        await File('$path/$fileName.pdf').writeAsBytes(certificate);

        displayDialog(true, '$path/$fileName.pdf', 'Success');
      }
    } catch (e) {
      Helper.showSnackBarMessage(
          context: context,
          text:
              "${AppLocalizations.of(context)?.mStaticCertificateDownloadError}",
          bgColor: AppColors.negativeLight);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future displayDialog(bool isSuccess, String filePath, String message) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (cntxt) => Stack(
              children: [
                Positioned(
                    child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.all(20).r,
                          width: double.infinity.w,
                          height: filePath != '' ? 190.0.w : 140.w,
                          color: AppColors.appBarBackground,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 15)
                                          .r,
                                  child: Text(
                                    isSuccess
                                        ? AppLocalizations.of(context)!
                                            .mStaticFileDownloadingCompleted
                                        : message,
                                    style: GoogleFonts.montserrat(
                                        decoration: TextDecoration.none,
                                        color: AppColors.greys87,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400),
                                  )),
                              filePath != ''
                                  ? Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                                top: 5, bottom: 10)
                                            .r,
                                        child: GestureDetector(
                                          onTap: () => _openFile(filePath),
                                          child: roundedButton(
                                            AppLocalizations.of(context)!
                                                .mStaticOpen,
                                            AppColors.darkBlue,
                                            AppColors.appBarBackground,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(),
                              // Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 15).r,
                                child: GestureDetector(
                                  onTap: () => Navigator.of(cntxt).pop(false),
                                  child: roundedButton(
                                      AppLocalizations.of(context)!
                                          .mCommonClose,
                                      AppColors.appBarBackground,
                                      AppColors.customBlue),
                                ),
                              ),
                            ],
                          ),
                        )))
              ],
            ));
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = Container(
      padding: EdgeInsets.all(10).r,
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0)).r,
        border: bgColor == AppColors.appBarBackground
            ? Border.all(color: AppColors.grey40)
            : Border.all(color: bgColor),
      ),
      child: Text(
        buttonLabel,
        style: GoogleFonts.montserrat(
            decoration: TextDecoration.none,
            color: textColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500),
      ),
    );
    return loginBtn;
  }

  Future<dynamic> _openFile(filePath) async {
    await OpenFile.open(filePath);
  }
}
