import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/bottom_bar.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/user_community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_explore.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_joined.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_tab.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_item_carousel_widget_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_topics_carousel_widget_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/global_feeds.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/popular_community_widget_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/base_scaffold.dart';
import 'package:karmayogi_mobile/ui/widgets/hubs_custom_app_bar.dart';
import 'package:provider/provider.dart';

class CommunityHome extends StatefulWidget {
  final int? defaultTabIndex;
  const CommunityHome({Key? key, this.defaultTabIndex}) : super(key: key);

  @override
  CommunityHomeState createState() => CommunityHomeState();
}

class CommunityHomeState extends State<CommunityHome>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  Future<List<UserCommunityIdData>>? _joinedCommunityFuture;
  bool _isLoading = false;
  List<UserCommunityIdData> _userJoinedCommunities = [];
  int _defaultTabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.defaultTabIndex != null)
      _defaultTabIndex = widget.defaultTabIndex!;
    _loadCategoryList();
  }

  Future<void> _loadCategoryList() async {
    _joinedCommunityFuture = _getUserJoinedCommunities();
  }

  Future<List<UserCommunityIdData>> _getUserJoinedCommunities() async {
    List<UserCommunityIdData> response = [];
    try {
      _isLoading = true;
      response = await Provider.of<DiscussionRepository>(context, listen: false)
          .getUserJoinedCommunities();
      _userJoinedCommunities = response;
      if (_userJoinedCommunities.isEmpty) {
        _defaultTabIndex = 1;
        _switchTab(_defaultTabIndex);
      }
      _isLoading = false;
      return Future.value(response);
    } catch (err) {
      _isLoading = false;
      return [];
    }
  }

  void _switchTab(int tabIndex) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        _controller.animateTo(tabIndex);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if ((CommunityTab.communityViewItems(context: context).length) >
        _defaultTabIndex) {
      _controller = TabController(
          length: CommunityTab.communityViewItems(context: context).length,
          vsync: this,
          initialIndex: _defaultTabIndex);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: buildLayout(),
    )).withChatbotButton();
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
        duration: Duration(milliseconds: 500),
        child: DefaultTabController(
          length: CommunityTab.communityViewItems(context: context).length,
          child: SafeArea(
              child: Scaffold(
            backgroundColor: AppColors.lightBackground,
            appBar: HubsCustomAppBar(
              title: AppLocalizations.of(context)!.mCommonDiscuss,
              titlePrefixIcon: Icon(Icons.question_answer, size: 24.sp, color: AppColors.darkBlue),
            ),
            body: bodyView(),
            bottomNavigationBar: BottomBar(),
          )),
        ),
      ),
      // bottomSheet: BottomBar()
    );
  }

  Widget bodyView() {
    return FutureBuilder(
      future: _joinedCommunityFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return (_isLoading) ? communityViewSkeleton() : Container();
        } else {
          return communityView();
        }
      },
    );
  }

  Widget communityViewSkeleton() {
    return SingleChildScrollView(
        child: Container(
      child: Column(
        children: [
          CommunityTopicsCarouselWidgetSkeleton(),
          PopularCommunityWidgetSkeleton(),
          CommunityItemCarouselWidgetSkeleton(),
          CommunityItemCarouselWidgetSkeleton(),
          CommunityItemCarouselWidgetSkeleton(),
        ],
      ),
    ));
  }

  Widget communityView() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.lightBackground,
            toolbarHeight: 40.w,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              height: 40.w,
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.w, color: AppColors.grey08),
                ),
              ),
              alignment: Alignment.center,
              child: TabBar(
                isScrollable: true,
                controller: _controller,
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.darkBlue,
                      width: 2.0.w,
                    ),
                  ),
                ),
                indicatorColor: AppColors.appBarBackground,
                labelPadding: EdgeInsets.only(right: 2.0).r,
                unselectedLabelColor: AppColors.greys60,
                labelColor: AppColors.darkBlue,
                labelStyle: GoogleFonts.lato(
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                unselectedLabelStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.disabledTextGrey),
                tabs: [
                  tabItemView(
                      AppLocalizations.of(context)!.mDiscussionFeeds,
                      Icon(
                        Icons.newspaper_outlined,
                        size: 20.w,
                      )),
                  tabItemView(
                      AppLocalizations.of(context)!.mDiscussionAllCommunities,
                      Icon(
                        Icons.diversity_2_outlined,
                        size: 20.w,
                      )),
                  tabItemView(
                      AppLocalizations.of(context)!.mDiscussionMyCommunities,
                      Icon(
                        Icons.diversity_2_outlined,
                        size: 20.w,
                      )),
                ],
              ),
            ),
          ),
        ];
      },
      // TabBar view
      body: Container(
        color: AppColors.lightBackground,
        child: FutureBuilder(
            future: Future.delayed(Duration(milliseconds: 500)),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return TabBarView(
                controller: _controller,
                children: [
                  GlobalFeeds(),
                  CommunityExplore(),
                  CommunityJoined(),
                ],
              );
            }),
      ),
    );
  }

  Widget tabItemView(String title, Widget prefixIcon) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16).r,
      child: Tab(
        child: Padding(
          padding: EdgeInsets.all(5.0).r,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4).w,
                child: prefixIcon,
              ),
              Text(
                title,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
