import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/toc_player_model.dart';
import 'package:karmayogi_mobile/models/_models/course_hierarchy_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/course_structure_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/course_sharing/course_sharing_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/model/navigation_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/about_tab.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/player/toc_content_player.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/player/toc_offline_player.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/services/toc_services.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/toc_content_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/screen/toc_open_resource.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/util/toc_helper.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/widgets/course_progress_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/widgets/toc_appbar_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/widgets/toc_player_button.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/toc_player_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/learn_tab.dart';
import 'package:karmayogi_mobile/ui/widgets/base_scaffold.dart';
import 'package:karmayogi_mobile/ui/widgets/title_regular_grey60.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PreTocPlayerScreen extends StatefulWidget {
  final TocPlayerModel arguments;

  PreTocPlayerScreen({Key? key, required this.arguments}) : super(key: key);
  @override
  State<PreTocPlayerScreen> createState() => _PreTocPlayerScreenState();
}

class _PreTocPlayerScreenState extends State<PreTocPlayerScreen>
    with SingleTickerProviderStateMixin {
  Course? course;
  CourseHierarchyModel? courseHierarchyData;
  String? courseId, lastAccessContentId;
  TabController? learnTabController;
  List navigationItems = [];
  List<NavigationModel> resourceNavigateItems = [];
  bool fullScreen = false,
      isCuratedProgram = false,
      isFeatured = false,
      isFetchDataCalled = false;
  int courseIndex = 0;
  double courseOverallProgress = 0;
  double prevCourseOverallProgress = 0;
  ValueNotifier<bool> updatePlayerProgress = ValueNotifier(false);
  bool isContentProgressRead = false;
  ValueNotifier<bool> isCourseCompleted = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    isCuratedProgram = widget.arguments.isCuratedProgram ?? false;
    lastAccessContentId = widget.arguments.lastAccessContentId;
    isFeatured = widget.arguments.isFeatured != null
        ? widget.arguments.isFeatured!
        : false;
    courseId = widget.arguments.courseId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<TocServices>(context, listen: false).clearCourseProgress();
    });
  }

  @override
  void dispose() {
    navigationItems.clear();
    super.dispose();
  }

  List<LearnTab> tabItems = [];

  Future<void> setTabItems() async {
    tabItems = LearnTab.preTocPlayerTabs(context);
    learnTabController = TabController(
      length: tabItems.length,
      vsync: this,
      initialIndex: 1,
    );
  }

  int? startAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        updatePlayerProgress.value = true;
        Future.delayed(Duration(seconds: 2), () {
          navigationItems.clear();
          Navigator.pop(context);
        });
      },
      child: Scaffold(
          body: buildBody(),
          bottomNavigationBar: bottomNavigationView()),
    ).withChatbotButton();
  }

  Widget buildBody() {
    return DefaultTabController(
      length: tabItems.length,
      child: Selector<LearnRepository, CourseStructure>(
          selector: (_, repo) => CourseStructure(repo.contentRead, repo.courseHierarchyInfo),
          builder: (context, value, child) {
            if (course == null && value.contentRead.isNotEmpty) {
              course = Course.fromJson(value.contentRead);
            }
            if (courseHierarchyData == null && course?.preEnrolmentResources != null) {
              courseHierarchyData = course?.preEnrolmentResources;
              courseHierarchyData?.identifier = course?.id ??'';
              courseHierarchyData?.name = course?.name ??'';
              setTabItems();
            }
            if (course != null && courseHierarchyData != null && courseId == course!.id && courseId == courseHierarchyData!.identifier) {
              if (navigationItems.isEmpty) {
                if (course!.courseCategory == PrimaryCategory.curatedProgram) {
                  isCuratedProgram = true;
                } else {
                  isCuratedProgram = false;
                }
                if (!isContentProgressRead) {
                  isContentProgressRead = true;
                  getContentAndProgress();
                }
              }
              if (resourceNavigateItems.isEmpty) {
                return TocPlayerSkeleton(
                    showCourseShareOption: false,
                    isFeatured: isFeatured,
                    courseShareOptionCallback: _shareModalBottomSheetMenu);
              }

              if (course.runtimeType == String) {
                return NoDataWidget(message: 'No course');
              } else {
                return buildPlayerView();
              }
            } else {
              // If content read or hierarchy is not called in one step resume of player call the content read and hierarchy API and get the data
              if (!isFetchDataCalled) {
                clearCourse(context);
                fetchCourseData();
                isFetchDataCalled = true;
              }
              return TocPlayerSkeleton(
                  showCourseShareOption: false,
                  courseShareOptionCallback: _shareModalBottomSheetMenu);
            }
          }),
    );
  }

  Widget buildPlayerView() {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: SafeArea(
        child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, innerBoxIsScrolled) {
              return <Widget>[
                TocAppbarWidget(
                    isOverview: false,
                    showCourseShareOption: _showCourseShareOption(),
                    courseShareOptionCallback: _shareModalBottomSheetMenu,
                    isPlayer: true,
                    courseId: courseId!),
              ];
            },
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<bool>(
                    valueListenable: updatePlayerProgress,
                    builder: (context, value, _) {
                      return (resourceNavigateItems[courseIndex].mimeType != EMimeTypes.offline)
                          ? TocContentPlayer(
                        startAt: startAt,
                        courseHierarchyData: courseHierarchyData!,
                        batchId: '',
                        changeLayout: manageScreen,
                        fullScreen: fullScreen,
                        isCuratedProgram: course?.cumulativeTracking != null && course!.cumulativeTracking,
                        isFeatured: isFeatured,
                        resourceNavigateItems: resourceNavigateItems[courseIndex],
                        showLatestProgress: updateContentProgress,
                        primaryCategory: resourceNavigateItems[courseIndex] is! List && resourceNavigateItems[courseIndex].primaryCategory.isNotEmpty
                            ? resourceNavigateItems[courseIndex].primaryCategory
                            : course!.courseCategory,
                        navigationItems: resourceNavigateItems,
                        playNextResource: (value) {
                          _playNextResource(context);
                        },
                        updatePlayerProgress: value,
                        courseCategory:
                        course!.courseCategory,
                        isPreRequisite: true
                      )
                          : Consumer<TocServices>(
                        builder: (context, tocServices, _) {
                          return TocOfflinePlayer(
                            batch: tocServices.batch,
                            batches: course?.batches ?? [],
                          );
                        },
                      );
                    }),
                if (!fullScreen && !isFeatured)
                  progressView(),
                !fullScreen ? Column(children: [
                  Container(
                    color: AppColors.greys87,
                    width: 1.sw,
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
                                color:
                                AppColors.darkBlue,
                                width: 2.0.w,
                              ),
                            ),
                          ),
                          indicatorColor: AppColors.appBarBackground,
                          labelPadding: EdgeInsets.only(top: 0.0).r,
                          unselectedLabelColor: AppColors.greys60,
                          labelColor: AppColors.darkBlue,
                          labelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600),
                          unselectedLabelStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400),
                          tabs: [
                            for (var tabItem in tabItems)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16).r,
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
                  SizedBox(
                    height: 8.w,
                  )
                ])
                    : Center(),
                !fullScreen
                    ? Expanded(
                  child: TabBarView(
                      controller: learnTabController,
                      children: [
                        ValueListenableBuilder<bool>(
                            valueListenable: isCourseCompleted,
                            builder: (context, value, _) {
                              return AboutTab(
                                  courseRead: course!,
                                  courseHierarchy: courseHierarchyData!,
                                  isBlendedProgram:
                                  false,
                                  showCertificate:
                                  value);
                            }),
                        TocContentPage(
                          courseId: courseId!,
                          course: course!,
                          courseHierarchy: courseHierarchyData!,
                          navigationItems: navigationItems,
                          lastAccessContentId: lastAccessContentId,
                          startNewResourse: startNewResource,
                          isPlayer: true,
                          isFeatured: isFeatured,
                          enrollmentList: widget.arguments.enrollmentList,
                        )
                      ]),
                )
                    : Center(),
              ],
            )),
      ),
    );
  }

  Widget progressView() {
    double progress = 0;
    return Consumer<TocServices>(builder: (context, tocServices, _) {
      var courseProgress = tocServices.courseProgress;
      if (courseProgress != null) {
        progress = courseProgress;
      }
      return Container(
          height: 50.w,
          padding: EdgeInsets.only(left: 16, right: 16,).r,
          width: 1.sw,
          color: (progress * 100).toInt() == COURSE_COMPLETION_PERCENTAGE
              ? AppColors.deepBlue
              : AppColors.appBarBackground,
          child: CourseProgressWidget(
              progress: progress,
              width: 200.w)
      );
    });
  }

  Widget bottomNavigationView() {
    return BottomAppBar(
        child: TocPlayerButton(
          aiTutorButton: SizedBox(),
          courseIndex: courseIndex,
          resourceNavigateItems: resourceNavigateItems,
          clickedPrevious: () {
            startAt = null;
            setState(() {
              courseIndex--;
              lastAccessContentId =
                  resourceNavigateItems[courseIndex].contentId;
            });
          },
          clickedNext: () {
            startAt = null;

            setState(() {
              courseIndex++;
              lastAccessContentId =
                  resourceNavigateItems[courseIndex].contentId;
            });
          },
          clickedFinish: () {
            Navigator.of(context).pop({'isFinished': true});
          },
        ));
  }

  void _playNextResource(BuildContext context) {
    startAt = null;
    if (courseIndex < resourceNavigateItems.length - 1) {
      setState(() {
        courseIndex++;
        lastAccessContentId = resourceNavigateItems[courseIndex].contentId;
      });
    }
  }

  Future<void> getContentAndProgress() async {
    await generateNavigation();
    await getLastAccessContentId();
    setState(() {});
  }

  void manageScreen(bool fullScreen) {
    setState(() {
      fullScreen = fullScreen;
    });
  }

  Future<void> updateContentProgress(Map data) async {
    if (!isFeatured) {
      for (int i = 0; i < resourceNavigateItems.length; i++) {
        if (resourceNavigateItems[i].identifier == data['identifier']) {
          resourceNavigateItems[i].completionPercentage =
              data['completionPercentage'];
          resourceNavigateItems[i].currentProgress =
              data['mimeType'] == EMimeTypes.assessment
                  ? data['completionPercentage'].toString()
                  : data['current'].toString();
          if ((data['mimeType'] == EMimeTypes.youtubeLink &&
                  data['completionPercentage'].toString() == '1') ||
              data['completionPercentage'] == 1) {
            resourceNavigateItems[i].status = 2;
          }
          double totalProgress = 0;
          totalProgress = TocHelper().getCourseOverallProgress(totalProgress, resourceNavigateItems);
          if ((totalProgress / resourceNavigateItems.length) >
                  courseOverallProgress &&
              (totalProgress / resourceNavigateItems.length) -
                      courseOverallProgress >=
                  0.1) {
            courseOverallProgress =
                (totalProgress / resourceNavigateItems.length);
          }
          if (course != null &&
              TocHelper().isResourceLocked(
                  courseCategory: course!.courseCategory,
                  contextLockingType: course!.contextLockingType,
                  compatibilityLevel:
                      course!.compatibilityLevel)) {
            TocHelper()
                .updateLock(resourceNavigateItems, widget.arguments.courseId);
          }

          Provider.of<TocServices>(context, listen: false).setCourseProgress(
              (totalProgress / resourceNavigateItems.length));
          isCourseCompleted.value = totalProgress / resourceNavigateItems.length == 1;
          await updateNavigationItems(navigationItems, data);
          break;
        }
      }
      Future.delayed(Duration.zero, () => setState(() {}));
    }
  }

  Future<void> getLastAccessContentId() async {
    if (lastAccessContentId == null) {
      if (resourceNavigateItems.first is! List) {
        lastAccessContentId = resourceNavigateItems.first.identifier;
      } else {}
    }

    if (resourceNavigateItems.isNotEmpty && lastAccessContentId != null) {
      getCurrentResourceIndex();
    }
    double totalProgress = 0;
    totalProgress = TocHelper()
        .getCourseOverallProgress(totalProgress, resourceNavigateItems);

    courseOverallProgress = totalProgress / resourceNavigateItems.length;
    prevCourseOverallProgress = courseOverallProgress;
  }

  void getCurrentResourceIndex() {
    courseIndex = resourceNavigateItems.indexWhere((element) =>
        (element is! List && element.contentId == lastAccessContentId));
    if (courseIndex < 0) {
      courseIndex = 0;
    }
  }

  void startNewResource(String value) {
    if (lastAccessContentId != value) {
      startAt = null;
      setState(() {
        lastAccessContentId = value;
        getCurrentResourceIndex();
      });
    }
    if (resourceNavigateItems[courseIndex].mimeType != EMimeTypes.mp4 &&
        resourceNavigateItems[courseIndex].mimeType != EMimeTypes.m3u8 &&
        resourceNavigateItems[courseIndex].mimeType != EMimeTypes.mp3 &&
        resourceNavigateItems[courseIndex].mimeType != EMimeTypes.collection) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OpenResource(
                      startAt: startAt,
                      courseHierarchyData: courseHierarchyData!,
                      batchId: '',
                      changeLayout: manageScreen,
                      isCuratedProgram: course?.cumulativeTracking != null &&
                          course!.cumulativeTracking,
                      isFeatured: isFeatured,
                      resourceNavigateItem: resourceNavigateItems[courseIndex],
                      navigationItems: resourceNavigateItems,
                      showLatestProgress: updateContentProgress,
                      primaryCategory: resourceNavigateItems[courseIndex]
                              .primaryCategory
                              .isNotEmpty
                          ? resourceNavigateItems[courseIndex].primaryCategory
                          : course!.courseCategory,
                      playNextResource: (value) {
                        _playNextResource(context);
                      },
                      courseCategory: course!.courseCategory,
                      isPreRequisite: true
                    )));
      });
    }
  }

  bool _showCourseShareOption() {
    return (course!.courseCategory != PrimaryCategory.inviteOnlyProgram &&
        course!.courseCategory != PrimaryCategory.moderatedCourses &&
        course!.courseCategory != PrimaryCategory.moderatedProgram &&
        course!.courseCategory != PrimaryCategory.moderatedAssessment);
  }

  void _shareModalBottomSheetMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
            child: CourseSharingPage(course!.id, course!.name, course!.appIcon,
                course!.source, course!.courseCategory, receiveShareResponse));
      },
    );
  }

  void receiveShareResponse(String data) {
    _showSuccessDialogBox();
  }

  _showSuccessDialogBox() => {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (BuildContext contxt) => FutureBuilder(
                future:
                    Future.delayed(Duration(seconds: 3)).then((value) => true),
                builder: (BuildContext futureContext, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    Navigator.of(contxt).pop();
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AlertDialog(
                          insetPadding: EdgeInsets.symmetric(horizontal: 16).r,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12).r),
                          actionsPadding: EdgeInsets.zero.r,
                          actions: [
                            Container(
                              padding: EdgeInsets.all(16).r,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12).r,
                                  color: AppColors.positiveLight),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: TitleRegularGrey60(
                                        AppLocalizations.of(context)!
                                            .mContentSharePageSuccessMessage,
                                        fontSize: 14.sp,
                                        color: AppColors.appBarBackground,
                                        maxLines: 3,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 4, 4, 0)
                                            .r,
                                    child: Icon(
                                      Icons.check,
                                      color: AppColors.appBarBackground,
                                      size: 24.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ],
                  );
                }))
      };

  updateNavigationItems(navigationItem, data) {
    for (var child in navigationItem) {
      if (child is! List) {
        if (child.contentId == data['identifier']) {
          child.currentProgress = data['current'].toString();
          child.completionPercentage = data['completionPercentage'];
          return;
        }
      } else {
        updateNavigationItems(child, data);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<dynamic> generateNavigation() async {
    Map response = await TocHelper().generatePreEnrollNavigationItem(
        course: course!,
        courseHierarchyData: courseHierarchyData!,
        isPlayer: true,
        courseCategory: course!.courseCategory,
        isFeatured: widget.arguments.isFeatured ?? false,
        context: context);
    navigationItems = response['navItems'];
    resourceNavigateItems = response['resourceNavItems'];
    double totalProgress = 0;
    totalProgress = TocHelper()
        .getCourseOverallProgress(totalProgress, response['resourceNavItems']);
    if (totalProgress / resourceNavigateItems.length == 1) {
      isCourseCompleted.value = true;
    }
    Future.delayed(
        Duration(milliseconds: 500),
        () => Provider.of<TocServices>(context, listen: false)
            .setCourseProgress((totalProgress / resourceNavigateItems.length)));
  }

  Future<void> fetchCourseData() async {
    await getCourseInfo();
    await getCourseHierarchyDetails();
  }

  // Content read api - To get all course details including batch info
  Future<void> getCourseInfo() async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getCourseData(courseId);
  }

  Future<void> getCourseHierarchyDetails() async {
    await Provider.of<LearnRepository>(context, listen: false)
        .getCourseDetails(courseId, isFeatured: isFeatured);
  }

  void clearCourse(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //Clear content read, hierarchy, rating and review
      Provider.of<LearnRepository>(context, listen: false).clearCourseDetails();
      //Clear course progress
      Provider.of<TocServices>(context, listen: false).clearCourseProgress();
    });
  }
}
