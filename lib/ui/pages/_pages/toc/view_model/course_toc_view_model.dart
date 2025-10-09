import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/reference_nodes.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/services/_services/smartech_service.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:provider/provider.dart';
import '../../../../../models/_arguments/index.dart';
import '../../../../../models/index.dart';
import '../../../../../util/telemetry_repository.dart';
import '../../../../widgets/buttons/button_with_border.dart';
import '../../../../widgets/index.dart';
import '../../../index.dart';
import '../model/language_map_model.dart';
import '../util/toc_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/compatibility_dialog.dart';

class CourseTocViewModel extends ChangeNotifier {
  // Dependencies
  final LearnRepository _learnRepository = LearnRepository();

  // Controllers
  TabController? _learnTabController;

  // Core State
  CourseTocModel? _arguments;
  String? _courseId;
  String? _baseCourseId;
  String? _batchId;
  String? _lastAccessContentId;
  String? overallCourseLanguage;
  Course? _course;
  CourseHierarchyModel? _courseHierarchyData;
  Map<String, String> programCourseLanguages = {};

  // Observable State
  final ValueNotifier<Course?> _enrolledCourse = ValueNotifier<Course?>(null);
  final ValueNotifier<List> _navigationItems = ValueNotifier([]);
  final ValueNotifier<bool> _isCourseCompleted = ValueNotifier(false);

  // Collections
  List<Batch> _batches = [];
  List<LearnTab> _tabItems = [];
  List<ReferenceNode> _teachersResource = [];
  List<ReferenceNode> _referenceResource = [];
  List _resourceNavigateItems = [];
  List<Course> _enrollmentList = [];

  // Flags
  bool _isRatingTriggered = false;
  bool _isFeaturedCourse = false;
  bool _isCuratedProgram = false;
  bool _isProgressRead = false;
  bool _showToc = false;
  bool _isBlendedProgram = false;
  bool _isModeratedContent = false;
  bool _focusRating = false;
  bool _smtTrackCourseViewEnabled = true;
  bool _isLearningPathContent = false;
  bool _isFeedbackPending = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isCourseCategoryNotCompatible = false;

  // Additional State
  int _tabInitialIndex = 0;
  int? _numberOfCourseRating;
  double? _courseRating;
  String? _error;

  // Getters
  TabController? get learnTabController => _learnTabController;
  Course? get course => _course;
  CourseHierarchyModel? get courseHierarchyData => _courseHierarchyData;
  ValueNotifier<Course?> get enrolledCourse => _enrolledCourse;
  ValueNotifier<List> get navigationItems => _navigationItems;
  ValueNotifier<bool> get isCourseCompleted => _isCourseCompleted;
  List<Batch> get batches => _batches;
  List<LearnTab> get tabItems => _tabItems;
  List<ReferenceNode> get teachersResource => _teachersResource;
  List<ReferenceNode> get referenceResource => _referenceResource;
  List get resourceNavigateItems => _resourceNavigateItems;
  List<Course> get enrollmentList => _enrollmentList;
  String? get courseId => _courseId;
  String? get batchId => _batchId;
  String? get lastAccessContentId => _lastAccessContentId;
  bool get isRatingTriggered => _isRatingTriggered;
  bool get isFeaturedCourse => _isFeaturedCourse;
  bool get isCuratedProgram => _isCuratedProgram;
  bool get isProgressRead => _isProgressRead;
  bool get showToc => _showToc;
  bool get isBlendedProgram => _isBlendedProgram;
  bool get isModeratedContent => _isModeratedContent;
  bool get focusRating => _focusRating;
  bool get isLearningPathContent => _isLearningPathContent;
  bool get isFeedbackPending => _isFeedbackPending;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  int? get numberOfCourseRating => _numberOfCourseRating;
  double? get courseRating => _courseRating;
  String? get error => _error;

