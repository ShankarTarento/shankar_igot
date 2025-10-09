import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/screen/contents/widgets/microsites_course_filters.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../util/telemetry_repository.dart';
import '../../../my_learnings/no_data_widget.dart';
import 'microsites_course_card.dart';

class MicroSiteAllContents extends StatefulWidget {
  final String? providerName;

  MicroSiteAllContents({this.providerName});

  @override
  _MicroSiteAllContentsState createState() => _MicroSiteAllContentsState();
}

class _MicroSiteAllContentsState extends State<MicroSiteAllContents> {
  List<Course> _listOfCourses = [];
  Future<dynamic>? _courseResponseData;
  List<Course> _filteredListOfCourses = [];
  bool _isLoading = false;

  String? dropdownValue;
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
    _courseResponseData = _getCoursesByProvider();
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByProviderCoursesPageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.browseByProviderCoursesPageUri
            .replaceAll(":providerName", widget.providerName ?? ""),
        env: EnglishLang.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<dynamic> _getCoursesByProvider() async {
    _listOfCourses = await Provider.of<LearnRepository>(context, listen: false)
        .getCoursesByProvider(widget.providerName ?? "", selectedContentTypes);
    setState(() {
      _filteredListOfCourses = _listOfCourses;
      _isLoading = false;
    });
    return _listOfCourses;
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

  Future<void> updateFilters(Map data) async {
    if (selectedContentTypes.contains(data['item'].toLowerCase())) {
      selectedContentTypes.remove(data['item'].toLowerCase());
    } else {
      selectedContentTypes.add(data['item'].toLowerCase());
    }
  }

  Future<void> applyFilters(String filter) async {
    setState(() {
      _isLoading = true;
    });
    _courseResponseData = _getCoursesByProvider();
  }

  Future<void> setDefault(String filter) async {
    setState(() {
      _isLoading = true;
      selectedContentTypes = [];
    });
    _courseResponseData = _getCoursesByProvider();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
          future: _courseResponseData,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            return Scaffold(
              appBar: _appBar(),
              body: ((snapshot.hasData && snapshot.data != null))
                  ? _buildLayout()
                  : PageLoader(bottom: 150),
              bottomNavigationBar: ((snapshot.hasData && snapshot.data != null))
                  ? _bottomNavigationView()
                  : SizedBox.shrink(),
            );
          }),
    );
  }

  PreferredSizeWidget _appBar() {
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

  Widget _buildLayout() {
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
                      (_filteredListOfCourses.length > 0)
                          ? _courseListView()
                          : NoDataWidget(
                              message: AppLocalizations.of(context)!
                                  .mCommonNoContentsFound,
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

  Widget _bottomNavigationView() {
    return Container(
      height: 80.w,
      width: 1.0.w,
      color: AppColors.appBarBackground,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(left: 16).w,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
          padding: EdgeInsets.only(top: 9),
          child: IconButton(
              onPressed: () {
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
              icon: const Icon(
                Icons.filter_list_outlined,
                color: AppColors.greys60,
              )),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              filterButton(
                displayTitle:
                    AppLocalizations.of(context)!.mCommonAllContentType,
                title: AppLocalizations.of(context)!.mStaticSectors,
                count: selectedContentTypes.length.toString(),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ]),
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
