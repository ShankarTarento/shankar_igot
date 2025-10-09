import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/igot_component_kit.dart';
import 'package:igot_ui_components/ui/components/microsite_expandable_text.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:igot_ui_components/ui/widgets/elevated_chip/elevated_chip.dart';
import 'package:igot_ui_components/ui/widgets/microsite_banner_slider/microsite_banner_slider.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../util/faderoute.dart';
import '../../../../../../util/helper.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../model/ati_cti_microsite_data_model.dart';
import '../../model/microsites_top_section_data_model.dart';
import '../../screen/contents/microsites_all_contents.dart';
import 'microsites_insight_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MicroSitesTopSectionView extends StatefulWidget {
  final GlobalKey? containerKey;
  final String? providerName;
  final String? orgId;
  final ColumnData columnData;

  MicroSitesTopSectionView({
    this.containerKey,
    this.providerName,
    this.orgId,
    required this.columnData,
    Key? key,
  }) : super(key: key);

  @override
  _MicroSitesTopSectionViewState createState() {
    return _MicroSitesTopSectionViewState();
  }
}

class _MicroSitesTopSectionViewState extends State<MicroSitesTopSectionView> {
  Future<MicroSitesTopSectionDataModel>? microSitesTopSectionDataModel;

  @override
  void initState() {
    super.initState();
    getTopSectionData();
  }

  Future<void> getTopSectionData() async {
    var responseData = widget.columnData.data;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        microSitesTopSectionDataModel =
            Future.value(MicroSitesTopSectionDataModel.fromJson(responseData));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
      key: widget.containerKey,
      child: FutureBuilder(
        future: microSitesTopSectionDataModel,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            MicroSitesTopSectionDataModel microSitesTopSectionData =
                snapshot.data;
            var _profileIconExtension;
            if (microSitesTopSectionData.logo != null &&
                microSitesTopSectionData.logo != 'null') {
              _profileIconExtension = microSitesTopSectionData.logo!
                  .substring(microSitesTopSectionData.logo!.length - 3);
            }
            return Container(
              color: AppColors.appBarBackground,
              margin: EdgeInsets.only(bottom: 16).w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 290.w,
                    child: Stack(
                      children: [
                        MicroSiteBannerSlider(
                          width: 1.sw,
                          height: 232.w,
                          sliderList:
                              microSitesTopSectionData.sliderData!.sliders,
                          defaultView: MicroSiteDefaultBanner(
                              height: 232.w,
                              width: 1.sw,
                              child: Positioned(
                                child: Align(
                                  alignment: FractionalOffset.center,
                                  child: Container(
                                      margin: EdgeInsets.all(16).w,
                                      padding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 32)
                                          .w,
                                      decoration: BoxDecoration(
                                        color: AppColors.lightBluish,
                                        border: Border.all(
                                          color: AppColors.lightBluish,
                                          width: 1.w,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(18.w),
                                      ),
                                      child: Text(
                                        ((microSitesTopSectionData.title !=
                                                    null) &&
                                                (microSitesTopSectionData
                                                        .title !=
                                                    ''))
                                            ? microSitesTopSectionData.title ??
                                                "".toUpperCase()
                                            : widget.providerName ??
                                                "".toUpperCase(),
                                        style: GoogleFonts.lato(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.greys87,
                                        ),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                ),
                              )),
                          showDefaultView: true,
                          showNavigationButtonAboveBanner: true,
                          showBottomIndicator: false,
                          onRightClickCallback: () {
                            _generateInteractTelemetryData(
                                clickId: TelemetryIdentifier.bannerMoreRight,
                                subType: TelemetrySubType.atiCti);
                          },
                          onLeftClickCallback: () {
                            _generateInteractTelemetryData(
                                clickId: TelemetryIdentifier.bannerMoreLeft,
                                subType: TelemetrySubType.atiCti);
                          },
                        ),
                        Positioned(
                            child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8)
                                      .w,
                                  child: ((microSitesTopSectionData.logo !=
                                              null) &&
                                          microSitesTopSectionData.logo != '' &&
                                          _profileIconExtension != 'svg')
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(100.w),
                                          ),
                                          child: Container(
                                              height: 112.w,
                                              width: 112.w,
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColors.appBarBackground,
                                                shape: BoxShape.circle,
                                              ),
                                              child: MicroSiteImageView(
                                                  imgUrl:
                                                      microSitesTopSectionData
                                                              .logo ??
                                                          '',
                                                  height: 112.w,
                                                  width: 112.w,
                                                  radius: 100.w,
                                                  fit: BoxFit.contain)),
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(100.w),
                                          ),
                                          child: Container(
                                            child: Container(
                                              height: 112.w,
                                              width: 112.w,
                                              decoration: BoxDecoration(
                                                color: AppColors.networkBg[
                                                    Random().nextInt(AppColors
                                                        .networkBg.length)],
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  Helper.getInitialsNew(
                                                      widget.providerName ??
                                                          ''),
                                                  style: GoogleFonts.lato(
                                                      color:
                                                          AppColors.avatarText,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16.0.sp),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                ))),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Positioned.fill(
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: SvgPicture.asset(
                            'assets/img/microsite_description_bg.svg',
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ).w,
                              child: MicroSiteExpandableText(
                                text: ((microSitesTopSectionData.title !=
                                            null) &&
                                        (microSitesTopSectionData.title != ''))
                                    ? microSitesTopSectionData.title!
                                    : widget.providerName ?? '',
                                style: GoogleFonts.montserrat(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.sp,
                                  height: 1.5.w,
                                ),
                                maxLines: 2,
                                showMaxLine: true,
                                showMaxCharacter: false,
                                enableCollapse: false,
                              )),
                          if ((microSitesTopSectionData.description != null) &&
                              (microSitesTopSectionData.description != ''))
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4)
                                  .w,
                              child: MicroSiteExpandableText(
                                text: microSitesTopSectionData.description!,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys60,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  height: 1.5.w,
                                ),
                                maxLines: 3,
                                showMaxLine: false,
                                maxCharacter: 1000,
                                showMaxCharacter: true,
                                enableCollapse: false,
                              ),
                            ),
                          if (widget.columnData.enabled)
                            MicroSitesInsightView(
                              orgId: widget.orgId,
                            ),
                          _viewAllContentWidget(),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _viewAllContentWidget() {
    return Container(
      margin: EdgeInsets.only(bottom: 16, left: 16, right: 16).w,
      child: ElevatedChip(
        onTap: () {
          _generateInteractTelemetryData(
              clickId: TelemetryIdentifier.viewAllContents,
              subType: TelemetrySubType.atiCti);
          Navigator.push(
            context,
            FadeRoute(
                page: MicroSiteAllContents(
                    providerName: widget.providerName ?? '')),
          );
        },
        borderColor: AppColors.darkBlue,
        borderWidth: 1.w,
        text: AppLocalizations.of(context)!.mStaticViewAllContents,
        textColor: AppColors.darkBlue,
        fontSize: 14.sp,
      ),
    );
  }

  void _generateInteractTelemetryData(
      {String? contentId, String? subType, String? clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByProviderAllCbpPageId,
        contentId: contentId ?? "",
        subType: subType ?? "",
        clickId: clickId ?? "",
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