  // Initialization
  Future<void> initialize(
      CourseTocModel arguments, BuildContext context) async {
    if (_isInitialized) return;

    _arguments = arguments;
    _navigationItems.value = [];
    _courseId = arguments.courseId;
    _isFeaturedCourse = arguments.isFeaturedCourse;
    _isFeedbackPending = arguments.isFeedbackPending;
    if (arguments.initialTabIndex != null) {
      _tabInitialIndex = arguments.initialTabIndex!;
    }

    await _setIsLearningPathContent();
    await fetchData(context);

    _isInitialized = true;
    notifyListeners();
  }

  // Main data fetching orchestrator
  Future<void> fetchData(BuildContext context) async {
    _setLoading(true);

    try {
      Provider.of<LearnRepository>(context, listen: false)
          .resetLanguageProgress();
      await getCourseInfo(context);
      if (!_isCourseCategoryNotCompatible) {
        await getEnrolmentInfo(context);
        await syncContentWithEnrollment(context);
        await getCourseHierarchyDetails(context);
        await _navigateToPlayer(context);

        if (!_isProgressRead &&
            _courseHierarchyData != null &&
            _course != null) {
          await getContentAndProgress(context);
        }

        if (_course != null && _courseHierarchyData != null && _showToc) {
          await _smtTrackCourseView();
        }

        if (!_isRatingTriggered && _course != null) {
          await getReviews(context);
          await _getYourRatingAndReview(_course, context);
          _isRatingTriggered = true;
        }

        await _generateTelemetryData(context);
        await setTabItems(context);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Content read api - To get all course details including batch info
  Future<void> getCourseInfo(BuildContext context) async {
    final courseInfo =
        await Provider.of<LearnRepository>(context, listen: false)
            .getCourseData(_courseId,
                isFeatured: _isFeaturedCourse,
                pointToProd: _arguments?.pointToProd ?? false);

    if (courseInfo != null) {
      _course = Course.fromJson(courseInfo);
      if (_course != null && _course!.languageMap.languages.isNotEmpty) {
        // Find the language key where id matches _courseId
        for (final entry in _course!.languageMap.languages.entries) {
          if (entry.value.id == _courseId) {
            overallCourseLanguage =
                entry.key; // Always use the key from the map
          }
          if (entry.value.isBaseLanguage) {
            _baseCourseId = entry.value.id;
          }
          if (overallCourseLanguage != null && _baseCourseId != null) {
            break;
          }
        }
      } else if (_course != null) {
        // Fallback: if not multilingual, try to match the language value to a key in masterLanguagesArray
        overallCourseLanguage =
            LanguageMapV1.getLanguageDisplayName(_course!.language);
        _baseCourseId = _course!.id;
      }
      _isBlendedProgram =
          _course!.courseCategory == PrimaryCategory.blendedProgram;
      _isModeratedContent = _course!.courseCategory
          .toString()
          .toLowerCase()
          .contains('moderated');

      if (_isBlendedProgram || _isModeratedContent) {
        await getBatchDetails(context);
      }

      if (_course!.courseCategory == PrimaryCategory.curatedProgram) {
        _isCuratedProgram = true;
      }

      await _checkCompatibility(context);
      notifyListeners();
    }
  }

  // Get enrolment info
  Future<void> getEnrolmentInfo(BuildContext context) async {
    List<Course> response = await _learnRepository
        .getCourseEnrollDetailsByIds(courseIds: [_baseCourseId!]);

    if (response.isNotEmpty) {
      _enrollmentList = response;
      _enrolledCourse.value = response.cast<Course?>().firstWhere(
          (course) => course!.id == _baseCourseId,
          orElse: () => null);

      if (_enrolledCourse.value != null) {
        _lastAccessContentId = _enrolledCourse.value!.lastReadContentId;
        _batchId = _enrolledCourse.value!.batchId;
      }
    }

    _isProgressRead = false;
    notifyListeners();
  }

  Future<void> syncContentWithEnrollment(BuildContext context) async {
    if (_enrolledCourse.value != null &&
        _enrolledCourse.value!.languageMap.languages.isNotEmpty &&
        _enrolledCourse.value?.completionPercentage != 100) {
      final String? recentLang = _enrolledCourse.value!.recent_language;
      if (recentLang != null) {
        if (recentLang.toLowerCase() != course!.language.toLowerCase()) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)).r,
            ),
            builder: (context) {
              return SafeArea(
                child: Container(
                  height: 0.35.sh,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32).r,
                  child: Column(
                    children: [
                      Icon(
                        Icons.translate,
                        size: 40.sp,
                        color: AppColors.darkBlue,
                      ),
                      SizedBox(height: 16.w),
                      Text(
                          AppLocalizations.of(context)!
                              .mTocAlreadyStartedCourse,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center),
                      SizedBox(height: 16.w),
                      Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text:
                              AppLocalizations.of(context)!.mTocYouHaveMadeSome,
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                                text:
                                    AppLocalizations.of(context)!.mTocProgress,
                                style:
                                    Theme.of(context).textTheme.displayLarge),
                            TextSpan(
                              text: AppLocalizations.of(context)!
                                  .mTocInAnotherLanguageCourse,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.w),
                      Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text:
                              AppLocalizations.of(context)!.mTocWouldYouLikeTo,
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .mTocWhereYouLeftOff,
                                style:
                                    Theme.of(context).textTheme.displayLarge),
                            TextSpan(
                              text: AppLocalizations.of(context)!
                                  .mTocContinueWithThisVersion,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ButtonWithBorder(
                              onPressCallback: () {
                                Navigator.of(context).pop();
                              },
                              text: AppLocalizations.of(context)!
                                  .mTocContinueHere,
                              borderRadius: 4,
                              padding: EdgeInsets.symmetric(horizontal: 16).r),
                          SizedBox(width: 8.w),
                          ButtonWithBorder(
                              onPressCallback: () async {
                                final languageEntry = _enrolledCourse
                                    .value!.languageMap.languages.entries
                                    .firstWhere(
                                  (entry) =>
                                      entry.value.name.toLowerCase() ==
                                      recentLang.toLowerCase(),
                                  orElse: () => MapEntry(
                                      '',
                                      LanguageContent(
                                          status: '',
                                          id: '',
                                          name: '',
                                          isBaseLanguage: false,
                                          selectedLanguage: false)),
                                );
                                if (languageEntry.key.isNotEmpty) {
                                  _courseId = languageEntry.value.id;
                                  overallCourseLanguage = languageEntry.key;
                                  await getCourseInfo(context);
                                  await getCourseHierarchyDetails(context);
                                  await getReviews(context);
                                  await _getYourRatingAndReview(
                                      _course, context);
                                  _isRatingTriggered = true;
                                  if (_courseHierarchyData != null &&
                                      _courseHierarchyData!.leafNodes
                                          .contains(_lastAccessContentId)) {
                                    _showToc = false;
                                  }
                                  notifyListeners();
                                }
                                Navigator.of(context).pop();
                              },
                              text: AppLocalizations.of(context)!.mLearnResume,
                              bgColor: AppColors.darkBlue,
                              textStyle:
                                  Theme.of(context).textTheme.displaySmall,
                              borderRadius: 4),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      }
    }
  }

  Future<void> getCourseHierarchyDetails(BuildContext context) async {
    final response = await Provider.of<LearnRepository>(context, listen: false)
        .getCourseDetails(_courseId,
            isFeatured: _isFeaturedCourse,
            pointToProd: _arguments?.pointToProd ?? false);

    if (response != null) {
      _courseHierarchyData = CourseHierarchyModel.fromJson(response);
      await setTabItems(context);
      notifyListeners();
    }
  }

  Future<void> getBatchDetails(BuildContext context) async {
    _batches = await Provider.of<LearnRepository>(context, listen: false)
        .getBatchList(_courseId);

    if (_course != null) {
      Provider.of<TocServices>(context, listen: false).setInitialBatch(
          batches: _batches,
          courseId: _course!.id,
          enrolledCourse: _enrolledCourse.value);
    }

    notifyListeners();
  }

  Future<void> setTabItems(BuildContext context) async {
    _tabItems = LearnTab.tocTabs(context, isFeatured: _isFeaturedCourse);

    if (!(_course?.referenceNodes == null ||
            _course!.referenceNodes!.isEmpty) &&
        !_isFeaturedCourse) {
      _referenceResource = _course!.referenceNodes!
          .where((e) => e.resourceCategory == PrimaryCategory.referenceResource)
          .toList();

      if (AppConfiguration.mentorshipEnabled) {
        bool isMentor =
            await Provider.of<ProfileRepository>(context, listen: false)
                .profileDetails!
                .roles!
                .contains(Roles.mentor.toUpperCase());

        if (isMentor) {
          _teachersResource = _course!.referenceNodes!
              .where(
                  (e) => e.resourceCategory == PrimaryCategory.teachersResource)
              .toList();

          if (_teachersResource.isNotEmpty) {
            _tabItems.add(
                LearnTab(title: AppLocalizations.of(context)!.mTeachersNotes));
          }
        }
      }

      if (_referenceResource.isNotEmpty) {
        _tabItems.add(
            LearnTab(title: AppLocalizations.of(context)!.mReferenceNotes));
      }
    }

    notifyListeners();
  }

  Future<void> getContentAndProgress(BuildContext context) async {
    if (!_isProgressRead && _course != null) {
      await _generateNavigation(context);
    }
  }

  Future<dynamic> _generateNavigation(BuildContext context) async {
    Map response = await TocHelper().generateNavigationItem(
        courseHierarchyData: _courseHierarchyData!,
        course: _course!,
        enrolledCourse: _enrolledCourse.value,
        isFeatured: _arguments?.isFeaturedCourse ?? false,
        context: context,
        enrollmentList: _enrollmentList);

    _resourceNavigateItems = response['resourceNavItems'];
    _navigationItems.value = response['navItems'];
    _isProgressRead = true;

    double totalProgress = 0;
    totalProgress = TocHelper()
        .getCourseOverallProgress(totalProgress, response['resourceNavItems']);
    _isCourseCompleted.value =
        totalProgress / _resourceNavigateItems.length == 1;

    Provider.of<TocServices>(context, listen: false)
        .setCourseProgress((totalProgress / _resourceNavigateItems.length));

    notifyListeners();
  }

  Future<void> getReviews(BuildContext context) async {
    if (_isFeaturedCourse) return;

    await Provider.of<LearnRepository>(context, listen: false)
        .getCourseReviewSummery(
            courseId: _courseId!, primaryCategory: _course!.primaryCategory);
  }

  Future<void> _getYourRatingAndReview(
      Course? course, BuildContext context) async {
    if (_isFeaturedCourse) return;

    await Provider.of<LearnRepository>(context, listen: false)
        .getYourReview(id: course!.id, primaryCategory: course.primaryCategory);
  }

  // UI Event Handlers
  void onTabTap(int index, BuildContext context) {
    _tabInitialIndex = index;
    FocusScope.of(context).unfocus();
    _generateInteractTelemetryData(
        index == 0
            ? TelemetryIdentifier.aboutTab
            : (index == 1)
                ? TelemetryIdentifier.contentTab
                : TelemetryIdentifier.commentsTab,
        context);
  }

  void onRatingClicked() {
    _focusRating = true;
    notifyListeners();
  }

  void onFeedbackSubmitted() {
    _isFeedbackPending = false;
    notifyListeners();
  }

  Future<void> readCourseProgress(BuildContext context) async {
    _isProgressRead = false;
    await getContentAndProgress(context);
  }

  Future<void> updateEnrolmentList(BuildContext context) async {
    await getEnrolmentInfo(context);
  }

  Future<void> clearCourse(BuildContext context) async {
    Provider.of<LearnRepository>(context, listen: false).clearCourseDetails();
    Provider.of<TocServices>(context, listen: false).clearCourseProgress();
  }

  // Navigation and sharing
  bool showCourseShareOption() {
    if (_course == null) return false;

    return (_course!.courseCategory != PrimaryCategory.inviteOnlyProgram &&
        _course!.courseCategory != PrimaryCategory.moderatedCourses &&
        _course!.courseCategory != PrimaryCategory.moderatedProgram &&
        _course!.courseCategory != PrimaryCategory.moderatedAssessment);
  }

  // Private helper methods
  Future<void> _setIsLearningPathContent() async {
    _isLearningPathContent = await isLearningPathContentHelper(_courseId ?? '');
  }

  Future<bool> isLearningPathContentHelper(String courseId) async {
    try {
      CbPlanModel? cbpList = await LearnRepository().getCbplan();

      if (cbpList == null) return false;

      final List<Content>? cbpCourse = cbpList.content;
      if (cbpCourse == null) return false;

      return cbpCourse.any((course) {
        final List<Course>? contentList = course.contentList;
        return contentList?.any((content) => content.id == courseId) ?? false;
      });
    } catch (_) {
      return false;
    }
  }

  Future<void> _smtTrackCourseView() async {
    if (_smtTrackCourseViewEnabled) {
      try {
        bool isContentViewEnabled = await _learnRepository
            .isSmartechEventEnabled(eventName: SMTTrackEvents.contentView);

        if (isContentViewEnabled) {
          Future.delayed(Duration(seconds: 1), () {
            SmartechService.trackCourseView(
              courseCategory: _course?.courseCategory ?? '',
              courseName: _course?.name ?? '',
              image: _course?.appIcon ?? '',
              contentUrl: "${ApiUrl.baseUrl}/app/toc/${_course?.id ?? ''}",
              doId: _course?.id ?? '',
              courseDuration: int.tryParse(_course?.duration?.toString() ?? ''),
              learningPathContent: _isLearningPathContent ? 1 : 0,
              provider: _course?.source ?? '',
              courseRating: _courseRating,
              numberOfCourseRating: _numberOfCourseRating,
            );
          });
          _smtTrackCourseViewEnabled = false;
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> _generateTelemetryData(BuildContext context) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: _isFeaturedCourse
            ? TelemetryPageIdentifier.publicCourseDetailsPageId
            : TelemetryPageIdentifier.courseDetailsPageId,
        telemetryType: TelemetryType.page,
        pageUri: (_isFeaturedCourse
                ? TelemetryPageIdentifier.publicCourseDetailsPageUri
                : TelemetryPageIdentifier.courseDetailsPageUri)
            .replaceAll(':do_ID', _courseId!),
        env: TelemetryEnv.learn,
        objectId: _courseId,
        objectType: _course?.courseCategory,
        isPublic: _isFeaturedCourse);

    await telemetryRepository.insertEvent(
        eventData: eventData, isPublic: _isFeaturedCourse);
  }

  Future<void> _generateInteractTelemetryData(
      String contentId, BuildContext context) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: (_isFeaturedCourse
                ? TelemetryPageIdentifier.publicCourseDetailsPageId
                : TelemetryPageIdentifier.courseDetailsPageId) +
            '_' +
            contentId,
        contentId: contentId,
        subType: TelemetrySubType.courseTab,
        env: TelemetryEnv.learn,
        isPublic: _isFeaturedCourse);

    await telemetryRepository.insertEvent(
        eventData: eventData, isPublic: _isFeaturedCourse);
  }

  Future<void> _checkCompatibility(BuildContext context) async {
    if (_course!.compatibilityLevel != 0) {
      _isCourseCategoryNotCompatible =
          await TocHelper.isCourseCategoryNotCompatible(
              courseCategory: _course!.courseCategory,
              compatibilityLevel: _course!.compatibilityLevel);

      if (_isCourseCategoryNotCompatible) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            backgroundColor: AppColors.grey04.withValues(alpha: 0.4),
            builder: (BuildContext context) {
              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 0.26.sh, bottom: 0.26.sh),
                  child: CompatibilityDialog(
                    closeCallback: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          );
        });
      }
    }
  }

