import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/my_learning_card/download_complete_message.dart';
import 'package:karmayogi_mobile/common_components/my_learning_card/my_learning_card_header.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/services/_services/learn_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/share_certificate_helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseCompleteCard extends StatefulWidget {
  final Course course;
  const CourseCompleteCard({super.key, required this.course});

  @override
  State<CourseCompleteCard> createState() => _CourseCompleteCardState();
}

class _CourseCompleteCardState extends State<CourseCompleteCard> {
  LearnService learnService = LearnService();
  final ValueNotifier<bool> _isShareLoading = ValueNotifier(false);
  final ValueNotifier<bool> _isDownloadLoading = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      width: 0.9.sw,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12).r,
        border: Border.all(color: AppColors.grey08, width: 1.w),
        color: AppColors.appBarBackground,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              MyLearningCardHeader(
                course: widget.course,
              ),
              widget.course.raw['content']['status'] == 'Live'
                  ? SizedBox()
                  : Positioned(
                      child: Container(
                      height: 130.w,
                      color: AppColors.appBarBackground.withValues(alpha: 0.7),
                    ))
            ],
          ),
          SizedBox(
            height: 16.w,
          ),
          Row(
            children: [
              Icon(
                Icons.check,
                size: 20.sp,
                color: AppColors.positiveLight,
              ),
              Text(
                Helper.capitalize(
                    AppLocalizations.of(context)!.mStaticCompleted),
                style: GoogleFonts.lato(
                  color: AppColors.positiveLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0.sp,
                ),
              ),
              SizedBox(
                height: 10.w,
              ),
            ],
          ),
          widget.course.courseCategory != PrimaryCategory.caseStudy
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      buttonText:
                          AppLocalizations.of(context)!.mStaticCertificates,
                      subText: AppLocalizations.of(context)!.mStaticShare,
                      onPressed: () {
                        _isShareLoading.value = true;
                        _shareCertificate();
                      },
                      loadingListener: _isShareLoading,
                      icon: Icons.share,
                    ),
                    _buildActionButton(
                      buttonText:
                          AppLocalizations.of(context)!.mStaticCertificates,
                      subText: AppLocalizations.of(context)!.mDownload,
                      onPressed: () async {
                        _isDownloadLoading.value = true;
                        await _saveAsPdf(context);
                      },
                      loadingListener: _isDownloadLoading,
                      icon: Icons.arrow_downward_sharp,
                    ),
                  ],
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required String buttonText,
      required String subText,
      required VoidCallback onPressed,
      required ValueNotifier<bool> loadingListener,
      required IconData icon}) {
    return SizedBox(
      width: 0.38.sw,
      child: ValueListenableBuilder(
          valueListenable: loadingListener,
          builder: (BuildContext context, bool isLoading, Widget? child) {
            return ElevatedButton(
              style: _buttonStyle(),
              onPressed: isLoading ? () {} : onPressed,
              child: isLoading
                  ? _buildLoader()
                  : _buildButtonContent(buttonText, subText, icon),
            );
          }),
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

  Future<void> _saveAsPdf(BuildContext parentContext) async {
    String nameOfCourse = widget.course.name;
    String? certificateId = widget.course.issuedCertificates.length > 0
        ? (widget.course.issuedCertificates.length > 1
            ? widget.course.issuedCertificates[1]['identifier']
            : widget.course.issuedCertificates[0]['identifier'])
        : null;

    final isInDynamicCertProgramCategoriesList = PrimaryCategory
        .dynamicCertProgramCategoriesList
        .contains(widget.course.courseCategory.toLowerCase());

    String? _base64CertificateImage;
    if (isInDynamicCertProgramCategoriesList) {
      _base64CertificateImage =
          await learnService.getCourseCompletionDynamicCertificate(
              widget.course.id, widget.course.batchId ?? '');
    } else if (certificateId != null) {
      _base64CertificateImage =
          await learnService.getCourseCompletionCertificate(certificateId);
    }

    if (_base64CertificateImage != null) {
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
          final certificate = await learnService
              .downloadCompletionCertificate(_base64CertificateImage);

          await File('$path/$fileName.pdf').writeAsBytes(certificate);

          _displayDialog(parentContext, true, '$path/$fileName.pdf', 'Success');
        }
      } catch (e) {
        Helper.showSnackBarMessage(
            context: context,
            text:
                "${AppLocalizations.of(context)?.mStaticCertificateDownloadError}",
            bgColor: AppColors.negativeLight);
      } finally {
        _isDownloadLoading.value = false;
      }
    } else {
      _isDownloadLoading.value = false;
      Helper.showSnackBarMessage(
          context: context,
          text:
              "${AppLocalizations.of(context)?.mStaticCertificateDownloadError}",
          bgColor: AppColors.negativeLight);
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

  Future<void> _shareCertificate() async {
    String? certificateId = widget.course.issuedCertificates.length > 0
        ? (widget.course.issuedCertificates.length > 1
            ? widget.course.issuedCertificates[1]['identifier']
            : widget.course.issuedCertificates[0]['identifier'])
        : null;
    _generateInteractTelemetryData(certificateId ?? "",
        subType: TelemetrySubType.certificate,
        edataId: TelemetryIdentifier.shareCertificate);
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
        _isShareLoading.value = false;
      });
    } else {
      try {
        _isShareLoading.value = true;
        await _sharePdfCertificate();
      } catch (e) {
      } finally {
        _isShareLoading.value = false;
      }
    }
  }

  Future<void> _sharePdfCertificate() async {
    String nameOfCourse = widget.course.name;
    String? certificateId = widget.course.issuedCertificates.length > 0
        ? (widget.course.issuedCertificates.length > 1
            ? widget.course.issuedCertificates[1]['identifier']
            : widget.course.issuedCertificates[0]['identifier'])
        : null;
    nameOfCourse = nameOfCourse.replaceAll(RegExpressions.specialChar, '');
    if (nameOfCourse.length > 20) {
      nameOfCourse = nameOfCourse..substring(0, 20);
    }
    String fileName =
        '$nameOfCourse-' + DateTime.now().millisecondsSinceEpoch.toString();
    String path = await Helper.getDownloadPath();
    String outputFormat = CertificateType.png;
    await Directory('$path').create(recursive: true);

    Permission _permision = Permission.storage;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        _permision = Permission.photos;
      }
    }

    if (await Helper.requestPermission(_permision)) {
      final isInDynamicCertProgramCategoriesList = PrimaryCategory
          .dynamicCertProgramCategoriesList
          .contains(widget.course.courseCategory.toLowerCase());

      String? _base64CertificateImage;
      if (isInDynamicCertProgramCategoriesList) {
        _base64CertificateImage =
            await learnService.getCourseCompletionDynamicCertificate(
                widget.course.id, widget.course.batchId ?? '');
      } else if (certificateId != null) {
        _base64CertificateImage =
            await learnService.getCourseCompletionCertificate(certificateId);
      }

      if (_base64CertificateImage != null) {
        final certificate = await learnService.downloadCompletionCertificate(
            _base64CertificateImage,
            outputType: outputFormat);
        await File('$path/$fileName.' + outputFormat).writeAsBytes(certificate);
        await SharePlus.instance.share(ShareParams(files: [
          XFile('$path/$fileName.' + outputFormat, mimeType: EMimeTypes.png)
        ], text: "Certificate of completion"));
      }
    }
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '',
      String? primaryCategory,
      required String edataId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null ? primaryCategory : subType,
        clickId: edataId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
