import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../models/_arguments/index.dart';
import '../../../models/_models/competency_data_model.dart' as competencyTheme;
import '../../../util/helper.dart';
import '../../../util/telemetry_repository.dart';

class CompetencyPassbookCertificateCard extends StatefulWidget {
  final competencyTheme.CourseData courseInfo;
  final String? certificate;
  final bool isCertificateProvided;
  const CompetencyPassbookCertificateCard(
      {Key? key,
      required this.courseInfo,
      this.certificate,
      this.isCertificateProvided = false})
      : super(key: key);

  @override
  State<CompetencyPassbookCertificateCard> createState() =>
      _CompetencyPassbookCertificateCardState();
}

class _CompetencyPassbookCertificateCardState
    extends State<CompetencyPassbookCertificateCard> {
  final double leftPadding = 20.0.r;
  bool isDownloadingToSave = false;
  late WebViewController? _webViewController;
  bool isDownloaded = false;
  String? certificatePrintUri;
  var certificate;
  String? _previousCertificatePrintUri;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.greys)
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (WebResourceError error) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Error loading URL',
                          style: GoogleFonts.montserrat(
                            color: AppColors.greys87,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Error code: ${error.errorCode}\nDescription: ${error.description}',
                          style: GoogleFonts.montserrat(
                            color: AppColors.greys87,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ));

    if (widget.certificate != null) {
      _webViewController?.loadRequest(Uri.parse(widget.certificate!));
    }
  }

  @override
  void didUpdateWidget(covariant CompetencyPassbookCertificateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_previousCertificatePrintUri != certificatePrintUri &&
        certificatePrintUri != null) {
      _webViewController?.loadRequest(Uri.parse(certificatePrintUri!));
      _previousCertificatePrintUri = certificatePrintUri;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16).r,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppUrl.courseTocPage,
              arguments: CourseTocModel.fromJson(
                  {'courseId': widget.courseInfo.courseId}));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipPath(
              clipper: BottomCornerClipper(),
              child: Container(
                width: 1.sw,
                decoration: BoxDecoration(
                  color: AppColors.appBarBackground,
                  borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12))
                      .r,
                ),
                child: Container(
                  width: 1.sw,
                  padding: EdgeInsets.all(16).r,
                  decoration: DottedDecoration(
                    strokeWidth: 2,
                    shape: Shape.line,
                    linePosition: LinePosition.bottom,
                    color: AppColors.grey16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 0.65.sw,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitleBoldWidget(
                                  widget.courseInfo.courseName ?? '',
                                  maxLines: 2,
                                ),
                                widget.courseInfo.completedOn != null
                                    ? SizedBox(height: 4.w)
                                    : SizedBox.shrink(),
                                widget.courseInfo.completedOn != null
                                    ? TitleRegularGrey60(
                                        '${AppLocalizations.of(context)!.mProfileIssuedOn} ${DateTimeHelper.getDateTimeInFormat(widget.courseInfo.completedOn!, desiredDateFormat: 'MMM yyyy')}')
                                    : SizedBox.shrink()
                              ],
                            ),
                          ),
                          !widget.isCertificateProvided
                              ? SizedBox.shrink()
                              : isDownloadingToSave && isDownloaded
                                  ? SizedBox(
                                      height: 20.w,
                                      width: 20.w,
                                      child: PageLoader())
                                  : IconButton(
                                      padding: EdgeInsets.only(right: 0).r,
                                      alignment: Alignment.centerRight,
                                      onPressed: downloadClicked,
                                      icon: Icon(
                                        Icons.arrow_downward,
                                        color: AppColors.darkBlue,
                                        size: 24.sp,
                                      ))
                        ],
                      ),
                      SizedBox(height: 16.w),
                      Container(
                        width: double.infinity.w,
                        height: 210.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8).r),
                        child: widget.isCertificateProvided
                            ? isDownloaded
                                ? showCertInWebView()
                                : Stack(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 16).r,
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
                                                        AppColors.black,
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
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    width: double.maxFinite,
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.greys60
                                          .withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(8).r,
                                    ),
                                    child: Center(
                                        child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.lato(
                                          color: AppColors.appBarBackground,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                          letterSpacing: 0.25,
                                          height: 1.5.w,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: AppLocalizations.of(context)!
                                                .mStaticWaitingForCertificateGeneration,
                                          ),
                                          TextSpan(
                                            text: ' $supportEmail',
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                              color: AppColors.customBlue,
                                            ),
                                            recognizer: TapGestureRecognizer()
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
            ClipPath(
              clipper: TopCornerClipper(),
              child: Container(
                  width: 1.sw,
                  decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12))
                          .r),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 16).r,
                    child: CompetencyPassbookSubtheme(
                        competencySubthemes:
                            widget.courseInfo.courseSubthemes!),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget showCertInWebView() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _webViewController != null
            ? WebViewWidget(controller: _webViewController!)
            : SizedBox());
  }

  void downloadClicked() async {
    _generateInteractTelemetryData(widget.courseInfo.courseId ?? '',
        edataId: TelemetryIdentifier.downloadCertificate,
        subType: TelemetrySubType.certificate);
    try {
      await _saveAsPdf(widget.courseInfo.courseName ?? '');
    } catch (e) {
      print('Error: $e');
    }
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '', edataId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier:
            (TelemetryPageIdentifier.courseDetailsPageId + '_' + contentId),
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.learn,
        objectType: subType,
        clickId: edataId);
    await telemetryRepository.insertEvent(eventData: eventData);
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
        if (PrimaryCategory.dynamicCertProgramCategoriesList.contains(
            (widget.courseInfo.primaryCategory ?? '').toLowerCase())) {
          certificatePrintUri =
              await learnService.getCourseCompletionDynamicCertificate(
                  widget.courseInfo.courseId ?? '',
                  widget.courseInfo.batchId ?? '');
        } else {
          if ((widget.courseInfo.certificateId ?? '').isNotEmpty) {
            certificatePrintUri =
                await learnService.getCourseCompletionCertificate(
                    widget.courseInfo.certificateId!);
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

  Future displayDialog(bool isSuccess, String filePath, String message) async {
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
                          borderRadius: BorderRadius.all(Radius.circular(16)).r,
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
    await OpenFile.open(filePath);
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = Container(
      width: 1.sw - 50.w,
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
}
