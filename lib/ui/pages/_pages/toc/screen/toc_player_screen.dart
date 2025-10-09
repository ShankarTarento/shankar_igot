import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/home_screen_components/hubs_strip/widgets/new_widget_animation.dart';
import 'package:karmayogi_mobile/igot_app.dart';
import 'package:karmayogi_mobile/services/_services/smartech_service.dart';
import 'package:karmayogi_mobile/models/_models/reference_nodes.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/blended_program_content/blended_program_content.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/player/toc_offline_player.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/teachers_notes/teachers_notes.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/transcript/transcript.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/screen/toc_open_resource.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/util/toc_helper.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/view_model/course_toc_view_model.dart';
import 'package:karmayogi_mobile/ui/widgets/base_scaffold.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/igot_ai_tutor/widgets/ai_tutor_button.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../constants/index.dart';
import '../../../../../models/_arguments/index.dart';
import '../../../../../models/_models/course_structure_model.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../skeleton/index.dart';
import '../../../../widgets/index.dart';
import '../../../index.dart';
import '../../learn/course_sharing/course_sharing_page.dart';
import '../model/navigation_model.dart';
import '../pages/about_tab/about_tab.dart';
import '../pages/course_comments.dart';
import '../widgets/overall_progress.dart';

class TocPlayerScreen extends StatefulWidget {
  final TocPlayerModel arguments;

  TocPlayerScreen({Key? key, required this.arguments}) : super(key: key);
  @override
  State<TocPlayerScreen> createState() => _TocPlayerScreenState();
}

