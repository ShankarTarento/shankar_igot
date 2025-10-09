import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:igot_ui_components/ui/widgets/microsite_banner_slider/microsite_banner_slider_skeleton.dart';
import 'package:igot_ui_components/ui/widgets/microsite_insight/microsite_insight_skeleton.dart';
import '../../../../../constants/_constants/color_constants.dart';

class MicroSitesTopSectionViewSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topSectionSkeletonView(),
      ],
    );
  }

  Widget _topSectionSkeletonView() {
    return Container(
      color: AppColors.appBarBackground,
      margin: EdgeInsets.only(bottom: 16).w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 290.w,
            child: Stack(
              children: [
                _microSiteBannerSkeletonView(),
                Positioned(
                    child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.appBarBackground,
                                borderRadius: BorderRadius.circular(100.w)),
                            margin: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8)
                                .w,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: AppColors.grey04,
                                  borderRadius: BorderRadius.circular(100.w)),
                              child: ContainerSkeleton(
                                width: 112.w,
                                height: 112.w,
                                radius: 100.w,
                              ),
                            )))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).w,
            child: ContainerSkeleton(
              width: 0.5.sw,
              height: 36.w,
              radius: 12.w,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4).w,
            child: ContainerSkeleton(
              width: double.maxFinite,
              height: 80.w,
              radius: 12.w,
            ),
          ),
          MicroSiteInsightSkeleton(
            itemHeight: 75.w,
            itemWidth: 249.w,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4).w,
            child: ContainerSkeleton(
              width: 120.w,
              height: 36.w,
              radius: 12.w,
            ),
          ),
          SizedBox(
            height: 12.w,
          )
        ],
      ),
    );
  }

  Widget _microSiteBannerSkeletonView() {
    return MicroSiteBannerSliderSkeleton(
      width: double.maxFinite,
      height: 232.w,
      radius: 0.w,
      showNavigationButtonAboveBanner: false,
      showBottomIndicator: false,
    );
  }
}
