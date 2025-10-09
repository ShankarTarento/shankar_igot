import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/constants/color_constants.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:igot_ui_components/ui/widgets/microsite_icon_button/microsite_icon_button.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/in_app_webview_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TocOfflinePlayer extends StatefulWidget {
  final List<Batch> batches;
  final Batch? batch;
  const TocOfflinePlayer(
      {Key? key,
        this.batch,
        required this.batches})
      : super(key: key);

  @override
  State<TocOfflinePlayer> createState() => TocOfflinePlayerState();
}

class TocOfflinePlayerState extends State<TocOfflinePlayer> {
  List<SessionDetailV2> sessionList = [];
  final _bannerPageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void initState() {
    getBatchAttributes();
    super.initState();
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TocOfflinePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (((oldWidget.batch != null && widget.batch != null) &&
        (oldWidget.batch!.batchId != widget.batch!.batchId)) ||
        (oldWidget.batch == null && widget.batch != null)) {
      getBatchAttributes();
    }
  }

  void getBatchAttributes() {
    if (widget.batch != null) {
      Batch? batch = widget.batches.cast<Batch?>().firstWhere(
            (element) => element!.batchId == widget.batch!.id,
        orElse: () => null,
      );
      if (batch != null) {
        sessionList = batch.batchAttributes!.sessionDetailsV2;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.w,
      width: 1.sw,
      color: AppColors.grey40,
      padding: EdgeInsets.symmetric(horizontal: 16).r,
      child: sessionItemWidgetSlider()
    );
  }

  Widget sessionItemWidgetSlider() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        _sessionView(),
        if (sessionList.isNotEmpty && sessionList.length > 1)
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
                      _currentPage = sessionList.length - 1;
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
                        if (_currentPage <
                            sessionList.length - 1) {
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
        sessionList.length > 1 ? Positioned(
          bottom: 16.w,
          child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10).w,
              child: SmoothPageIndicator(
                controller: _bannerPageController,
                count: sessionList.length,
                effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.orangeTourText,
                    dotColor: ModuleColors.profilebgGrey20,
                    dotHeight: 4,
                    dotWidth: 4,
                    spacing: 4),
              ),
            ),
          ),
        ) : const SizedBox.shrink()
      ],
    );
  }

  Widget _sessionView() {
    return (sessionList.isNotEmpty)
        ? SizedBox(
        height: 250.w,
        child: PageView.builder(
            controller: _bannerPageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: sessionList.length,
            itemBuilder: (context, pageIndex) {
              return sessionItemWidget(sessionList[pageIndex]);
            }))
        : const SizedBox.shrink();
  }

  Widget sessionItemWidget(SessionDetailV2 sessionDetailV2) {
    return (sessionDetailV2.attachLinks.isNotEmpty)
        ? Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if ((sessionDetailV2.attachLinks[0].logo??'').isNotEmpty)
              MicroSiteImageView(
                imgUrl: sessionDetailV2.attachLinks[0].logo??'',
                height: 60.w,
                width: 60.w,
                fit: BoxFit.fill,
              ),
            SizedBox(height: 8.w,),
            Text(
              sessionDetailV2.attachLinks[0].title??'',
              style: GoogleFonts.lato(
                  color: AppColors.appBarBackground,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  letterSpacing: 0.25),
              maxLines: 4,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.w,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context, FadeRoute(
                      page: InAppWebViewPage(
                          parentContext: context,
                          url: sessionDetailV2.attachLinks[0].url??'')),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6).r,
                decoration: BoxDecoration(
                    color: AppColors.orangeTourText,
                    borderRadius: BorderRadius.circular(63).r),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/img/link.svg',
                      height: 24.w,
                      width: 24.w,
                      colorFilter: ColorFilter.mode(
                          AppColors.greys87, BlendMode.srcIn),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      AppLocalizations.of(context)!.mStaticOpen,
                      style: GoogleFonts.lato(
                          color: AppColors.deepBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                          letterSpacing: 0.25),
                    )
                  ],
                ),
              ),
            ),
          ],
        ))
        : SizedBox.shrink();
  }
}