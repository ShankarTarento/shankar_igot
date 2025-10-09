import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/index.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/competency/self_attest_competency.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../respositories/_respositories/competency_repository.dart';
import '../../../../util/telemetry_repository.dart';

class CompetencyDetailsPage extends StatefulWidget {
  static const route = AppUrl.coursesInCompetency;
  final BrowseCompetencyCardModel browseCompetencyCardModel;
  final updateCompetencyAddedStatus;
  CompetencyDetailsPage(this.browseCompetencyCardModel,
      {this.updateCompetencyAddedStatus});

  @override
  _CoursesInCompetencyState createState() {
    return new _CoursesInCompetencyState();
  }
}

class _CoursesInCompetencyState extends State<CompetencyDetailsPage> {
  final CompetencyService competencyService = CompetencyService();

  var _levels = [];
  var _profileCompetencies = [];
  bool _isAlreadyAdded = false;
  List<Course> _listOfCourses = [];
  bool _pageInitilized = false;
  bool _bottomBarInitilized = false;
  List<Course> _filteredListOfCourses = [];
  var _addedCompetency;

  String? dropdownValue;
  List<String> dropdownItems = [
    EnglishLang.ascentAtoZ,
    EnglishLang.descentZtoA
  ];

  bool? dataSent;
  bool isDiscussionTypesOpen = false;
  bool isTrending = true;
  List typesOfDiscussions = ['Trending', 'Recent'];

  @override
  void initState() {
    super.initState();
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByCompetencyCoursesPageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.browseByCompetencyCoursesPageUri
            .replaceAll(
                ":competencyName", widget.browseCompetencyCardModel.name),
        env: TelemetryEnv.competency);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<dynamic> _getCoursesByCompetencies() async {
    // getting list of courses in the current competency
    List<String> emptyList = [];
    _listOfCourses = await Provider.of<LearnRepository>(context, listen: false)
        .getCoursesByCompetencies(
            widget.browseCompetencyCardModel.name, emptyList, emptyList);

    //getting all levels and description
    _levels = await _getLevelsAndDescription();

    if (!_pageInitilized) {
      setState(() {
        _filteredListOfCourses = _listOfCourses;
        _pageInitilized = true;
      });
    }
    return _listOfCourses;
  }

  Future<bool> _checkAlreadyAdded() async {
    if (!_bottomBarInitilized) {
      List<Profile> _profileDetails =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getProfileDetailsById('');
      _profileCompetencies = _profileDetails[0].competencies!;

      final foundId = _profileCompetencies.where((competency) =>
          competency['id'] == widget.browseCompetencyCardModel.id);

      setState(() {
        if (foundId.isNotEmpty) {
          _addedCompetency = foundId.first;
          _isAlreadyAdded = true;
        } else {
          _isAlreadyAdded = false;
        }
        _bottomBarInitilized = true;
      });
    }
    return _isAlreadyAdded;
  }

