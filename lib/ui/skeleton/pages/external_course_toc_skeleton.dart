import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/index.dart';
import '../../pages/index.dart';
import '../../widgets/comment_section/pages/widgets/comment_view_skeleton.dart';
import '../../widgets/index.dart';
import '../index.dart';

class ExternalCourseTocSkeleton extends StatefulWidget {
  final bool? showCourseShareOption;
  final Function? courseShareOptionCallback;
  ExternalCourseTocSkeleton(
      {Key? key, this.showCourseShareOption, this.courseShareOptionCallback})
      : super(key: key);
  ExternalCourseTocSkeletonState createState() =>
      ExternalCourseTocSkeletonState();
}

class ExternalCourseTocSkeletonState extends State<ExternalCourseTocSkeleton>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<Color?> animation;
  TabController? learnTabController;
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

  @override
  void didChangeDependencies() {
    learnTabController = TabController(
        length: LearnTab.externalCourseTocTabs(context).length,
        vsync: this,
        initialIndex: 0);
    super.didChangeDependencies();
  }

  @override
  dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: LearnTab.externalCourseTocTabs(context).length,
        child: Stack(children: [
          NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: SafeArea(
              child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, innerBoxIsScrolled) {
                    return <Widget>[
                      TocAppbarWidget(
                        isOverview: true,
                        showCourseShareOption: widget.showCourseShareOption,
                        courseShareOptionCallback:
                            widget.courseShareOptionCallback,
                      ),
                      SliverToBoxAdapter(
                        child: TocContentHeaderSkeletonPage(),
                      ),
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: true,
                        flexibleSpace: Container(
                          color: AppColors.darkBlue,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ).r,
                            child: Container(
                              padding: EdgeInsets.only(top: 4).r,
                              color: AppColors.appBarBackground,
                              child: TabBar(
                                tabAlignment: TabAlignment.start,
                                isScrollable: true,
                                indicator: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.darkBlue,
                                      width: 2.0.w,
                                    ),
                                  ),
                                ),
                                indicatorColor: AppColors.appBarBackground,
                                labelPadding: EdgeInsets.only(top: 0.0).r,
                                unselectedLabelColor: AppColors.greys60,
                                labelColor: AppColors.darkBlue,
                                labelStyle: GoogleFonts.lato(
                                  fontSize: 10.0.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                unselectedLabelStyle: GoogleFonts.lato(
                                  fontSize: 10.0.sp,
                                  fontWeight: FontWeight.normal,
                                ),
                                tabs: [
                                  for (var tabItem
                                      in LearnTab.externalCourseTocTabs(
                                          context))
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16)
                                              .r,
                                      child: Tab(
                                        child: Padding(
                                          padding: EdgeInsets.all(5.0).r,
                                          child: Text(
                                            tabItem.title,
                                            style: GoogleFonts.lato(
                                              color: AppColors.greys87,
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                                controller: learnTabController,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: Container(
                    color: AppColors.lightBackground,
                    child:
                        TabBarView(controller: learnTabController, children: [
                      TocAboutSkeletonPage(),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16).w,
                        child: CommentViewSkeleton(itemCount: 10),
                      )
                    ]),
                  )),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 32).r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.lightGrey.withValues(alpha: 0),
                      AppColors.appBarBackground.withValues(alpha: 1)
                    ],
                  ),
                ),
                child: ContainerSkeleton(
                  height: 40.w,
                  width: 1.sw,
                  color: animation.value!,
                ),
              )),
        ]));
  }
}
