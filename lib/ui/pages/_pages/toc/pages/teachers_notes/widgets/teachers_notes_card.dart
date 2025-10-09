import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/reference_nodes.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/details_screen/details_screen.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeachersNotesCard extends StatefulWidget {
  final ReferenceNode referenceNode;
  final Course course;
  final String type;

  const TeachersNotesCard(
      {super.key,
      required this.referenceNode,
      required this.course,
      required this.type});

  @override
  State<TeachersNotesCard> createState() => _TeachersNotesCardState();
}

class _TeachersNotesCardState extends State<TeachersNotesCard> {
  bool _isDownloading = false;

  // Download the PDF file
  Future<void> _downloadFile() async {
    try {
      Permission _permision = Permission.storage;
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          _permision = Permission.videos;
        }
      }
      if (await Helper.requestPermission(_permision)) {
        setState(() {
          _isDownloading = true;
        });
        var response =
            await http.get(Uri.parse(widget.referenceNode.downloadUrl!));

        if (response.statusCode == 200) {
          _generateInteractTelemetryData();
          String path = await Helper.getDownloadPath();
          String fileName = widget.referenceNode.name +
              widget.referenceNode.downloadUrl!.split('/').last;
          String filePath = '${path}/$fileName';

          File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          displayDialog(true, '$filePath', 'Success');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.mStaticSomethingWrong),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.mStoragePermissionDisabled),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.mStaticSomethingWrong),
      ));
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  void _generateInteractTelemetryData() async {
    String pageId = (TelemetryPageIdentifier.courseDetailsPageUri)
        .replaceAll(':do_ID/overview', widget.course.id);

    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
      pageIdentifier: pageId,
      contentId: widget.course.id,
      subType: TelemetrySubType.download,
      env: TelemetryEnv.learn,
      objectType: widget.course.primaryCategory,
      clickId: widget.type == PrimaryCategory.teachersResource
          ? TelemetryIdentifier.teachersnotes
          : TelemetryIdentifier.referencenotes,
    );
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 80.w,
      padding: EdgeInsets.all(12).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(4).r,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 0.52.sw,
                    child: Text(
                      widget.referenceNode.name,
                      maxLines: 1,
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    height: 12.sp,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        FadeRoute(
                          page: ResourceDetailsScreenV2(
                            resourceId: widget.referenceNode.identifier,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 18.sp,
                            color: AppColors.greys60,
                          ),
                          SizedBox(
                            width: 6.w,
                          ),
                          Text(
                            AppLocalizations.of(context)!.mLearnView,
                            style: GoogleFonts.lato(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.greys60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              _isDownloading
                  ? PageLoader()
                  : SizedBox(
                      height: 30.w,
                      child: ElevatedButton(
                        onPressed: _isDownloading ? null : _downloadFile,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.appBarBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side:
                                BorderSide(color: AppColors.darkBlue, width: 1),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.mDownload,
                          style: GoogleFonts.lato(
                            fontSize: 12.sp,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
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
                                fontSize: 14,
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
                            AppColors.darkBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ));
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
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
              decoration: TextDecoration.none,
              fontFamily: GoogleFonts.montserrat().fontFamily,
            ),
      ),
    );
    return loginBtn;
  }

  Future<void> openFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    debugPrint("OpenFile result: ${result.message}");
  }
}
