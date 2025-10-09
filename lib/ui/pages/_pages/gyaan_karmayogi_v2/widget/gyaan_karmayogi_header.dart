import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:igot_ui_components/models/microsites_banner_slider_data_model.dart';
import 'package:igot_ui_components/ui/widgets/microsite_banner_slider/microsite_banner_slider.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/services/gyaan_karmayogi_services.dart';

import 'package:provider/provider.dart';

import '../../../../../constants/_constants/color_constants.dart';

class GyaanKarmayogiHeaderV2 extends StatefulWidget {
  final String? title;
  final Function(String) searchFunction;

  final TextEditingController searchController;
  const GyaanKarmayogiHeaderV2(
      {Key? key,
      required this.searchFunction,
      required this.searchController,
      this.title})
      : super(key: key);

  @override
  State<GyaanKarmayogiHeaderV2> createState() => _GyaanKarmayogiHeaderState();
}

class _GyaanKarmayogiHeaderState extends State<GyaanKarmayogiHeaderV2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      color: AppColors.scaffoldBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<GyaanKarmayogiServicesV2>(
            builder: (context, providerData, child) {
              Map<String, dynamic> amritGyaanConfig =
                  providerData.amritGyaanConfig;
              List<MicroSiteBannerSliderDataModel>
                  microSiteBannerSliderDataModel = [];
              if (amritGyaanConfig['sliderData'] != null) {
                microSiteBannerSliderDataModel = [];
                for (Map<String, dynamic> banner
                    in amritGyaanConfig['sliderData']) {
                  microSiteBannerSliderDataModel
                      .add(MicroSiteBannerSliderDataModel.fromJson(banner));
                }
              }

              return microSiteBannerSliderDataModel.isNotEmpty
                  ? MicroSiteBannerSlider(
                      displayPageIndicator: false,
                      height: 120.w,
                      width: 1.sw,
                      sliderList: microSiteBannerSliderDataModel,
                      showIndicatorAtBottomCenterInBanner: true,
                      defaultView: SizedBox.shrink())
                  : SizedBox();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  height: 40.w,
                  width: 1.sw / 1.5,
                  child: TextField(
                    controller: widget.searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.appBarBackground,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(40.0).r,
                      ),
                      contentPadding: EdgeInsets.only(left: 12, right: 12).r,
                      hintText:
                          AppLocalizations.of(context)!.mSearchInAmritGyaanKosh,
                      hintStyle: GoogleFonts.lato(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Spacer(),
                SizedBox(
                  height: 40.w,
                  child: ElevatedButton(
                      onPressed: () async {
                        widget.searchFunction(widget.searchController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeTourText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20).r,
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.mStaticSearch)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
