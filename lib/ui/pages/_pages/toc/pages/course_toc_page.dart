import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/about_tab.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/about_tab/widgets/igot_tutor_atrip.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/teachers_notes/teachers_notes.dart';
import 'package:karmayogi_mobile/ui/widgets/base_scaffold.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:provider/provider.dart';
import '../../../../../models/_arguments/index.dart';
import '../../../../../models/index.dart';
import '../../../../../respositories/index.dart';
import '../../../../skeleton/index.dart';
import '../../../index.dart';
import '../../learn/course_sharing/course_sharing_page.dart';
import '../util/toc_helper.dart';
import '../view_model/course_toc_view_model.dart';
import '../widgets/rate_now_pop_up.dart';
import '../widgets/toc_button_widget.dart';
import 'about_tab/widgets/enroll_blended_program_button.dart';
import 'blended_program_content/blended_program_content.dart';
import 'course_comments.dart';

class CourseTocPage extends StatefulWidget {
  final CourseTocModel arguments;

  CourseTocPage({Key? key, required this.arguments}) : super(key: key);

  @override
  State<CourseTocPage> createState() => _CourseTocPageState();
}

class _CourseTocPageState extends State<CourseTocPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController? _tabController;
  bool _isInitialized = false;
  late CourseTocViewModel viewModel;
  String _tagCommentId = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      if (widget.arguments.tagCommentId != null &&
          widget.arguments.tagCommentId!.isNotEmpty) {
        _tagCommentId = widget.arguments.tagCommentId!;
      }

      viewModel = Provider.of<CourseTocViewModel>(context, listen: false);

      // Delay the call to clearCourseProgress until after the build phase
      Future.microtask(() {
        Provider.of<TocServices>(context, listen: false).clearCourseProgress();
        viewModel.clearCourse(context);

        // Initialize the view model
        viewModel.initialize(widget.arguments, context).then((_) {
          if (!mounted) return;

          // Create the tab controller
          setState(() {
            _createTabController(viewModel);
          });

          // Check if player needs to be opened
          doOneStepResume();
        });
      });

      _isInitialized = true;
    }
  }

  void doOneStepResume() {
    if (!viewModel.showToc &&
        viewModel.enrolledCourse.value != null &&
        (viewModel.course != null &&
            viewModel.course!.languageMap.languages.isNotEmpty &&
            viewModel.enrolledCourse.value!.recent_language?.toLowerCase() ==
                viewModel.course!.language.toLowerCase()) &&
        viewModel.lastAccessContentId != null &&
        _tagCommentId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamed(
          context,
          AppUrl.tocPlayer,
          arguments: TocPlayerModel(
            enrolledCourse: viewModel.enrolledCourse.value!,
            batchId: viewModel.enrolledCourse.value!.batchId ?? '',
            lastAccessContentId: viewModel.lastAccessContentId!,
            courseId: viewModel.course!.id,
            isFeatured: widget.arguments.isFeaturedCourse,
            enrollmentList: viewModel.enrollmentList,
          ),
        ).then((result) {
          // Handle post-player result if needed
          if (result is Map<String, bool> && result['isFinished'] == true) {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              backgroundColor: AppColors.greys60,
              builder: (_) => RateNowPopUp(courseDetails: viewModel.course!),
            ).whenComplete(() {
              context
                  .read<InAppReviewRespository>()
                  .triggerInAppReviewPopup(context);
            });
          }
        });

        // Mark TOC as shown to prevent re-navigation
        viewModel.setShowToc(true);
      });
    } else {
      viewModel.setShowToc(true);
    }
  }

  void _createTabController(CourseTocViewModel viewModel) {
    if (viewModel.tabItems.isNotEmpty) {
      _tabController?.dispose();
      _tabController = TabController(
        length: viewModel.tabItems.length,
        vsync: this,
        initialIndex: viewModel.initialTabIndex,
      );
      viewModel.setTabController(_tabController!);
    }
  }

  @override
  void dispose() {
    viewModel.navigationItems.value.clear();
    viewModel.reset();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseTocViewModel>(
      builder: (context, viewModel, child) {
        // Recreate TabController when tab items change
        if (viewModel.tabItems.isNotEmpty &&
            (_tabController == null ||
                _tabController!.length != viewModel.tabItems.length)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _createTabController(viewModel);
          });
        }

        return SafeArea(
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _doPopAction();
            },
            child: Scaffold(
              resizeToAvoidBottomInset:
                  viewModel.isBlendedProgram ? false : true,
              body: _buildBody(viewModel),
            ),
          ),
        ).withChatbotButton();
      },
    );
  }

  Widget _buildBody(CourseTocViewModel viewModel) {
    if (viewModel.isLoading ||
        !viewModel.isInitialized ||
        viewModel.error != null) {
      return TocSkeletonPage(
        showCourseShareOption: false,
        isFeatured: widget.arguments.isFeaturedCourse,
        courseShareOptionCallback: () => _shareModalBottomSheetMenu(viewModel),
      );
    } else if (viewModel.course != null &&
        viewModel.courseHierarchyData != null &&
        viewModel.showToc) {
      return _buildMainContent(viewModel);
    } else if (viewModel.course != null &&
        viewModel.courseHierarchyData != null) {
      doOneStepResume();
      return TocSkeletonPage(
        showCourseShareOption: false,
        isFeatured: widget.arguments.isFeaturedCourse,
        courseShareOptionCallback: () => _shareModalBottomSheetMenu(viewModel),
      );
    } else {
      return TocSkeletonPage(
        showCourseShareOption: false,
        isFeatured: widget.arguments.isFeaturedCourse,
        courseShareOptionCallback: () => _shareModalBottomSheetMenu(viewModel),
      );
    }
  }

  Widget _buildMainContent(CourseTocViewModel viewModel) {
    if (_tabController == null || viewModel.tabItems.isEmpty) {
      return TocSkeletonPage(
        showCourseShareOption: false,
        isFeatured: widget.arguments.isFeaturedCourse,
        courseShareOptionCallback: () => _shareModalBottomSheetMenu(viewModel),
      );
    }

    return DefaultTabController(
      length: viewModel.tabItems.length,
      child: Stack(
        children: [
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
                    _buildAppBar(viewModel),
                    _buildContentHeader(viewModel),
                    _buildTabBar(viewModel),
                  ];
                },
                body: _buildTabBarView(viewModel),
              ),
            ),
          ),
          _buildBottomActions(viewModel),
        ],
      ),
    );
  }

  Widget _buildAppBar(CourseTocViewModel viewModel) {
    return TocAppbarWidget(
      isOverview: true,
      showCourseShareOption: viewModel.showCourseShareOption(),
      courseShareOptionCallback: () => _shareModalBottomSheetMenu(viewModel),
    );
  }

  Widget _buildContentHeader(CourseTocViewModel viewModel) {
    return SliverToBoxAdapter(
      child: ValueListenableBuilder<Course?>(
        valueListenable: viewModel.enrolledCourse,
        builder: (context, value, _) {
          return TocContentHeader(
            course: viewModel.course!,
            enrolledCourse: value,
            isFeedbackPending: viewModel.isFeedbackPending,
            recommendationId: widget.arguments.recommendationId,
            clickedRating: viewModel.onRatingClicked,
            submitFeedback: viewModel.onFeedbackSubmitted,
          );
        },
      ),
    );
  }

  Widget _buildTabBar(CourseTocViewModel viewModel) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      flexibleSpace: Container(
        color: AppColors.darkBlue,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0).r,
            topRight: Radius.circular(16.0).r,
          ),
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
              labelStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
              unselectedLabelStyle:
                  Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
              onTap: (value) => viewModel.onTabTap(value, context),
              tabs: viewModel.tabItems
                  .map((tabItem) => Container(
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
                      ))
                  .toList(),
              controller: _tabController,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBarView(CourseTocViewModel viewModel) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAboutTab(viewModel),
        _buildContentTab(viewModel),
        if (!(widget.arguments.isFeaturedCourse)) _buildCommentsTab(viewModel),
        if (viewModel.teachersResource.isNotEmpty && viewModel.course != null)
          TeachersNotes(
            referenceNodes: viewModel.teachersResource,
            course: viewModel.course!,
            type: PrimaryCategory.teachersResource,
          ),
        if (viewModel.referenceResource.isNotEmpty && viewModel.course != null)
          TeachersNotes(
            referenceNodes: viewModel.referenceResource,
            course: viewModel.course!,
            type: PrimaryCategory.referenceResource,
          ),
      ],
    );
  }

  Widget _buildAboutTab(CourseTocViewModel viewModel) {
    return ValueListenableBuilder<bool>(
      valueListenable: viewModel.isCourseCompleted,
      builder: (context, value, _) {
        return AboutTab(
          aiTutorStrip: _buildAiTutorStrip(viewModel),
          isBlendedProgram: viewModel.isBlendedProgram,
          courseRead: viewModel.course!,
          enrolledCourse: viewModel.enrolledCourse.value,
          courseHierarchy: viewModel.courseHierarchyData!,
          highlightRating: viewModel.focusRating,
          showCertificate: value,
        );
      },
    );
  }

  Widget _buildAiTutorStrip(CourseTocViewModel viewModel) {
    if (AppConfiguration.iGOTAiConfig.aiTutor &&
        !widget.arguments.isFeaturedCourse &&
        !TocHelper.hasScromContent(viewModel.resourceNavigateItems)) {
      return Selector<TocServices, Batch?>(
        selector: (context, tocServices) => tocServices.batch,
        builder: (context, batch, _) {
          return IgotTutorAtrip(
            isBlendedProgram: viewModel.isBlendedProgram,
            isModerated: viewModel.isModeratedContent,
            courseDetails: viewModel.course!,
            enrolledCourse: viewModel.enrolledCourse.value,
            navigationItems: viewModel.navigationItems.value,
            isCuratedProgram: viewModel.isCuratedProgram,
            batchId: viewModel.batchId,
            courseId: viewModel.courseId!,
            lastAccessContentId: viewModel.lastAccessContentId,
            selectedBatch: batch,
            readCourseProgress: () => viewModel.readCourseProgress(context),
            updateEnrolmentList: () => viewModel.updateEnrolmentList(context),
            resourceNavigateItems: viewModel.resourceNavigateItems,
            numberOfCourseRating: viewModel.numberOfCourseRating,
            isLearningPathContent: viewModel.isLearningPathContent,
            courseRating: viewModel.courseRating,
            isFeatured: widget.arguments.isFeaturedCourse,
            enrollmentList: viewModel.enrollmentList,
            isEnrolled: viewModel.enrolledCourse.value != null,
          );
        },
      );
    } else {
      return SizedBox();
    }
  }

  Widget _buildContentTab(CourseTocViewModel viewModel) {
    if (viewModel.isBlendedProgram) {
      return Consumer<TocServices>(
        builder: (context, tocServices, _) {
          return ValueListenableBuilder<List>(
            valueListenable: viewModel.navigationItems,
            builder: (context, value, _) {
              return BlendedProgramContent(
                courseDetails: viewModel.course!,
                batch: tocServices.batch,
                course: viewModel.course,
                courseHierarchyData: viewModel.courseHierarchyData,
                courseId: viewModel.courseId!,
                lastAccessContentId: viewModel.lastAccessContentId,
                navigationItems: value,
                enrolledCourse: viewModel.enrolledCourse.value,
                enrollmentList: viewModel.enrollmentList,
                batches: viewModel.batches,
                showLatestProgress: () => viewModel.readCourseProgress(context),
              );
            },
          );
        },
      );
    }

    return ValueListenableBuilder<List>(
      valueListenable: viewModel.navigationItems,
      builder: (context, value, _) {
        return TocContentPage(
          courseId: viewModel.courseId!,
          course: viewModel.course!,
          enrolledCourse: viewModel.enrolledCourse.value,
          courseHierarchy: viewModel.courseHierarchyData!,
          navigationItems: value,
          lastAccessContentId: viewModel.lastAccessContentId,
          readCourseProgress: () {
            if (viewModel.enrolledCourse.value != null) {
              viewModel.readCourseProgress(context);
            }
          },
          startNewResourse: (value) {},
          isFeatured: widget.arguments.isFeaturedCourse,
          enrollmentList: viewModel.enrollmentList,
        );
      },
    );
  }

  Widget _buildCommentsTab(CourseTocViewModel viewModel) {
    return CourseComments(
      courseId: viewModel.courseId ?? '',
      isEnrolled: viewModel.enrolledCourse.value != null,
      bottomMargin: viewModel.isBlendedProgram ? 180 : 32,
      tagCommentId: _tagCommentId,
      backToAllCommentsCallback: () {
        _tagCommentId = '';
      },
      enableUserTagging: true,
    );
  }

  Widget _buildBottomActions(CourseTocViewModel viewModel) {
    return Positioned(
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
              AppColors.appBarBackground.withValues(alpha: 1),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            viewModel.isBlendedProgram
                ? _buildBlendedProgramButton(viewModel)
                : _buildTocButton(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildBlendedProgramButton(CourseTocViewModel viewModel) {
    return Consumer<TocServices>(
      builder: (context, tocServices, _) {
        return EnrollBlendedProgramButton(
          batches: viewModel.batches,
          selectedBatch: tocServices.batch,
          courseDetails: viewModel.course!,
          enrolledCourse: viewModel.enrolledCourse.value,
          lastAccessContentId: viewModel.lastAccessContentId,
          navigationItems: viewModel.navigationItems.value,
          courseId: viewModel.courseId!,
          readCourseProgress: () => viewModel.readCourseProgress(context),
          numberOfCourseRating: viewModel.numberOfCourseRating,
          isLearningPathContent: viewModel.isLearningPathContent,
          courseRating: viewModel.courseRating,
          isFeatured: widget.arguments.isFeaturedCourse,
          enrollmentList: viewModel.enrollmentList,
        );
      },
    );
  }

  Widget _buildTocButton(CourseTocViewModel viewModel) {
    return Selector<TocServices, Batch?>(
      selector: (context, tocServices) => tocServices.batch,
      builder: (context, batch, _) {
        if (viewModel.batches.isNotEmpty) {
          viewModel.course!.batches = viewModel.batches;
        }

        return TocButtonWidget(
            isStandAloneAssesment: viewModel.course!.courseCategory ==
                EnglishLang.standaloneAssessment,
            isModerated: viewModel.isModeratedContent,
            courseDetails: viewModel.course!,
            enrolledCourse: viewModel.enrolledCourse.value,
            navigationItems: viewModel.navigationItems.value,
            isCuratedProgram: viewModel.isCuratedProgram,
            batchId: viewModel.batchId,
            courseId: viewModel.courseId!,
            lastAccessContentId: viewModel.lastAccessContentId,
            selectedBatch: batch,
            readCourseProgress: () => viewModel.readCourseProgress(context),
            updateEnrolmentList: () => viewModel.updateEnrolmentList(context),
            resourceNavigateItems: viewModel.resourceNavigateItems,
            numberOfCourseRating: viewModel.numberOfCourseRating,
            isLearningPathContent: viewModel.isLearningPathContent,
            courseRating: viewModel.courseRating,
            isFeatured: widget.arguments.isFeaturedCourse,
            enrollmentList: viewModel.enrollmentList,
            recommendationId: widget.arguments.recommendationId);
      },
    );
  }

  // Event Handlers
  void _doPopAction() {
    final viewModel = Provider.of<CourseTocViewModel>(context, listen: false);
    viewModel.navigationItems.value.clear();
    Navigator.pop(context);
  }

  void _shareModalBottomSheetMenu(CourseTocViewModel viewModel) {
    if (viewModel.course == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          child: CourseSharingPage(
            viewModel.course!.id,
            viewModel.course!.name,
            viewModel.course!.appIcon,
            viewModel.course!.source,
            viewModel.course!.courseCategory,
            _receiveShareResponse,
          ),
        );
      },
    );
  }

  void _receiveShareResponse(String data) {
    _showSuccessDialogBox();
  }

  void _showSuccessDialogBox() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext contxt) => FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)).then((value) => true),
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
                  borderRadius: BorderRadius.circular(12).r,
                ),
                actionsPadding: EdgeInsets.zero.r,
                actions: [
                  Container(
                    padding: EdgeInsets.all(16).r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12).r,
                      color: AppColors.positiveLight,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          padding: const EdgeInsets.fromLTRB(16, 4, 4, 0).r,
                          child: Icon(
                            Icons.check,
                            color: AppColors.appBarBackground,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