  Future<void> _removeFromYourCompetency(id) async {
    List<Profile> profileDetails =
        await Provider.of<ProfileRepository>(context, listen: false)
            .getProfileDetailsById('');
    var _response =
        await competencyService.removeFromYourCompetency(id, profileDetails);

    if (_response['params']['errmsg'] == null ||
        _response['params']['errmsg'] == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.mStaticRemovedFromYourCompetency),
          backgroundColor: AppColors.positiveLight,
        ),
      );
      setState(() {
        _bottomBarInitilized = false;
        if (widget.updateCompetencyAddedStatus != null) {
          widget.updateCompetencyAddedStatus(false);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.mStaticErrorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _addedStatus(dynamic response) async {
    if (response['params']['errmsg'] == null ||
        response['params']['errmsg'] == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.mStaticAddedToYourCompetency),
          backgroundColor: AppColors.positiveLight,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.mStaticErrorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
    setState(() {
      _bottomBarInitilized = false;
    });
    if (widget.updateCompetencyAddedStatus != null) {
      widget.updateCompetencyAddedStatus(false);
    }
  }

  Future<dynamic> _getLevelsAndDescription() async {
    var levels = await Provider.of<CompetencyRepository>(context, listen: false)
        .getLevelsForCompetency(
            widget.browseCompetencyCardModel.id, "COMPETENCY");
    return levels;
  }

  void _filterCourses(value) {
    setState(() {
      _filteredListOfCourses = _listOfCourses
          .where((course) => course.name.toLowerCase().contains(value))
          .toList();
    });
  }

  void _sortCourses(sortBy) {
    setState(() {
      if (sortBy == EnglishLang.ascentAtoZ) {
        _filteredListOfCourses
            .sort((a, b) => a.name.trim().compareTo(b.name.trim()));
      } else
        _filteredListOfCourses
            .sort((a, b) => b.name.trim().compareTo(a.name.trim()));
    });
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = Container(
      width: 1.sw,
      padding: EdgeInsets.all(10).r,
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0).r),
        border: bgColor == AppColors.appBarBackground
            ? Border.all(color: AppColors.grey40)
            : Border.all(color: bgColor),
      ),
      child: Text(
        buttonLabel,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontFamily: GoogleFonts.montserrat().fontFamily,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
      ),
    );
    return loginBtn;
  }

  Future<bool?> _confirmDeletion() {
    return showModalBottomSheet(
        isScrollControlled: true,
        // useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8).r,
            topRight: Radius.circular(8).r,
          ),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (context) => SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 20).r,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20).r,
                            height: 6.w,
                            width: 0.25.sw,
                            decoration: BoxDecoration(
                              color: AppColors.grey16,
                              borderRadius: BorderRadius.all(
                                Radius.circular(16).r,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.only(top: 5, bottom: 15).r,
                            child: Text(
                              AppLocalizations.of(context)!
                                  .mStaticDoYouWantToRemove,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                            )),
                        Container(
                          padding: const EdgeInsets.only(top: 5, bottom: 15).r,
                          child: GestureDetector(
                            onTap: () async {
                              _removeFromYourCompetency(
                                  widget.browseCompetencyCardModel.id);
                              Navigator.of(context).pop(true);
                            },
                            child: roundedButton(
                                AppLocalizations.of(context)!.mStaticYesRemove,
                                AppColors.appBarBackground,
                                AppColors.primaryThree),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 0, bottom: 15).r,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: roundedButton(
                                AppLocalizations.of(context)!.mStaticNoBackText,
                                AppColors.primaryThree,
                                AppColors.appBarBackground),
                          ),
                        ),
                      ])),
            ));
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
        title: Text(
          AppLocalizations.of(context)!.mStaticBackToAllCompetencies,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                wordSpacing: 1.0,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: _getCoursesByCompetencies(),
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
                          Text(
                            widget.browseCompetencyCardModel.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.5.w,
                                  letterSpacing: 0.12,
                                ),
                          ),
                          widget.browseCompetencyCardModel.description != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8).r,
                                  child: Text(
                                    widget.browseCompetencyCardModel
                                            .description ??
                                        "",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          letterSpacing: 0.12,
                                          height: 1.5.w,
                                        ),
                                  ),
                                )
                              : Center(),
                          Padding(
                            padding: const EdgeInsets.only(top: 16).r,
                            child: Row(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .mCompLabelCompetencyType,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        height: 1.5.w,
                                        letterSpacing: 0.12,
                                      ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8).r,
                                  child: Text(
                                    widget.browseCompetencyCardModel
                                        .competencyType,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge!
                                        .copyWith(
                                          letterSpacing: 0.12,
                                          height: 1.5.w,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16).r,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .mCompLabelCompetencyArea,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        height: 1.5.w,
                                        letterSpacing: 0.12,
                                      ),
                                ),
                                Container(
                                  width: 0.6.sw,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8).r,
                                    child: Text(
                                      widget.browseCompetencyCardModel
                                          .competencyArea,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .copyWith(
                                            letterSpacing: 0.12,
                                            height: 1.5.w,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0).r,
                      child: Container(
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _levels.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 8.0).r,
                              child: Container(
                                width: 75.w,
                                color: AppColors.appBarBackground,
                                child: Wrap(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16).r,
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          // mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 1.sw / 3,
                                                  child: Text(
                                                    _levels[index]['level'],
                                                    // "Name of the competency",

                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall!
                                                        .copyWith(
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 1.sw / 3,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                                top: 4)
                                                            .r,
                                                    child: Text(
                                                      _levels[index]['name'],
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .copyWith(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            VerticalDivider(
                                              thickness: 1.w,
                                              width: 20.w,
                                              color: AppColors.grey16,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  width: 1.sw / 2,
                                                  child: Text(
                                                    _levels[index]
                                                        ['description'],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displaySmall!
                                                        .copyWith(
                                                          fontSize: 14.sp,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 16).r,
                      child: Container(
                        color: AppColors.appBarBackground,
                        width: double.infinity.w,
                        height: 117.w,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16).r,
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
                                            _filterCourses(value);
                                          },
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.done,
                                          style: GoogleFonts.lato(
                                              fontSize: 14.0.sp),
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.search),
                                            contentPadding: EdgeInsets.fromLTRB(
                                                    16.0, 10.0, 0.0, 10.0)
                                                .r,
                                            // border: OutlineInputBorder(
                                            //     borderSide: BorderSide(
                                            //         color: AppColors
                                            //             .primaryThree, width: 10),),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0).r,
                                              borderSide: BorderSide(
                                                color: AppColors.grey16,
                                                width: 1.0.w,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(1.0).r,
                                              borderSide: BorderSide(
                                                color: AppColors.primaryThree,
                                              ),
                                            ),
                                            hintText:
                                                AppLocalizations.of(context)!
                                                    .mCommonSearch,

                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .headlineSmall!
                                                .copyWith(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                            // focusedBorder: OutlineInputBorder(
                                            //   borderSide: const BorderSide(
                                            //       color: AppColors.primaryThree, width: 1.0),
                                            // ),
                                            counterStyle: TextStyle(
                                              height: double.minPositive.w,
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
                                          Radius.circular(4).r,
                                        ),
                                        // color: AppColors.lightGrey,
                                      ),
                                      // color: AppColors.appBarBackground,
                                      // width: double.infinity,
                                      // margin: EdgeInsets.only(right: 225, top: 2),
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
                                          padding:
                                              const EdgeInsets.only(left: 8).r,
                                          child: Container(
                                              width: 50.w,
                                              alignment: Alignment.center,
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .mCommonSortBy,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                        ),
                                        iconSize: 26.r,
                                        elevation: 16,
                                        style:
                                            TextStyle(color: AppColors.greys87),
                                        underline: Container(
                                          // height: 2,
                                          color: AppColors.lightGrey,
                                        ),
                                        selectedItemBuilder:
                                            (BuildContext context) {
                                          return dropdownItems.map<Widget>(
                                            (String item) {
                                              return Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                                15.0,
                                                                15.0,
                                                                0,
                                                                15.0)
                                                            .r,
                                                    child: Text(
                                                      item,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium,
                                                    ),
                                                  )
                                                ],
                                              );
                                            },
                                          ).toList();
                                        },
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            dropdownValue = newValue;
                                          });
                                          _sortCourses(dropdownValue);
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _listOfCourses.length > 0
                        ? Container(
                            // height: 100,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: _filteredListOfCourses.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8).r,
                                  child: BrowseCard(
                                      course: _filteredListOfCourses[index]),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 80, bottom: 150).r,
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
                                    ),
                              ),
                            ),
                          ),
                  ],
                ),
              );
            } else {
              return PageLoader(
                bottom: 150,
              );
            }
          },
        ),
      ),
      bottomNavigationBar: FutureBuilder(
          future: _checkAlreadyAdded(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0).r,
                child: Container(
                  // height: _activeTabIndex == 0 ? 60 : 0,
                  height: 50.w,
                  child: Column(
                    children: [
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //     primary: AppColors.primaryThree,
                      //     minimumSize: const Size.fromHeight(40), // NEW
                      //   ),
                      //   onPressed: () {},
                      //   child: const Text(
                      //     EnglishLang.competencyAssessment,
                      //     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 4,
                      // ),
                      _isAlreadyAdded &&
                              (_addedCompetency != null &&
                                  _addedCompetency[
                                          'competencySelfAttestedLevel'] !=
                                      null)
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.appBarBackground,
                                minimumSize: const Size.fromHeight(40),
                                side: BorderSide(
                                    width: 1.w, color: AppColors.primaryThree),
                              ),
                              onPressed: () {
                                _confirmDeletion();
                              },
                              child: Text(
                                AppLocalizations.of(context)!
                                    .mStaticRemoveFromYourCompetency,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.primaryThree,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.appBarBackground,
                                minimumSize: const Size.fromHeight(40),
                                side: BorderSide(
                                    width: 1.w, color: AppColors.primaryThree),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SelfAttestCompetency(
                                            currentCompetencySelected: widget
                                                .browseCompetencyCardModel,
                                            profileCompetencies:
                                                _profileCompetencies,
                                            addedStatus: _addedStatus,
                                            levels: _levels,
                                            addedCompetency: _addedCompetency,
                                          )),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!
                                    .mStaticSelfAttestCompetency,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.primaryThree,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
