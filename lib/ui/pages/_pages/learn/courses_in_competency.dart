import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/filter/course_filters.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CoursesInCompetency extends StatefulWidget {
  static const route = AppUrl.coursesInCompetency;
  final BrowseCompetencyCardModel browseCompetencyCardModel;
  CoursesInCompetency(this.browseCompetencyCardModel);

  @override
  _CoursesInCompetencyState createState() {
    return new _CoursesInCompetencyState();
  }
}

class _CoursesInCompetencyState extends State<CoursesInCompetency> {
  // var _levels = [];
  List<Course> _listOfCourses = [];
  bool _pageInitilized = false;
  List<Course> _filteredListOfCourses = [];
  dynamic _listOfProviders = [];
  // List<Course> _allCourses = [];

  List<String> contentTypes = [
    EnglishLang.program,
    EnglishLang.course,
  ];

  List<String> selectedContentTypes = [];
  List<String> selectedProviders = [];

  String? dropdownValue;
  List<String> dropdownItems = [
    EnglishLang.ascentAtoZ,
    EnglishLang.descentZtoA
  ];

  String? userId;
  String? userSessionId;
  String? messageIdentifier;
  String? departmentId;
  // List allEventsData;
  bool? dataSent;
  bool isDiscussionTypesOpen = false;
  bool isTrending = true;
  List typesOfDiscussions = ['Trending', 'Recent'];
  String? deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _generateTelemetryData();
    // _getLevelsAndDescription();
    // setState(() {
    //   selectedContentTypes = contentTypes;
    //   selectedProviders = _listOfProviders;
    // });
    // _getListOfCompetencies();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByCompetencyCoursesPageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.browseByCompetencyCoursesPageUri
            .replaceAll(
                ':competencyName', widget.browseCompetencyCardModel.name),
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<dynamic> _getCoursesByCompetencies(
      selectedContentTypes, selectedProviders) async {
    _listOfCourses = await Provider.of<LearnRepository>(context, listen: false)
        .getCoursesByCompetencies(widget.browseCompetencyCardModel.name,
            selectedContentTypes, selectedProviders);
    if (!_pageInitilized) {
      final listOfProviders = _getAllProviders(_listOfCourses);
      _listOfProviders = listOfProviders.map((item) => (item).toList());
      setState(() {
        _filteredListOfCourses = _listOfCourses;
        _listOfProviders = listOfProviders;
        _pageInitilized = true;
      });
    }
    return _listOfCourses;
  }

  // Future<dynamic> _getLevelsAndDescription() async {
  //   _levels = await Provider.of<CompetencyRepository>(context, listen: false)
  //       .getLevelsForCompetency(
  //           widget.browseCompetencyCardModel.id, "COMPETENCY");
  //   return _levels;
  // }

  _getAllProviders(courses) {
    var data = [];
    courses.forEach((item) => data.add(item.source));
    var seen = Set<String>();
    data = data.where((type) => seen.add(type)).toList();
    return data;
  }

  void _filterCourses(value) {
    setState(() {
      _filteredListOfCourses = _listOfCourses
          .where((course) => course.name.toLowerCase().contains(value))
          .toList();
    });
  }

  Future<void> updateFilters(Map data) async {
    switch (data['filter']) {
      case EnglishLang.contentType:
        if (selectedContentTypes.contains(data['item'].toLowerCase())) {
          selectedContentTypes.remove(data['item'].toLowerCase());
        } else {
          selectedContentTypes.add(data['item'].toLowerCase());
        }
        break;
      default:
        // if (!selectedProviders.contains(data['item'].toLowerCase()) &&
        //     selectedProviders.length > 0)
        //   selectedProviders.remove(selectedProviders[0]);
        if (selectedProviders.contains(data['item'].toLowerCase()))
          selectedProviders.remove(data['item'].toLowerCase());
        else
          selectedProviders.add(data['item'].toLowerCase());
        break;
    }
    _listOfCourses = await Provider.of<LearnRepository>(context, listen: false)
        .getCoursesByCompetencies(widget.browseCompetencyCardModel.name,
            selectedContentTypes, selectedProviders);
    setState(() {
      _filteredListOfCourses = _listOfCourses;
    });
  }

  Future<void> setDefault(String filter) async {
    switch (filter) {
      case EnglishLang.contentType:
        setState(() {
          selectedContentTypes = [];
        });
        break;
      default:
        selectedProviders = [];
    }
    // setState(() {});
    _listOfCourses = await _getCoursesByCompetencies(
        selectedContentTypes, selectedProviders);
    setState(() {
      _filteredListOfCourses = _listOfCourses;
    });
  }

