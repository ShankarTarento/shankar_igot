import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../localization/_langs/english_lang.dart';
import '../../../models/_arguments/index.dart';
import '../../../models/_models/course_model.dart';
import '../../../services/_services/landing_page_service.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../util/telemetry_repository.dart';
import '../chatbotbtn.dart';

class FeaturedCoursesPage extends StatefulWidget {
  const FeaturedCoursesPage({Key? key}) : super(key: key);

  @override
  State<FeaturedCoursesPage> createState() => _FeaturedCoursesPageState();
}

class _FeaturedCoursesPageState extends State<FeaturedCoursesPage> {
  final landingPageService = LandingPageService();
  late List<Course> _featuredCourses;

  @override
  void initState() {
    super.initState();
  }

  Future<List<Course>> _getFeaturedCourse() async {
    List<Course> fCourse = await landingPageService.getFeaturedCourses();
    _featuredCourses = fCourse
        .where((course) =>
            course.courseCategory.toLowerCase() ==
            PrimaryCategory.course.toLowerCase())
        .toList();
    return _featuredCourses;
  }

  void _generateInteractTelemetryData(String contentId) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.learnPageId,
        contentId: contentId,
        subType: TelemetrySubType.courseCard,
        env: TelemetryEnv.learn,
        objectType: TelemetrySubType.courseCard,
        isPublic: true);
    await telemetryRepository.insertEvent(eventData: eventData, isPublic: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: FutureBuilder(
              future: _getFeaturedCourse(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                return (snapshot.hasData && snapshot.data != null)
                    ? Stack(
                        children: [
                          Container(
                            color: AppColors.appBarBackground,
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 0).r,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 8.w,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          alignment: Alignment.centerLeft,
                                          padding: EdgeInsets.all(0).r,
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          icon: Icon(Icons.arrow_back)),
                                      Text(
                                          AppLocalizations.of(context)!
                                              .mStaticShowcasedCourses,
                                          style: GoogleFonts.montserrat(
                                              fontSize: 18.0.sp,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.w,
                                  ),
                                  AnimationLimiter(
                                    child: ListView.builder(
                                      padding: EdgeInsets.only(bottom: 80).r,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      scrollDirection:
                                          MediaQuery.of(context).orientation ==
                                                  Orientation.portrait
                                              ? Axis.vertical
                                              : Axis.horizontal,
                                      itemCount: _featuredCourses.length,
                                      itemBuilder: (context, index) {
                                        return AnimationConfiguration
                                            .staggeredList(
                                          position: index,
                                          duration:
                                              const Duration(milliseconds: 375),
                                          child: SlideAnimation(
                                            verticalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: InkWell(
                                                  onTap: () {
                                                    _generateInteractTelemetryData(
                                                        _featuredCourses[index]
                                                            .id);
                                                    Navigator.pushNamed(context,
                                                        AppUrl.courseTocPage,
                                                        arguments: CourseTocModel(
                                                            courseId:
                                                                _featuredCourses[
                                                                        index]
                                                                    .id,
                                                            isFeaturedCourse:
                                                                true));
                                                  },
                                                  child: Container(
                                                    child: CourseCard(
                                                      course: _featuredCourses[
                                                          index],
                                                      isVertical: MediaQuery.of(
                                                                      context)
                                                                  .orientation ==
                                                              Orientation
                                                                  .portrait
                                                          ? true
                                                          : false,
                                                      isFeatured: true,
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : PageLoader(
                        bottom: 150,
                      );
              }),
        ),
        bottomSheet: SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? 0.07.sh
                : (MediaQuery.of(context).size.shortestSide * 0.1).w,
            color: AppColors.primaryBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: 0.43.sw,
                    padding: EdgeInsets.only(left: 16).r,
                    child: TextButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AppUrl.selfRegister),
                        child: Text(
                          AppLocalizations.of(context)!.mLearnRegister,
                          // 'Register',
                          style: GoogleFonts.montserrat(
                              color: AppColors.appBarBackground,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.375.w,
                              letterSpacing: 0.125),
                        ))),
                Padding(
                  padding: const EdgeInsets.all(16).r,
                  child: Opacity(
                    opacity: 0.75,
                    child: VerticalDivider(
                      color: AppColors.appBarBackground,
                      width: 10.w,
                    ),
                  ),
                ),
                Container(
                    width: 0.35.sw,
                    padding: EdgeInsets.only(right: 16).r,
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppUrl.loginPage);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.mBtnSignIn,
                          style: GoogleFonts.montserrat(
                              color: AppColors.appBarBackground,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.375.w,
                              letterSpacing: 0.125),
                        )))
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Chatbotbtn(
          loggedInStatus: EnglishLang.loggedIn,
        ));
  }
}
