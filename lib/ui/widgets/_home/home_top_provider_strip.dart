import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/util/app_config.dart';

import '../../../models/index.dart';
import '../../pages/index.dart';

class HomeTopProviderStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<TopProviderModel> data = getTopProviderModel();
    return data.isNotEmpty
        ? TopProviders(
            topProviderList: data,
          )
        : SizedBox();
  }

  List<TopProviderModel> getTopProviderModel() {
    Map<String, dynamic>? homeConfig = AppConfiguration.homeConfigData;
    List topProviderList = homeConfig?['clientList'] ?? [];

    return topProviderList
        .map((item) => TopProviderModel.fromJson(item))
        .toList();
  }
}
