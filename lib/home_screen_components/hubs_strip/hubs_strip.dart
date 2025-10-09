import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/home_screen_components/hubs_strip/widgets/hub_items.dart';
import 'package:karmayogi_mobile/home_screen_components/models/hub_item_model.dart';

class HubsStrip extends StatelessWidget {
  final List<HubItemModel> hubItems;

  const HubsStrip({super.key, required this.hubItems});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            hubItems.length,
            (index) => hubItems[index].isEnabled
                ? Padding(
                    padding: const EdgeInsets.all(8.0).r,
                    child: HubItem(hubItem: hubItems[index]),
                  )
                : SizedBox(),
          ),
        ),
      ),
    );
  }
}
