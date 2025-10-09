import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../models/index.dart';
import '../../../../util/faderoute.dart';
import '../../../widgets/_signup/contact_us.dart';
import '../../../widgets/index.dart';

class ShowAllCourses extends StatefulWidget {
  final List<Course>? courseList;
  final String title;
  const ShowAllCourses({Key? key, this.courseList, required this.title})
      : super(key: key);

  @override
  _ShowAllCoursesState createState() => _ShowAllCoursesState();
}

class _ShowAllCoursesState extends State<ShowAllCourses> {
  List<Course> courseDisplayList = [];
  bool _showLoader = true;

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> updateCourseList() async {
    try {
      if (widget.courseList!.length >= courseDisplayList.length + 5) {
        courseDisplayList.addAll(widget.courseList!
            .sublist(courseDisplayList.length, courseDisplayList.length + 5));
      } else {
        courseDisplayList.addAll(widget.courseList!.sublist(
            courseDisplayList.length,
            widget
                .courseList!.length)); // If original list has less than 5 items
      }
      _showLoader = false;
      return courseDisplayList;
    } catch (err) {
      return err;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Text('',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontFamily: GoogleFonts.montserrat().fontFamily,
                    )),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadeRoute(page: ContactUs()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8).r,
                child: SvgPicture.asset(
                  'assets/img/help_icon.svg',
                  width: 56.0.w,
                  height: 56.0.w,
                ),
              ),
            ),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (widget.courseList!.length != courseDisplayList.length) {
              setState(() {});
            }
          }
          return true;
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: FutureBuilder(
            future: updateCourseList(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if ((snapshot.hasData &&
                      (snapshot.data != null &&
                          courseDisplayList.length > 0)) &&
                  !_showLoader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8).r,
                      child: TitleBoldWidget(widget.title),
                    ),
                    AnimationLimiter(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: courseDisplayList.length + 1,
                        itemBuilder: (context, index) {
                          if (index < courseDisplayList.length) {
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8).r,
                                    child: BrowseCard(
                                      course: courseDisplayList[index],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else if (courseDisplayList.length !=
                              widget.courseList!.length) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 100).r,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else {
                            return Center();
                          }
                        },
                      ),
                    )
                  ],
                );
              } else if (courseDisplayList.length == 0) {
                return Stack(
                  children: <Widget>[
                    Column(
                      children: [
                        Container(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 125).r,
                              child: SvgPicture.asset(
                                'assets/img/empty_search.svg',
                                alignment: Alignment.center,
                                // color: AppColors.grey16,
                                width: 0.2.sw,
                                height: 0.2.sh,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16).r,
                          child: Text(
                              AppLocalizations.of(context)!
                                  .mStaticNoResultsFound,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    height: 1.5.w,
                                    letterSpacing: 0.25,
                                  )),
                        ),
                        Container(
                          width: 0.75.sw,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20).r,
                            child: Text(
                              AppLocalizations.of(context)!
                                  .mCommonRemoveFilters,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    height: 1.5.w,
                                    letterSpacing: 0.25,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                );
              } else {
                return PageLoader(
                  bottom: 150,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