  void _sortCourses(sortBy) {
    setState(() {
      if (sortBy == EnglishLang.ascentAtoZ) {
        _filteredListOfCourses.sort((a, b) =>
            a.name.toLowerCase().trim().compareTo(b.name.toLowerCase().trim()));
      } else
        _filteredListOfCourses.sort((a, b) =>
            b.name.toLowerCase().trim().compareTo(a.name.toLowerCase().trim()));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackground,
          elevation: 0,
          titleSpacing: 0,
          // automaticallyImplyLeading: false,
          // leading: Row(children: [
          //   IconButton(
          //       icon: Icon(
          //         Icons.close,
          //         color: AppColors.greys87,
          //       ),
          //       onPressed: () {
          //         Navigator.pop(context);
          //       }),
          //   Text(widget.backToTitle)
          // ]),
          title: Text(
              AppLocalizations.of(context)!.mCompetenciesBackToAllCompetencies,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    wordSpacing: 1.0,
                  )),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: FutureBuilder(
                future: _getCoursesByCompetencies(
                    selectedContentTypes, selectedProviders),
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Container(
                      // color: Color.fromRGBO(241, 244, 244, 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16, bottom: 16)
                                .r,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.browseCompetencyCardModel.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          height: 1.5.w,
                                          letterSpacing: 0.12,
                                        )),
                                (widget.browseCompetencyCardModel.description !=
                                            null &&
                                        widget.browseCompetencyCardModel
                                                .description !=
                                            '')
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8).r,
                                        child: Text(
                                            widget.browseCompetencyCardModel
                                                    .description ??
                                                "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  height: 1.5.w,
                                                  letterSpacing: 0.12,
                                                )),
                                      )
                                    : Center(),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16).r,
                                  child: Row(
                                    children: [
                                      Text(
                                        Helper.capitalizeEachWordFirstCharacter(
                                                AppLocalizations.of(context)!
                                                    .mStaticCompetencyArea) +
                                            ":",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              height: 1.5.w,
                                              letterSpacing: 0.12,
                                            ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8).r,
                                        child: Text(
                                            Helper.capitalizeFirstLetter(widget
                                                .browseCompetencyCardModel
                                                .competencyType),
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(
                                                  height: 1.5.w,
                                                  letterSpacing: 0.12,
                                                )),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16).r,
                                  child: Row(
                                    children: [
                                      Text(
                                        Helper.capitalizeEachWordFirstCharacter(
                                                AppLocalizations.of(context)!
                                                    .mCompetencyTheme) +
                                            ":",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              height: 1.5.w,
                                              letterSpacing: 0.12,
                                            ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8).r,
                                        child: Text(
                                            Helper.capitalizeFirstLetter(widget
                                                .browseCompetencyCardModel
                                                .competencyArea),
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayLarge!
                                                .copyWith(
                                                  height: 1.5.w,
                                                  letterSpacing: 0.12,
                                                )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 24, bottom: 16).r,
                            child: Container(
                              color: AppColors.appBarBackground,
                              width: double.infinity.w,
                              height: 136.w,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 16).r,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 300.w,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .mCompetenciesExploreallAssociatedCBPs,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              height: 1.5.w,
                                              letterSpacing: 0.12,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8).r,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 0.7.sw,
                                            // width: 316,
                                            height: 48.w,
                                            child: TextFormField(
                                                onChanged: (value) {
                                                  _filterCourses(value);
                                                },
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.done,
                                                style: GoogleFonts.lato(
                                                    fontSize: 14.0.sp),
                                                decoration: InputDecoration(
                                                  prefixIcon:
                                                      Icon(Icons.search),
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(16.0,
                                                              16.0, 0.0, 16.0)
                                                          .r,
                                                  // border: OutlineInputBorder(
                                                  //     borderSide: BorderSide(
                                                  //         color: AppColors
                                                  //             .primaryThree, width: 10),),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                                4.0)
                                                            .r,
                                                    borderSide: BorderSide(
                                                      color: AppColors.grey16,
                                                      width: 1.0.w,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                                4.0)
                                                            .r,
                                                    borderSide: BorderSide(
                                                      color: AppColors
                                                          .primaryThree,
                                                    ),
                                                  ),
                                                  hintText: AppLocalizations.of(
                                                          context)!
                                                      .mCommonSearch,

                                                  hintStyle: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall!
                                                      .copyWith(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                  // focusedBorder: OutlineInputBorder(
                                                  //   borderSide: const BorderSide(
                                                  //       color: AppColors.primaryThree, width: 1.0),
                                                  // ),
                                                  counterStyle: TextStyle(
                                                    height:
                                                        double.minPositive.w,
                                                  ),
                                                  counterText: '',
                                                )),
                                          ),
                                          Container(
                                            height: 48.w,
                                            width: 0.2.sw,
                                            decoration: BoxDecoration(
                                                color:
                                                    AppColors.appBarBackground,
                                                border: Border.all(
                                                  color: AppColors.grey16,
                                                  width: 1.w,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4).r)),
                                            child: DropdownButton<String>(
                                              value: dropdownValue != null
                                                  ? dropdownValue
                                                  : null,
                                              icon: Icon(
                                                Icons.arrow_drop_down,
                                                color: AppColors.greys60,
                                                size: 18.sp,
                                              ),
                                              hint: Padding(
                                                padding: const EdgeInsets.only(
                                                        left: 8)
                                                    .r,
                                                child: Container(
                                                    width: 50.w,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .mCommonSortBy,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                              ),
                                              iconSize: 26.r,
                                              elevation: 16,
                                              style: TextStyle(
                                                  color: AppColors.greys87),
                                              underline: Container(
                                                // height: 2,
                                                color: AppColors.lightGrey,
                                              ),
                                              selectedItemBuilder:
                                                  (BuildContext context) {
                                                return dropdownItems
                                                    .map<Widget>((String item) {
                                                  return Row(
                                                    children: [
                                                      Padding(
                                                          padding: EdgeInsets
                                                                  .fromLTRB(
                                                                      15.0,
                                                                      15.0,
                                                                      0,
                                                                      15.0)
                                                              .r,
                                                          child: Text(
                                                            item,
                                                            style: GoogleFonts
                                                                .lato(
                                                              color: AppColors
                                                                  .greys87,
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ))
                                                    ],
                                                  );
                                                }).toList();
                                              },
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  dropdownValue = newValue;
                                                });
                                                _sortCourses(dropdownValue);
                                              },
                                              items: dropdownItems.map<
                                                      DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          selectedProviders.length > 1
                              ? Container(
                                  padding: EdgeInsets.only(
                                          left: 16, right: 16, bottom: 16)
                                      .r,
                                  child: Wrap(
                                    children: [
                                      for (var i = 0;
                                          i < selectedProviders.length;
                                          i++)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8).r,
                                          child: (Chip(
                                              label: Text(
                                                  'Provider | ' + //
                                                      selectedProviders[i]
                                                          .toUpperCase(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall!
                                                      .copyWith(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        height: 1.5.w,
                                                        letterSpacing: 0.12,
                                                      )))),
                                        )
                                    ],
                                  ))
                              : Center(),
                          _listOfCourses.length > 0
                              ? Container(
                                  // height: 100,
                                  child: ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    itemCount: _filteredListOfCourses.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8).r,
                                        child: BrowseCard(
                                            course:
                                                _filteredListOfCourses[index]),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 80).r,
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .mStaticNoAssociatedCBPs,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              height: 1.5.w,
                                              letterSpacing: 0.12,
                                            )),
                                  ),
                                ),
                        ],
                      ),
                    );
                  } else {
                    return PageLoader(
                      //  bottom: 150,
                      top: MediaQuery.of(context).size.height / 4,
                    );
                  }
                }),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            // height: _activeTabIndex == 0 ? 60 : 0,
            height: 60.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.all(10).r,
                  child: IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: AppColors.appBarBackground,
                      ),
                      onPressed: () {}),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8).r,
                    color: AppColors.primaryThree,
                  ),
                  height: 40.w,
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseFilters(
                                filterName: EnglishLang.contentType,
                                items: contentTypes,
                                selectedItems: selectedContentTypes,
                                parentAction1: updateFilters,
                                parentAction2: setDefault,
                              ),
                            ),
                          ),
                        },
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10).r,
                            padding: const EdgeInsets.only(left: 0, right: 0).r,
                            height: 40.w,
                            child: FilterCard(
                                AppLocalizations.of(context)!
                                    .mCourseContentType,
                                (selectedContentTypes.length < 2 &&
                                        selectedContentTypes.length != 0
                                    ? (selectedContentTypes[0].toUpperCase())
                                    : EnglishLang.all))),
                      ),
                      InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseFilters(
                                filterName: EnglishLang.providers,
                                items: _listOfProviders,
                                selectedItems: selectedProviders,
                                parentAction1: updateFilters,
                                parentAction2: setDefault,
                              ),
                            ),
                          ),
                        },
                        child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10).r,
                            padding:
                                const EdgeInsets.only(left: 10, right: 10).r,
                            height: 40.w,
                            child: FilterCard(
                                AppLocalizations.of(context)!.mStaticProviders,
                                selectedProviders.length > 0
                                    ? (selectedProviders.length == 1
                                        ? (selectedProviders[0].toUpperCase())
                                        : ('MULTIPLE SELECTED'))
                                    : (EnglishLang.all))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
