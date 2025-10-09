import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../util/telemetry_repository.dart';
import '../../../../mdo_channels/screens/contents_screen/mdo_all_content_screen_skeleton.dart';
import '../../../../my_learnings/no_data_widget.dart';
import '../../../screen/contents/microsites_course_card.dart';
import '../../../screen/contents/widgets/microsites_course_filters.dart';

class MicroSiteShowAllCourses extends StatefulWidget {
  final String? title;
  final String? orgId;
  final String? type;
  final String? selectedCoursePill;

  MicroSiteShowAllCourses(
      {this.title, this.orgId, this.type, this.selectedCoursePill});

  @override
  _MicroSiteShowAllCoursesState createState() =>
      _MicroSiteShowAllCoursesState();
}

class _MicroSiteShowAllCoursesState extends State<MicroSiteShowAllCourses> {
  List<Course> _listOfCourses = [];
  late Future<dynamic> _courseResponseDataFuture;
  List<Course> _filteredListOfCourses = [];
  bool _isLoading = false;

  late String dropdownValue;
  List<String> dropdownItems = [
    EnglishLang.ascentAtoZ,
    EnglishLang.descentZtoA
  ];

  List contentTypes = [
    // EnglishLang.all,
    EnglishLang.course,
    EnglishLang.program,
    EnglishLang.learningResource,
    EnglishLang.standaloneAssessment,
    EnglishLang.moderatedCourse,
    PrimaryCategory.moderatedProgram,
    PrimaryCategory.moderatedAssessment,
    EnglishLang.blendedProgram,
    EnglishLang.curatedPrograms,
  ];

  List<String> selectedContentTypes = [];

  @override
  void initState() {
    super.initState();
    _courseResponseDataFuture = getCoursesData();
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByProviderCoursesPageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.browseByProviderCoursesPageUri
            .replaceAll(":providerName", widget.type ?? ''),
        env: EnglishLang.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<dynamic> getCoursesData() async {
    if (widget.type.toString() == 'featuredContents') {
      await getMicroSiteFeaturedCourses();
    } else {
      await getMicroSiteTopCourses();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _filteredListOfCourses = _listOfCourses;
        _isLoading = false;
      });
    });
    return _listOfCourses;
  }

  Future<void> getMicroSiteTopCourses() async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMicroSiteTopCourses(widget.orgId ?? '', selectedContentTypes,
                widget.selectedCoursePill ?? '', 100);
    _listOfCourses =
        responseData.map<Course>((data) => Course.fromJson(data)).toList();
  }

  Future<void> getMicroSiteFeaturedCourses() async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMicroSiteFeaturedCourses(widget.orgId ?? '',
                selectedContentTypes, widget.selectedCoursePill ?? '');
    _listOfCourses =
        responseData.map<Course>((data) => Course.fromJson(data)).toList();
  }

  void _filterTopicCourses(value) {
    setState(() {
      _filteredListOfCourses = _listOfCourses
          .where((course) => course.name
              .toLowerCase()
              .contains(value.toString().toLowerCase()))
          .toList();
    });
  }

  Future<void> applyFilters(String filter) async {
    setState(() {
      _isLoading = true;
    });
    _courseResponseDataFuture = getCoursesData();
  }

  Future<void> updateFilters(Map data) async {
    if (selectedContentTypes.contains(data['item'].toLowerCase())) {
      selectedContentTypes.remove(data['item'].toLowerCase());
    } else {
      selectedContentTypes.add(data['item'].toLowerCase());
    }
  }

  Future<void> setDefault(String filter) async {
    setState(() {
      _isLoading = true;
      selectedContentTypes = [];
    });
    _courseResponseDataFuture = getCoursesData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
          future: _courseResponseDataFuture,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            return Scaffold(
              appBar: _appBar(),
              body: ((snapshot.hasData && snapshot.data != null))
                  ? _buildLayout(snapshot.data ?? '')
                  : MdoAllContentScreenSkeleton(),
              // bottomNavigationBar: ((snapshot.hasData && snapshot.data != null))
              //     ? _bottomNavigationView()
              //     : SizedBox.shrink(),
            );
          }),
    );
  }

  AppBar _appBar() {
    return AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_sharp,
              size: 20.w, color: AppColors.greys60),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 4).w,
              child: Text(
                widget.title ??
                    AppLocalizations.of(context)!.mStaticAllContents,
                style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    letterSpacing: 0.12.w,
                    height: 1.5.w),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }

  Widget _buildLayout(List<Course> courseList) {
    return SafeArea(
      child: Container(
          margin: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 8).w,
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_listOfCourses.length > 0) _toolBarView(),
                      (_listOfCourses.length > 0)
                          ? _courseListView()
                          : NoDataWidget(
                              message: AppLocalizations.of(context)!
                                  .mCommonNoCourseFound,
                              paddingTop: 125.w),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: Align(
                  alignment: FractionalOffset.center,
                  child: Visibility(
                    visible: _isLoading,
                    child: PageLoader(bottom: 150),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget _toolBarView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).w,
      child: Container(
        width: double.infinity,
        child: Container(
          height: 40.w,
          child: TextFormField(
              onChanged: (value) {
                _filterTopicCourses(value);
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.lato(fontSize: 14.0.sp),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.appBarBackground,
                prefixIcon: Icon(
                  Icons.search,
                  size: 24.w,
                  color: AppColors.greys60,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 8).w,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.w),
                  borderSide: BorderSide(
                    color: AppColors.appBarBackground,
                    width: 1.0.w,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.w),
                  borderSide: BorderSide(color: AppColors.appBarBackground),
                ),
                hintText: AppLocalizations.of(context)!.mCommonSearch,
                hintStyle: GoogleFonts.lato(
                    color: AppColors.greys,
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w400),
                counterStyle: TextStyle(
                  height: double.minPositive,
                ),
                counterText: '',
              )),
        ),
      ),
    );
  }

  Widget _courseListView() {
    return AnimationLimiter(
      child: Container(
        child: Column(children: [
          for (int i = 0; i < _filteredListOfCourses.length; i++)
            AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: MicroSitesCourseCard(
                    course: _filteredListOfCourses[i],
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget filterButton(
      {required String title,
      required String count,
      required String displayTitle}) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            isScrollControlled: true,
            useSafeArea: true,
            isDismissible: true,
            enableDrag: true,
            context: context,
            builder: (BuildContext context) {
              return MicroSitesCourseFilters(
                filterName: EnglishLang.contentType,
                items: contentTypes,
                selectedItems: selectedContentTypes,
                updateFiltersCallback: updateFilters,
                applyFilters: applyFilters,
                setDefaultCallback: setDefault,
              );
            });
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 9, left: 8).w,
            height: 32.w,
            padding: const EdgeInsets.only(left: 10, right: 10).w,
            decoration: BoxDecoration(
              color: AppColors.grey08,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.grey16),
            ),
            child: Center(
              child: Row(
                children: [
                  Text(
                    displayTitle,
                    style: GoogleFonts.lato(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Icon(Icons.arrow_drop_down)
                ],
              ),
            ),
          ),
          count != "0"
              ? Positioned(
                  top: 1,
                  left: 15,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: AppColors.darkBlue,
                    child: Text(
                      count,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.appBarBackground,
                      ),
                    ),
                  ))
              : const SizedBox()
        ],
      ),
    );
  }
}
