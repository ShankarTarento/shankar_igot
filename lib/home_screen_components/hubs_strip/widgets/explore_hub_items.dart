import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/hubs_strip/widgets/new_widget_animation.dart';
import 'package:karmayogi_mobile/home_screen_components/models/hub_item_model.dart';

class ExploreHubItems extends StatelessWidget {
  final HubItemModel hubItem;
  const ExploreHubItems({super.key, required this.hubItem});

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
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4).r,
        padding: const EdgeInsets.fromLTRB(15, 15, 10, 15).r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4).r,
          color: AppColors.appBarBackground,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(20).r,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(6).r,
                  ),
                  child: ImageWidget(
                    width: 25.0.w,
                    height: 25.0.w,
                    imageUrl: ApiUrl.baseUrl + hubItem.imageUrl,
                    imageColor: AppColors.darkBlue,
                  ),
                ),
                hubItem.isNew
                    ? Positioned(top: 0, right: 0, child: NewWidgetAnimation())
                    : SizedBox.shrink()
              ],
            ),
            Padding(
                padding: EdgeInsets.only(left: 15, right: 5).r,
                child: SizedBox(
                  width: 0.7.sw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        hubItem.title.getText(context).replaceAll('\n', ' '),
                        style: GoogleFonts.lato(
                          color: AppColors.greys87,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.5.w,
                        ),
                      ),
                      Text(
                        hubItem.description.getText(context),
                        maxLines: 2,
                        style: GoogleFonts.lato(
                            color: AppColors.greys60,
                            height: 1.5.w,
                            fontSize: 12.sp),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
