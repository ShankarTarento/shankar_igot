import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:igot_ui_components/ui/widgets/microsite_icon_button/microsite_icon_button.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_banner_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_banner_image_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../../constants/index.dart';

class CommunityBannerSliderWidget extends StatefulWidget {
  final double height;
  final double width;
  final List<CommunityBannerModel> sliderList;
  final Widget defaultView;
  final bool showDefaultView;
  final bool showNavigationButtonAboveBanner;
  final bool showBottomIndicator;
  final bool showIndicatorAtBottomCenterInBanner;
  final bool autoSlide;
  final Color activeIndicatorColor;
  final Function(String)? onClickCallback;
  final VoidCallback? onRightClickCallback;
  final VoidCallback? onLeftClickCallback;
  final BorderRadiusGeometry? imageBorderRadius;
  final bool displayPageIndicator;
  const CommunityBannerSliderWidget({
    required this.height,
    required this.width,
    required this.sliderList,
    required this.defaultView,
    this.displayPageIndicator = true,
    this.showDefaultView = false,
    this.showNavigationButtonAboveBanner = true,
    this.showBottomIndicator = false,
    this.autoSlide = true,
    this.onClickCallback,
    this.onRightClickCallback,
    this.onLeftClickCallback,
    this.showIndicatorAtBottomCenterInBanner = false,
    this.activeIndicatorColor = ModuleColors.orangeTourText,
    this.imageBorderRadius,
    super.key,
  });
  @override
  CommunityBannerSliderWidgetState createState() =>
      CommunityBannerSliderWidgetState();
}

