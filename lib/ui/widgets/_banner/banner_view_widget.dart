import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_banner/model/banner_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_banner/repository/banner_repository.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerViewWidget extends StatefulWidget {
  BannerViewWidget({Key? key}) : super(key: key);

  @override
  BannerViewWidgetState createState() => BannerViewWidgetState();
}

class BannerViewWidgetState extends State<BannerViewWidget> {
  final PageController _controller = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _timer;
  List<BannerData> banner = [];
  late Locale locale;

  @override
  void initState() {
    super.initState();
    banner = BannerRepository.getBanners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    if (banner.isEmpty) return;

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!mounted || banner.isEmpty) return;

      _currentPage = (_currentPage + 1) % banner.length;

      if (_controller.hasClients) {
        _controller.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _launchURL(String uri) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Helper.showToastMessage(context,
          message: AppLocalizations.of(context)!.mStaticErrorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    locale = Localizations.localeOf(context);
    return banner.isEmpty
        ? SizedBox()
        : Container(
            margin: EdgeInsets.only(top: 36).r,
            padding: EdgeInsets.only(bottom: 38).r,
            height: 250.w,
            width: 1.sw,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12)).r,
            ),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: banner.length,
                    itemBuilder: (context, index) {
                      final bannerData = banner[index];
                      final imageUrl =
                          bannerData.imageUrl.getImageUrl(locale.languageCode);

                      return InkWell(
                        onTap: () {
                          if (bannerData.redirectionUrl != null &&
                              bannerData.redirectionUrl!.isNotEmpty) {
                            _launchURL(bannerData.redirectionUrl!);
                          }
                        },
                        child: ImageWidget(
                          width: 1.sw,
                          boxFit: BoxFit.fill,
                          imageUrl: imageUrl,
                          enableImageCache: false,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10).r,
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: banner.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.orangeTourText,
                      dotColor: AppColors.profilebgGrey20,
                      dotHeight: 4.w,
                      dotWidth: 4.w,
                      spacing: 4.w,
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