class _TocPlayerScreenState extends State<TocPlayerScreen>
    with SingleTickerProviderStateMixin {
  Course? course;
  CourseHierarchyModel? courseHierarchyData;
  String? courseId, batchId, lastAccessContentId;
  TabController? learnTabController;
  Course? enrolledCourse;
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
  int? _numberOfCourseRating;
  double? _courseRating;
  bool isLearningPathContent = false;
  bool isContentProgressRead = false;
  ValueNotifier<bool> isCourseCompleted = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    enrolledCourse = widget.arguments.enrolledCourse;
    isCuratedProgram = widget.arguments.isCuratedProgram ?? false;
    batchId = widget.arguments.batchId;
    lastAccessContentId = widget.arguments.lastAccessContentId;
    isFeatured = widget.arguments.isFeatured != null
        ? widget.arguments.isFeatured!
        : false;
    courseId = widget.arguments.courseId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<TocServices>(context, listen: false).clearCourseProgress();
    });
    setIsLearningPathContent();
  }

  @override
  void dispose() {
    navigationItems.clear();
    super.dispose();
  }

  List<LearnTab> tabItems = [];
  List<ReferenceNode> teachersResource = [];
  List<ReferenceNode> referenceResource = [];

  Future<void> setTabItems() async {
    tabItems = LearnTab.tocPlayerTabs(context, isFeatured: isFeatured);

    if (!(course?.referenceNodes == null || course!.referenceNodes!.isEmpty) &&
        !isFeatured) {
      referenceResource = course!.referenceNodes!
          .where((e) => e.resourceCategory == PrimaryCategory.referenceResource)
          .toList();

      if (AppConfiguration.mentorshipEnabled) {
        bool isMentor =
            await Provider.of<ProfileRepository>(context, listen: false)
                .profileDetails!
                .roles!
                .contains(Roles.mentor.toUpperCase());

        if (isMentor) {
          teachersResource = course!.referenceNodes!
              .where(
                  (e) => e.resourceCategory == PrimaryCategory.teachersResource)
              .toList();

          if (teachersResource.isNotEmpty) {
            tabItems.add(
                LearnTab(title: AppLocalizations.of(context)!.mTeachersNotes));
          }
        }
      }
      if (referenceResource.isNotEmpty) {
        tabItems.add(
            LearnTab(title: AppLocalizations.of(context)!.mReferenceNotes));
      }
    }
    learnTabController = TabController(
      length: tabItems.length,
      vsync: this,
      initialIndex: 2,
    );
  }

  setIsLearningPathContent() async {
    isLearningPathContent = await CourseTocViewModel()
        .isLearningPathContentHelper(widget.arguments.courseId);
  }

  int? startAt;

  @override
  Widget build(BuildContext context) {
    Provider.of<LearnRepository>(context);
    if (Provider.of<LearnRepository>(context).courseRating != null) {
      _numberOfCourseRating = TocHelper.getTotalNumberOfRatings(
          Provider.of<LearnRepository>(context).courseRating);
      _courseRating = TocHelper.getRating(
          Provider.of<LearnRepository>(context).courseRating);
    }
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
          body: DefaultTabController(
            length: tabItems.length,
            child: Selector<LearnRepository, CourseStructure>(
                selector: (_, repo) =>
                    CourseStructure(repo.contentRead, repo.courseHierarchyInfo),
                builder: (context, value, child) {
                  if (course == null && value.contentRead.isNotEmpty) {
                    course = Course.fromJson(value.contentRead);
                  }
                  if (courseHierarchyData == null &&
                      value.courseHierarchyInfo.isNotEmpty) {
                    courseHierarchyData = CourseHierarchyModel.fromJson(
                        value.courseHierarchyInfo);
                    setTabItems();
                  }
                  if (course != null &&
                      courseHierarchyData != null &&
                      courseId == course!.id &&
                      courseId == courseHierarchyData!.identifier) {
                    if (navigationItems.isEmpty) {
                      if (course!.courseCategory ==
                          PrimaryCategory.curatedProgram) {
                        isCuratedProgram = true;
                      } else {
                        isCuratedProgram = false;
                      }
                      if (!isContentProgressRead) {
                        isContentProgressRead = true;
                        getContentAndProgress();
                        getReviews();
                        getYourRatingAndReview();
                      }
                    }
                    if (resourceNavigateItems.isEmpty) {
                      return TocPlayerSkeleton(
                          showCourseShareOption: false,
                          isFeatured: isFeatured,
                          courseShareOptionCallback:
                              _shareModalBottomSheetMenu);
                    }

                    if (course.runtimeType == String) {
                      return NoDataWidget(message: 'No course');
                    } else {
                      return NotificationListener<
                          OverscrollIndicatorNotification>(
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
                                      isOverview: false,
                                      showCourseShareOption:
                                          _showCourseShareOption(),
                                      courseShareOptionCallback:
                                          _shareModalBottomSheetMenu,
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
                                        return (resourceNavigateItems[courseIndex]
                                                    .mimeType !=
                                                EMimeTypes.offline)
                                            ? TocContentPlayer(
                                                startAt: startAt,
                                                courseHierarchyData:
                                                    courseHierarchyData!,
                                                batchId: enrolledCourse != null &&
                                                        enrolledCourse!.batchId !=
                                                            null
                                                    ? enrolledCourse!.batchId!
                                                    : '',
                                                changeLayout: manageScreen,
                                                fullScreen: fullScreen,
                                                isCuratedProgram: course
                                                            ?.cumulativeTracking !=
                                                        null &&
                                                    course!.cumulativeTracking,
                                                isFeatured: isFeatured,
                                                resourceNavigateItems:
                                                    resourceNavigateItems[
                                                        courseIndex],
                                                showLatestProgress:
                                                    updateContentProgress,
                                                primaryCategory: resourceNavigateItems[courseIndex]
                                                            is! List &&
                                                        resourceNavigateItems[courseIndex]
                                                            .primaryCategory
                                                            .isNotEmpty
                                                    ? resourceNavigateItems[
                                                            courseIndex]
                                                        .primaryCategory
                                                    : course!.courseCategory,
                                                navigationItems:
                                                    resourceNavigateItems,
                                                playNextResource: (value) {
                                                  _playNextResource(context);
                                                },
                                                updatePlayerProgress: value,
                                                courseCategory:
                                                    course!.courseCategory)
                                            : Consumer<TocServices>(
                                                builder:
                                                    (context, tocServices, _) {
                                                  return TocOfflinePlayer(
                                                    batch: tocServices.batch,
                                                    batches:
                                                        course?.batches ?? [],
                                                  );
                                                },
                                              );
                                      }),
                                  !fullScreen
                                      ? Column(children: [
                                          if (!isFeatured)
                                            OverallProgress(
                                                course: course!,
                                                enrolledCourse:
                                                    enrolledCourse!),
                                          Container(
                                            color: AppColors.greys87,
                                            width: 1.sw,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16.0),
                                                topRight: Radius.circular(16.0),
                                              ).r,
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(top: 4).r,
                                                color:
                                                    AppColors.appBarBackground,
                                                child: TabBar(
                                                  tabAlignment:
                                                      TabAlignment.start,
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
                                                  indicatorColor: AppColors
                                                      .appBarBackground,
                                                  labelPadding:
                                                      EdgeInsets.only(top: 0.0)
                                                          .r,
                                                  unselectedLabelColor:
                                                      AppColors.greys60,
                                                  labelColor:
                                                      AppColors.darkBlue,
                                                  labelStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall!
                                                      .copyWith(
                                                          fontSize: 10.sp,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                  unselectedLabelStyle:
                                                      Theme.of(context)
                                                          .textTheme
                                                          .headlineSmall!
                                                          .copyWith(
                                                              fontSize: 10.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                  tabs: getTabItems(),
                                                  controller:
                                                      learnTabController,
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
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              controller: learnTabController,
                                              children: [
                                                resourceNavigateItems[
                                                                    courseIndex]
                                                                .mimeType ==
                                                            EMimeTypes.mp4 &&
                                                        AppConfiguration
                                                            .iGOTAiConfig
                                                            .transcription
                                                    ? SingleChildScrollView(
                                                        child: Transcript(
                                                        resourceId:
                                                            resourceNavigateItems[
                                                                    courseIndex]
                                                                .identifier,
                                                        startAt: (value) {
                                                          startAt = value;
                                                          setState(() {});
                                                        },
                                                      ))
                                                    : SizedBox.shrink(),
                                                ValueListenableBuilder<bool>(
                                                    valueListenable:
                                                        isCourseCompleted,
                                                    builder:
                                                        (context, value, _) {
                                                      return AboutTab(
                                                          courseRead: course!,
                                                          enrolledCourse:
                                                              enrolledCourse,
                                                          courseHierarchy:
                                                              courseHierarchyData!,
                                                          isBlendedProgram:
                                                              false,
                                                          showCertificate:
                                                              value);
                                                    }),
                                                ((course!.courseCategory ==
                                                        PrimaryCategory
                                                            .blendedProgram))
                                                    ? Consumer<TocServices>(
                                                        builder: (context,
                                                            tocServices, _) {
                                                          return BlendedProgramContent(
                                                              courseDetails:
                                                                  course!,
                                                              batch: tocServices
                                                                  .batch,
                                                              course: course,
                                                              courseHierarchyData:
                                                                  courseHierarchyData,
                                                              courseId:
                                                                  courseId!,
                                                              lastAccessContentId:
                                                                  lastAccessContentId,
                                                              navigationItems:
                                                                  navigationItems,
                                                              enrolledCourse:
                                                                  enrolledCourse,
                                                              batches: course
                                                                      ?.batches ??
                                                                  [],
                                                              enrollmentList: widget
                                                                  .arguments
                                                                  .enrollmentList,
                                                              isPlayer: true,
                                                              showLatestProgress:
                                                                  () async =>
                                                                      await generateNavigation(),
                                                              startNewResourse:
                                                                  startNewResourse);
                                                        },
                                                      )
                                                    : TocContentPage(
                                                        courseId: courseId!,
                                                        course: course!,
                                                        enrolledCourse:
                                                            enrolledCourse,
                                                        courseHierarchy:
                                                            courseHierarchyData!,
                                                        navigationItems:
                                                            navigationItems,
                                                        lastAccessContentId:
                                                            lastAccessContentId,
                                                        startNewResourse:
                                                            startNewResourse,
                                                        isPlayer: true,
                                                        isFeatured: isFeatured,
                                                        enrollmentList: widget
                                                            .arguments
                                                            .enrollmentList,
                                                      ),
                                                if (!isFeatured)
                                                  CourseComments(
                                                    courseId: courseId ?? '',
                                                    isEnrolled: true,
                                                    bottomMargin: 0,
                                                    enableUserTagging: true,
                                                  ),
                                                if (teachersResource
                                                        .isNotEmpty &&
                                                    course != null)
                                                  TeachersNotes(
                                                    referenceNodes:
                                                        teachersResource,
                                                    type: PrimaryCategory
                                                        .teachersResource,
                                                    course: course!,
                                                  ),
                                                if (referenceResource
                                                        .isNotEmpty &&
                                                    course != null)
                                                  TeachersNotes(
                                                    referenceNodes:
                                                        referenceResource,
                                                    course: course!,
                                                    type: PrimaryCategory
                                                        .referenceResource,
                                                  ),
                                              ]),
                                        )
                                      : Center(),
                                ],
                              )),
                        ),
                      );
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
          ),
          bottomNavigationBar: BottomAppBar(
              child: TocPlayerButton(
            aiTutorButton: AppConfiguration.iGOTAiConfig.aiTutor &&
                    !TocHelper.hasScromContent(resourceNavigateItems)
                ? AiTutorButton(
                    tocContext: context,
                    resourceNavigationItems: resourceNavigateItems,
                    resourceId: AppConfiguration.iGOTAiConfig.useResourceId
                        ? lastAccessContentId ?? ""
                        : courseId ?? "",
                    onTap: (value) {
                      startAt = int.parse(value.contentStart != null &&
                              value.contentStart!.trim().isNotEmpty
                          ? value.contentStart!.trim()
                          : "0");
                      lastAccessContentId = value.identifier;
                      if (value.mimeType == EMimeTypes.pdf) {
                        startNewResourse(value.identifier);
                      }

                      setState(() {});
                    },
                  )
                : SizedBox(),
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
              var resourceNotCompleted = resourceNavigateItems
                  .where((item) => item.status != 2)
                  .firstOrNull;
              if (resourceNotCompleted == null) {
                Navigator.of(context).pop({'isFinished': true});
              } else {
                Navigator.pop(context);
              }
            },
          ))),
    ).withChatbotButton();
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
          totalProgress = TocHelper()
              .getCourseOverallProgress(totalProgress, resourceNavigateItems);
          if ((totalProgress / resourceNavigateItems.length) >
                  courseOverallProgress &&
              (totalProgress / resourceNavigateItems.length) -
                      courseOverallProgress >=
                  0.1) {
            courseOverallProgress =
                (totalProgress / resourceNavigateItems.length);
            /** SMT track course completion **/
            await trackCourseCompleted();
          }
          if (course != null &&
              TocHelper().isResourceLocked(
                  courseCategory: course!.courseCategory,
                  contextLockingType: course!.contextLockingType,
                  compatibilityLevel: course!.compatibilityLevel)) {
            TocHelper()
                .updateLock(resourceNavigateItems, widget.arguments.courseId);
          }
          final context = navigatorKey.currentContext!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<TocServices>(context, listen: false).setCourseProgress(
                (totalProgress / resourceNavigateItems.length));
          });
          isCourseCompleted.value =
              totalProgress / resourceNavigateItems.length == 1;
          await updateNavigationItems(navigationItems, data);

          Map<String, dynamic> languageProgress =
              Provider.of<LearnRepository>(context, listen: false)
                  .languageProgress;
          if (languageProgress.isNotEmpty &&
              languageProgress[course!.language.toLowerCase()] < 50 &&
              totalProgress / resourceNavigateItems.length >= 0.5) {
            Provider.of<LearnRepository>(context, listen: false)
                .readContentProgress(
                    enrolledCourse!.id, enrolledCourse!.batch!.batchId,
                    contentIds: course!.leafNodes,
                    language: course!.language,
                    forceUpdateOverallProgress: true);
          }
          break;
        }
      }
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {});
        }
      });
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

  void startNewResourse(String value) {
    if (lastAccessContentId != value) {
      startAt = null;
      setState(() {
        lastAccessContentId = value;
        getCurrentResourceIndex();
      });
    }
    if (resourceNavigateItems[courseIndex].mimeType != EMimeTypes.mp4 &&
        resourceNavigateItems[courseIndex].mimeType != EMimeTypes.m3u8 &&
        resourceNavigateItems[courseIndex].mimeType != EMimeTypes.mp3) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OpenResource(
                    startAt: startAt,
                    courseHierarchyData: courseHierarchyData!,
                    batchId: batchId!,
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
                    courseCategory: course!.courseCategory)));
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
      Future.microtask(() {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  Future<dynamic> generateNavigation() async {
    try {
      Map response = await TocHelper().generateNavigationItem(
          course: course!,
          courseHierarchyData: courseHierarchyData!,
          enrolledCourse: enrolledCourse,
          isPlayer: true,
          courseCategory: course!.courseCategory,
          isFeatured: widget.arguments.isFeatured ?? false,
          context: context,
          enrollmentList: widget.arguments.enrollmentList);
      navigationItems = response['navItems'];
      resourceNavigateItems = response['resourceNavItems'];
      double totalProgress = 0;
      totalProgress = TocHelper().getCourseOverallProgress(
          totalProgress, response['resourceNavItems']);
      if (totalProgress / resourceNavigateItems.length == 1) {
        isCourseCompleted.value = true;
      }
      Future.delayed(
          Duration(milliseconds: 500),
          () => Provider.of<TocServices>(context, listen: false)
              .setCourseProgress(
                  (totalProgress / resourceNavigateItems.length)));
    } catch (e) {
      print(e);
    }
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

  Future<void> getReviews() async {
    if (isFeatured) return;
    await Provider.of<LearnRepository>(context, listen: false)
        .getCourseReviewSummery(
            courseId: courseId!, primaryCategory: course!.primaryCategory);
  }

  Future<void> getYourRatingAndReview() async {
    if (!isFeatured)
      await Provider.of<LearnRepository>(context, listen: false).getYourReview(
          id: course!.id, primaryCategory: course!.primaryCategory);
  }

  Future<void> trackCourseCompleted() async {
    if ((prevCourseOverallProgress != courseOverallProgress) &&
        (courseOverallProgress >= 0.98)) {
      try {
        bool _isContentCompletionEnabled =
            await Provider.of<LearnRepository>(context, listen: false)
                .isSmartechEventEnabled(
                    eventName: SMTTrackEvents.contentCompletion);
        if (_isContentCompletionEnabled) {
          await SmartechService.trackCourseCompleted(
            courseCategory: course?.courseCategory ?? '',
            courseName: course?.name ?? '',
            image: course?.appIcon ?? '',
            contentUrl: "${ApiUrl.baseUrl}/app/toc/${course?.id ?? ''}",
            doId: course?.id ?? '',
            courseDuration: int.parse(course?.duration?.toString() ?? ''),
            learningPathContent: isLearningPathContent ? 1 : 0,
            provider: course?.source ?? '',
            courseRating: _courseRating,
            numberOfCourseRating: _numberOfCourseRating,
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }

  List<Widget> getTabItems() {
    final isMp4 =
        resourceNavigateItems[courseIndex].mimeType == EMimeTypes.mp4 &&
            AppConfiguration.iGOTAiConfig.transcription;

    return tabItems.map((tabItem) {
      final isTranscription =
          tabItem.title == AppLocalizations.of(context)!.mTranscript;

      if (isTranscription && !isMp4) {
        return const SizedBox.shrink();
      }

      return isTranscription
          ? Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16).r,
                  child: Tab(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
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
                ),
                Positioned(
                  right: 5,
                  top: 0,
                  child: NewWidgetAnimation(),
                ),
              ],
            )
          : Container(
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
            );
    }).toList();
  }
}