class CommunityBannerSliderWidgetState
    extends State<CommunityBannerSliderWidget> {
  final _bannerPageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoSlide) {
      startTimer();
    }
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_currentPage < widget.sliderList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_bannerPageController.hasClients && mounted) {
        _bannerPageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: (widget.showBottomIndicator)
          ? Column(
              children: [
                _bannerView(),
                if ((widget.sliderList.isNotEmpty) &&
                    widget.showBottomIndicator)
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16).w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10).w,
                          child: SmoothPageIndicator(
                            controller: _bannerPageController,
                            count: widget.sliderList.length,
                            effect: ExpandingDotsEffect(
                                activeDotColor: widget.activeIndicatorColor,
                                dotColor: ModuleColors.profilebgGrey20,
                                dotHeight: 4,
                                dotWidth: 4,
                                spacing: 4),
                          ),
                        ),
                        Row(
                          children: [
                            MicroSiteIconButton(
                              onTap: () {
                                if (_currentPage > 0) {
                                  _currentPage--;
                                  if (_bannerPageController.hasClients &&
                                      mounted) {
                                    _bannerPageController.animateToPage(
                                      _currentPage,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                } else {
                                  _currentPage = widget.sliderList.length - 1;
                                  if (_bannerPageController.hasClients &&
                                      mounted) {
                                    _bannerPageController.animateToPage(
                                      _currentPage,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                }
                              },
                              backgroundColor: ModuleColors.black,
                              icon: Icons.arrow_back_ios_sharp,
                              iconColor: ModuleColors.white,
                            ),
                            MicroSiteIconButton(
                              onTap: () {
                                if (widget.onRightClickCallback != null) {
                                  widget.onRightClickCallback!();
                                }
                                if (_currentPage <
                                    widget.sliderList.length - 1) {
                                  _currentPage++;
                                  if (_bannerPageController.hasClients &&
                                      mounted) {
                                    _bannerPageController.animateToPage(
                                      _currentPage,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                } else {
                                  _currentPage = 0;
                                  if (_bannerPageController.hasClients &&
                                      mounted) {
                                    _bannerPageController.animateToPage(
                                      _currentPage,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                }
                              },
                              backgroundColor: ModuleColors.black,
                              icon: Icons.arrow_forward_ios_sharp,
                              iconColor: ModuleColors.white,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
              ],
            )
          : SizedBox(
              width: widget.width,
              height: widget.height,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  _bannerView(),
                  if ((widget.sliderList.isNotEmpty &&
                          widget.sliderList.length > 1) &&
                      widget.showNavigationButtonAboveBanner)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: FractionalOffset.centerLeft,
                          child: MicroSiteIconButton(
                            onTap: () {
                              if (_currentPage > 0) {
                                _currentPage--;
                                if (_bannerPageController.hasClients &&
                                    mounted) {
                                  _bannerPageController.animateToPage(
                                    _currentPage,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              } else {
                                _currentPage = widget.sliderList.length - 1;
                                if (_bannerPageController.hasClients &&
                                    mounted) {
                                  _bannerPageController.animateToPage(
                                    _currentPage,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }
                            },
                            backgroundColor: ModuleColors.black,
                            icon: Icons.arrow_back_ios_sharp,
                            iconColor: ModuleColors.white,
                          ),
                        ),
                        Align(
                            alignment: FractionalOffset.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: MicroSiteIconButton(
                                onTap: () {
                                  if (widget.onLeftClickCallback != null) {
                                    widget.onLeftClickCallback!();
                                  }
                                  if (_currentPage <
                                      widget.sliderList.length - 1) {
                                    _currentPage++;
                                    if (_bannerPageController.hasClients &&
                                        mounted) {
                                      _bannerPageController.animateToPage(
                                        _currentPage,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  } else {
                                    _currentPage = 0;
                                    if (_bannerPageController.hasClients &&
                                        mounted) {
                                      _bannerPageController.animateToPage(
                                        _currentPage,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  }
                                },
                                backgroundColor: ModuleColors.black,
                                icon: Icons.arrow_forward_ios_sharp,
                                iconColor: ModuleColors.white,
                              ),
                            ))
                      ],
                    ),
                  widget.displayPageIndicator
                      ? widget.sliderList.length > 1 &&
                              widget.showIndicatorAtBottomCenterInBanner
                          ? Positioned(
                              bottom: 16.w,
                              child: Align(
                                alignment: FractionalOffset.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10).w,
                                  child: SmoothPageIndicator(
                                    controller: _bannerPageController,
                                    count: widget.sliderList.length,
                                    effect: ExpandingDotsEffect(
                                        activeDotColor:
                                            widget.activeIndicatorColor,
                                        dotColor: ModuleColors.profilebgGrey20,
                                        dotHeight: 4,
                                        dotWidth: 4,
                                        spacing: 4),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink()
                      : const SizedBox.shrink()
                ],
              ),
            ),
    );
  }

  Widget _bannerView() {
    return (widget.sliderList.isNotEmpty)
        ? SizedBox(
            height: widget.height,
            child: PageView.builder(
                controller: _bannerPageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: widget.sliderList.length,
                itemBuilder: (context, pageIndex) {
                  return GestureDetector(
                    onTap: () {
                      if (widget.onClickCallback != null) {
                        widget.onClickCallback!(
                            widget.sliderList[_currentPage].id ?? '');
                      }
                    },
                    child: Container(
                      height: widget.height,
                      child: ClipRRect(
                        borderRadius: widget.imageBorderRadius ??
                            BorderRadius.all(
                              Radius.circular(0),
                            ),
                        child: Stack(
                          children: [
                            Positioned(
                              child: Align(
                                  alignment: FractionalOffset.center,
                                  child: _bannerImageView(widget
                                      .sliderList[_currentPage].imageUrl)),
                            ),
                            Positioned(
                                top: 0.w,
                                left: 0.w,
                                right: 0.w,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        AppColors.greys.withValues(
                                            alpha: 0.8), // Middle: More opacity
                                        AppColors.greys.withValues(
                                            alpha:
                                                0.04), // Bottom: Less opacity
                                      ],
                                    ),
                                  ),
                                  padding: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: 8,
                                          bottom: 8)
                                      .r,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.sliderList[_currentPage]
                                                  .title ??
                                              '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14.sp,
                                                  color: AppColors
                                                      .appBarBackground),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ),
                  );
                }))
        : (widget.showDefaultView)
            ? SizedBox(height: widget.height, child: widget.defaultView)
            : const SizedBox.shrink();
  }

  Widget _bannerImageView(String? imgUrl) {
    return CommunityBannerImageWidget(
        imgUrl: imgUrl,
        height: widget.height,
        width: widget.width,
        fit: BoxFit.fill,
        borderRadius: widget.imageBorderRadius);
  }
}
