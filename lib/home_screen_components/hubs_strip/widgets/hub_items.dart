import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/hubs_strip/widgets/new_widget_animation.dart';
import 'package:karmayogi_mobile/home_screen_components/models/hub_item_model.dart';

class HubItem extends StatelessWidget {
  final HubItemModel hubItem;
  const HubItem({
    required this.hubItem,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          try {
            Navigator.pushNamed(context, hubItem.navigationRoute);
          } catch (e) {
            debugPrint("error in hub item $e");
          }
        },
        splashColor: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5).r,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0).r,
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hubItem.backgroundColor ?? AppColors.appBarBackground,
                      border: Border.all(
                        width: 1.w,
                        color: AppColors.darkBlue,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0).r,
                        child: ImageWidget(
                          height: 25.w,
                          width: 25.w,
                          imageColor: hubItem.iconColor,
                          imageUrl: ApiUrl.baseUrl + hubItem.imageUrl,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4).r,
                    child: Text(
                      hubItem.title.getText(context),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(letterSpacing: 0.25.r, fontSize: 14.sp),
                    ),
                  )
                ],
              ),
            ),
            hubItem.isNew
                ? Positioned(top: 0, right: 0, child: NewWidgetAnimation())
                : SizedBox.shrink()
          ],
        ));
  }
}
