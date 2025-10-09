import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/skeleton/profile_tab_skeleton.dart';

import '../../../../../../constants/index.dart';
import '../../../../../skeleton/index.dart';
import '../../../../../widgets/index.dart';
import 'profile_top_section_skeleton.dart';

class ProfileDashboardSkeleton extends StatefulWidget {
  final bool notMyUser;
  final bool showMyActivity;
  final bool isMyProfile;
  const ProfileDashboardSkeleton(
      {Key? key,
      required this.notMyUser,
      this.showMyActivity = false,
      this.isMyProfile = false})
      : super(key: key);

  @override
  State<ProfileDashboardSkeleton> createState() =>
      _ProfileDashboardSkeletonState();
}

class _ProfileDashboardSkeletonState extends State<ProfileDashboardSkeleton>
    with TickerProviderStateMixin {
  TabController? tabController;
  AnimationController? _controller;
  late Animation<Color?> animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    animation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey04,
            end: AppColors.grey08,
          ),
        ),
        TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(
            begin: AppColors.grey04,
            end: AppColors.grey08,
          ),
        ),
      ],
    ).animate(_controller!)
      ..addListener(() {
        setState(() {});
      });
    _controller!.repeat();
  }

  void _initializeTabController() {
    List<String> tabItems = _getTabItems();

    tabController?.dispose();
    tabController = TabController(
      length: tabItems.length,
      vsync: this,
      initialIndex: 0,
    );
  }

  List<String> _getTabItems() {
    List<String> tabItems = !widget.notMyUser && widget.isMyProfile
        ? [
            AppLocalizations.of(context)!.mStaticProfile,
            AppLocalizations.of(context)!.mStaticMyActivities,
          ]
        : [
            AppLocalizations.of(context)!.mStaticProfile,
          ];

    return tabItems;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTabController();
  }

  @override
  dispose() {
    _controller!.dispose();
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabItems = _getTabItems();
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      body: SafeArea(
          child: DefaultTabController(
        length: tabItems.length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: AppColors.appBarBackground,
                      padding: const EdgeInsets.all(16).r,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.only(right: 50).r,
                            icon: Icon(Icons.arrow_back_ios,
                                color: AppColors.greys60, size: 20.sp),
                          ),
                          SizedBox(height: 8.w),
                          ContainerSkeleton(
                            height: 25.w,
                            width: 40.w,
                            color: animation.value,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 8.w),
                    ContainerSkeleton(
                      height: 0.3.sw,
                      width: 1.0.sw,
                      radius: 0,
                      color: animation.value ?? AppColors.grey04,
                    ),
                    ProfileTopSectionSkeleton(
                      color: animation.value ?? AppColors.grey04,
                    )
                  ],
                ),
              ),
              SliverPersistentHeader(
                  pinned: true,
                  floating: false,
                  delegate: SilverAppBarDelegate(TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.grey08,
                          width: 2.0,
                        ),
                      ),
                    ),
                    indicatorColor: AppColors.appBarBackground,
                    labelPadding: EdgeInsets.only(top: 0.0).r,
                    unselectedLabelColor: AppColors.greys60,
                    labelColor: AppColors.grey08,
                    labelStyle: Theme.of(context).textTheme.displayLarge,
                    unselectedLabelStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.greys60),
                    controller: tabController,
                    tabs: tabItems
                        .map((tabItem) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16).r,
                              child: Tab(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ContainerSkeleton(
                                    height: 25.w,
                                    width: 80.w,
                                    radius: 8,
                                    color: animation.value,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  )))
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: [
              Padding(
                padding: const EdgeInsets.all(16).r,
                child: ProfileTabSkeleton(
                    color: animation.value ?? AppColors.grey04,
                    isMyProfile: widget.isMyProfile),
              ),
              if (!widget.notMyUser && widget.isMyProfile) ...{
                ListView(
                  children: [
                    StatsSkeleton(),
                    WeeklyclapSkeleton(),
                    DiscussSkeleton()
                  ],
                )
              }
            ],
          ),
        ),
      )),
    );
  }
}
