import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/constants/color_constants.dart';
import 'package:igot_ui_components/ui/components/microsite_expandable_text.dart';
import 'package:igot_ui_components/ui/widgets/microsite_banner_slider/microsite_banner_slider.dart';
import 'package:igot_ui_components/ui/widgets/microsite_default_banner/microsite_default_banner.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_insights_view.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/ati_cti_microsite_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/microsites_top_section_data_model.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../../../util/helper.dart';
import '../../../../../../../../util/telemetry_repository.dart';
import '../../../../../../../skeleton/widgets/container_skeleton.dart';
import 'mdo_insight_view.dart';

class MdoTopSectionView extends StatefulWidget {
  final GlobalKey? containerKey;
  final String providerName;
  final String orgId;
  final ColumnData columnData;
  final Map<String, dynamic>? slwConfig;

  MdoTopSectionView({
    this.containerKey,
    required this.providerName,
    required this.orgId,
    required this.columnData,
    this.slwConfig,
    Key? key,
  }) : super(key: key);

  @override
  _MdoTopSectionViewState createState() {
    return _MdoTopSectionViewState();
  }
}

class _MdoTopSectionViewState extends State<MdoTopSectionView>
    with SingleTickerProviderStateMixin {
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
            return Column(
              children: [
                Container(
                  color: AppColors.appBarBackground,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: Align(
                              alignment: FractionalOffset.bottomRight,
                              child: Padding(
                                padding: EdgeInsets.only(top: 230).w,
                                child: SvgPicture.asset(
                                  'assets/img/microsite_description_bg.svg',
                                  fit: BoxFit.fill,
                                ),
                              ))),
                      Container(
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
                                    sliderList: microSitesTopSectionData
                                        .sliderData!.sliders,
                                    defaultView: MicroSiteDefaultBanner(
                                        height: 232.w,
                                        width: 1.sw,
                                        child: Positioned(
                                          child: Align(
                                            alignment: FractionalOffset.center,
                                            child: Container(
                                                margin: EdgeInsets.all(16).w,
                                                padding: EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 32)
                                                    .w,
                                                decoration: BoxDecoration(
                                                  color: AppColors.lightBluish,
                                                  border: Border.all(
                                                    color:
                                                        AppColors.lightBluish,
                                                    width: 1.w,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18.w),
                                                ),
                                                child: Text(
                                                  ((microSitesTopSectionData
                                                                  .title !=
                                                              null) &&
                                                          (microSitesTopSectionData
                                                                  .title !=
                                                              ''))
                                                      ? microSitesTopSectionData
                                                          .title!
                                                          .toUpperCase()
                                                      : widget.providerName
                                                          .toUpperCase(),
                                                  style: GoogleFonts.lato(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.greys87,
                                                  ),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                          ),
                                        )),
                                    showDefaultView: true,
                                    showNavigationButtonAboveBanner: true,
                                    showBottomIndicator: false,
                                    onRightClickCallback: () {
                                      _generateInteractTelemetryData(
                                          clickId: TelemetryIdentifier
                                              .bannerMoreRight,
                                          subType: TelemetrySubType.mdoChannel);
                                    },
                                    onLeftClickCallback: () {
                                      _generateInteractTelemetryData(
                                          clickId: TelemetryIdentifier
                                              .bannerMoreLeft,
                                          subType: TelemetrySubType.mdoChannel);
                                    },
                                  ),
                                  Positioned(
                                      child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8)
                                                  .w,
                                              child: ((microSitesTopSectionData
                                                              .logo !=
                                                          null) &&
                                                      microSitesTopSectionData
                                                              .logo !=
                                                          '' &&
                                                      _profileIconExtension !=
                                                          'svg')
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(12.w),
                                                      ),
                                                      child: Container(
                                                          height: 99.w,
                                                          width: 157.w,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColors
                                                                .appBarBackground,
                                                          ),
                                                          child:
                                                              _profileImageWidget(
                                                            url: microSitesTopSectionData
                                                                    .mobileLogo ??
                                                                microSitesTopSectionData
                                                                    .logo ??
                                                                '',
                                                            title: (((microSitesTopSectionData.title !=
                                                                            null) &&
                                                                        (microSitesTopSectionData.title !=
                                                                            ''))
                                                                    ? microSitesTopSectionData
                                                                        .title
                                                                    : widget
                                                                        .providerName) ??
                                                                '',
                                                          )),
                                                    )
                                                  : _errorImage(
                                                      title: (((microSitesTopSectionData
                                                                          .title !=
                                                                      null) &&
                                                                  (microSitesTopSectionData
                                                                          .title !=
                                                                      ''))
                                                              ? microSitesTopSectionData
                                                                  .title
                                                              : widget
                                                                  .providerName) ??
                                                          '',
                                                    )))),
                                ],
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
                                      text: (((microSitesTopSectionData.title !=
                                                      null) &&
                                                  (microSitesTopSectionData
                                                          .title !=
                                                      ''))
                                              ? microSitesTopSectionData.title
                                              : widget.providerName) ??
                                          '',
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
                                microSitesTopSectionData.subtitle != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                                left: 16.0, right: 16, top: 6)
                                            .r,
                                        child: Text(
                                          microSitesTopSectionData.subtitle!,
                                          style: GoogleFonts.montserrat(
                                            color: AppColors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16.sp,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : SizedBox(),
                                microSitesTopSectionData.subtitle2 != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                                left: 16.0, right: 16, top: 4)
                                            .r,
                                        child: Text(
                                          microSitesTopSectionData.subtitle2!,
                                          style: GoogleFonts.montserrat(
                                            color: AppColors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.sp,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : SizedBox(),
                                if ((microSitesTopSectionData.description !=
                                        null) &&
                                    (microSitesTopSectionData.description !=
                                        ''))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4)
                                        .w,
                                    child: MicroSiteExpandableText(
                                      text:
                                          microSitesTopSectionData.description!,
                                      style: GoogleFonts.lato(
                                        color: AppColors.greys60,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.sp,
                                        height: 1.5.w,
                                      ),
                                      maxLines: 3,
                                      showMaxLine: false,
                                      maxCharacter: 250,
                                      showMaxCharacter: true,
                                      enableCollapse: false,
                                    ),
                                  ),
                              ],
                            ),
                            if (widget.columnData.enabled)
                              Container(
                                  height: 120.w,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        child: Align(
                                          alignment:
                                              FractionalOffset.bottomCenter,
                                          child: Container(
                                            height: 64.w,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          ),
                                        ),
                                      ),
                                      widget.slwConfig != null &&
                                              widget.slwConfig!['enabled']
                                          ? SlwInsightView(
                                              orgId: widget.orgId,
                                            )
                                          : MdoInsightView(orgId: widget.orgId),
                                    ],
                                  )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _profileImageWidget({required String url, required String title}) {
    return Container(
        height: 99.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12.w)),
          color: AppColors.appBarBackground,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          child: CachedNetworkImage(
              height: 99.w,
              width: 157.w,
              fit: BoxFit.contain,
              imageUrl: url.toString().trim(),
              placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                        color: ModuleColors.grey04,
                        borderRadius: BorderRadius.circular(12)),
                    child: ContainerSkeleton(
                      height: 99.w,
                      width: 157.w,
                      radius: 12,
                    ),
                  ),
              errorWidget: (context, url, error) => _errorImage(title: title)),
        ));
  }

  Widget _errorImage({required String title}) {
    return ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(12.w),
      ),
      child: Container(
        child: Container(
          height: 99.w,
          width: 157.w,
          decoration: BoxDecoration(
            color: AppColors
                .networkBg[Random().nextInt(AppColors.networkBg.length)],
            // shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              Helper.getInitialsNew(title),
              style: GoogleFonts.lato(
                  color: AppColors.avatarText,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0.sp),
            ),
          ),
        ),
      ),
    );
  }

  void _generateInteractTelemetryData(
      {String contentId = '',
      required String subType,
      required String clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByProviderAllCbpPageId,
        contentId: contentId,
        subType: subType,
        clickId: clickId,
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
