import 'package:flutter/widgets.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_tips_for_learning/data_models/tips_model.dart';
import 'package:karmayogi_mobile/util/app_config.dart';

class TipsRepository {
  static List<TipsModel> getTips() {
    try {
      final Map<String, dynamic>? homeConfig = AppConfiguration.homeConfigData;

      if (homeConfig == null) return [];

      final List<dynamic>? tipsDataList = homeConfig['data'];
      if (tipsDataList == null || tipsDataList.isEmpty) return [];

      for (var item in tipsDataList) {
        if (item is Map<String, dynamic> &&
            item['type'] == WidgetConstants.learnerTips) {
          final List<dynamic> tipsList = item['data'] ?? [];
          return tipsList
              .map((tip) => TipsModel.fromJson(tip as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error parsing tips: $e');
    }

    return [];
  }
}
