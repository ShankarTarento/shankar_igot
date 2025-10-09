import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/widgets/resource_details_screen/widgets/custom_pdf_viewer.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:igot_ui_components/ui/widgets/microsite_icon_button/microsite_icon_button.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_models/media_view_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/discussion_view/_widgets/discussion_video_player.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/deeplinks/smt_deeplink_service.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaSliderWidget extends StatefulWidget {
  final double height;
  final double width;
  final List<MediaViewModel> mediaList;
  final String contentType;
  final Widget defaultView;
  final bool showDefaultView;
  final bool showNavigationButtonAboveBanner;
  final bool showIndicatorAtBottomCenterInBanner;
  final bool autoSlide;
  final Color activeIndicatorColor;
  final VoidCallback? onRightClickCallback;
  final VoidCallback? onLeftClickCallback;
  final BorderRadiusGeometry? imageBorderRadius;
  final bool displayPageIndicator;

  const MediaSliderWidget({
    required this.height,
    required this.width,
    required this.mediaList,
    required this.contentType,
    required this.defaultView,
    this.displayPageIndicator = true,
    this.showDefaultView = false,
    this.showNavigationButtonAboveBanner = true,
    this.autoSlide = true,
    this.onRightClickCallback,
    this.onLeftClickCallback,
    this.showIndicatorAtBottomCenterInBanner = false,
    this.activeIndicatorColor = ModuleColors.orangeTourText,
    this.imageBorderRadius,
    super.key,
  });
  @override
  MediaSliderWidgetState createState() => MediaSliderWidgetState();
}

class MediaSliderWidgetState extends State<MediaSliderWidget> {
  final _bannerPageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if ((widget.contentType == MediaConst.image) ||
            (widget.contentType == MediaConst.video))
          _mediaImageVideView(widget.mediaList),
        if ((widget.contentType == MediaConst.file) ||
            (widget.contentType == MediaConst.link))
          _mediaFileLinkView(widget.mediaList)
      ],
    );
  }

  Widget _mediaImageVideView(List<MediaViewModel> sliderList) {
    if (sliderList.isEmpty) return SizedBox.shrink();
    return SizedBox(
      width: widget.width,
      child: Column(
        children: [
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                _bannerView(sliderList),
                if ((sliderList.isNotEmpty && sliderList.length > 1) &&
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
                              if (_bannerPageController.hasClients && mounted) {
                                _bannerPageController.animateToPage(
                                  _currentPage,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            } else {
                              _currentPage = sliderList.length - 1;
                              if (_bannerPageController.hasClients && mounted) {
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
                                if (_currentPage < sliderList.length - 1) {
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
                (widget.displayPageIndicator &&
                        widget.contentType != MediaConst.video)
                    ? sliderList.length > 1 &&
                            widget.showIndicatorAtBottomCenterInBanner
                        ? Positioned(
                            bottom: 16.w,
                            child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10).w,
                                child: SmoothPageIndicator(
                                  controller: _bannerPageController,
                                  count: sliderList.length,
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
          (widget.displayPageIndicator &&
                  widget.contentType == MediaConst.video)
              ? (sliderList.length > 1 &&
                      widget.showIndicatorAtBottomCenterInBanner)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10).w,
                        child: SmoothPageIndicator(
                          controller: _bannerPageController,
                          count: sliderList.length,
                          effect: ExpandingDotsEffect(
                              activeDotColor: widget.activeIndicatorColor,
                              dotColor: ModuleColors.profilebgGrey20,
                              dotHeight: 4,
                              dotWidth: 4,
                              spacing: 4),
                        ),
                      ),
                    )
                  : const SizedBox.shrink()
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _bannerView(List<MediaViewModel> sliderList) {
    return (sliderList.isNotEmpty)
        ? Container(
            height: widget.height,
            child: PageView.builder(
                controller: _bannerPageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: sliderList.length,
                itemBuilder: (context, pageIndex) {
                  return Column(
                    children: [
                      (widget.contentType == MediaConst.image)
                          ? Container(
                              height: widget.height,
                              child: MicroSiteImageView(
                                imgUrl: sliderList[_currentPage].mediaUrl ?? '',
                                height: widget.height,
                                width: widget.width,
                                borderRadius: widget.imageBorderRadius,
                                fit: BoxFit.contain,
                              ),
                            )
                          : (widget.contentType == MediaConst.video)
                              ? DiscussionVideoPlayer(
                                  mediaUrl:
                                      sliderList[_currentPage].mediaUrl ?? '',
                                  height: widget.height,
                                  width: widget.width,
                                )
                              : Container()
                    ],
                  );
                }))
        : (widget.showDefaultView)
            ? SizedBox(height: widget.height, child: widget.defaultView)
            : const SizedBox.shrink();
  }

  Widget _mediaFileLinkView(List<MediaViewModel> sliderList) {
    return Container(
        width: widget.width,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: sliderList.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              height: 78.w,
              margin: EdgeInsets.only(top: (index == 0) ? 0 : 4, bottom: 4).r,
              child: (widget.contentType == MediaConst.file)
                  ? _fileItemView(
                      sliderList[index].mediaUrl ?? '', sliderList.length)
                  : _linkItemView(
                      sliderList[index].mediaUrl ?? '', sliderList.length),
            );
          },
        ));
  }

  Widget _fileItemView(String fileUrl, int sliderListCount) {
    return GestureDetector(
      onTap: () {
        if (DiscussionHelper.isPDF(fileUrl)) {
          Navigator.push(
              context,
              FadeRoute(
                  page: CustomPdfPlayer(
                pdfUrl: fileUrl,
              )));
        } else {
          Helper.doLaunchUrl(url: fileUrl, mode: LaunchMode.platformDefault);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16).r,
        decoration: BoxDecoration(
          color: AppColors.whiteGradientOne,
          border: Border.all(color: AppColors.grey16),
          borderRadius: BorderRadius.all(const Radius.circular(8.0).r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 28.w,
              width: 28.w,
              color: AppColors.appBarBackground,
              child: Icon(
                Icons.description_outlined,
                color: AppColors.greys60,
                size: 28.w,
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                getFileNameFromUrl(fileUrl),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _linkItemView(String fileUrl, int sliderListCount) {
    return GestureDetector(
      onTap: () async {
        Platform.isIOS
            ? await SMTDeeplinkService.instance.initSMTAppLink(
                smtDeeplinkSource: BroadCastEvent.InAppMessage,
                deeplink: fileUrl,
              )
            : Helper.doLaunchUrl(
                url: fileUrl,
              );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16).r,
        decoration: BoxDecoration(
          color: AppColors.whiteGradientOne,
          border: Border.all(color: AppColors.grey16),
          borderRadius: BorderRadius.all(const Radius.circular(8.0).r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 28.w,
              width: 28.w,
              color: AppColors.appBarBackground,
              child: Icon(
                Icons.link_outlined,
                color: AppColors.darkBlue,
                size: 28.w,
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                fileUrl,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                      fontSize: 14.sp,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }

  String getFileNameFromUrl(String url) {
    try {
      Uri uri = Uri.parse(url);
      String fileName =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      return fileName;
    } catch (e) {
      return '';
    }
  }
}
