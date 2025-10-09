import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/models/microsites_banner_slider_data_model.dart';
import 'package:igot_ui_components/ui/widgets/microsite_banner_slider/microsite_banner_slider.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';

class EventsBanner extends StatelessWidget {
  final Map<String, dynamic>? eventsConfigFuture;
  const EventsBanner({super.key, this.eventsConfigFuture});

  @override
  Widget build(BuildContext context) {
    if (eventsConfigFuture == null) {
      return SizedBox();
    }

    List<MicroSiteBannerSliderDataModel> microSiteBannerSliderDataModel = [];

    // Check if the data exists
    if (eventsConfigFuture!['banner'] != null &&
        eventsConfigFuture!['banner']['widgetData'] != null) {
      // Iterate through the banners and process the data
      for (Map<String, dynamic> banner in eventsConfigFuture!['banner']
          ['widgetData']) {
        if (banner['banners']["m"] != null &&
            !banner['banners']["m"].contains("https://portal")) {
          banner['banners']["m"] = banner['banners']["m"].startsWith("/")
              ? ApiUrl.baseUrl + banner['banners']["m"]
              : ApiUrl.baseUrl + '/' + banner['banners']["m"];
        }

        // Add the banner data to the list of models
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
            defaultView: SizedBox.shrink(),
          )
        : SizedBox();
  }
}
