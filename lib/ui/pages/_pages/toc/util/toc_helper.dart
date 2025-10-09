import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/learn_compatibility_constants.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:provider/provider.dart';
import '../../../../../constants/index.dart';
import '../../../../../respositories/_respositories/learn_repository.dart';
import '../../../index.dart';
import '../model/content_state_model.dart';
import '../model/navigation_model.dart';
import '../model/progress_model.dart';
import '../view_model/toc_player_view_model.dart';
import 'toc_constants.dart';

class TocHelper {
  Future<Course?> checkIsCoursesInProgress(
      {Course? enrolledCourse,
      required String courseId,
      BuildContext? context}) async {
    if (enrolledCourse != null &&
        enrolledCourse.lastReadContentId != null &&
        enrolledCourse.status.toString() != '2') {
      var response = await getCourseInfo(courseId, context!);
      if (response != null && response.isNotEmpty) {
        Course courseInfo = Course.fromJson(response);
        if (courseInfo.courseCategory == PrimaryCategory.moderatedProgram) {
          if (isProgramLive(enrolledCourse)) {
            return enrolledCourse;
          } else {
            return null;
          }
        } else if (courseInfo.courseCategory ==
            PrimaryCategory.blendedProgram) {
          if (isProgramLive(enrolledCourse)) {
            return enrolledCourse;
          } else {
            return null;
          }
        } else if (isInviteOnlyProgram(courseInfo)) {
          if (isProgramLive(enrolledCourse)) {
            return enrolledCourse;
          } else {
            return null;
          }
        } else {
          return enrolledCourse;
        }
      }
    }
    return null;
  }

  Course? checkCourseEnrolled({String? id, List<Course>? enrolmentList}) {
    if (enrolmentList == null && enrolmentList!.isEmpty) {
      return null;
    } else {
      return enrolmentList.cast<Course?>().firstWhere(
            (element) => element!.contentId == id,
            orElse: () => null,
          );
    }
  }

  // Content read api - To get all course details including batch info
  Future<dynamic> getCourseInfo(String courseId, BuildContext context) async {
    return await Provider.of<LearnRepository>(context, listen: false)
        .getCourseData(courseId);
  }

  isInviteOnlyProgram(Course courseInfo) {
    return courseInfo.batches != null &&
        courseInfo.batches!.isNotEmpty &&
        courseInfo.batches![0].enrollmentType == "invite-only";
  }

  bool isProgramLive(enrolledCourse) {
    var batchStartDate =
        DateTime.parse(enrolledCourse.raw['batch']['startDate']).toLocal();
    var batchEndDate = enrolledCourse.raw['batch']['endDate'] != null
        ? DateTime.parse(enrolledCourse.raw['batch']['endDate']).toLocal()
        : null;

    var now = DateTime.now();

    bool isLive = (batchStartDate.isBefore(now) ||
            batchStartDate
                .isAtSameMomentAs(DateTime(now.year, now.month, now.day))) &&
        (batchEndDate == null ||
            batchEndDate.isAfter(now) ||
            batchEndDate
                .isAtSameMomentAs(DateTime(now.year, now.month, now.day)));

    return isLive;
  }

