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
import '../../../../../../util/telemetry_repository.dart';
import '../../../microsites/screen/contents/microsites_course_card.dart';
import '../../../my_learnings/no_data_widget.dart';
import 'mdo_all_content_screen_skeleton.dart';

class MdoAllContentScreen extends StatefulWidget {
  final String? title;
  final String? orgId;
  final String? type;
  final String? selectedCoursePill;

  MdoAllContentScreen(
      {this.title, this.orgId, this.type, this.selectedCoursePill});

  @override
  _MdoAllContentScreenState createState() => _MdoAllContentScreenState();
}

class _MdoAllContentScreenState extends State<MdoAllContentScreen> {
  List<Course> _listOfCourses = [];
  late Future<dynamic> _courseResponseDataFuture;
  List<Course> _filteredListOfCourses = [];
  bool _isLoading = false;

  late String dropdownValue;
  List<String> dropdownItems = [
    EnglishLang.ascentAtoZ,
    EnglishLang.descentZtoA
  ];

  @override
  void initState() {
    super.initState();
    _courseResponseDataFuture = getMdoCoursesData();
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

  Future<dynamic> getMdoCoursesData() async {
    if (widget.type.toString() == 'sectionCertificationsOfWeeks') {
      var responseData =
          await Provider.of<LearnRepository>(context, listen: false)
              .getMdoCertificateOfWeek(widget.orgId ?? '');
      _listOfCourses =
          responseData.map<Course>((data) => Course.fromJson(data)).toList();
    } else {
      var responseData =
          await Provider.of<LearnRepository>(context, listen: false)
              .getMdoCoursesData(widget.orgId ?? '', widget.type ?? '',
                  widget.selectedCoursePill ?? '');
      _listOfCourses =
          responseData.map<Course>((data) => Course.fromJson(data)).toList();
    }
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

  Future<void> applyFilters(String filter) async {
    setState(() {
      _isLoading = true;
    });
    _courseResponseDataFuture = getMdoCoursesData();
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
              size: 20.sp, color: AppColors.greys60),
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
                      (_filteredListOfCourses.length > 0)
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
                  size: 24.sp,
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
}
