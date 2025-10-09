import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/search/ui/widgets/course_search_card.dart';
import '../../../../../../constants/index.dart';
import '../../../../../../models/_arguments/index.dart';
import '../../../../../../models/index.dart';
import '../../../../../../respositories/index.dart';
import '../../../../../../util/index.dart';
import '../../../../../widgets/index.dart';
import '../../models/composite_search_model.dart';
import '../../repository/search_repository.dart';
import '../skeleton/course_search_skeleton.dart';
import '../../utils/search_helper.dart';
import '../view_model/external_content_view_model.dart';

class CourseSearch extends StatefulWidget {
  final String searchText;
  final bool showAll;
  final bool showContent;
  final bool showExternalContent;
  final Map<String, dynamic>? filters;
  final VoidCallback? changeSelectedCategory;
  final Map<String, dynamic>? sortBy;
  final VoidCallback callBackOnEmptyResult;
  final Function(List<Facet>) callBackWithFacet;
  final Function(TelemetryDataModel)? onTelemetryCallBack;
  final LearnRepository learnRepository;
  final SearchRepository searchRepository;
  final double? height;

  CourseSearch(
      {super.key,
      required this.searchText,
      this.showAll = true,
      this.showContent = false,
      this.showExternalContent = false,
      this.filters,
      this.changeSelectedCategory,
      this.sortBy,
      required this.callBackOnEmptyResult,
      required this.callBackWithFacet,
      this.onTelemetryCallBack,
      this.height,
      LearnRepository? learnRepository,
      SearchRepository? searchRepository})
      : learnRepository = learnRepository ?? LearnRepository(),
        searchRepository = searchRepository ?? SearchRepository();

  @override
  State<CourseSearch> createState() => _CourseSearchState();
}

class _CourseSearchState extends State<CourseSearch> {
  Future<CompositeSearchModel?>? futureCourse;
  List<Course> enrollmentList = [];
  ValueNotifier<bool> isLoadingValueNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> isUpdateDataValueNotifier = ValueNotifier<bool>(true);
  int pageNo = 0;
  CompositeSearchModel? externalData;
  bool showLoadMore = true;

  @override
  void initState() {
    super.initState();
    futureCourse = fetchData();
  }

  @override
  void didUpdateWidget(CourseSearch oldWidget) {
    if (oldWidget.showAll != widget.showAll ||
        oldWidget.showContent != widget.showContent ||
        oldWidget.showExternalContent != widget.showExternalContent ||
        SearchHelper.hasFilterChanged(
            oldFilter: oldWidget.filters, newFilter: widget.filters) ||
        oldWidget.searchText != widget.searchText ||
        SearchHelper.hasSortByChanged(
            oldSortBy: oldWidget.sortBy, newSortBy: widget.sortBy)) {
      futureCourse = null;
      isLoadingValueNotifier.value = true;
      isUpdateDataValueNotifier.value = true;
      pageNo = 0;
      futureCourse = fetchData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureCourse,
        builder: (context, snapshot) {
          return ValueListenableBuilder<bool>(
              valueListenable: isUpdateDataValueNotifier,
              builder: (context, isUpdateDataValue, _) {
                if (snapshot.hasData && !isUpdateDataValue) {
                  if (snapshot.data != null && snapshot.data!.content.isNotEmpty) {
                    List<Course> courseList = snapshot.data!.content;
                    return !widget.showAll
                        ? Container(
                      height: (widget.height ?? 0.68).sh,
                      child: SingleChildScrollView(
                        physics: widget.showAll
                            ? NeverScrollableScrollPhysics()
                            : ClampingScrollPhysics(),
                        child: ContentWidget(context, snapshot.data!.count, courseList),
                      ),
                    )
                        : ContentWidget(context, snapshot.data!.count, courseList);
                  } else {
                    return SizedBox();
                  }
                } else {
                  return CourseSearchSkeleton();
                }
              }
          );
        });
  }