  bool checkInviteOnlyProgramIsActive(
      Course courseDetails, Course? enrolledCourse) {
    if (courseDetails.batches != null &&
        courseDetails.batches!.isNotEmpty &&
        courseDetails.batches![0].enrollmentType == "invite-only") {
      DateTime today = DateTime.now();
      if (enrolledCourse != null) {
        if (DateTime.parse(enrolledCourse.batch!.startDate)
            .isAfter(DateTime(today.year, today.month, today.day))) {
          return false;
        } else if ((DateTime.parse(enrolledCourse.batch!.startDate)
                    .isBefore(DateTime(today.year, today.month, today.day)) ||
                DateTime.parse(enrolledCourse.batch!.startDate)
                    .isAtSameMomentAs(
                        DateTime(today.year, today.month, today.day))) &&
            (DateTime.parse(enrolledCourse.batch!.endDate)
                    .isAfter(DateTime(today.year, today.month, today.day)) ||
                DateTime.parse(enrolledCourse.batch!.endDate).isAtSameMomentAs(
                    DateTime(today.year, today.month, today.day)))) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else if (courseDetails.batches != null &&
        courseDetails.batches!.isNotEmpty &&
        courseDetails.batches![0].enrollmentType == 'open' &&
        enrolledCourse != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> generateNavigationItem(
      {required CourseHierarchyModel courseHierarchyData,
      required Course course,
      required BuildContext context,
      required List<Course> enrollmentList,
      Course? enrolledCourse,
      bool isPlayer = false,
      String? courseCategory,
      bool isFeatured = false}) async {
    int index;
    int k = 0;
    List tempNavItems = [];

    List<NavigationModel> resourceNavigateItems = [];
    bool isCompleted = false;
    List<ContentStateModel> parentContentList = [];
    double? currentLangProgress;
    late Map<String, dynamic> languageProgress;

    if (!isFeatured) {
      if (enrolledCourse != null) {
        isCompleted =
            enrolledCourse.completionPercentage == COURSE_COMPLETION_PERCENTAGE;
        if (!isCompleted ||
            enrolledCourse.languageMap.languages.isNotEmpty &&
                enrolledCourse.languageMap.languages.length > 1) {
          parentContentList.clear();
          parentContentList =
              await Provider.of<LearnRepository>(context, listen: false)
                  .readContentProgress(
                      enrolledCourse.id, enrolledCourse.batch!.batchId,
                      contentIds: course.leafNodes,
                      language: course.language,
                      forceUpdateOverallProgress: true);
          if (course.languageMap.languages.isNotEmpty &&
              enrolledCourse.completionPercentage ==
                  COURSE_COMPLETION_PERCENTAGE) {
            Provider.of<TocServices>(context, listen: false)
                .setCourseProgress(1.0);
          } else {
            getOverallProgress(parentContentList, course, context);
          }

          languageProgress =
              Provider.of<LearnRepository>(context, listen: false)
                  .languageProgress;
          if (languageProgress.isNotEmpty &&
              languageProgress[course.language.toLowerCase()] != null) {
            currentLangProgress =
                languageProgress[course.language.toLowerCase()];
          }
          isCompleted = enrolledCourse.completionPercentage ==
                  COURSE_COMPLETION_PERCENTAGE &&
              (currentLangProgress == COURSE_COMPLETION_PERCENTAGE);
        }
      }
    }
    if (courseHierarchyData.children != null) {
      for (index = 0; index < courseHierarchyData.children!.length; index++) {
        String? parentBatchId = null;
        String? parentCourseId = null;
        String? language = null;
        List<ContentStateModel> contentList = [];

        if (course.cumulativeTracking && !isFeatured) {
          isCompleted = false;
          if (enrolledCourse != null &&
              courseHierarchyData.children![index].parent ==
                  courseHierarchyData.identifier &&
              enrolledCourse.id ==
                  TocPlayerViewModel().getEnrolledCourseId(
                      context, courseHierarchyData.identifier)) {
            parentBatchId = enrolledCourse.batchId;
            parentCourseId = enrolledCourse.id;
            language = course.language;
            isCompleted = enrolledCourse.completionPercentage ==
                    COURSE_COMPLETION_PERCENTAGE &&
                (currentLangProgress == null ||
                    currentLangProgress == COURSE_COMPLETION_PERCENTAGE);
          }
          Course? enrolledSubCourse = enrollmentList.cast<Course?>().firstWhere(
              (course) =>
                  course!.id ==
                  TocPlayerViewModel().getEnrolledCourseId(
                      context, courseHierarchyData.children![index].identifier),
              orElse: () => null);

          if (enrolledSubCourse != null) {
            try {
              parentBatchId = enrolledSubCourse.batch!.batchId;
              parentCourseId = enrolledSubCourse.id;
              Map<String, dynamic>? _course = await LearnRepository()
                  .getCourseData(
                      courseHierarchyData.children![index].identifier,
                      isFeatured: isFeatured);
              language =
                  _course != null ? Course.fromJson(_course).language : null;

              double? currentSubCourseLangProgress;
              if (languageProgress.isNotEmpty &&
                  language != null &&
                  languageProgress[language.toLowerCase()] != null) {
                currentSubCourseLangProgress =
                    languageProgress[language.toLowerCase()];
              }
              isCompleted = enrolledSubCourse.completionPercentage ==
                      COURSE_COMPLETION_PERCENTAGE &&
                  (currentSubCourseLangProgress == null ||
                      currentSubCourseLangProgress ==
                          COURSE_COMPLETION_PERCENTAGE);
              if (!isCompleted && language != null) {
                contentList.clear();
                contentList = await LearnRepository().readContentProgress(
                    enrolledSubCourse.id, enrolledSubCourse.batch!.batchId,
                    contentIds: course.leafNodes, language: language);
              }
            } catch (e) {}
          } else if (courseHierarchyData.children![index].mimeType !=
                  EMimeTypes.collection &&
              enrolledCourse != null) {
            try {
              contentList.clear();
              contentList = await LearnRepository().readContentProgress(
                  enrolledCourse.id, enrolledCourse.batch!.batchId,
                  contentIds: course.leafNodes,
                  language: language ?? course.language);
            } catch (e) {}
          } else {
            contentList = parentContentList;
          }
        } else if (!course.cumulativeTracking) {
          if (!isFeatured) {
            contentList = parentContentList;
          }
          language = course.language;
        }
        if ((courseHierarchyData.children![index].contentType == 'Collection' ||
            courseHierarchyData.children![index].contentType == 'CourseUnit')) {
          List<NavigationModel> temp = [];
          Map<String, dynamic> childObject =
              courseHierarchyData.children![index].toJson();

          if (courseHierarchyData.children![index].children != null) {
            for (int i = 0;
                i < courseHierarchyData.children![index].children!.length;
                i++) {
              ProgressModel progress = getProgress(isCompleted,
                  childObject['children']![i]['identifier'], contentList);
              NavigationModel content = NavigationModel.fromJson(childObject,
                  index: k++,
                  childIndex: i,
                  hasChildren: true,
                  parentBatchId: parentBatchId,
                  parentCourseId: parentCourseId,
                  progress: progress,
                  language: language);
              temp.add(content);
              resourceNavigateItems.add(content);
            }
          } else {
            ProgressModel progress = getProgress(
                isCompleted, childObject['identifier'], contentList);
            NavigationModel content = NavigationModel.fromJson(childObject,
                index: k++, progress: progress, language: language);
            temp.add(content);
            resourceNavigateItems.add(content);
          }
          tempNavItems.add(temp);
        } else if (courseHierarchyData.children![index].contentType ==
            'Course') {
          List courseList = [];
          for (var i = 0;
              i < courseHierarchyData.children![index].children!.length;
              i++) {
            List<NavigationModel> temp = [];
            if (courseHierarchyData.children![index].children![i].contentType ==
                    'Collection' ||
                courseHierarchyData.children![index].children![i].contentType ==
                    'CourseUnit') {
              Map<String, dynamic> childObject =
                  courseHierarchyData.children![index].children![i].toJson();

              for (var j = 0;
                  j <
                      courseHierarchyData
                          .children![index].children![i].children!.length;
                  j++) {
                ProgressModel progress = getProgress(isCompleted,
                    childObject['children']![j]['identifier'], contentList);
                NavigationModel content = NavigationModel.fromJson(childObject,
                    index: k++,
                    hasChildren: true,
                    parentBatchId: parentBatchId,
                    parentCourseId: parentCourseId,
                    courseName: courseHierarchyData.children![index].name,
                    childIndex: j,
                    progress: progress,
                    language: language);
                temp.add(content);
                resourceNavigateItems.add(content);
              }
              courseList.add(temp);
            } else {
              Map<String, dynamic> childObject =
                  courseHierarchyData.children![index].toJson();
              ProgressModel progress = getProgress(isCompleted,
                  childObject['children']![i]['identifier'], contentList);
              NavigationModel content = NavigationModel.fromJson(childObject,
                  index: k++,
                  parentBatchId: parentBatchId,
                  parentCourseId: parentCourseId,
                  isCourse: true,
                  hasChildren: true,
                  courseName: courseHierarchyData.children![index].name,
                  childIndex: i,
                  progress: progress,
                  language: language);
              courseList.add(content);
              resourceNavigateItems.add(content);
            }
          }
          tempNavItems.add(courseList);
        } else {
          Map<String, dynamic> childObject =
              courseHierarchyData.children![index].toJson();
          ProgressModel progress =
              getProgress(isCompleted, childObject['identifier'], contentList);
          NavigationModel content = NavigationModel.fromJson(childObject,
              index: k++,
              parentBatchId: parentBatchId,
              parentCourseId: parentCourseId,
              isCourse: true,
              progress: progress,
              language: language);
          tempNavItems.add(content);
          resourceNavigateItems.add(content);
        }
      }
      if (enrolledCourse != null &&
          isResourceLocked(
              courseCategory: course.courseCategory,
              contextLockingType: course.contextLockingType,
              compatibilityLevel: course.compatibilityLevel)) {
        resourceNavigateItems =
            updateLock(resourceNavigateItems, courseHierarchyData.identifier);
      }
      return {
        'navItems': tempNavItems,
        'resourceNavItems': resourceNavigateItems
      };
    }
  }

  bool isResourceLocked(
      {required String courseCategory,
      required String contextLockingType,
      required int compatibilityLevel}) {
    return (TocConstants.contextLockCategories.contains(courseCategory) &&
        contextLockingType == EContextLockingType.courseAssessmentOnly &&
        compatibilityLevel >=
            ContextLockingCompatibility.CuratedPgmFinalAssessmentLock);
  }

  Future<dynamic> generatePreEnrollNavigationItem(
      {required CourseHierarchyModel courseHierarchyData,
      required Course course,
      required BuildContext context,
      bool isPlayer = false,
      String? courseCategory,
      bool isFeatured = false}) async {
    int index;
    int k = 0;
    List tempNavItems = [];

    List<NavigationModel> resourceNavigateItems = [];
    bool isCompleted = false;
    List<ContentStateModel> parentContentList = [];

    if (!isFeatured) {
      if ((course.preEnrolmentResources?.children ?? []).isNotEmpty) {
        final contentIds = TocHelper.getContentIdsFromCourse(
            course.preEnrolmentResources?.children ?? []);
        parentContentList.clear();
        parentContentList =
            await LearnRepository().readPreRequisiteContentProgress(contentIds);
        getOverallProgress(parentContentList, course, context);
      }
    }
    if (courseHierarchyData.children != null) {
      for (index = 0; index < courseHierarchyData.children!.length; index++) {
        String? parentCourseId = null;
        List<ContentStateModel> contentList = [];

        if (course.cumulativeTracking && !isFeatured) {
          contentList = parentContentList;
        }

        if ((courseHierarchyData.children![index].contentType == 'Collection' ||
            courseHierarchyData.children![index].contentType == 'CourseUnit')) {
          List<NavigationModel> temp = [];
          Map<String, dynamic> childObject =
              courseHierarchyData.children![index].toJson();

          if (courseHierarchyData.children![index].children != null) {
            for (int i = 0;
                i < courseHierarchyData.children![index].children!.length;
                i++) {
              ProgressModel progress = getProgress(isCompleted,
                  childObject['children']![i]['identifier'], contentList);
              NavigationModel content = NavigationModel.fromJson(childObject,
                  index: k++,
                  childIndex: i,
                  hasChildren: true,
                  parentBatchId: course.batches?[0].batchId ?? '',
                  parentCourseId: parentCourseId,
                  progress: progress,
                  isMandatory:
                      courseHierarchyData.children![index].isMandatory);
              temp.add(content);
              resourceNavigateItems.add(content);
            }
          } else {
            ProgressModel progress = getProgress(
                isCompleted, childObject['identifier'], contentList);
            NavigationModel content = NavigationModel.fromJson(childObject,
                index: k++,
                progress: progress,
                isMandatory: courseHierarchyData.children![index].isMandatory);
            temp.add(content);
            resourceNavigateItems.add(content);
          }
          tempNavItems.add(temp);
        } else if (courseHierarchyData.children![index].contentType ==
            'Course') {
          List courseList = [];
          for (var i = 0;
              i < courseHierarchyData.children![index].children!.length;
              i++) {
            List<NavigationModel> temp = [];
            if (courseHierarchyData.children![index].children![i].contentType ==
                    'Collection' ||
                courseHierarchyData.children![index].children![i].contentType ==
                    'CourseUnit') {
              Map<String, dynamic> childObject =
                  courseHierarchyData.children![index].children![i].toJson();

              for (var j = 0;
                  j <
                      courseHierarchyData
                          .children![index].children![i].children!.length;
                  j++) {
                ProgressModel progress = getProgress(isCompleted,
                    childObject['children']![j]['identifier'], contentList);
                NavigationModel content = NavigationModel.fromJson(childObject,
                    index: k++,
                    hasChildren: true,
                    parentBatchId: course.batches?[0].batchId ?? '',
                    parentCourseId: parentCourseId,
                    courseName: courseHierarchyData.children![index].name,
                    childIndex: j,
                    progress: progress,
                    isMandatory:
                        courseHierarchyData.children![index].isMandatory);
                temp.add(content);
                resourceNavigateItems.add(content);
              }
              courseList.add(temp);
            } else {
              Map<String, dynamic> childObject =
                  courseHierarchyData.children![index].toJson();
              ProgressModel progress = getProgress(isCompleted,
                  childObject['children']![i]['identifier'], contentList);
              NavigationModel content = NavigationModel.fromJson(childObject,
                  index: k++,
                  parentBatchId: course.batches?[0].batchId ?? '',
                  parentCourseId: parentCourseId,
                  isCourse: true,
                  hasChildren: true,
                  courseName: courseHierarchyData.children![index].name,
                  childIndex: i,
                  progress: progress,
                  isMandatory:
                      courseHierarchyData.children![index].isMandatory);
              courseList.add(content);
              resourceNavigateItems.add(content);
            }
          }
          tempNavItems.add(courseList);
        } else {
          Map<String, dynamic> childObject =
              courseHierarchyData.children![index].toJson();
          ProgressModel progress =
              getProgress(isCompleted, childObject['identifier'], contentList);
          NavigationModel content = NavigationModel.fromJson(childObject,
              index: k++,
              parentBatchId: course.batches?[0].batchId ?? '',
              parentCourseId: parentCourseId,
              isCourse: true,
              progress: progress,
              isMandatory: courseHierarchyData.children![index].isMandatory);
          tempNavItems.add(content);
          resourceNavigateItems.add(content);
        }
      }
      return {
        'navItems': tempNavItems,
        'resourceNavItems': resourceNavigateItems
      };
    }
  }

  ProgressModel getProgress(
      isCompleted, identifier, List<ContentStateModel> contentList) {
    if (isCompleted) {
      return ProgressModel.fromJson({'completionPercentage': 1.0, 'status': 2});
    }
    if (contentList.isNotEmpty) {
      for (int i = 0; i < contentList.length; i++) {
        if (contentList[i].contentId == identifier) {
          int spentTime = contentList[i].progressdetails != null &&
                  contentList[i].progressdetails!['spentTime'] != null
              ? contentList[i].progressdetails!['spentTime']
              : 0;
          String currentProgress = contentList[i].progressdetails != null &&
                  contentList[i].progressdetails!['current'] != null
              ? (contentList[i].progressdetails!['current'].length > 0)
                  ? contentList[i].progressdetails!['current'].last.toString()
                  : '0'
              : '0';
          return ProgressModel.fromJson({
            'completionPercentage': contentList[i].completionPercentage / 100,
            'spentTime': spentTime,
            'currentProgress': currentProgress,
            'status': contentList[i].status
          });
        }
      }
    }
    return ProgressModel.fromJson({'completionPercentage': 0.0});
  }

  static NavigationModel compareAndUpdate(
      {required NavigationModel resourseFromHierarchy,
      required NavigationModel resource}) {
    resource.parentBatchId = resourseFromHierarchy.parentBatchId;
    resource.parentCourseId = resourseFromHierarchy.parentCourseId;
    if (resource.duration == null || resource.duration == '0') {
      resource.duration = resourseFromHierarchy.duration;
    }
    resource.moduleDuration = resourseFromHierarchy.moduleDuration;
    resource.courseDuration = resourseFromHierarchy.courseDuration;
    if (double.parse(resource.currentProgress) <
        double.parse(resourseFromHierarchy.currentProgress != ''
            ? resourseFromHierarchy.currentProgress
            : '0')) {
      resource.currentProgress = resourseFromHierarchy.currentProgress;
    }
    if (resource.completionPercentage <
        resourseFromHierarchy.completionPercentage) {
      resource.completionPercentage =
          resourseFromHierarchy.completionPercentage;
    }
    if (resource.status < resourseFromHierarchy.status) {
      resource.status = resourseFromHierarchy.status;
    }
    return resource;
  }

  // Content read api - To get all resourcedetails including batch info
  static Future<NavigationModel?> getResourceInfo(
      {required BuildContext context,
      required String resourceId,
      required bool isFeatured,
      required NavigationModel resourceNavigateItems}) async {
    final courseInfo = await Provider.of<LearnRepository>(context,
            listen: false)
        .getCourseData(resourceId, isFeatured: isFeatured, isResource: true);

    if (courseInfo != null) {
      NavigationModel resource = NavigationModel.fromJson(courseInfo,
          index: 0, language: resourceNavigateItems.language);
      resource = TocHelper.compareAndUpdate(
          resourseFromHierarchy: resourceNavigateItems, resource: resource);
      return resource;
    }
    return null;
  }

  void getOverallProgress(
      List<ContentStateModel> response, Course course, BuildContext context) {
    double completionPercentage = 0;
    response.forEach((element) {
      course.leafNodes.firstWhere((item) {
        if (item == element.contentId) {
          if (element.status == 2) {
            completionPercentage = completionPercentage + 1;
          } else {
            completionPercentage =
                completionPercentage + (element.completionPercentage / 100);
          }
          return true;
        }
        return false;
      }, orElse: () => false);
    });
    if (course.leafNodes.length > 0) {
      Provider.of<TocServices>(context, listen: false)
          .setCourseProgress(completionPercentage / course.leafNodes.length);
    }
  }

  static int? getTotalNumberOfRatings(dynamic courseRating) {
    try {
      if (courseRating is! Map) return null;
      var totalNumberOfRatings = courseRating['total_number_of_ratings'];
      if (totalNumberOfRatings == null) {
        return null;
      }
      return totalNumberOfRatings.ceil();
    } catch (e) {
      return null;
    }
  }

  static double? getRating(dynamic courseRating) {
    try {
      if (courseRating is! Map) return null;
      var sumOfTotalRatings = courseRating['sum_of_total_ratings'];
      var totalNumberOfRatings = courseRating['total_number_of_ratings'];

      if (sumOfTotalRatings == null ||
          totalNumberOfRatings == null ||
          totalNumberOfRatings == 0) {
        return null;
      }

      double rating = sumOfTotalRatings / totalNumberOfRatings;
      return double.parse(rating.toStringAsFixed(1));
    } catch (e) {
      return null;
    }
  }

  static bool checkResourceStatus(
      {required List resourceNavigationItems, required String resourceId}) {
    for (int i = 0; i < resourceNavigationItems.length; i++) {
      if (resourceNavigationItems[i].identifier == resourceId) {
        return true;
      }
    }
    return false;
  }

  List<NavigationModel> updateLock(
      List<NavigationModel> resourceNavigateItems, String id) {
    NavigationModel? result = resourceNavigateItems
        .where((resource) =>
            resource.parentCourseId != id &&
            (resource.status != 2 && resource.completionPercentage != 1))
        .firstOrNull;
    for (NavigationModel resource in resourceNavigateItems) {
      if (resource.mimeType == EMimeTypes.newAssessment &&
          resource.parentCourseId == id) {
        if (result != null) {
          resource.isLocked = true;
        } else {
          resource.isLocked = false;
        }
      }
    }
    return resourceNavigateItems;
  }

  double getCourseOverallProgress(
      double totalProgress, List<NavigationModel> resourceNavigateItems) {
    resourceNavigateItems.forEach((element) {
      if (element is! List) {
        if (element.status == 2) {
          totalProgress += 1;
        } else {
          totalProgress +=
              double.parse((element.completionPercentage).toString());
        }
      }
    });
    return totalProgress;
  }

  static bool hasScromContent(resourceNavigateItems) {
    for (int i = 0; i < resourceNavigateItems.length; i++) {
      if (resourceNavigateItems[i].mimeType == EMimeTypes.html) {
        return true;
      }
    }
    return false;
  }

  static String getMimeTypeIcon(String? mimeType) {
    switch (mimeType) {
      case EMimeTypes.mp4:
      case EMimeTypes.m3u8:
        return 'assets/img/icons-av-play.svg';
      case EMimeTypes.mp3:
        return 'assets/img/audio.svg';
      case EMimeTypes.externalLink:
      case EMimeTypes.youtubeLink:
        return 'assets/img/link.svg';
      case EMimeTypes.pdf:
        return 'assets/img/icons-file-types-pdf-alternate.svg';
      case EMimeTypes.assessment:
      case EMimeTypes.newAssessment:
        return 'assets/img/assessment_icon.svg';
      default:
        return 'assets/img/resource.svg';
    }
  }

  static bool containsLastAccessedContent(
      dynamic content, String? lastAccessContentId) {
    if (content is List) {
      for (var item in content) {
        if (containsLastAccessedContent(item, lastAccessContentId)) {
          return true;
        }
      }
    } else if (content != null && content.contentId == lastAccessContentId) {
      return true;
    }
    return false;
  }

  static List<String> getContentIdsFromCourse(
      List<CourseHierarchyModelChild?>? courseHierarchyList) {
    if (courseHierarchyList == null) return [];
    return courseHierarchyList
        .whereType<CourseHierarchyModelChild>() // filter out null entries
        .map((child) => child.identifier)
        .whereType<String>() // filter out null identifiers
        .toList();
  }

  /// check if the course category is not compatible with the given compatibility level
  static bool isCourseCategoryNotCompatible({
    required String courseCategory,
    required int compatibilityLevel,
  }) {
    final formattedCourseCategory = courseCategory.toLowerCase();

    try {
      final allVersions = CourseCategoryVersion.getAllVersions();

      // If the category is found in the map, compare its version with the compatibility level
      if (allVersions.containsKey(formattedCourseCategory)) {
        return compatibilityLevel > allVersions[formattedCourseCategory]!;
      }

      // If the category is not found in the map, assume it's not compatible
      return true;
    } catch (_) {
      return true;
    }
  }
}