  Future<void> _navigateToPlayer(BuildContext context) async {
    Course? enrolledCourseInfo = await TocHelper().checkIsCoursesInProgress(
        enrolledCourse: _enrolledCourse.value,
        courseId: _courseId!,
        context: context);

    if (enrolledCourseInfo != null &&
        enrolledCourseInfo.lastReadContentId != null &&
        _course != null &&
        _courseHierarchyData != null) {
      _showToc = false;
    } else {
      _showToc = true;
    }

    if (_enrolledCourse.value != null) {
      await getContentAndProgress(context);
    }

    notifyListeners();
  }

  Future<void> setOverallCourseLanguage(
      String language, BuildContext context) async {
    overallCourseLanguage = language;
    for (var entry in course!.languageMap.languages.entries) {
      if (entry.key == language) {
        _courseId = entry.value.id;
        _navigationItems.value = [];
        await getCourseInfo(context);
        await getEnrolmentInfo(context);
        await getCourseHierarchyDetails(context);

        if (!_isProgressRead &&
            _courseHierarchyData != null &&
            _course != null) {
          await getContentAndProgress(context);
        }
        if (_course != null) {
          await getReviews(context);
          await _getYourRatingAndReview(_course, context);
          _isRatingTriggered = true;
        }
      }
    }
    course!.languageMap.languages.forEach((key, val) {
      val.selectedLanguage = (key == language);
    });

    notifyListeners();
  }

