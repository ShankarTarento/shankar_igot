import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';
import '../../../../../services/index.dart';
import '../../../../../util/helper.dart';
import '../../../../widgets/index.dart';
import '../../../index.dart';

class TocDownloadCertificateWidget extends StatefulWidget {
  TocDownloadCertificateWidget(
      {Key? key,
      required this.courseId,
      this.isPlayer = false,
      this.isExpanded = false,
      this.enrolledCourse})
      : super(key: key);
  final String courseId;
  final bool isPlayer, isExpanded;
  final Course? enrolledCourse;

  @override
  State<TocDownloadCertificateWidget> createState() =>
      _TocDownloadCertificateWidgetState();
}

class _TocDownloadCertificateWidgetState
    extends State<TocDownloadCertificateWidget> {
  bool isDownloadingToSave = false;
  String? certificateId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: getCertificateId(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null && snapshot.data != '') {
              return TextButton(
                onPressed: () async {
                  await saveAsPdf();
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0).r,
                      color: widget.isExpanded
                          ? AppColors.appBarBackground
                          : AppColors.darkBlue),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4).r,
                  child: isDownloadingToSave
                      ? SizedBox(
                          height: 20,
                          width: 80,
                          child: PageLoader(isLightTheme: widget.isExpanded))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.mStaticCertificates,
                              style: GoogleFonts.lato(
                                  height: 1.333.w,
                                  decoration: TextDecoration.none,
                                  color: widget.isExpanded
                                      ? AppColors.darkBlue
                                      : AppColors.appBarBackground,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.25),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_downward,
                              size: 16.sp,
                              color: widget.isExpanded
                                  ? AppColors.darkBlue
                                  : AppColors.appBarBackground,
                            )
                          ],
                        ),
                ),
              );
            } else {
              return LinearProgressIndicatorWidget(
                  value: 1, isExpnaded: widget.isExpanded, isCourse: true);
            }
          } else {
            return Center();
          }
        });
  }

  Future<bool?> displayDialog(
      bool isSuccess, String filePath, String message) async {
    return showModalBottomSheet(
        isScrollControlled: true,
        // useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8))
              .r,
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20).r,
                        height: 6.w,
                        width: 0.25.sw,
                        decoration: BoxDecoration(
                          color: AppColors.grey16,
                          borderRadius: BorderRadius.all(Radius.circular(16).r),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 15).r,
                        child: Text(
                          isSuccess
                              ? AppLocalizations.of(context)!
                                  .mStaticFileDownloadingCompleted
                              : message,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                decoration: TextDecoration.none,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                              ),
                        )),
                    filePath != ''
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 5, bottom: 10).r,
                            child: GestureDetector(
                              onTap: () => openFile(filePath),
                              child: roundedButton(
                                AppLocalizations.of(context)!.mStaticOpen,
                                AppColors.darkBlue,
                               AppColors.appBarBackground,
                              ),
                            ),
                          )
                        : Center(),
                    // Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 15).r,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: roundedButton(
                            AppLocalizations.of(context)!.mCommonClose,
                            AppColors.appBarBackground,
                            AppColors.customBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Future saveAsPdf() async {
    String cname =
        widget.enrolledCourse!.name.replaceAll(RegExpressions.specialChar, '');
    String fileName =
        '$cname-' + DateTime.now().millisecondsSinceEpoch.toString();

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
        setState(() {
          isDownloadingToSave = true;
        });

        final isInDynamicCertProgramCategoriesList = PrimaryCategory.dynamicCertProgramCategoriesList
            .contains((widget.enrolledCourse?.courseCategory??'').toLowerCase());

        var base64CertificateImage;

        if (isInDynamicCertProgramCategoriesList) {
          base64CertificateImage = await LearnService().getCourseCompletionDynamicCertificate(
              widget.enrolledCourse?.contentId??'', widget.enrolledCourse?.batchId ?? '');
        } else {
          if ((certificateId??'').isNotEmpty) {
            base64CertificateImage = await LearnService().getCourseCompletionCertificate(certificateId!);
          }
        }

        if (base64CertificateImage != null) {
          final certificate = await LearnService()
              .downloadCompletionCertificate(base64CertificateImage);

          await File('$path/$fileName.pdf').writeAsBytes(certificate);

          setState(() {
            isDownloadingToSave = false;
          });
          displayDialog(true, '$path/$fileName.pdf', 'Success');
        } else {
          Helper.showSnackBarMessage(
              context: context,
              text:
              "${AppLocalizations.of(context)?.mStaticCertificateDownloadError}",
              bgColor: AppColors.negativeLight);
        }
      } else {
        return false;
      }
    } catch (e) {} finally {
      setState(() {
        isDownloadingToSave = false;
      });
    }
  }

  Future<String> getCertificateId() async {
    if (widget.enrolledCourse != null) {
      List issuedCertificate = widget.enrolledCourse!.issuedCertificates;
      if (mounted) {
        if (widget.enrolledCourse!.batchId != null) {
          certificateId = issuedCertificate.length > 0
              ? (issuedCertificate.length > 1
                  ? issuedCertificate[1]['identifier']
                  : issuedCertificate[0]['identifier'])
              : null;
        }
      }
    }
    return certificateId ?? '';
  }

  Future<dynamic> openFile(filePath) async {
    await OpenFile.open(filePath);
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = Container(
      width: 1.sw - 50.w,
      padding: EdgeInsets.all(10).r,
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0).r),
        border: bgColor == AppColors.appBarBackground
            ? Border.all(color: AppColors.grey40)
            : Border.all(color: bgColor),
      ),
      child: Text(
        buttonLabel,
        style: Theme.of(context).textTheme.displaySmall!.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
              decoration: TextDecoration.none,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
      ),
    );
    return loginBtn;
  }
}
