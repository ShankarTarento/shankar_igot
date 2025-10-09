import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/reference_nodes.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/teachers_notes/widgets/teachers_notes_card.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeachersNotes extends StatefulWidget {
  final List<ReferenceNode> referenceNodes;
  final Course course;
  final String type;
  const TeachersNotes(
      {super.key,
      required this.referenceNodes,
      required this.course,
      required this.type});

  @override
  State<TeachersNotes> createState() => _TeachersNotesState();
}

class _TeachersNotesState extends State<TeachersNotes> {
  bool _isDownloading = false;
  List<String> downloadUrl = [];

  @override
  void initState() {
    downloadUrl =
        widget.referenceNodes.map((e) => e.downloadUrl ?? '').toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16).r,
        child: Column(
          children: [
            Row(children: [
              SizedBox(
                width: 0.55.sw,
                child: Text(
                  AppLocalizations.of(context)!.mTeachersNotesDescription,
                  style: GoogleFonts.lato(
                      fontSize: 14.sp, color: AppColors.greys60),
                ),
              ),
              Spacer(),
              _isDownloading
                  ? PageLoader()
                  : TextButton(
                      onPressed: () {
                        _downloadFiles(downloadUrl);
                      },
                      child: SizedBox(
                        width: 90.w,
                        child: Text(
                          AppLocalizations.of(context)!.mDownloadAll,
                          style: GoogleFonts.lato(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlue),
                          textAlign: TextAlign.center,
                        ),
                      ))
            ]),
            SizedBox(
              height: 20.w,
            ),
            ListView.separated(
              itemCount: widget.referenceNodes.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return TeachersNotesCard(
                  referenceNode: widget.referenceNodes[index],
                  course: widget.course,
                  type: widget.type,
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 8.w,
                );
              },
            ),
            SizedBox(
              height: 100.w,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFiles(List<String> urls) async {
    try {
      setState(() {
        _isDownloading = true;
      });
      Permission _permission = Permission.storage;

      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          _permission = Permission.videos;
        }
      }

      if (await Helper.requestPermission(_permission)) {
        for (String url in urls) {
          var response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            String path = await Helper.getDownloadPath();
            String fileName = url.split('/').last;
            String filePath = '${path}/$fileName';

            File file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
          }
        }
        _generateInteractTelemetryData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context)!.mAllFilesDownloadedSuccessfully),
        ));
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
}