  Padding ContentWidget(BuildContext context, int totalCourses, List<Course> courseList) {
    return Padding(
      padding:
          EdgeInsets.only(left: 16, right: 16, bottom: widget.showAll ? 0 : 100)
              .r,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${widget.showContent ? AppLocalizations.of(context)!.mStaticContents : AppLocalizations.of(context)!.mSearchExternalContents} (${totalCourses})',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: AppColors.blackLegend)),
              courseList.length > SHOW4 && widget.showAll
                  ? InkWell(
                      onTap: () => widget.changeSelectedCategory!(),
                      child: Row(
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .mSearchShowAllResults,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: AppColors.darkBlue,
                            size: 10.sp,
                          )
                        ],
                      ),
                    )
                  : Center()
            ],
          ),
          SizedBox(height: 8.w),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: (widget.showAll && courseList.length > SHOW3)
                ? SHOW3
                : courseList.length,
            itemBuilder: (context, index) {
              Course course = courseList[index];
              return InkWell(
                  onTap: () {
                    widget.onTelemetryCallBack!(TelemetryDataModel(
                        id: course.id,
                        clickId: '${TelemetryClickId.searchCard}-${index + 1}',
                        subType: TelemetrySubType.learnSearch,
                        pageId: TelemetryPageIdentifier.globalSearchCardPageId,
                        objectType: course.courseCategory));
                    if (course.courseCategory ==
                        PrimaryCategory.externalCourse) {
                      Navigator.pushNamed(context, AppUrl.externalCourseTocPage,
                          arguments: CourseTocModel(
                              courseId: course.contentId,
                              externalId: course.externalId,
                              contentType: course.courseCategory));
                    } else {
                      Navigator.pushNamed(context, AppUrl.courseTocPage,
                          arguments: CourseTocModel(courseId: course.id));
                    }
                  },
                  child: CourseSearchCard(
                    course: course,
                  ));
            },
          ),
          ValueListenableBuilder<bool>(
              valueListenable: isLoadingValueNotifier,
              builder: (context, isLoadingValue, _) {
                return Column(
                    children: [
                      !isLoadingValue && (courseList.length < totalCourses)
                          ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            side: BorderSide(color: AppColors.darkBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                          ),
                          onPressed: () {
                            isLoadingValueNotifier.value = true;
                            pageNo = pageNo + 10;
                            futureCourse = fetchData();
                            setState(() {});
                          },
                          child: Text(
                            AppLocalizations.of(context)!.mStaticLoadMore,
                            style: GoogleFonts.lato(
                                color: AppColors.darkBlue, fontWeight: FontWeight.w600),
                          ))
                          : SizedBox.shrink(),
                      isLoadingValue && !widget.showAll
                          ? Container(
                          height: 40,
                          width: 80,
                          margin: EdgeInsets.symmetric(vertical: 16).r,
                          child: PageLoader())
                          : SizedBox()
                    ],
                );
              }
          )
        ],
      ),
    );
  }

  Future<CompositeSearchModel> fetchData() async {
    // Get course based on search keyword
    CompositeSearchModel? data;
    if (widget.showContent) {
      data = await getCompositeSearchData();
    } else if (widget.showExternalContent) {
      CompositeSearchModel? existingData = await futureCourse;
      data = await ExternalContentViewModel().getExternalContentData(
          existingData: existingData,
          filters: widget.filters,
          searchText: widget.searchText,
          sortBy: widget.sortBy,
          pageNo: pageNo);
      if (data != null && data.content.isNotEmpty && data.facets.isNotEmpty) {
        Future.delayed(
            Duration.zero, () => widget.callBackWithFacet(data!.facets));
      } else {
        checkIsEmpty([]);
      }
    }
    if (data != null) {
      // Get enrollment list based on course doid's
      enrollmentList = await getEnrollmentList(data.content);
      enrollmentList.forEach((enrolledCourse) {
        int index = data!.content.indexWhere((course) =>
            course.courseCategory == PrimaryCategory.multilingualCourse
                ? Helper.getBaseCourseId(course) == enrolledCourse.id
                : course.id == enrolledCourse.id);
        if (index >= 0) {
          data.content[index].completionPercentage =
              enrolledCourse.completionPercentage;
          data.content[index].issuedCertificates =
              enrolledCourse.issuedCertificates;
          data.content[index].batchId = enrolledCourse.batchId;
        }
      });
    }
    isLoadingValueNotifier.value = false;
    isUpdateDataValueNotifier.value = false;
    checkIsEmpty(data != null ? data.content : []);
    return Future.value(data);
  }

  Future<CompositeSearchModel?> getCompositeSearchData() async {
    CompositeSearchModel? data;
    CompositeSearchModel? existingData = await futureCourse;
    try {
      List<String> categories = [];
      addCategories(categories);

      // Fetch normal course/program/assessment based on course category
      data = await getCourseData(
          categories: categories,
          filters: widget.filters,
          facets: [
            if (widget.showContent) SearchFilterFacet.courseCategory,
            SearchFilterFacet.language,
            SearchFilterFacet.avgRating,
            SearchFilterFacet.competencyAreaName,
            SearchFilterFacet.competencyThemeName,
            SearchFilterFacet.competencySubThemeName,
            SearchFilterFacet.sector,
            SearchFilterFacet.subSector,
            SearchFilterFacet.organisation
          ],
          sortBy: widget.sortBy ?? {});

      if (data != null) {
        // if (data.content.isNotEmpty && data.content.length > 9) {
        //   showLoadMore = true;
        // } else {
        //   showLoadMore = false;
        // }
        if (existingData != null && data.content.isNotEmpty) {
          existingData.content.addAll(data.content);
        } else {
          if (data.facets.isNotEmpty) {
            updateFilter(data);
          }
          existingData = data;
        }
      }
      if (existingData != null &&
          existingData.content.isNotEmpty &&
          existingData.facets.isNotEmpty) {
        Future.delayed(Duration.zero,
            () => widget.callBackWithFacet(existingData!.facets));
      }
      return existingData;
    } catch (err) {
      checkIsEmpty([]);
      return null;
    }
  }

  void addCategories(List<String> categories) {
    if (widget.showContent) {
      categories.addAll([
        PrimaryCategory.course.toLowerCase(),
        PrimaryCategory.moderatedCourses.toLowerCase(),
        PrimaryCategory.curatedProgram,
        PrimaryCategory.program.toLowerCase(),
        PrimaryCategory.blendedProgram.toLowerCase(),
        PrimaryCategory.moderatedProgram.toLowerCase(),
        PrimaryCategory.inviteOnlyProgram.toLowerCase(),
        PrimaryCategory.standaloneAssessment.toLowerCase(),
        PrimaryCategory.inviteOnlyAssessment.toLowerCase(),
        PrimaryCategory.moderatedAssessment.toLowerCase(),
        PrimaryCategory.caseStudy.toLowerCase(),
        PrimaryCategory.multilingualCourse.toLowerCase(),
        PrimaryCategory.comprehensiveAssessmentProgram.toLowerCase()
      ]);
    }
  }

  Future<CompositeSearchModel?> getCourseData(
      {required List<String> categories,
      Map<String, dynamic>? filters,
      required List<String> facets,
      required Map<String, dynamic> sortBy,
      int? limit}) async {
    Map<String, dynamic> updatedFilter = {};
    if (filters != null) {
      if (filters.containsKey(SearchFilterFacet.extContentPartner)) {
        filters.forEach((key, value) {
          if (key != SearchFilterFacet.extContentPartner) {
            updatedFilter[key] = value;
          }
        });
      } else {
        updatedFilter = filters;
      }
    }
    // Fetch search data
    CompositeSearchModel? result = await widget.learnRepository
        .getCompositeSearchData(pageNo, widget.searchText, categories, [], [],
            filters: updatedFilter,
            ttl: Duration.zero,
            facets: facets,
            fields: [
              'organisation',
              'language',
              'source',
              'appIcon',
              'identifier',
              'name',
              'primaryCategory',
              'contentType',
              'posterImage',
              'createdOn',
              'duration',
              'avgRating',
              'additionalTags',
              'courseCategory',
              'mimeType',
              'contentId',
              'creatorLogo',
              'sectorDetails_v1',
              'languageMapV1'
            ],
            sortBy: sortBy,
            limit: limit);

    return result;
  }

  void updateFilter(CompositeSearchModel data) {
    data.facets.removeWhere((facet) => facet.values.isEmpty);
    int index = data.facets
        .indexWhere((facet) => facet.name == SearchFilterFacet.avgRating);
    updateAvgFilterValues(index, data);
  }

  void updateAvgFilterValues(int index, CompositeSearchModel data) {
    if (index > -1) {
      List<Value> avgFacet = [];
      groupFacets(avgFacet: avgFacet, facets: data.facets[index].values);
      if (avgFacet.isNotEmpty) {
        data.facets[index].values = avgFacet;
      } else {
        data.facets
            .removeWhere((facet) => facet.name == SearchFilterFacet.avgRating);
      }
    }
  }

  Future<List<Course>> getEnrollmentList(List<Course> courses) async {
    if (courses.isEmpty) return [];
    List<String> doIdList = Helper.filterDoIds(courses);
    List<Course> responseList = await widget.learnRepository
        .getCourseEnrollDetailsByIds(courseIds: doIdList);
    return responseList;
  }

  void checkIsEmpty(List<Course> courses) {
    if (courses.isEmpty) {
      Future.delayed(Duration.zero, () {
        widget.callBackOnEmptyResult();
      });
    }
  }

  void groupFacets(
      {required List<Value> avgFacet, required List<Value> facets}) {
    Map<String, int> groupedCounts = {};
    facets.sort((a, b) => double.parse(b.name.toString())
        .compareTo(double.parse(a.name.toString())));

    for (var facet in facets) {
      double value = double.tryParse(facet.name.toString()) ?? 0.0;

      if (value >= 4.5) {
        String key = '4.5';
        groupedCounts[key] = (groupedCounts[key] ?? 0) + facet.count;
      } else if (value >= 4.0) {
        String key = '4.0';
        groupedCounts[key] = (groupedCounts[key] ?? 0) + facet.count;
      } else if (value >= 3.5) {
        String key = '3.5';
        groupedCounts[key] = (groupedCounts[key] ?? 0) + facet.count;
      } else if (value >= 3.0) {
        String key = '3.0';
        groupedCounts[key] = (groupedCounts[key] ?? 0) + facet.count;
      }
    }

    groupedCounts.forEach((name, count) {
      if (count > 0) {
        // Ensures zero counts are not added
        int index = avgFacet.indexWhere((element) => element.name == name);
        if (index == -1) {
          avgFacet.add(Value(
              name: name,
              count: count,
              isChecked: false,
              isExpanded: false,
              showMore: false));
        } else {
          avgFacet[index].count += count;
        }
      }
    });
  }
}
