import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/resource_details_screen/widgets/custom_pdf_viewer.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_detailv2_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/widgets/events_documents/widgets/document_viewer.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_image_widget.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:open_file_plus/open_file_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:path/path.dart' as provider;

class EventsDocumentsCard extends StatefulWidget {
  final EventHandout eventHandout;
  const EventsDocumentsCard({super.key, required this.eventHandout});

  @override
  State<EventsDocumentsCard> createState() => _EventsDocumentsCardState();
}

class _EventsDocumentsCardState extends State<EventsDocumentsCard> {
  bool _isDownloading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: 74.w,
      padding: EdgeInsets.all(10).r,
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
        borderRadius: BorderRadius.circular(4).r,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              getIcon(),
              SizedBox(
                width: 6.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 0.51.sw,
                    child: Text(
                      widget.eventHandout.title ?? "",
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
                      String fileExtension =
                          provider.extension(widget.eventHandout.content!);

                      Navigator.push(
                          context,
                          FadeRoute(
                              page: fileExtension == ".pdf"
                                  ? CustomPdfPlayer(
                                      pdfUrl: widget.eventHandout.content ?? "",
                                    )
                                  : DocumentWebView(
                                      title: widget.eventHandout.title ?? "",
                                      fileUrl:
                                          widget.eventHandout.content ?? "",
                                    )));
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

  Future<void> _downloadFile() async {
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
          _isDownloading = true;
        });
        var response =
            await http.get(Uri.parse(widget.eventHandout.content ?? ""));

        if (response.statusCode == 200) {
          String path = await Helper.getDownloadPath();
          String fileExtension =
              provider.extension(widget.eventHandout.content!);

          String filePath =
              '${path}/${widget.eventHandout.title}.$fileExtension';

          File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          displayDialog(true, '$filePath', 'Success');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.mStaticSomethingWrong),
          ));
        }
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

  Future<dynamic> openFile(filePath) async {
    await OpenFile.open(filePath);
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

  Widget getIcon() {
    String fileExtension = provider.extension(widget.eventHandout.content!);
    print(fileExtension);
    if (fileExtension == FileExtension.ppt ||
        fileExtension == FileExtension.pptx) {
      return ImageWidget(
        imageUrl: ApiUrl.baseUrl + "/assets/icons/ppt.svg",
        height: 30.w,
        width: 30.w,
      );
    } else if (fileExtension == FileExtension.pdf) {
      return ImageWidget(
        imageUrl: ApiUrl.baseUrl + "/assets/icons/pdf.svg",
        height: 30.w,
        width: 30.w,
      );
    } else if (fileExtension == FileExtension.text ||
        fileExtension == FileExtension.doc ||
        fileExtension == FileExtension.docx) {
      return ImageWidget(
        imageUrl: ApiUrl.baseUrl + "/assets/icons/doc.svg",
        height: 30.w,
        width: 30.w,
      );
    }
    return SizedBox.shrink();
  }
}
