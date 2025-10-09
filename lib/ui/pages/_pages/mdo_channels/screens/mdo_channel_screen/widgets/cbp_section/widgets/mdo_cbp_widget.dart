import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../../../../../constants/_constants/app_constants.dart';
import '../../../../../../../../../services/_services/learn_service.dart';
import '../../../../../../../../../util/helper.dart';
import '../../../../../../../../../util/hexcolor.dart';
import '../../../../../../../../widgets/_common/page_loader.dart';
import '../../../../../../my_learnings/no_data_widget.dart';
import '../../../../../model/mdo_cbp_section_data_model.dart';

class MdoCBPWidget extends StatefulWidget {
  final CBPSectionData cbpSectionData;
  MdoCBPWidget({
    Key? key,
    required this.cbpSectionData,
  }) : super(key: key);

  @override
  _MdoCBPWidgetState createState() => _MdoCBPWidgetState();
}

class _MdoCBPWidgetState extends State<MdoCBPWidget> {
  final _pageController = PageController();
  int _currentPage = 0;

  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.cbpSectionData.list == null
        ? CourseCardSkeletonPage()
        : widget.cbpSectionData.list.runtimeType == String
            ? Center()
            : widget.cbpSectionData.list!.isEmpty
                ? NoDataWidget(
                    message: AppLocalizations.of(context)!.mStaticNoCbpData,
                    paddingTop: 16.w,
                  )
                : Padding(
                    padding: EdgeInsets.only(top: 32, bottom: 16).w,
                    child: Column(
                      children: [
                        Container(
                          height: 140.w,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              cbpCardView(),
                              if ((widget.cbpSectionData.list!.isNotEmpty))
                                Positioned(
                                  child: Align(
                                    alignment: FractionalOffset.centerLeft,
                                    child: actionButton(
                                      onTap: () {
                                        if (_currentPage > 0) {
                                          _currentPage--;
                                          if (_pageController.hasClients &&
                                              mounted) {
                                            _pageController.animateToPage(
                                              _currentPage,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        } else {
                                          _currentPage = widget
                                                  .cbpSectionData.list!.length -
                                              1;
                                          if (_pageController.hasClients &&
                                              mounted) {
                                            _pageController.animateToPage(
                                              _currentPage,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        }
                                      },
                                      backgroundColor: AppColors.black,
                                      icon: Icons.arrow_back_ios_sharp,
                                      iconColor: AppColors.appBarBackground,
                                    ),
                                  ),
                                ),
                              if ((widget.cbpSectionData.list!.isNotEmpty))
                                Positioned(
                                  child: Align(
                                      alignment: FractionalOffset.centerRight,
                                      child: actionButton(
                                        onTap: () {
                                          if (_currentPage <
                                              (widget.cbpSectionData.list!
                                                      .length) -
                                                  1) {
                                            _currentPage++;
                                            if (_pageController.hasClients &&
                                                mounted) {
                                              _pageController.animateToPage(
                                                _currentPage,
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          } else {
                                            _currentPage = 0;
                                            if (_pageController.hasClients &&
                                                mounted) {
                                              _pageController.animateToPage(
                                                _currentPage,
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          }
                                        },
                                        backgroundColor: AppColors.black,
                                        icon: Icons.arrow_forward_ios_sharp,
                                        iconColor: AppColors.appBarBackground,
                                      )),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.w),
                        widget.cbpSectionData.list!.length > 1
                            ? SmoothPageIndicator(
                                controller: _pageController,
                                count: widget.cbpSectionData.list!.length,
                                effect: ExpandingDotsEffect(
                                    activeDotColor: AppColors.orangeTourText,
                                    dotColor: AppColors.profilebgGrey20,
                                    dotHeight: 4,
                                    dotWidth: 4,
                                    spacing: 4),
                              )
                            : Center()
                      ],
                    ),
                  );
  }

  Widget cbpCardView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (int page) {
        setState(() {
          _currentPage = page;
        });
      },
      itemCount: widget.cbpSectionData.list!.length,
      itemBuilder: (context, index) {
        return cbpCardWidget(widget.cbpSectionData.list![_currentPage]);
      },
    );
  }

  Widget cbpCardWidget(CBPListData cbpListData) {
    return Container(
        width: double.maxFinite,
        margin: EdgeInsets.only(left: 16, right: 16).w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.w)),
            border: Border.all(
                color: ((widget.cbpSectionData.listItem!.border != null) ||
                        (widget.cbpSectionData.listItem!.border != ''))
                    ? HexColor(widget.cbpSectionData.listItem!.border!)
                    : AppColors.darkBlue),
            color: ((widget.cbpSectionData.listItem!.background != null) ||
                    (widget.cbpSectionData.listItem!.background != ''))
                ? HexColor(widget.cbpSectionData.listItem!.background!)
                : AppColors.darkBlue.withValues(alpha: 0.08)),
        child: Padding(
            padding: EdgeInsets.all(16).w,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    cbpListData.title ?? '',
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkBlue,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                      onPressed: () async {
                        if (isDownloading) return;
                        await _saveAsPdf(
                            cbpListData.title!, cbpListData.downloadUrl ?? '');
                      },
                      child: Container(
                        width: 86.w,
                        child: isDownloading
                            ? Center(
                                child: Container(
                                    width: 16,
                                    height: 16,
                                    alignment: Alignment
                                        .center, // Center align the indicator
                                    child: PageLoader(
                                        strokeWidth: 2, isLightTheme: true)),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_download_outlined,
                                    color: AppColors.darkBlue,
                                    size: 16.w,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .mCommondownload,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(
                                          letterSpacing: 0.5,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkBlue,
                                        ),
                                  ),
                                ],
                              ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appBarBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(63).r,
                        ),
                      )),
                )
              ],
            )));
  }

  Widget actionButton(
      {required VoidCallback onTap,
      Color? backgroundColor,
      required IconData icon,
      required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.all(4).w,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(8).w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.w),
                color: backgroundColor ?? ModuleColors.black),
            child: Icon(
              icon,
              color: ModuleColors.white,
              size: 8.w,
            )),
      ),
    );
  }

  Future<void> _saveAsPdf(String name, String fileUrl) async {
    name = name.replaceAll(RegExpressions.specialChar, '');
    if (name.length > 150) {
      name = name.substring(0, 100);
    }
    String fileName =
        '$name-' + DateTime.now().millisecondsSinceEpoch.toString();

    String path = await Helper.getDownloadPath();
    await Directory('$path').create(recursive: true);

    var certificateType = CertificateType.pdf;

    try {
      LearnService learnService = LearnService();
      if (fileUrl != '') {
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
            isDownloading = true;
          });
          var fileData = await learnService.downloadCBPlan(fileUrl);

          await File('$path/$fileName.$certificateType').writeAsBytes(fileData);

          setState(() {
            isDownloading = false;
          });
          displayDialog(true, '$path/$fileName.$certificateType', 'Success');
        }
      } else {
        displayDialog(false, '', 'Download Failed');
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  Future<void> displayDialog(
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
