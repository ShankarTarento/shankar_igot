import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/microsite_expandable_text.dart';
import 'package:igot_ui_components/ui/widgets/microsite_icon_button/microsite_icon_button.dart';
import 'package:igot_ui_components/ui/widgets/microsite_spane_text/microsites_span_text.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../util/telemetry_repository.dart';
import '../../model/ati_cti_microsite_data_model.dart';
import '../../model/microsites_contributors_data_model.dart';
import '../../../../../../util/hexcolor.dart';
import 'microsites_contributor_item_widget.dart';

class MicroSitesContributorsView extends StatefulWidget {
  final GlobalKey? containerKey;
  final String? orgId;
  final ColumnData columnData;

  MicroSitesContributorsView({
    this.containerKey,
    this.orgId,
    required this.columnData,
    Key? key,
  }) : super(key: key);

  @override
  _MicroSitesContributorsViewState createState() {
    return _MicroSitesContributorsViewState();
  }
}

class _MicroSitesContributorsViewState
    extends State<MicroSitesContributorsView> {
  MicroSitesContributorsDataModel? microSitesContributorsDataModel;

  final ScrollController _contributorsScrollController = ScrollController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    getContributorsColumnDataData();
    _contributorsScrollController.addListener(_onScroll);
  }

  void _onScroll() {
    int page = (_contributorsScrollController.position.pixels / 250.w).round();
    setState(() {
      _currentPage = page;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _contributorsScrollController.dispose();
  }

  Future<void> getContributorsColumnDataData() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        microSitesContributorsDataModel =
            MicroSitesContributorsDataModel.fromJson(widget.columnData.data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
      key: widget.containerKey,
      color: ((widget.columnData.background != null) ||
              (widget.columnData.background != ''))
          ? HexColor(widget.columnData.background!)
          : AppColors.darkBlue,
      child: _contributorsView(),
    );
  }

  Widget _contributorsView() {
    return (microSitesContributorsDataModel != null)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(top: 32, left: 16, right: 16).w,
                  child: Wrap(
                    children: [
                      MicroSiteSpanText(
                        textOne:
                            microSitesContributorsDataModel?.detaulTitle ?? '',
                        textTwo:
                            microSitesContributorsDataModel?.defaultTitle1 ??
                                '',
                        textOneColor: AppColors.appBarBackground,
                        textTwoColor: AppColors.primaryOne,
                      ),
                      MicroSiteSpanText(
                        textOne: microSitesContributorsDataModel?.myTitle ?? '',
                        textTwo:
                            microSitesContributorsDataModel?.myTitle1 ?? '',
                        textOneColor: AppColors.appBarBackground,
                        textTwoColor: AppColors.primaryOne,
                      )
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 8, left: 16, right: 16).w,
                  child: MicroSiteExpandableText(
                    text: microSitesContributorsDataModel?.description ?? '',
                    style: GoogleFonts.montserrat(
                      color: AppColors.appBarBackground,
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      height: 1.5.w,
                    ),
                    maxLines: 4,
                    enableCollapse: false,
                  )),
              if (microSitesContributorsDataModel!.contributors.isNotEmpty)
                _microSiteContributorList(
                    microSitesContributorsDataModel!.contributors),
            ],
          )
        : SizedBox.shrink();
  }

  Widget _microSiteContributorList(List<Contributors> contributors) {
    return Container(
        padding: EdgeInsets.only(top: 16).w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SingleChildScrollView(
              controller: _contributorsScrollController,
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(top: 8, bottom: 32, right: 80).w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    (contributors.length).ceil(),
                    (pageIndex) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (pageIndex == 0)
                              SizedBox(
                                width: 16.w,
                              ),
                            MicroSiteContributorItemWidget(
                                name: contributors[pageIndex].name ?? '',
                                description:
                                    contributors[pageIndex].description ?? '',
                                imgUrl: contributors[pageIndex].image ?? ''),
                          ]);
                    },
                  ),
                ),
              ),
            ),
            _contributorListIndicator(itemLength: contributors.length),
          ],
        ));
  }

  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 2.0).w,
          height: 4.w,
          width: _currentPage == index ? 12.w : 4.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(50.w)),
            color: _currentPage == index
                ? AppColors.orangeTourText
                : AppColors.black,
          ),
        );
      }),
    );
  }

  Widget _contributorListIndicator({int? itemLength}) {
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16).w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPageIndicator(itemLength!),
            Row(
              children: [
                MicroSiteIconButton(
                  onTap: () {
                    _generateInteractTelemetryData(
                        clickId: TelemetryIdentifier.meetOurExpertiseMoreLeft,
                        subType: TelemetrySubType.atiCti);
                    _contributorsScrollController.animateTo(
                      _contributorsScrollController.offset - 250,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundColor: AppColors.black,
                  icon: Icons.arrow_back_ios_sharp,
                  iconColor: AppColors.appBarBackground,
                ),
                MicroSiteIconButton(
                  onTap: () {
                    _generateInteractTelemetryData(
                        clickId: TelemetryIdentifier.meetOurExpertiseMoreRight,
                        subType: TelemetrySubType.atiCti);
                    _contributorsScrollController.animateTo(
                      _contributorsScrollController.offset + 250,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  backgroundColor: AppColors.black,
                  icon: Icons.arrow_forward_ios_sharp,
                  iconColor: AppColors.appBarBackground,
                ),
              ],
            )
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
