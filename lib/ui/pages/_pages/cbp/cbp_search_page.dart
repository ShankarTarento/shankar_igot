import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:provider/provider.dart';

import '../../../../constants/index.dart';
import '../../../../models/index.dart';
import '../../../../respositories/_respositories/learn_repository.dart';
import '../../../../util/index.dart';
import '../../../widgets/index.dart';

class CBPSearchPage extends StatefulWidget {
  const CBPSearchPage({
    Key? key,
    required this.allCourseList,
    required this.upcomingCourseList,
    required this.overdueCourseList,
    required this.completedCourseList,
    required this.aparCourseList,
  }) : super(key: key);

  final List<Course> allCourseList;
  final List<Course> upcomingCourseList;
  final List<Course> overdueCourseList;
  final List<Course> completedCourseList;
  final List<Course> aparCourseList;

  @override
  State<CBPSearchPage> createState() => _CBPSearchPageState();
}

class _CBPSearchPageState extends State<CBPSearchPage>
    with SingleTickerProviderStateMixin {
  LearnRepository learnRepository = LearnRepository();
  List<Course> allCourseList = [];
  ValueNotifier<List<Course>> _filteredListOfCourses =
      ValueNotifier<List<Course>>([]);
  List<Course> enrolmentList = [];
  List<dynamic> selectedFilterList = [];
  List<Map<String, dynamic>> filterField = [], competencyName = [];
  List checkStatus = [];
  bool? selectedTimelineValue;
  FocusNode focusNode = FocusNode();
  var updatedFilterList;
  var competencyThemeList;
  var competencyInfo;
  CBPFilter? cbpFilterProvider;

  @override
  void initState() {
    super.initState();
    cbpFilterProvider = Provider.of<CBPFilter>(context, listen: false);
    getCompetency();
    getEnrollmentList();
    allCourseList = widget.allCourseList;
    _filteredListOfCourses.value = widget.allCourseList;
    clearAllFilters();
  }

  void filterSearchedCourses(value) {
    _filteredListOfCourses.value = [];
    setState(() {
      _filteredListOfCourses.value = allCourseList
          .where((course) =>
              (course.name).toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  Future<void> filterCourses() async {
    List<Course> filteredList = [];
    List<Course> tempList = List.from(allCourseList);

    selectedFilterList.forEach((element) {
      switch (element.category) {
        //Filtering based on content type
        case CBPFilterCategory.contentType:
          bool isFilterSelected = false;
          filteredList = [];
          element.filters.forEach((item) {
            if (item.isSelected) {
              isFilterSelected = true;
              if (item.name.toString().toLowerCase() ==
                  PrimaryCategory.moderatedCourses) {
                filteredList.addAll(tempList
                    .where((course) => (course.id.toString().contains('_rc')))
                    .toList());
              } else {
                filteredList.addAll(tempList
                    .where((course) => (course.raw['primaryCategory'])
                        .toLowerCase()
                        .contains(item.name.toLowerCase()))
                    .toList());
              }
            }
          });
          if (isFilterSelected) tempList = filteredList;
          break;
        // Filtering based on competency area
        case CBPFilterCategory.competencyArea:
          bool isFilterSelected = false;
          filteredList = [];
          element.filters.forEach((item) {
            if (item.isSelected) {
              isFilterSelected = true;
              tempList.forEach((course) {
                if (course.competenciesV5 != null &&
                    course.competenciesV5!.isNotEmpty) {
                  for (int index = 0;
                      index < course.competenciesV5!.length;
                      index++) {
                    if (course.competenciesV5![index].competencyArea ==
                        item.name) {
                      bool isExist = false;
                      filteredList.forEach((filtereditem) {
                        if (filtereditem.raw['identifier'] ==
                            course.raw['identifier']) {
                          isExist = true;
                        }
                      });
                      if (!isExist) {
                        filteredList.add(course);
                      }
                      break;
                    }
                  }
                }
              });
            }
          });
          if (isFilterSelected) tempList = filteredList;
          break;
        // Filtering based on competency theme
        case CBPFilterCategory.competencyTheme:
          bool isFilterSelected = false;
          filteredList = [];
          element.filters.forEach((item) {
            if (item.isSelected) {
              isFilterSelected = true;
              tempList.forEach((course) {
                if (course.competenciesV5 != null &&
                    course.competenciesV5!.isNotEmpty) {
                  for (int index = 0;
                      index < course.competenciesV5!.length;
                      index++) {
                    if (course.competenciesV5![index].competencyTheme ==
                        item.name) {
                      bool isExist = false;
                      filteredList.forEach((filtereditem) {
                        if (filtereditem.raw['identifier'] ==
                            course.raw['identifier']) {
                          isExist = true;
                        }
                      });
                      if (!isExist) {
                        filteredList.add(course);
                      }
                      break;
                    }
                  }
                }
              });
            }
          });
          if (isFilterSelected) tempList = filteredList;
          break;
        // Filtering based on competency subtheme
        case CBPFilterCategory.competencySubtheme:
          bool isFilterSelected = false;
          filteredList = [];
          element.filters.forEach((item) {
            if (item.isSelected) {
              isFilterSelected = true;
              tempList.forEach((course) {
                if (course.competenciesV5 != null &&
                    course.competenciesV5!.isNotEmpty) {
                  for (int index = 0;
                      index < course.competenciesV5!.length;
                      index++) {
                    if (course.competenciesV5![index].competencySubTheme ==
                        item.name) {
                      bool isExist = false;
                      filteredList.forEach((filtereditem) {
                        if (filtereditem.raw['identifier'] ==
                            course.raw['identifier']) {
                          isExist = true;
                        }
                      });
                      if (!isExist) {
                        filteredList.add(course);
                      }
                      break;
                    }
                  }
                }
              });
            }
          });
          if (isFilterSelected) tempList = filteredList;
          break;
        // Filtering based on course status
        case CBPFilterCategory.status:
          bool isFilterSelected = false;
          filteredList = [];
          element.filters.forEach((item) {
            if (item.isSelected) {
              isFilterSelected = true;
              if (item.name == CBPCourseStatus.inProgress) {
                tempList.forEach((course) {
                  for (int index = 0; index < enrolmentList.length; index++) {
                    if (course.id
                        .toString()
                        .contains(enrolmentList[index].id.toString())) {
                      if (enrolmentList[index].completionPercentage !=
                          COURSE_COMPLETION_PERCENTAGE) {
                        filteredList.add(course);
                        break;
                      }
                    }
                  }
                });
              } else if (item.name == CBPCourseStatus.completed) {
                tempList.forEach((course) {
                  for (int index = 0; index < enrolmentList.length; index++) {
                    if (course.id
                        .toString()
                        .contains(enrolmentList[index].id.toString())) {
                      if (enrolmentList[index].completionPercentage ==
                          COURSE_COMPLETION_PERCENTAGE) {
                        filteredList.add(course);
                        break;
                      }
                    }
                  }
                });
              } else {
                tempList.forEach((course) {
                  bool isEnrolled = false;
                  for (int index = 0; index < enrolmentList.length; index++) {
                    if (course.id
                        .toString()
                        .contains(enrolmentList[index].id.toString())) {
                      isEnrolled = true;
                      break;
                    }
                  }
                  if (!isEnrolled) {
                    filteredList.add(course);
                  }
                });
              }
            }
          });
          if (isFilterSelected) tempList = filteredList;
          break;
        // Filtering based on time duration
        case CBPFilterCategory.timeDuration:
          bool isFilterSelected = false;
          filteredList = [];
          element.filters.forEach((item) {
            if (item.isSelected) {
              isFilterSelected = true;
              if (item.name == CBPFilterTimeDuration.upcoming7days) {
                filteredList = filterOnUpcomingTime(filteredList, tempList, 7);
              } else if (item.name == CBPFilterTimeDuration.upcoming30days) {
                filteredList = filterOnUpcomingTime(filteredList, tempList, 30);
              } else if (item.name == CBPFilterTimeDuration.upcoming3months) {
                filteredList = filterOnUpcomingTime(filteredList, tempList, 90);
              } else if (item.name == CBPFilterTimeDuration.upcoming6months) {
                filteredList =
                    filterOnUpcomingTime(filteredList, tempList, 180);
              } else if (item.name == CBPFilterTimeDuration.lastWeek) {
                filteredList = filterOnPastTime(filteredList, tempList, 7);
              } else if (item.name == CBPFilterTimeDuration.lastMonth) {
                filteredList = filterOnPastTime(filteredList, tempList, 30);
              } else if (item.name == CBPFilterTimeDuration.last3month) {
                filteredList = filterOnPastTime(filteredList, tempList, 90);
              } else if (item.name == CBPFilterTimeDuration.last6month) {
                filteredList = filterOnPastTime(filteredList, tempList, 180);
              } else if (item.name == CBPFilterTimeDuration.lastYear) {
                filteredList = filterOnPastTime(filteredList, tempList, 365);
              }
            }
          });
          if (isFilterSelected) tempList = filteredList;
          break;
        // Filtering based on provider
        case CBPFilterCategory.provider:
          bool isFilterSelected = false;
          filteredList = [];
          element.filters.forEach((item) {
            if (item.isSelected) {
              isFilterSelected = true;
              tempList.forEach((course) {
                if (course.createdFor!.contains(item.providerId)) {
                  filteredList.add(course);
                }
              });
            }
          });
          if (isFilterSelected) tempList = filteredList;
          break;
        default:
      }
    });
    _filteredListOfCourses.value = tempList;
  }

  List<Course> filterOnUpcomingTime(
      List<Course> filteredList, List<Course> tempList, int dayCount) {
    filteredList.addAll(tempList
        .where((course) =>
            (getTimeDiff(course.endDate!, DateTime.now().toString()) <=
                    dayCount &&
                getTimeDiff(course.endDate!, DateTime.now().toString()) >= 0))
        .toList());
    return filteredList;
  }

  List<Course> filterOnPastTime(
      List<Course> filteredList, List<Course> tempList, int dayCount) {
    filteredList.addAll(tempList
        .where((course) =>
            (getTimeDiff(DateTime.now().toString(), course.endDate!) <=
                    dayCount &&
                getTimeDiff(DateTime.now().toString(), course.endDate!) >= 0))
        .toList());
    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TimelinesViewWidget(
            completedCourseList: widget.completedCourseList,
            allCourseList: allCourseList,
            upcomingCourseList: widget.upcomingCourseList,
            overdueCourseList: widget.overdueCourseList,
            aparCourseList: widget.aparCourseList,
            filterParentAction: (value) async {
              selectedFilterList = value;
              await filterCourses();
            }),
        Padding(
          padding: const EdgeInsets.only(top: 16).r,
          child: Text(
            AppLocalizations.of(context)!.mStaticAcbpBannerTitle,
            style: GoogleFonts.lato(
                color: AppColors.greys87,
                fontSize: 16.0.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.12),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5).r,
          padding: const EdgeInsets.only(top: 8).r,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 0.75.sw,
                height: 48.w,
                child: TextFormField(
                  onChanged: (value) {
                    if (updatedFilterList != null &&
                        updatedFilterList.runtimeType != String &&
                        updatedFilterList.isNotEmpty) {
                      for (int index = 0;
                          index < updatedFilterList.length;
                          index++) {
                        for (int filterIndex = 0;
                            filterIndex <
                                updatedFilterList[index].filters.length;
                            filterIndex++) {
                          if (updatedFilterList[index]
                              .filters[filterIndex]
                              .isSelected) {
                            cbpFilterProvider?.toggleFilter(
                                updatedFilterList[index].category, filterIndex);
                          }
                        }
                      }
                    }
                    filterSearchedCourses(value);
                  },
                  focusNode: focusNode,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  cursorColor: AppColors.darkBlue,
                  style: GoogleFonts.lato(fontSize: 14.0.sp),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.appBarBackground,
                    focusColor: AppColors.darkBlue,
                    prefixIcon: Icon(Icons.search,
                        color: focusNode.hasFocus
                            ? AppColors.darkBlue
                            : AppColors.grey08),
                    contentPadding:
                        EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0).r,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0).r,
                      borderSide: BorderSide(
                        color: AppColors.grey16,
                        width: 1.0.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0).r,
                      borderSide: BorderSide(
                        color: AppColors.darkBlue,
                      ),
                    ),
                    hintText: AppLocalizations.of(context)!.mStaticSearch,
                    hintStyle:
                        Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                    counterStyle: TextStyle(
                      height: double.minPositive,
                    ),
                    counterText: '',
                  ),
                ),
              ),
              IconButton(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.all(0).r,
                onPressed: () {
                  focusNode.unfocus();
                  showBottomFilterSheet(clearInfo: true);
                },
                icon: Icon(
                  Icons.filter_list,
                  size: 24.sp,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
        // Selected Filter name list
        ValueListenableBuilder<List<Course>>(
          valueListenable: _filteredListOfCourses,
          builder: (context, value, _) {
            return CBPFilterDisplayWidget(
              allCourseList: _filteredListOfCourses.value,
              filterParentAction: (value) async {
                await filterCourses();
              },
              updateFilterParentAction: (
                  {String? category,
                  List<String>? areaList,
                  List<String>? themeList}) {
                updateCompetencyFilter(
                    category: category,
                    areaList: areaList,
                    themeList: themeList);
              },
            );
          },
        ),
      ],
    );
  }

  Future showBottomFilterSheet({clearInfo = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(
            16,
          ).r,
          topLeft: Radius.circular(
            16,
          ).r,
        ),
      ),
      builder: (BuildContext context) {
        return Consumer<CBPFilter>(
          builder: (context, filterProvider, _) {
            updatedFilterList = List.from(filterProvider.filters);
            Future.delayed(
              Duration(microseconds: 100),
              () {
                if (checkStatus.isNotEmpty && clearInfo) {
                  for (int index = 0;
                      index < updatedFilterList.length;
                      index++) {
                    var list = updatedFilterList[index];
                    for (int filterIndex = 0;
                        filterIndex < list.filters.length;
                        filterIndex++) {
                      checkStatus.forEach(
                        (element) {
                          if (element['contentType'] == list.category &&
                              element['index'] == filterIndex) {
                            filterProvider.toggleFilter(
                                list.category, filterIndex);
                          }
                        },
                      );
                    }
                  }
                  checkStatus.clear();
                } else if (checkStatus.isEmpty && clearInfo) {
                  List<String> areaList = [], themeList = [];
                  //Get the list of themes being selected
                  updatedFilterList.forEach(
                    (filterItem) {
                      if (filterItem.category ==
                          CompetencyFilterCategory.competencyArea) {
                        filterItem.filters.forEach(
                          (element) {
                            if (element.isSelected) {
                              areaList.add(element.name);
                            }
                          },
                        );
                      } else if (filterItem.category ==
                          CompetencyFilterCategory.competencyTheme) {
                        filterItem.filters.forEach(
                          (element) {
                            if (element.isSelected) {
                              themeList.add(element.name);
                            }
                          },
                        );
                      }
                    },
                  );
                  updateCompetencyFilter(
                      category: CompetencyFilterCategory.competencyTheme,
                      areaList: areaList,
                      themeList: themeList);
                  updateCompetencyFilter(
                      category: CompetencyFilterCategory.competencySubtheme,
                      areaList: areaList,
                      themeList: themeList);
                }
                clearInfo = false;
              },
            );
            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    height: 0.8.sh,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 88,
                          child: FractionallySizedBox(
                            heightFactor: 1,
                            child: SingleChildScrollView(
                              physics: ScrollPhysics(),
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 16)
                                            .r,
                                    child: Container(
                                      width: 0.25.sw,
                                      height: 8.w,
                                      decoration: BoxDecoration(
                                          color: AppColors.greys60,
                                          borderRadius:
                                              BorderRadius.circular(60).r),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 16)
                                        .r,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .mStaticFilterResults,
                                          style: GoogleFonts.montserrat(
                                              color: AppColors.greys87,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.12),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            clearAllFilters();
                                          },
                                          child: Container(
                                            height: 60.w,
                                            padding:
                                                EdgeInsets.only(left: 50).r,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .mStaticClearAll,
                                                style: GoogleFonts.lato(
                                                    color: AppColors.darkBlue,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.25),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: AppColors.darkGrey,
                                    thickness: 1.w,
                                    height: 0.w,
                                  ),
                                  CBPFilterWidget(
                                      updatedFilterList: updatedFilterList,
                                      selectedTimelineValue:
                                          selectedTimelineValue ?? false,
                                      checkStatus: checkStatus,
                                      filterProvider: filterProvider,
                                      competencyInfo: competencyInfo,
                                      doRefresh: true,
                                      updateFilterParentAction: (
                                          {String? category,
                                          List<String>? areaList,
                                          List<String>? themeList}) {
                                        updateCompetencyFilter(
                                            category: category,
                                            areaList: areaList,
                                            themeList: themeList);
                                      }),
                                  SizedBox(
                                    height: 150.w,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 88,
                          child: Container(
                            height: 88.w,
                            width: 1.sw,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.grey08,
                                  width: 1.w,
                                ),
                                color: AppColors.appBarBackground),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ButtonWidget(
                                    title: AppLocalizations.of(context)!
                                        .mStaticCancel,
                                    bgColor: AppColors.appBarBackground,
                                    textColor: AppColors.darkBlue,
                                    onPressed: () {
                                      for (int index = 0;
                                          index < updatedFilterList.length;
                                          index++) {
                                        var list = updatedFilterList[index];
                                        for (int filterIndex = 0;
                                            filterIndex < list.filters.length;
                                            filterIndex++) {
                                          checkStatus.forEach((element) {
                                            if (element['contentType'] ==
                                                    list.category &&
                                                element['index'] ==
                                                    filterIndex) {
                                              filterProvider.toggleFilter(
                                                  list.category, filterIndex);
                                            }
                                          });
                                        }
                                      }
                                      checkStatus.clear();
                                      Navigator.pop(context);
                                    }),
                                SizedBox(width: 20.w),
                                ButtonWidget(
                                  title: AppLocalizations.of(context)!
                                      .mCompetenciesContentTypeApplyFilters,
                                  onPressed: () async {
                                    for (int index = 0;
                                        index < updatedFilterList.length;
                                        index++) {
                                      var list = updatedFilterList[index];
                                      for (int filterIndex = 0;
                                          filterIndex < list.filters.length;
                                          filterIndex++) {
                                        checkStatus.forEach((element) {
                                          if (element['contentType'] ==
                                                  list.category &&
                                              element['index'] == filterIndex) {
                                            list.filters[filterIndex]
                                                    .isSelected =
                                                !list.filters[filterIndex]
                                                    .isSelected;
                                            filterProvider.toggleFilter(
                                                list.category, filterIndex);
                                          }
                                        });
                                      }
                                    }
                                    checkStatus.clear();
                                    selectedFilterList = updatedFilterList;
                                    await filterCourses();
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  int getTimeDiff(String date1, String date2) {
    return DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date1)))
        .difference(DateTime.parse(
            DateFormat('yyyy-MM-dd').format(DateTime.parse(date2))))
        .inDays;
  }

  void clearAllFilters() {
    _filteredListOfCourses.value = List.from(allCourseList);
    List<CBPFilterModel> filterList = cbpFilterProvider!.filters;
    bool isThemeExist = false, isSubThemeExist = false;
    for (int index = 0; index < filterList.length; index++) {
      if (filterList[index].category == CBPFilterCategory.competencyTheme) {
        isThemeExist = true;
      } else if (filterList[index].category ==
          CBPFilterCategory.competencySubtheme) {
        isSubThemeExist = true;
      } else {
        for (int filterIndex = 0;
            filterIndex < filterList[index].filters!.length;
            filterIndex++) {
          if (filterList[index].filters![filterIndex].isSelected) {
            cbpFilterProvider!
                .toggleFilter(filterList[index].category!, filterIndex);
          }
        }
      }
    }
    if (isSubThemeExist) {
      cbpFilterProvider!.removeFilter(CBPFilterCategory.competencySubtheme);
    }
    if (isThemeExist) {
      cbpFilterProvider!.removeFilter(CBPFilterCategory.competencyTheme);
    }
    checkStatus.clear();
  }

  void updateCompetencyFilter(
      {String? category, List<String>? areaList, List<String>? themeList}) {
    competencyName.clear();
    filterField.clear();
    try {
      if (competencyInfo != null &&
          competencyInfo.runtimeType != String &&
          competencyInfo['competency'] != null &&
          competencyInfo['competency'].isNotEmpty) {
        if (category == CompetencyFilterCategory.competencyArea) {
          AppConfiguration().useCompetencyv6
              ? competencyInfo['content'].forEach((element) {
                  competencyName.add({'name': element['name']});
                })
              : competencyInfo['competency'].forEach((element) {
                  competencyName.add({'name': element['name']});
                });
        } else if (category == CompetencyFilterCategory.competencyTheme &&
            areaList != null &&
            areaList.isNotEmpty) {
          areaList.forEach(
            (area) {
              competencyInfo['competency'].forEach(
                (element) {
                  if (element['name'].toString().toLowerCase() ==
                          area.toLowerCase() &&
                      element['children'] != null &&
                      element['children'].isNotEmpty) {
                    element['children'].forEach(
                      (item) {
                        competencyName.add({'name': item['name']});
                      },
                    );
                  }
                },
              );
            },
          );
        } else if (category == CompetencyFilterCategory.competencySubtheme &&
            areaList != null &&
            areaList.isNotEmpty &&
            themeList != null &&
            themeList.isNotEmpty) {
          areaList.forEach((area) {
            competencyInfo['competency'].forEach((element) {
              if (element['name'].toString().toLowerCase() ==
                      area.toLowerCase() &&
                  element['children'] != null &&
                  element['children'].isNotEmpty) {
                element['children'].forEach((item) {
                  themeList.forEach((theme) {
                    if (item['name'].toString().toLowerCase() ==
                            theme.toLowerCase() &&
                        item['children'] != null &&
                        item['children'].isNotEmpty) {
                      item['children'].forEach((subtheme) {
                        competencyName.add({'name': subtheme['name']});
                      });
                    }
                  });
                });
              }
            });
          });
        }
        // Add competency filters to CBPFilter list
        if (competencyName.isNotEmpty) {
          competencyName.sort(((a, b) => a['name'].compareTo(b['name'])));
          filterField.add({'category': category, 'values': competencyName});
        }
      }

      cbpFilterProvider!.addFilters(filterField);
    } catch (e) {
      debugPrint("---------$e");
    }
  }

  Future<void> getCompetency() async {
    competencyInfo = await Provider.of<LearnRepository>(context, listen: false)
        .getCompetencySearchInfo();
    updateCompetencyFilter(category: CompetencyFilterCategory.competencyArea);
    Future.delayed((Duration(milliseconds: 500)), () {
      if (filterField.isNotEmpty) {
        cbpFilterProvider!.addFilters(filterField);
      }
    });
  }

  Future<void> getEnrollmentList() async {
    List<String> doIdList = Helper.filterDoIds(widget.allCourseList);
    List<Course> responseList =
        await learnRepository.getCourseEnrollDetailsByIds(courseIds: doIdList);
    enrolmentList = responseList;
  }
}
