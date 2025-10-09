import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:igot_ui_components/ui/widgets/microsite_banner_slider/microsite_banner_slider_skeleton.dart';

class MicroSitesInfraDetailViewSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 8,
          ).w,
          child: ContainerSkeleton(
            height: 18.w,
            width: 0.5.sw,
            radius: 12.w,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8).w,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 8,
            ).w,
            child: ContainerSkeleton(
              height: 68.w,
              width: 1.sw,
              radius: 12.w,
            ),
          ),
        ),
        _infraListView(),
        _physicalInfraBannerView(),
      ],
    );
  }

  Widget _infraListView() {
    return Column(
      children: [
        Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding:
                  EdgeInsets.only(top: 8, bottom: 32, right: 80, left: 8).w,
              child: Row(
                children: List.generate(
                  2,
                  (index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          ContainerSkeleton(
                            height: 51.w,
                            width: 0.59.sw,
                            radius: 12.w,
                          ),
                          SizedBox(height: 8.w),
                          ContainerSkeleton(
                            height: 51.w,
                            width: 0.59.sw,
                            radius: 12.w,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16).w,
          child: ContainerSkeleton(
            height: 12.w,
            width: double.maxFinite,
            radius: 12.w,
          ),
        )
      ],
    );
  }

  Widget _physicalInfraBannerView() {
    return Container(
        margin: EdgeInsets.only(top: 32).w,
        height: 320.w,
        child: Stack(
          children: [
            Container(
                margin: EdgeInsets.only(top: 16, left: 16, right: 16).w,
                width: 1.sw,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.w))),
                child: Column(
                  children: [
                    MicroSiteBannerSliderSkeleton(
                      width: 1.sw,
                      height: 220.w,
                      radius: 16.w,
                      showNavigationButtonAboveBanner: false,
                      showBottomIndicator: true,
                    ),
                  ],
                )),
          ],
        ));
  }
}
