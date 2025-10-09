import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/common_components/my_learning_card/download_complete_message.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/events_details_screenv2.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_v2.dart/widgets/my_learning_events/widgets/my_event_header.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import 'package:karmayogi_mobile/ui/widgets/_events/models/event_enrollment_list_model.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/share_certificate_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MyEventsCompletedCard extends StatefulWidget {
  final EventEnrollmentListModel event;
  final bool isVerticalList;

  const MyEventsCompletedCard(
      {super.key, required this.event, this.isVerticalList = true});

  @override
  State<MyEventsCompletedCard> createState() => _MyEventsCompletedCardState();
}

class _MyEventsCompletedCardState extends State<MyEventsCompletedCard> {
  final LearnService learnService = LearnService();
  bool _isLoading = false;
  bool _isShareLoading = false;

  static const double _buttonWidth = 0.38;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isVerticalList ? 1.sw : 0.9.sw,
      padding: EdgeInsets.all(12).r,
      margin: _buildContainerMargin(),
      decoration: _buildContainerDecoration(),
      child: Column(
        children: [
          MyEventHeader(event: widget.event),
          SizedBox(height: 8.w),
          _buildActionButtons(),
        ],
      ),
    );
  }

  EdgeInsetsGeometry _buildContainerMargin() {
    return widget.isVerticalList
        ? EdgeInsets.zero
        : EdgeInsets.only(left: 16).r;
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: AppColors.appBarBackground,
      borderRadius: BorderRadius.all(const Radius.circular(12).r),
    );
  }

  Widget _buildActionButtons() {
    return widget.event.issuedCertificates.isNotEmpty
        ? _buildCertificateButtons()
        : _buildViewRecordingButton();
  }

  Widget _buildCertificateButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          isShare: true,
          onPressed: _shareCertificate,
          isLoading: _isShareLoading,
          buttonText: AppLocalizations.of(context)!.mHomeProfileCardCertificate,
          subText: AppLocalizations.of(context)!.mStaticShare,
          icon: Icons.share,
        ),
        _buildActionButton(
          isShare: false,
          onPressed: () => _saveAsPdf(context),
          isLoading: _isLoading,
          buttonText: AppLocalizations.of(context)!.mStaticCertificates,
          subText: AppLocalizations.of(context)!.mDownload,
          icon: Icons.arrow_downward_sharp,
        ),
      ],
    );
  }

  Widget _buildViewRecordingButton() {
    return widget.event.event.status == WidgetConstants.live
        ? Row(
            children: [
              Spacer(),
              SizedBox(
                width: 0.38.sw,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.event.event.status == WidgetConstants.live) {
                      Navigator.push(
                          context,
                          FadeRoute(
                              page: EventsDetailsScreenv2(
                            eventId: widget.event.event.identifier,
                          )));
                      HomeTelemetryService.generateInteractTelemetryData(
                          widget.event.event.identifier,
                          primaryCategory: PrimaryCategory.event,
                          subType: TelemetrySubType.myLearning,
                          clickId: TelemetryIdentifier.cardContent);
                    } else {
                      Helper.showSnackBarMessage(
                          context: context,
                          text: AppLocalizations.of(context)!
                              .meventArchivedMessage,
                          bgColor: AppColors.darkBlue);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: Icon(
                          Icons.video_call_outlined,
                          size: 18.w,
                          color: AppColors.appBarBackground,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.mEventsBtnViewRecording,
                        style: GoogleFonts.lato(
                          decoration: TextDecoration.none,
                          color: AppColors.appBarBackground,
                          fontSize: 12.sp,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
          )
        : SizedBox();
  }

  Widget _buildActionButton({
    required bool isShare,
    required VoidCallback onPressed,
    required bool isLoading,
    required String buttonText,
    required String subText,
    required IconData icon,
  }) {
    return SizedBox(
      width: _buttonWidth.sw,
      child: ElevatedButton(
        style: _buttonStyle(),
        onPressed: isLoading ? () {} : onPressed,
        child: isLoading
            ? _buildLoader()
            : _buildButtonContent(buttonText, subText, icon),
      ),
    );
  }

  Widget _buildLoader() {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(6.w),
        child: SizedBox(
          width: 18.w,
          height: 18.w,
          child: PageLoader(
            strokeWidth: 1.8.w,
            isLightTheme: false,
          ),
        ));
  }

  Widget _buildButtonContent(String text, String subText, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: _getTextStyle(14.sp),
            ),
            Text(
              subText,
              style: _getTextStyle(10.sp),
            ),
          ],
        ),
        SizedBox(width: 10.w),
        Icon(
          icon,
          color: AppColors.avatarText,
          size: 24.sp,
        )
      ],
    );
  }

  TextStyle _getTextStyle(double fontSize) {
    return GoogleFonts.lato(
      color: AppColors.avatarText,
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      letterSpacing: 0.5.r,
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60.0).r,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      backgroundColor: AppColors.darkBlue,
    );
  }

  Future<void> _shareCertificate() async {
    _isShareLoading = true;
    setState(() {});
    String? certificateId = widget.event.issuedCertificates.length > 0
        ? (widget.event.issuedCertificates.length > 1
            ? widget.event.issuedCertificates[1]['identifier']
            : widget.event.issuedCertificates[0]['identifier'])
        : null;

    if (Platform.isIOS && certificateId != null) {
      ShareCertificateHelper.showPopupToSelectSharePlatforms(
        context: context,
        onLinkedinTap: () {
          Helper.doLaunchUrl(
              url: Helper.getLinkedlnUrlToShareCertificate(certificateId),
              mode: LaunchMode.externalApplication);
        },
        onOtherAppsTap: () async {
          await _sharePdfCertificate();
        },
      ).then((value) {
        _isShareLoading = false;
        setState(() {});
      });
    } else {
      try {
        _isShareLoading = true;
        await _sharePdfCertificate();
      } catch (e) {
        _isShareLoading = false;
      } finally {
        _isShareLoading = false;
        setState(() {});
      }
    }
  }

  Future<void> _sharePdfCertificate() async {
    final event = widget.event;
    final nameOfCourseRaw = event.event.name ?? '';
    final certificates = event.issuedCertificates;

    if (certificates.isEmpty) return;

    final certificateId = certificates.length > 1
        ? certificates[1]['identifier']
        : certificates[0]['identifier'];

    if (certificateId == null) return;

    String nameOfCourse =
        nameOfCourseRaw.replaceAll(RegExpressions.specialChar, '');
    if (nameOfCourse.length > 20) {
      nameOfCourse = nameOfCourse.substring(0, 20);
    }

    final fileName = '$nameOfCourse-${DateTime.now().millisecondsSinceEpoch}';
    final path = await Helper.getDownloadPath();
    final outputFormat = CertificateType.png;
    final fullFilePath = '$path/$fileName.$outputFormat';

    // Create directory if it doesn't exist
    await Directory(path).create(recursive: true);

    // Handle Android 13+ permission
    var permission = Permission.storage;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        permission = Permission.photos;
      }
    }

    if (!await Helper.requestPermission(permission)) return;

    final base64Image =
        await learnService.getCourseCompletionCertificate(certificateId);
    final certificateBytes = await learnService.downloadCompletionCertificate(
      base64Image,
      outputType: outputFormat,
    );

    await File(fullFilePath).writeAsBytes(certificateBytes);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(fullFilePath, mimeType: EMimeTypes.png)],
      text: "Certificate of completion",
    ));
  }

  Future<void> _saveAsPdf(BuildContext parentContext) async {
    _isLoading = true;
    setState(() {});

    try {
      Event event = widget.event.event;
      final certificates = widget.event.issuedCertificates;

      if (certificates.isEmpty) return;

      final certificateId = certificates.length > 1
          ? certificates[1]['identifier']
          : certificates[0]['identifier'];

      if (certificateId == null) return;

      String nameOfCourse =
          (event.name ?? "").replaceAll(RegExpressions.specialChar, '');
      if (nameOfCourse.length > 20) {
        nameOfCourse = nameOfCourse.substring(0, 20);
      }

      final fileName = '$nameOfCourse-${DateTime.now().millisecondsSinceEpoch}';
      final path = await Helper.getDownloadPath();
      await Directory(path).create(recursive: true);

      Permission permission = Permission.storage;
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          permission = Permission.photos;
        }
      }

      if (!await Helper.requestPermission(permission)) return;

      final isDynamicCert = PrimaryCategory.dynamicCertProgramCategoriesList
          .contains(event.category?.toLowerCase());
      final base64Certificate = isDynamicCert
          ? await learnService.getCourseCompletionDynamicCertificate(
              event.identifier, widget.event.batchId)
          : await learnService.getCourseCompletionCertificate(certificateId);

      final certificateBytes =
          await learnService.downloadCompletionCertificate(base64Certificate);
      final filePath = '$path/$fileName.pdf';

      await File(filePath).writeAsBytes(certificateBytes);
      await _displayDialog(parentContext, true, filePath, 'Success');
    } catch (e) {
      Helper.showSnackBarMessage(
          context: context,
          text:
              "${AppLocalizations.of(context)?.mStaticCertificateDownloadError}",
          bgColor: AppColors.negativeLight);
    } finally {
      _isLoading = false;
      setState(() {});
    }
  }

  Future _displayDialog(BuildContext parentContext, bool isSuccess,
      String filePath, String message) async {
    return showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (cntxt) => DownloadCompleteMessage(
        filePath: filePath,
        parentContext: parentContext,
      ),
    );
  }
}
