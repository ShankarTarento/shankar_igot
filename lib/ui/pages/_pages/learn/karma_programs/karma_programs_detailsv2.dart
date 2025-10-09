import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/models/microsites_banner_slider_data_model.dart';
import 'package:igot_ui_components/ui/components/microsite_expandable_text.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:igot_ui_components/ui/widgets/microsite_banner_slider/microsite_banner_slider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:karmayogi_mobile/models/_models/playlist_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/karma_programs/widgets/description_webview.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/karma_programs/widgets/program_contents.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/microsites_top_section_data_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../models/_models/course_model.dart';
import '../../microsites/model/ati_cti_microsite_data_model.dart';

class KarmaProgramDetailsv2 extends StatefulWidget {
  final PlayList karmaProgram;
  const KarmaProgramDetailsv2({Key? key, required this.karmaProgram})
      : super(key: key);

  @override
  State<KarmaProgramDetailsv2> createState() => _KarmaProgramDetailsv2State();
}

class _KarmaProgramDetailsv2State extends State<KarmaProgramDetailsv2> {
  List imageList = [];

  Future<List<Course>>? getKarmaProgramContentFuture;
  late Future<AtiCtiMicroSitesDataModel?> microSiteFuture;
  List<SectionListModel> microSiteSortedData = [];

  List<Widget> microSiteWidgets = [];
  @override
  void initState() {
    super.initState();
    microSiteFuture = _getKarmaProgramFormData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtiCtiMicroSitesDataModel?>(
        future: microSiteFuture,
        builder: (BuildContext context,
            AsyncSnapshot<AtiCtiMicroSitesDataModel?> microSiteData) {
          if (microSiteData.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                  child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: PageLoader(),
              )),
            );
          }
          if (microSiteData.data == null) {
            return Scaffold(
              appBar: _appBar(),
              body: Center(child: Text("No data found")),
            );
          }
          if (microSiteData.hasData && microSiteData.data != null) {
            List<SectionListModel> microSiteDataList =
                microSiteData.data!.sectionList ?? [];
            microSiteSortedData = microSiteDataList
                .where((item) => item.enabled ?? false)
                .toList();
            microSiteSortedData.sort((a, b) => a.order!.compareTo(b.order!));
            sortLayouts(microSiteSortedData);
            return Scaffold(
              appBar: _appBar(),
              body: (microSiteWidgets.isNotEmpty) ? _buildLayout() : SizedBox(),
            );
          } else {
            return Scaffold(
              appBar: _appBar(),
              body: SizedBox(),
            );
          }
        });
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: AppColors.appBarBackground,
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: kToolbarHeight.w,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 24.sp, color: AppColors.greys60),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Container(
          margin: EdgeInsets.only(bottom: 100).w,
          child: Column(children: microSiteWidgets),
        ),
      ),
    );
  }

  void sortLayouts(List<SectionListModel> _microSiteSortedData) {
    microSiteWidgets = [];
    _microSiteSortedData.forEach((element) {
      switch (element.key) {
        case 'bannerSection':
          if (element.column.isNotEmpty) {
            return microSiteWidgets.add(Column(
              children: [
                SizedBox(
                  height: 180,
                  width: 1.sw,
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl:
                        element.column[0].data["bannerImagesV2"]["m"] ?? "",
                    errorWidget: (context, url, error) {
                      return SizedBox();
                    },
                    progressIndicatorBuilder: (context, url, progress) {
                      return Center(
                          child: ContainerSkeleton(
                        height: 10,
                        width: 1.sw,
                      ));
                    },
                  ),
                ),
                DescriptionWebView(
                  data: element.column[0].data["descriptionV2"] ?? "",
                )
              ],
            ));
          }
          break;
        case 'row1':
          if (element.column.isNotEmpty) {
            List<dynamic> sliderData =
                element.column.first.data['sliderData']?['sliders'] ?? [];
            return microSiteWidgets.add(Container(
              color: AppColors.darkBlue,
              child: Column(
                children: [
                  MicroSiteBannerSlider(
                      height: 238.w,
                      width: 1.sw,
                      sliderList: sliderData
                          .map((slider) =>
                              MicroSiteBannerSliderDataModel.fromJson(slider))
                          .toList(),
                      showIndicatorAtBottomCenterInBanner: true,
                      imageBorderRadius: BorderRadius.only(
                          topLeft: Radius.elliptical(50, 30).w,
                          topRight: Radius.elliptical(50, 30).w),
                      defaultView: SizedBox.shrink()),
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/img/microsite_watermark.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: _getTitleDescriptionWidget(
                        MicroSitesTopSectionDataModel.fromJson(
                            element.column.first.data)),
                  )
                ],
              ),
            ));
          }
          break;

        case 'contentSearch':
          if (element.column.isNotEmpty &&
              element.column.first.data['strips'] != null &&
              element.column.first.data['strips'].isNotEmpty)
            return microSiteWidgets.add(ProgramContents(
              karmaProgram: widget.karmaProgram,
            ));
          break;
        default:
          return microSiteWidgets.add(SizedBox.shrink());
      }
    });
  }

  Widget _getTitleDescriptionWidget(
      MicroSitesTopSectionDataModel topSectionDataModel) {
    return Padding(
      padding: EdgeInsets.all(16).w,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: (topSectionDataModel.title ?? widget.karmaProgram.title)
                  .isNotEmpty,
              child: Text(
                topSectionDataModel.title ??
                    widget.karmaProgram.title.toString(),
                style: GoogleFonts.montserrat(
                    color: AppColors.appBarBackground,
                    fontSize: 32.0.sp,
                    fontWeight: FontWeight.w500),
              ),
            ),
            (topSectionDataModel.description ?? widget.karmaProgram.description)
                    .isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: MicroSiteExpandableText(
                        text: topSectionDataModel.description ??
                            widget.karmaProgram.description,
                        style: GoogleFonts.lato(
                            color: AppColors.appBarBackground,
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.w400),
                        maxLines: 6),
                  )
                : SizedBox(),
            topSectionDataModel.referenceLinks.isNotEmpty
                ? Column(
                    children: topSectionDataModel.referenceLinks
                        .map((reference) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    '${reference.label} : ',
                                    style: GoogleFonts.lato(
                                        color: AppColors.appBarBackground,
                                        fontSize: 16.0.sp,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  InkWell(
                                    onTap: () => _launchURL(reference.value),
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .mStaticClickHere,
                                      style: GoogleFonts.lato(
                                          color: AppColors.orangeTourText,
                                          fontSize: 16.0.sp,
                                          fontWeight: FontWeight.w700,
                                          textStyle: TextStyle(
                                              decoration:
                                                  TextDecoration.underline)),
                                    ),
                                  )
                                ])))
                        .toList())
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Future<AtiCtiMicroSitesDataModel?> _getKarmaProgramFormData() async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMicroSiteFormData(
      orgId: widget.karmaProgram.playListKey,
      type: 'karma-program',
      subtype: "microsite-v2",
    );
    if (responseData != null) {
      return AtiCtiMicroSitesDataModel.fromJson(responseData['data']);
    } else {
      return null;
    }
  }

  void _launchURL(String uri) async =>
      await canLaunchUrl(Uri.parse(uri)).then((value) => value
          ? launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication)
          : throw 'Please try after sometime');
}
