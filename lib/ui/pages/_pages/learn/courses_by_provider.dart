import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../util/telemetry_repository.dart';

class CoursesByProvider extends StatefulWidget {
  // static const route = AppUrl.coursesInCompetency;
  // final String identifier;
  final String providerName;
  final bool isCollection;
  final String collectionId;
  final String? collectionDescription;
  final bool isFromHome;

  CoursesByProvider(this.providerName,
      {this.isCollection = false,
      this.collectionId = '',
      this.collectionDescription,
      this.isFromHome = false});

  @override
  _CoursesByProviderState createState() => _CoursesByProviderState();
}

class _CoursesByProviderState extends State<CoursesByProvider> {
  List<Course> _listOfCourses = [];
  List<Course> _filteredListOfCourses = [];
  bool _pageInitilized = false;

  String? dropdownValue;
  List<String> dropdownItems = [
    EnglishLang.ascentAtoZ,
    EnglishLang.descentZtoA
  ];

  bool trimText = false;
  int _maxLength = 200;

  @override
  void initState() {
    super.initState();
    _generateTelemetryData();
    if (widget.isCollection && widget.collectionDescription != null) {
      if (widget.collectionDescription!.length > _maxLength) {
        trimText = true;
      }
    }
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: widget.isCollection
            ? TelemetryPageIdentifier.browseByCollectionCoursesPageId
            : TelemetryPageIdentifier.browseByProviderCoursesPageId,
        telemetryType: TelemetryType.page,
        pageUri: widget.isCollection
            ? TelemetryPageIdentifier.browseByCollectionCoursesPageUri
                .replaceAll(":collectionName", widget.providerName)
            : TelemetryPageIdentifier.browseByProviderCoursesPageUri
                .replaceAll(":providerName", widget.providerName),
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<dynamic> _getCoursesByProvider() async {
    _listOfCourses = !widget.isCollection
        ? await Provider.of<LearnRepository>(context, listen: false)
            .getCoursesByProvider(widget.providerName, [])
        : await Provider.of<LearnRepository>(context, listen: false)
            .getCoursesByCollection(widget.collectionId);
    if (!_pageInitilized) {
      setState(() {
        _filteredListOfCourses = _listOfCourses;
        _pageInitilized = true;
      });
    }
    return _listOfCourses;
  }

  void _filterTopicCourses(value) {
    setState(() {
      _filteredListOfCourses = _listOfCourses
          .where((course) => course.name.toLowerCase().contains(value))
          .toList();
    });
  }

  void _sortCourses(sortBy) {
    setState(() {
      if (sortBy == EnglishLang.ascentAtoZ) {
        _filteredListOfCourses.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      } else
        _filteredListOfCourses.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    });
  }

  void _toogleReadMore() {
    setState(() {
      trimText = !trimText;
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
          // elevation: 0,
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
              !widget.isFromHome
                  ? (!widget.isCollection
                      ? AppLocalizations.of(context)!.mCoursesBackToProviders
                      : AppLocalizations.of(context)!.mCoursesBackToCollections)
                  : AppLocalizations.of(context)!.mStaticBack,
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
                future: _getCoursesByProvider(),
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Container(
                      // color: Color.fromRGBO(241, 244, 244, 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              color: AppColors.appBarBackground,
                              // height: 56,
                              width: double.infinity.w,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 14, 16, 14).r,
                                child: Text(widget.providerName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(
                                          fontFamily: GoogleFonts.montserrat()
                                              .fontFamily,
                                          fontSize: 20.sp,
                                          height: 1.5.w,
                                          letterSpacing: 0.12,
                                        )),
                              )),
                          (widget.isCollection &&
                                  widget.collectionDescription != null)
                              ? Container(
                                  width: double.infinity.w,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 16, 16, 0)
                                            .r,
                                    child:
                                        Text(
                                            (trimText &&
                                                    widget.collectionDescription !=
                                                        null &&
                                                    widget.collectionDescription!
                                                            .length >
                                                        _maxLength)
                                                ? widget
                                                        .collectionDescription!
                                                        .substring(
                                                            0, _maxLength - 1) +
                                                    '...'
                                                : widget.collectionDescription!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontFamily:
                                                      GoogleFonts.montserrat()
                                                          .fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.5.w,
                                                  letterSpacing: 0.12,
                                                )),
                                  ))
                              : Center(),
                          (widget.isCollection &&
                                  widget.collectionDescription != null)
                              ? (widget.collectionDescription!.length >
                                      _maxLength)
                                  ? Padding(
                                      padding: const EdgeInsets.all(10).r,
                                      child: Center(
                                        child: InkWell(
                                            onTap: () => _toogleReadMore(),
                                            child: Text(
                                              trimText
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .mStaticReadMore
                                                  : AppLocalizations.of(
                                                          context)!
                                                      .mStaticShowLess,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium!
                                                  .copyWith(
                                                    fontFamily:
                                                        GoogleFonts.montserrat()
                                                            .fontFamily,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            )),
                                      ))
                                  : Center()
                              : Center(),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 24, bottom: 16).r,
                            child: Container(
                              color: AppColors.appBarBackground,
                              width: double.infinity.w,
                              height: 117.w,
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
                                        children: [
                                          Container(
                                            width: 0.7.sw,
                                            // width: 316,
                                            height: 48.w,
                                            child: TextFormField(
                                                onChanged: (value) {
                                                  _filterTopicCourses(value);
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
                                              color: AppColors.appBarBackground,
                                              border: Border.all(
                                                color: AppColors.grey16,
                                                width: 1.w,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4).r),
                                              // color: AppColors.lightGrey,
                                            ),
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
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
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
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyMedium,
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

                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16, bottom: 16).r,
                            child: Text(
                                _filteredListOfCourses.length.toString() +
                                    ' CBP\'s from this ' +
                                    (!widget.isCollection
                                        ? 'provider'
                                        : 'collection'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      height: 1.5.w,
                                      letterSpacing: 0.12,
                                    )),
                          ),

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
                                                _filteredListOfCourses[index],
                                            telemetryPageId:
                                                TelemetryPageIdentifier
                                                    .browseByAllProviderPageId),
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
                          // BrowseCompetencyCard(_listOfCourses)
                          // HubPage(),
                        ],
                      ),
                    );
                  } else {
                    return PageLoader(
                      top: MediaQuery.of(context).size.height / 4,
                    );
                  }
                }),
          ),
        ));
  }
}
