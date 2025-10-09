
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_banner_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_banner_slider_widget.dart';

class CommunityBannerCarouselWidget extends StatefulWidget {
  final List<CommunityItemData> communityList;
  final String? heading;
  final Function? onClickShowAll;

  CommunityBannerCarouselWidget({Key? key, required this.communityList, this.heading, this.onClickShowAll}) : super(key: key);
  CommunityBannerCarouselWidgetState createState() => CommunityBannerCarouselWidgetState();
}

class CommunityBannerCarouselWidgetState extends State<CommunityBannerCarouselWidget> {


  late List<CommunityBannerModel> sliderList;

  @override
  void initState() {
    super.initState();
    _getMediaData(context);
  }

  void _getMediaData(context) async {
    try {
      sliderList = widget.communityList.map((item) {
        return CommunityBannerModel(
          active: true,
          title: item.communityName,
          imageUrl: item.posterImageUrl,
          id: item.communityId
        );
      }).toList();
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Container(
      child: Column(
        children: [
          if (widget.heading != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8).r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.heading??'',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  if (widget.onClickShowAll != null)
                    InkWell(
                        onTap: () {
                          widget.onClickShowAll!();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2.0).r,
                          child: Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.mCommonShowAll,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                  letterSpacing: 0.12,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.darkBlue,
                                size: 18.sp,
                              )
                            ],
                          ),
                        ))
                ],
              ),
            ),
          _bannerView(),
        ],
      ),
    );
  }

  Widget _bannerView() {
    return Container(
      height: 179.w,
      padding: EdgeInsets.only(top: 8, bottom: 8).r,
      child: CommunityBannerSliderWidget(
        width: 1.sw,
        height: 179.w,
        imageBorderRadius: BorderRadius.all(Radius.circular(12.w)),
        sliderList: sliderList,
        defaultView: Container(),
        showDefaultView: false,
        showNavigationButtonAboveBanner: true,
        showIndicatorAtBottomCenterInBanner: true,
        autoSlide: true,
        onClickCallback: (communityId) {
          Navigator.pushNamed(
            context,
            AppUrl.communityPage,
            arguments: communityId,
          );
        },
      ),
    );
  }

}
