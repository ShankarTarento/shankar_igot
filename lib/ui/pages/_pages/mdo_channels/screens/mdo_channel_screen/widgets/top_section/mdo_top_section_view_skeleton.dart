import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:igot_ui_components/ui/widgets/microsite_banner_slider/microsite_banner_slider_skeleton.dart';
import 'package:igot_ui_components/ui/widgets/microsite_insight/microsite_insight_skeleton.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';

class MdoTopSectionViewSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topSectionView(),
      ],
    );
  }

  Widget _topSectionView() {
    return Stack(
      children: [
        Container(
          color: AppColors.appBarBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 290.w,
                child: Stack(
                  children: [
                    MicroSiteBannerSliderSkeleton(
                      width: double.maxFinite,
                      height: 232.w,
                      radius: 0.w,
                      showNavigationButtonAboveBanner: false,
                      showBottomIndicator: false,
                    ),
                    Positioned(
                        child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8)
                                  .w,
                              child: ContainerSkeleton(
                                height: 99.w,
                                width: 157.w,
                                radius: 12.w,
                              ),
                            ))),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4).w,
                child: ContainerSkeleton(
                  width: double.maxFinite,
                  height: 80.w,
                  radius: 12.w,
                ),
              ),
              Container(
                  height: 120.w,
                  child: Stack(
                    children: [
                      Positioned(
                        child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: Container(
                            height: 64.w,
                            color: AppColors.appBarBackground,
                          ),
                        ),
                      ),
                      MicroSiteInsightSkeleton(
                        itemHeight: 75.w,
                        itemWidth: 249.w,
                      ),
                    ],
                  )),
            ],
          ),
        )
      ],
    );
  }
}
