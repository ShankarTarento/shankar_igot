import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/filter/browse_by_competency_filter.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/competency_card.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrowseByCompetency extends StatefulWidget {
  static const route = AppUrl.browseByCompetencyPage;

  @override
  _BrowseByCompetencyState createState() => _BrowseByCompetencyState();
}

class _BrowseByCompetencyState extends State<BrowseByCompetency> {
  List<BrowseCompetencyCardModel> _listOfCompetencies = [];
  List<BrowseCompetencyCardModel> _filteredListOfCompetencies = [];
  bool _pageInitilized = false;

  // int pageNo = 1;
  String? dropdownValue;
  List<String> dropdownItems = [
    EnglishLang.ascentAtoZ,
    EnglishLang.descentZtoA
  ];

  List<dynamic> _allCompetencyArea = [];
  List<dynamic> _allCompetencyType = [];

  int? _selectedTypeIndex;
  int? _selectedAreaIndex;
  bool _isAppliedFilter = false;
  bool _loadMore = false;

  bool isDiscussionTypesOpen = false;
  bool isTrending = true;
  List typesOfDiscussions = ['Trending', 'Recent'];

  @override
  void initState() {
    super.initState();
    // _getListOfCompetencies();
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByAllCompetenciesPageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.browseByAllCompetenciesPageUri,
        env: TelemetryEnv.explore);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<dynamic> _getListOfCompetencies() async {
    _listOfCompetencies =
        await Provider.of<LearnRepository>(context, listen: false)
            .getListOfCompetencies(context);

    //getting list of competency types
    _allCompetencyType =
        _listOfCompetencies.map((e) => e.competencyType).toList();
    var seen = Set<String>();
    _allCompetencyType =
        _allCompetencyType.where((type) => seen.add(type)).toList();
    _allCompetencyType.remove('');
    _allCompetencyType.insert(0, 'All');

    //getting list of competency area
    _allCompetencyArea =
        _listOfCompetencies.map((e) => e.competencyArea).toList();
    _allCompetencyArea =
        _allCompetencyArea.where((area) => seen.add(area)).toList();
    _allCompetencyArea.remove('');
    _allCompetencyArea.insert(0, 'All');

    if (!_pageInitilized) {
      setState(() {
        _filteredListOfCompetencies = _listOfCompetencies;
        _pageInitilized = true;
      });
    }

    // listOfCompetencies = await courseService.getCompetenciesList();
    // print({'Browse by competencies page $_listOfCompetencies'});
    return _listOfCompetencies;
  }

  void filterCompetencies(value) {
    setState(() {
      _filteredListOfCompetencies = _listOfCompetencies
          .where((competency) => competency.name.toLowerCase().contains(value))
          .toList();
    });
  }

