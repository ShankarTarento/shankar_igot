import 'package:flutter/foundation.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_banner/model/banner_model.dart';
import 'package:karmayogi_mobile/util/app_config.dart';

class BannerRepository {
  static List<BannerData> getBanners() {
    final List<BannerData> banners = [];

    try {
      final Map<String, dynamic> homeConfigData =
          AppConfiguration.homeConfigData ?? {};

      if (homeConfigData.isNotEmpty) {
        final List<dynamic>? dataList =
            homeConfigData['data'] as List<dynamic>?;

        if (dataList != null) {
          final bannerSection =
              dataList.cast<Map<String, dynamic>?>().firstWhere(
                    (item) => item?['type'] == WidgetConstants.banner,
                    orElse: () => null,
                  );

          final List<dynamic>? bannerData = bannerSection?['data'];

          if (bannerData != null) {
            for (var item in bannerData) {
              if (item is Map<String, dynamic>) {
                banners.add(BannerData.fromJson(item));
              }
            }
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error in getBanners: $e\n$stackTrace');
    }

    return banners;
  }
}
