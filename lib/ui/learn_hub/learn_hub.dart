import 'dart:io';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/custom_tab_bar/custom_tab_bar.dart';
import 'package:karmayogi_mobile/ui/learn_hub/constants/learn_hub_constants.dart';
import 'package:karmayogi_mobile/ui/learn_hub/screens/explore_by/learn_explore_by.dart';
import 'package:karmayogi_mobile/ui/learn_hub/screens/learn_overview_screen/learn_overview_screen.dart';
import 'package:karmayogi_mobile/ui/learn_hub/screens/your_learning_screen/your_learning_screen.dart';
import 'package:karmayogi_mobile/ui/learn_hub/widgets/custom_sliver_appbar.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/bottom_bar.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/learn_main_tab.dart';
import 'package:karmayogi_mobile/ui/widgets/base_scaffold.dart';
import 'package:karmayogi_mobile/ui/widgets/hubs_banner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants/_constants/app_routes.dart';

class LearnHub extends StatefulWidget {
  static const route = AppUrl.learningHub;

  @override
  _LearnHubState createState() => _LearnHubState();
}

class _LearnHubState extends State<LearnHub>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  final service = HttpClient();

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _controller = TabController(
        length: LearnHubConstants.learnHubTabs.length,
        vsync: this,
        initialIndex: 0);
    _scrollController = ScrollController();
    super.didChangeDependencies();
  }

  void switchIntoYourLearningTab() {
    setState(() {
      _controller.index = 1;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: buildLayout(),
    );
  }

  Widget buildLayout() {
    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (
          Widget child,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        duration: Duration(milliseconds: 0),
        child: DefaultTabController(
          length: LearnMainTab.items(context: context).length,
          child: SafeArea(
              child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                CustomSliverAppBar(
                  title: AppLocalizations.of(context)!.mStaticLearn,
                  leading: Padding(
                    padding: const EdgeInsets.only(right: 8).r,
                    child: ImageWidget(
                        imageUrl: 'assets/img/Learn.svg',
                        imageColor: AppColors.darkBlue,
                        width: 24.0.w,
                        height: 24.0.w),
                  ),
                ),
                HubsBanner(
                  imageUrl: ApiUrl.baseUrl +
                      "/assets/mobile_app/banners/banner_learn_hub.png",
                ),
                SliverPersistentHeader(
                  pinned: true,
                  floating: false,
                  delegate: _TabBarDelegate(
                    height: 48.0.h,
                    child: CustomTabBar(
                      onTabChange: (value) {},
                      tabController: _controller,
                      tabTitles: LearnHubConstants.learnHubTabs,
                    ),
                  ),
                )
              ];
            },

            // TabBar view
            body: Container(
              color: AppColors.lightBackground,
              child: TabBarView(
                controller: _controller,
                children: [
                  LearnOverviewScreen(
                    scrollToTop: _scrollToTop,
                    switchIntoYourLearningTab: switchIntoYourLearningTab,
                  ),
                  YourLearningScreen(),
                  LearnExploreBy(),
                ],
              ),
            ),
          )),
        ),
      ),
      bottomSheet: BottomBar(),
    ).withChatbotButton();
  }

  void _scrollToTop() {
    _scrollController.animateTo(0.0,
        duration: Duration(seconds: 1), curve: Curves.ease);
  }
}

// Fixed SliverPersistentHeaderDelegate implementation
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _TabBarDelegate({
    required this.child,
    this.height = 48.0, // Default tab bar height
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: height,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}