  void filterCompetencyBy(Map filter) {
    // print('filterBy: ' + filter.toString());
    if (filter['type'] != EnglishLang.all &&
        filter['area'] == EnglishLang.all) {
      setState(() {
        _filteredListOfCompetencies = _listOfCompetencies
            .where((competency) => competency.competencyType
                .toLowerCase()
                .contains(filter['type'].toLowerCase()))
            .toList();
      });
    } else if (filter['area'] != EnglishLang.all &&
        filter['type'] == EnglishLang.all) {
      setState(() {
        _filteredListOfCompetencies = _listOfCompetencies
            .where((competency) => competency.competencyArea
                .toLowerCase()
                .contains(filter['area'].toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        _filteredListOfCompetencies = _listOfCompetencies;
      });
    }
  }

  void _selectedFilterIndex(Map index) {
    // print('Indexs: ' + index.toString());
    setState(() {
      _selectedTypeIndex = index['type'];
      _selectedAreaIndex = index['area'];
    });
  }

  void sortCompetencies(sortBy) {
    setState(() {
      if (sortBy == EnglishLang.ascentAtoZ) {
        _filteredListOfCompetencies
            .sort((a, b) => a.name.trim().compareTo(b.name.trim()));
      } else
        _filteredListOfCompetencies
            .sort((a, b) => b.name.trim().compareTo(a.name.trim()));
    });
  }

  void _setAppliedFilterStatus(bool isApplied) {
    setState(() {
      _isAppliedFilter = isApplied;
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
            AppLocalizations.of(context)!.mStaticBackToExploreBy,
            style: GoogleFonts.lato(
                color: AppColors.greys60,
                wordSpacing: 1.0,
                fontSize: 16.0.sp,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: FutureBuilder(
                future: _getListOfCompetencies(),
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Container(
                      // color: Color.fromRGBO(241, 244, 244, 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 16).r,
                            child: Text(
                              AppLocalizations.of(context)!
                                  .mStaticAllCompetencies,
                              style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp,
                                  letterSpacing: 0.12,
                                  height: 1.5.w),
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/img/competency_landing.svg',
                            width: 1.sw,
                            fit: BoxFit.fitWidth,
                          ),
                          Container(
                            padding:
                                const EdgeInsets.fromLTRB(16, 16, 16, 16).r,
                            child: Text(
                              AppLocalizations.of(context)!
                                  .mCompLabelPopularCompetencies,
                              style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.sp,
                                  letterSpacing: 0.12,
                                  height: 1.5.w),
                            ),
                          ),
                          _listOfCompetencies.length > 0
                              ? Container(
                                  height: 100.w,
                                  child: AnimationLimiter(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: 4,
                                      itemBuilder: (context, index) {
                                        return AnimationConfiguration
                                            .staggeredList(
                                          position: index,
                                          duration:
                                              const Duration(milliseconds: 375),
                                          child: SlideAnimation(
                                            verticalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: CompetencyCard(
                                                browseCompetencyCardModel:
                                                    _listOfCompetencies[index],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : Center(),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 24, bottom: 16).r,
                            child: Container(
                              color: AppColors.appBarBackground,
                              width: double.infinity,
                              // height: 112,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 16).r,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!
                                          .mStaticBrowseCompetency,
                                      style: GoogleFonts.lato(
                                          color: AppColors.greys87,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.sp,
                                          letterSpacing: 0.12,
                                          height: 1.5.w),
                                    ),
                                    SizedBox(
                                      height: 8.w,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 0.75.sw,
                                          // width: 316,
                                          height: 48.w,
                                          child: Center(
                                            child: TextFormField(
                                                onChanged: (value) {
                                                  filterCompetencies(value);
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
                                                              10.0, 0.0, 10.0)
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
                                                      .mStaticSearch,
                                                  hintStyle: GoogleFonts.lato(
                                                      color: AppColors.greys60,
                                                      fontSize: 14.0.sp,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  // focusedBorder: OutlineInputBorder(
                                                  //   borderSide: const BorderSide(
                                                  //       color: AppColors.primaryThree, width: 1.0),
                                                  // ),
                                                  counterStyle: TextStyle(
                                                    height: double.minPositive,
                                                  ),
                                                  counterText: '',
                                                )),
                                          ),
                                        ),
                                        Container(
                                          width: 48.r,
                                          height: 48.r,
                                          decoration: BoxDecoration(
                                            color: _isAppliedFilter
                                                ? AppColors.primaryThree
                                                : AppColors.appBarBackground,
                                            borderRadius: BorderRadius.all(
                                                    const Radius.circular(4.0))
                                                .w,
                                            border: Border.all(
                                                color: AppColors.grey16),
                                          ),
                                          child: IconButton(
                                              icon: Icon(
                                                Icons.filter_list,
                                                color: _isAppliedFilter
                                                    ? AppColors.appBarBackground
                                                    : AppColors.greys60,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  dropdownValue = null;
                                                });
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BrowseByCompetencyFilter(
                                                      allCompetencyTypes:
                                                          _allCompetencyType,
                                                      allCompetencyArea:
                                                          _allCompetencyArea,
                                                      parentAction1:
                                                          filterCompetencyBy,
                                                      selectedFilterIndex:
                                                          _selectedFilterIndex,
                                                      selectedTypeIndex:
                                                          _selectedTypeIndex,
                                                      selectedAreaIndex:
                                                          _selectedAreaIndex,
                                                      isAppliedFilter:
                                                          _setAppliedFilterStatus,
                                                    ),
                                                  ),
                                                );
                                              }),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 4).r,
                                    child: DropdownButton<String>(
                                      value: dropdownValue != null
                                          ? dropdownValue
                                          : null,
                                      icon:
                                          Icon(Icons.arrow_drop_down_outlined),
                                      iconSize: 18.w,
                                      hint: Container(
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(left: 16).r,
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .mCommonSortBy,
                                            style: GoogleFonts.lato(
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.25),
                                          )),
                                      style:
                                          TextStyle(color: AppColors.greys87),
                                      underline: Container(
                                        // height: 2,
                                        color: AppColors.lightGrey,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                        return dropdownItems
                                            .map<Widget>((String item) {
                                          return dropdownValue != null
                                              ? Row(
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                    15.0,
                                                                    15.0,
                                                                    0,
                                                                    15.0)
                                                                .r,
                                                        child: Flexible(
                                                          child: Text(
                                                            '${AppLocalizations.of(context)!.mCommonSortBy} $item',
                                                            // "Sort by $item",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: GoogleFonts
                                                                .lato(
                                                              color: AppColors
                                                                  .greys60,
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        )),
                                                  ],
                                                )
                                              : Center();
                                        }).toList();
                                      },
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValue = newValue;
                                        });
                                        sortCompetencies(dropdownValue);
                                      },
                                      items: dropdownItems
                                          .map<DropdownMenuItem<String>>(
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
                            ],
                          ),
                          _filteredListOfCompetencies.length > 1
                              ? Column(
                                  children: [
                                    Container(
                                      // height: 100,
                                      child: AnimationLimiter(
                                        child: ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemCount: _loadMore
                                              ? _filteredListOfCompetencies
                                                  .length
                                              : (_filteredListOfCompetencies
                                                          .length <
                                                      10
                                                  ? _filteredListOfCompetencies
                                                      .length
                                                  : 10),
                                          itemBuilder: (context, index) {
                                            return AnimationConfiguration
                                                .staggeredList(
                                              position: index,
                                              duration: const Duration(
                                                  milliseconds: 375),
                                              child: SlideAnimation(
                                                verticalOffset: 50.0,
                                                child: FadeInAnimation(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8),
                                                    child: BrowseCompetencyCard(
                                                      browseCompetencyCardModel:
                                                          _filteredListOfCompetencies[
                                                              index],
                                                      isCompetencyDetails:
                                                          false,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    _filteredListOfCompetencies.length > 10
                                        ? TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _loadMore = !_loadMore;
                                              });
                                            },
                                            child: Text(
                                              _loadMore
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .mStaticShowLess
                                                  : AppLocalizations.of(
                                                          context)!
                                                      .mStaticLoadMore,
                                              style: GoogleFonts.lato(
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5),
                                            ))
                                        : Center()
                                  ],
                                )
                              : Center(
                                  child: Text(AppLocalizations.of(context)!
                                      .mCompLabelNocompetenciesfound)),
                          SizedBox(
                            height: 32.w,
                          )
                        ],
                      ),
                    );
                  } else {
                    return PageLoader(
                      top: 1.sh / 4,
                    );
                  }
                }),
          ),
        ));
  }
}
