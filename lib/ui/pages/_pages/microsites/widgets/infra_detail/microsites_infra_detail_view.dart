import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/microsite_expandable_text.dart';
import 'package:igot_ui_components/ui/widgets/microsite_banner_slider/microsite_banner_slider.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/skeleton/microsites_infra_detail_view_skeleton.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../util/hexcolor.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../model/ati_cti_microsite_data_model.dart';
import '../../model/microsites_infra_details_data_model.dart';
import 'microsites_infra_item_widget.dart';

class MicroSitesInfraDetailView extends StatefulWidget {
  final GlobalKey? containerKey;
  final ColumnData? columnData;

  MicroSitesInfraDetailView({
    this.containerKey,
    this.columnData,
    Key? key,
  }) : super(key: key);

  @override
  _MicroSitesInfraDetailViewState createState() {
    return _MicroSitesInfraDetailViewState();
  }
}

class _MicroSitesInfraDetailViewState extends State<MicroSitesInfraDetailView> {
  final _physicalInfraScrollController = ScrollController();
  MicroSitesInfraDetailsDataModel? microSitesInfraDetailsDataModel;

  @override
  void initState() {
    super.initState();
    getInfraDetailsData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getInfraDetailsData() async {
    var responseData = widget.columnData!.data;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        microSitesInfraDetailsDataModel =
            MicroSitesInfraDetailsDataModel.fromJson(responseData);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return (microSitesInfraDetailsDataModel != null)
        ? Container(
            key: widget.containerKey,
            color: ((widget.columnData!.background != null) ||
                    (widget.columnData!.background != ''))
                ? HexColor(widget.columnData!.background!)
                : AppColors.darkBlue,
            margin: EdgeInsets.only(bottom: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _physicalInfraDetailView(),
              ],
            ),
          )
        : MicroSitesInfraDetailViewSkeleton();
  }

  Widget _physicalInfraDetailView() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16).w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                microSitesInfraDetailsDataModel?.detaulTitle ?? '',
                style: GoogleFonts.montserrat(
                  color: AppColors.primaryOne,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  height: 1.5.w,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8).w,
                child: MicroSiteExpandableText(
                  text: microSitesInfraDetailsDataModel?.description ?? '',
                  style: GoogleFonts.montserrat(
                    color: AppColors.appBarBackground,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    height: 1.5.w,
                  ),
                  maxLines: 4,
                  enableCollapse: false,
                ),
              ),
              RawScrollbar(
                controller: _physicalInfraScrollController,
                thumbColor: AppColors.appBarBackground.withValues(alpha: 0.4),
                trackColor: AppColors.black.withValues(alpha: 0.4),
                radius: Radius.circular(8),
                trackRadius: Radius.circular(8),
                thickness: 8.w,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _physicalInfraScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 32, right: 80).w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        (microSitesInfraDetailsDataModel!.metrics!.length / 2)
                            .ceil(),
                        (index) {
                          final item1 = microSitesInfraDetailsDataModel!
                              .metrics![index * 2];
                          final item2 = (index * 2 + 1 <
                                  microSitesInfraDetailsDataModel!
                                      .metrics!.length)
                              ? microSitesInfraDetailsDataModel!
                                  .metrics![index * 2 + 1]
                              : null;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                _physicalInfraItemView(
                                  title: item1.label!,
                                  value: item1.value!,
                                ),
                                SizedBox(width: 8.w),
                                if (item2 != null)
                                  _physicalInfraItemView(
                                    title: item2.label!,
                                    value: item2.value!,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _physicalInfraBannerView(),
      ],
    );
  }

  Widget _physicalInfraItemView({String? title, String? value}) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 16, 8, 8).w,
        width: 0.59.sw,
        child: MicroSiteInfraItemWidget(
          title: title!,
          value: value!,
          titleColor: AppColors.appBarBackground.withValues(alpha: 0.6),
          valueColor: AppColors.appBarBackground,
        ));
  }

  Widget _physicalInfraBannerView() {
    return Container(
        margin: EdgeInsets.only(top: 32).w,
        height: 320.w,
        child: Stack(
          children: [
            Positioned(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  height: 190.w,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 16, left: 16, right: 16).w,
                width: 1.sw,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.w))),
                child: Column(
                  children: [
                    MicroSiteBannerSlider(
                      width: 1.sw,
                      height: 220.w,
                      imageBorderRadius:
                          BorderRadius.all(Radius.circular(12.w)),
                      sliderList:
                          microSitesInfraDetailsDataModel!.sliderData!.sliders,
                      defaultView: SizedBox.shrink(),
                      showDefaultView: false,
                      showNavigationButtonAboveBanner: false,
                      showBottomIndicator: true,
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
                  ],
                )),
          ],
        ));
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
