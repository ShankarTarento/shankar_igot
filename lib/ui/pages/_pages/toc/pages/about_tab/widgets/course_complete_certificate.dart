import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/course_status_model.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/certificate_competency_subtheme.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart' as Webview;

import '../../../../../../../util/telemetry_repository.dart';

class CourseCompleteCertificate extends StatefulWidget {
  final Course courseInfo;
  final List<CompetencyPassbook>? competencies;
  final String? certificate;
  final CourseStatus? courseStatus;
  final bool isCertificateProvided;
  const CourseCompleteCertificate(
      {Key? key,
      required this.courseInfo,
      this.certificate,
      this.competencies,
      this.isCertificateProvided = false,
      this.courseStatus})
      : super(key: key);

  @override
  State<CourseCompleteCertificate> createState() =>
      _CourseCompleteCertificateState();
}

class _CourseCompleteCertificateState extends State<CourseCompleteCertificate> {
  bool isDownloadingToSave = false;
  late WebViewController _webViewController;

  @override
  void initState() {
    if (widget.certificate != null) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              double imageWidth = MediaQuery.of(context).size.width * 2;
              _webViewController.runJavaScript('''
            document.querySelector("svg").setAttribute("width", "$imageWidth");
            document.querySelector("svg").setAttribute("height", "500px");
          ''');
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.certificate!));
    }
    super.initState();
  }

  bool isDownloaded = false;
  String? certificatePrintUri;
  var certificate;

  @override
  Widget build(BuildContext context) {
    final double imageWidth = MediaQuery.of(context).size.width * 2.4;
    final double imageHeight = 120;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0).r,
        child: Container(
          padding: EdgeInsets.only(top: 20, bottom: 16).r,
          width: 1.sw,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/img/certificate_background.png'),
              fit: BoxFit.fill, // or BoxFit.fill, BoxFit.contain, etc.
            ),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 66.0, bottom: 30).w,
                  child: Text(
                    AppLocalizations.of(context)!.mStaticCertificateEarned,
                    style: GoogleFonts.lato(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp),
                  ),
                ),
                ClipPath(
                  clipper: TocBottomCornerClipper(),
                  child: Container(
                    margin: const EdgeInsets.only(left: 35.0, right: 35).r,
                    padding:
                        EdgeInsets.only(top: 1, left: 1, right: 1, bottom: 0).r,
                    decoration: BoxDecoration(
                      color: AppColors.grey16,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(9),
                        topRight: Radius.circular(9),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ).r,
                    ),
                    child: ClipPath(
                      clipper: TocBottomCornerClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(9),
                              topRight: Radius.circular(9),
                            ).r,
                            color: AppColors.appBarBackground),
                        child: ClipPath(
                          clipper: TocBottomCornerClipper(),
                          child: Container(
                            margin: EdgeInsets.only(left: 6, right: 6).r,
                            padding: EdgeInsets.all(16).r,
                            decoration: DottedDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(9),
                                topRight: Radius.circular(9),
                              ).r,
                              strokeWidth: 2.w,
                              shape: Shape.line,
                              linePosition: LinePosition.bottom,
                              color: AppColors.grey16,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 1.sw / 1.9,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.courseInfo.name,
                                            maxLines: 2,
                                            style: GoogleFonts.lato(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12.sp),
                                          ),
                                          widget.courseInfo.completedOn != null
                                              ? SizedBox(height: 4.w)
                                              : SizedBox.shrink(),
                                          widget.courseInfo.completedOn != null
                                              ? Text(
                                                  '${AppLocalizations.of(context)!.mStaticYouCompletedThisCourseOn(widget.courseInfo.courseCategory)} ${DateTimeHelper.getDateTimeInFormat("${DateTime.fromMillisecondsSinceEpoch(widget.courseInfo.completedOn!)}", desiredDateFormat: IntentType.dateFormat2)}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall!
                                                      .copyWith(
                                                        fontSize: 9.sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )
                                              : SizedBox.shrink()
                                        ],
                                      ),
                                    ),
                                    widget.courseInfo.completedOn == null
                                        ? SizedBox.shrink()
                                        : isDownloadingToSave && isDownloaded
                                            ? SizedBox(
                                                height: 20.w,
                                                width: 20.w,
                                                child: PageLoader(
                                                  strokeWidth: 3,
                                                ))
                                            : Visibility(
                                                visible: isDownloaded,
                                                child: IconButton(
                                                  padding:
                                                      EdgeInsets.only(right: 0),
                                                  alignment:
                                                      Alignment.centerRight,
                                                  onPressed: downloadClicked,
                                                  icon: Icon(
                                                    Icons.arrow_downward,
                                                    color: AppColors.darkBlue,
                                                    size: 24.sp,
                                                  ),
                                                ),
                                              ),
                                  ],
                                ),
                                SizedBox(height: 10.w),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 2.4,
                                  height: imageHeight,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: widget.isCertificateProvided
                                      ? isDownloaded
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: showCertInWebview(
                                                  context, imageWidth))
                                          : Stack(
                                              children: [
                                                Container(
                                                  height: imageHeight,
                                                  width: imageWidth,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                            'assets/img/default_certificate.png',
                                                          ),
                                                          fit: BoxFit.fill,
                                                          opacity: 0.3)),
                                                ),
                                                isDownloadingToSave
                                                    ? Center(
                                                        child: PageLoader(
                                                          strokeWidth: 3.w,
                                                        ),
                                                      )
                                                    : InkWell(
                                                        child: Center(
                                                          child: CircleAvatar(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .black,
                                                              child: Icon(
                                                                Icons.download,
                                                                color: AppColors
                                                                    .appBarBackground,
                                                              )),
                                                        ),
                                                        onTap: downloadClicked,
                                                      )
                                              ],
                                            )
                                      : Stack(
                                          children: [
                                            Image.asset(
                                              'assets/img/default_certificate.png',
                                              alignment: Alignment.center,
                                              height: imageHeight,
                                              width: imageWidth,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              height: imageHeight,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.5,
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: AppColors.greys60
                                                    .withValues(alpha: 0.85),
                                                borderRadius:
                                                    BorderRadius.circular(8).r,
                                              ),
                                              child: Center(
                                                  child: RichText(
                                                text: TextSpan(
                                                  style: GoogleFonts.lato(
                                                    color: AppColors
                                                        .appBarBackground,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12.sp,
                                                    letterSpacing: 0.25,
                                                    height: 1.5.w,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .mStaticWaitingForCertificateGeneration,
                                                    ),
                                                    TextSpan(
                                                      text: ' $supportEmail',
                                                      style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        color: AppColors
                                                            .customBlue,
                                                      ),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () async {
                                                              Helper.doLaunchUrl(
                                                                  url:
                                                                      "mailto:$supportEmail");
                                                            },
                                                    ),
                                                  ],
                                                ),
                                              )),
                                            ),
                                          ],
                                        ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                widget.competencies != null && widget.competencies!.isNotEmpty
                    ? ClipPath(
                        clipper: TocTopCornerClipper(),
                        child: Container(
                          margin:
                              const EdgeInsets.only(left: 35.0, right: 35).r,
                          width: 1.sw,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(9),
                              bottomRight: Radius.circular(9),
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ).r,
                            color: AppColors.grey16,
                          ),
                          padding: EdgeInsets.only(
                                  top: 0, left: 1, right: 1, bottom: 1)
                              .r,
                          child: ClipPath(
                            clipper: TocTopCornerClipper(),
                            child: Container(
                              width: 1.sw,
                              padding: EdgeInsets.all(12).r,
                              decoration: BoxDecoration(
                                color: AppColors.appBarBackground,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(9),
                                  bottomRight: Radius.circular(9),
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ).r,
                              ),
                              child: CertificateCompetencySubtheme(
                                  competencySubthemes: widget.competencies!),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showCertInWebview(BuildContext context, double imageWidth) {
    String resizeCertJS =
        'document.querySelector("svg").setAttribute("width", "$imageWidth");'
        'document.querySelector("svg").setAttribute("height", "500px");';
    return Webview.WebViewWidget(
      controller: Webview.WebViewController()
        ..setJavaScriptMode(Webview.JavaScriptMode.unrestricted)
        ..setNavigationDelegate(Webview.NavigationDelegate(
          onNavigationRequest: (Webview.NavigationRequest request) {
            return Webview.NavigationDecision.navigate;
          },
          onPageFinished: (String url) async {
            _webViewController.runJavaScript(resizeCertJS);
          },
        ))
        ..loadRequest(Uri.parse(
          certificatePrintUri ?? '',
        )),
    );
  }

  void downloadClicked() async {
    try {
      _generateInteractTelemetryData(
          (widget.courseStatus != null
              ? widget.courseStatus!.issuedCertificates![0]["identifier"]
              : widget.courseInfo.issuedCertificates[0]["identifier"]),
          edataId: TelemetryIdentifier.downloadCertificate,
          subType: TelemetrySubType.certificate);
    } catch (e) {
      debugPrint('Error generating telemetry data: $e');
    }
    try {
      await _saveAsPdf(widget.courseInfo.name);
    } catch (e) {
      debugPrint('Error saving certificate as PDF: $e');
    }
  }

  Future<void> _saveAsPdf(String courseName) async {
    courseName = courseName.replaceAll(RegExpressions.unicodeSpecialChar, '');
    if (courseName.length > 150) {
      courseName = courseName.substring(0, 100);
    }
    String fileName =
        '$courseName-' + DateTime.now().millisecondsSinceEpoch.toString();

    String path = await Helper.getDownloadPath();
    await Directory('$path').create(recursive: true);

    var certificateType = CertificateType.pdf;

    try {
      LearnService learnService = LearnService();
      if (certificatePrintUri == null) {
        String? certificateId = widget.courseStatus != null
            ? widget.courseStatus!.issuedCertificates![0]["identifier"]
            : widget.courseInfo.issuedCertificates[0]["identifier"];

        if (PrimaryCategory.dynamicCertProgramCategoriesList
            .contains(widget.courseInfo.courseCategory.toLowerCase())) {
          certificatePrintUri =
              await learnService.getCourseCompletionDynamicCertificate(
                  widget.courseInfo.id, widget.courseInfo.batchId ?? '');
        } else {
          if ((certificateId ?? '').isNotEmpty) {
            certificatePrintUri = await learnService
                .getCourseCompletionCertificate(certificateId!);
          }
        }
      }
      if (certificatePrintUri != null) {
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
          if (certificate == null) {
            certificate = await learnService.downloadCompletionCertificate(
                certificatePrintUri ?? "",
                outputType: certificateType);
          }

          await File('$path/$fileName.$certificateType')
              .writeAsBytes(certificate);

          setState(() {
            isDownloadingToSave = false;
            isDownloaded = true;
          });
          displayDialog(true, '$path/$fileName.$certificateType', 'Success');
        } else {
          false;
        }
      } else {
        displayDialog(false, '', 'Download Failed');
        Helper.showSnackBarMessage(
            context: context,
            text:
                "${AppLocalizations.of(context)?.mStaticCertificateDownloadError}",
            bgColor: AppColors.negativeLight);
      }
    } catch (e) {
      Helper.showSnackBarMessage(
          context: context,
          text:
              "${AppLocalizations.of(context)?.mStaticCertificateDownloadError}",
          bgColor: AppColors.negativeLight);
      setState(() {
        isDownloadingToSave = false;
      });
    } finally {
      setState(() {
        isDownloadingToSave = false;
      });
    }
  }

  Future<bool?> displayDialog(
      bool isSuccess, String filePath, String message) async {
    return showModalBottomSheet(
        isScrollControlled: true,
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
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                            ),
                      ),
                    ),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 15).r,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: roundedButton(
                            AppLocalizations.of(context)!.mStaticClose,
                            AppColors.appBarBackground,
                            AppColors.customBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Future<dynamic> openFile(filePath) async {
    OpenResult openRes = await OpenFile.open(filePath);
    if (openRes.type == ResultType.done) {
    } else {
      Helper.showSnackBarMessage(
          context: context,
          text: openRes.message,
          bgColor: AppColors.negativeLight);
    }
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
        style: GoogleFonts.montserrat(
            decoration: TextDecoration.none,
            color: textColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500),
      ),
    );
    return loginBtn;
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '', edataId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: (TelemetryPageIdentifier.courseDetailsPageId +
            '_' +
            widget.courseInfo.id),
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.learn,
        objectType: subType,
        clickId: edataId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
