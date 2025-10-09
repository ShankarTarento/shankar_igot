import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../constants/index.dart';
import '../../../../util/faderoute.dart';
import '../microsites/screen/microsite_screen/ati_cti_microsites_screen.dart';
import '../microsites/screen/all_provider_screen/browse_by_all_provider.dart';

class TopProviders extends StatefulWidget {
  final List<TopProviderModel>? topProviderList;
  const TopProviders({Key? key, this.topProviderList}) : super(key: key);

  @override
  TopProvidersState createState() => TopProvidersState();

}

class TopProvidersState extends State<TopProviders> {

  PageController _pageController = PageController(initialPage: 1, viewportFraction: 0.4);
  int _currentIndex = 0;
  late Timer _timer;
  bool _isScrollingRight = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_isScrollingRight) {
        if (_currentIndex < 998) {
          _currentIndex++;
        } else {
          _isScrollingRight = false;
        }
      } else {
        if (_currentIndex > 0) {
          _currentIndex--;
        } else {
          _isScrollingRight = true;
        }
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(seconds: 3),
        curve: Curves.linear,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _headerView(),
        SizedBox(height: 16.w,),
        ((widget.topProviderList??[]).length > 2) ? _buildAutoScrollView() : _buildListView(),
      ],
    );
  }

  Widget _headerView() {
    return Padding(
      padding: EdgeInsets.only(left: 8, top: 16).w,
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Text(
              AppLocalizations.of(context)!.mStaticTopProvidersTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                color: AppColors.greys87,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              width: 60.w,
              child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      FadeRoute(page: BrowseByAllProvider()),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                          AppLocalizations.of(context)!.mStaticShowAll,
                          style: GoogleFonts.lato(
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            letterSpacing: 0.12.r,
                          ),
                          overflow: TextOverflow.ellipsis
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.darkBlue,
                        size: 20.w,
                      )
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAutoScrollView() {
    return Center(
      child: Container(
        height: 120.0.w,
        child: PageView.builder(
          controller: _pageController,
          itemBuilder: (context, itemIndex) {
            return _itemView(itemIndex % (widget.topProviderList??[]).length);
          },
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Container(
        height: 120.0.w,
        margin: EdgeInsets.symmetric(horizontal: 8).w,
        child: AnimationLimiter(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: (widget.topProviderList??[]).length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                      child: _itemView(index)
                  ),
                ),
              );
            },
          ),
        )
    );
  }

  Widget _itemView(int index) {
    return Container(
      width: 150.w,
      color: AppColors.appBarBackground,
      child: InkWell(
          onTap: () => Navigator.push(
            context,
            FadeRoute(
                page: AtiCtiMicroSitesScreen(
                  providerName: widget.topProviderList![index].clientName,
                  orgId: widget.topProviderList![index].orgId,
                )),
          ),
          child: Container(
            width: 150.w,
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 8)
                .r,
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
                        color: AppColors.grey16))),
            child: Column(
              children: [
                Image(
                  height: 60.w,
                  width: 80.w,
                  image: NetworkImage(
                    ApiUrl.baseUrl +
                        '/' +
                        widget.topProviderList![index].clientImageUrl!,
                  ),
                  errorBuilder:
                      (context, error, stackTrace) =>
                      Center(),
                ),
                SizedBox(height: 4.w),
                Text(
                  widget.topProviderList![index].clientName ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    letterSpacing: 0.25.sp,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          )),
    );
  }

}