  void setCourseLanguage(String courseId, String language) {
    programCourseLanguages[courseId] = language;
    notifyListeners();
  }

  String? getCourseLanguage(String courseId) {
    return programCourseLanguages[courseId];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Update TabController reference from View
  void setTabController(TabController controller) {
    _learnTabController = controller;
    notifyListeners();
  }

  // Get initial tab index for TabController creation
  int get initialTabIndex => _tabInitialIndex;

  void reset() {
    // Controllers
    _learnTabController = null;

    // Core State
    _arguments = null;
    _courseId = null;
    _batchId = null;
    _lastAccessContentId = null;
    overallCourseLanguage = null;
    _course = null;
    _courseHierarchyData = null;
    _baseCourseId = null;
    programCourseLanguages.clear();

    // Observable State
    _enrolledCourse.value = null;
    _navigationItems.value.clear();
    _isCourseCompleted.value = false;

    // Collections
    _batches.clear();
    _tabItems.clear();
    _teachersResource.clear();
    _referenceResource.clear();
    _resourceNavigateItems.clear();
    _enrollmentList.clear();

    // Flags
    _isRatingTriggered = false;
    _isFeaturedCourse = false;
    _isCuratedProgram = false;
    _isProgressRead = false;
    _showToc = false;
    _isBlendedProgram = false;
    _isModeratedContent = false;
    _focusRating = false;
    _smtTrackCourseViewEnabled = true;
    _isLearningPathContent = false;
    _isFeedbackPending = false;
    _isLoading = false;
    _isInitialized = false;

    // Additional State
    _tabInitialIndex = 0;
    _numberOfCourseRating = null;
    _courseRating = null;
    _error = null;
  }

  void setShowToc(bool value) {
    if (_showToc != value) {
      _showToc = value;
      notifyListeners();
    }
  }
}
