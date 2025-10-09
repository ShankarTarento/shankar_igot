import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/models/microsites_banner_slider_data_model.dart';
import 'package:igot_ui_components/ui/widgets/microsite_banner_slider/microsite_banner_slider.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/week_metrics_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/ati_cti_microsite_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/microsites_top_section_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/services/national_learning_week_view_model.dart';

class NationalLearningWeekTopSection extends StatefulWidget {
  final ColumnData columnData;

  const NationalLearningWeekTopSection({super.key, required this.columnData});

  @override
  State<NationalLearningWeekTopSection> createState() =>
      _NationalLearningWeekTopSectionState();
}

class _NationalLearningWeekTopSectionState
    extends State<NationalLearningWeekTopSection> {
  @override
  void initState() {
    try {
      microSitesTopSectionDataModel =
          MicroSitesTopSectionDataModel.fromJson(widget.columnData.data);
    } catch (e) {
      print(e);
    }
    microSiteBannerSliderDataModel = microSitesTopSectionDataModel!
        .sliderData!.sliders
        .map((slider) => slider)
        .toList();
    getMetricsData();
    super.initState();
  }

  getMetricsData() async {
    metricsData = await NationalLearningWeekViewModel().getWeekMetrics();
    setState(() {});
  }

  List<MicroSiteBannerSliderDataModel> microSiteBannerSliderDataModel = [];
  MicroSitesTopSectionDataModel? microSitesTopSectionDataModel;
  List<WeekMetrics> metricsData = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            MicroSiteBannerSlider(
                displayPageIndicator: false,
                height: 232.w,
                width: 1.sw,
                sliderList: microSiteBannerSliderDataModel,
                showIndicatorAtBottomCenterInBanner: true,
                defaultView: SizedBox.shrink()),
            widget.columnData.data['metrics'] != null
                ? metricsWidget()
                : SizedBox()
          ],
        ),
        widget.columnData.data['metrics'] != null && metricsData.isNotEmpty
            ? Positioned(
                top: 232.w,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 0.7.sw,
                    padding: EdgeInsets.only(left: 16, right: 16).r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50).r,
                      color: AppColors.primaryOne,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/img/forward_arrow.png'),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8,
                          ),
                          child: Text(
                            widget.columnData.data['metrics']['title'] ?? "",

                            //  'STATS OF THE WEEK',
                            style: GoogleFonts.lato(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.appBarBackground),
                          ),
                        ),
                        Transform(
                          transform: Matrix4.rotationZ(3.1),
                          alignment: Alignment.center,
                          child: Image.asset('assets/img/forward_arrow.png'),
                        )
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox()
      ],
    );
  }

  Widget insightsWidget({
    String? imagePath,
    String? title,
    String? subTitle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        imagePath != null
            ? SvgPicture.network(
                imagePath,
                height: 32.w,
                width: 32.w,
                fit: BoxFit.contain,
              )
            : SizedBox(),
        SizedBox(
          width: 16.w,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? "0",
              style: GoogleFonts.montserrat(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.appBarBackground),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              subTitle ?? '',
              style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.appBarBackground),
            )
          ],
        ),
      ],
    );
  }

  Widget metricsWidget() {
    return metricsData.isNotEmpty
        ? Container(
            width: 1.sw,
            padding: EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 34),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.blue1,
                    AppColors.blue2,
                  ]),
            ),
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return insightsWidget(
                    imagePath: metricsData[index].icon,
                    subTitle: metricsData[index].label,
                    title: metricsData[index].value);
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 24,
                );
              },
              itemCount: metricsData.length,
            ),
          )
        : SizedBox();
  }
}
