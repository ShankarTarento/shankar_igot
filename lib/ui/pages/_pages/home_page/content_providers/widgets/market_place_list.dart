import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/common_components/show_all_card/show_all_card.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/show_all_courses.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import '../../../../../../models/_arguments/course_toc_model.dart';

class MarketPlaceList extends StatelessWidget {
  final Future<List<Course>> externalCourses;

  const MarketPlaceList({Key? key, required this.externalCourses})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Course>>(
      future: externalCourses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0).r,
            child: CourseCardSkeletonPage(),
          );
        }

        if (snapshot.data == null || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 300.w,
            child: Center(
              child: AnimationConfiguration.staggeredList(
                position: 0,
                duration: const Duration(milliseconds: 800),
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.all(16).r,
                    child: NoDataWidget(
                      message: AppLocalizations.of(context)!.mNoResourcesFound,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Container(
          height: 310.w,
          width: double.infinity,
          margin: const EdgeInsets.only(left: 0, top: 5, bottom: 15).w,
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length + 1,
              itemBuilder: (context, index) {
                if (index == snapshot.data!.length) {
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          FadeRoute(
                            page: ShowAllCourses(
                              courseList: snapshot.data ?? [],
                              title: AppLocalizations.of(context)!
                                  .mStaticProviders,
                            ),
                          ),
                        );
                      },
                      child: ShowAllCard());
                }

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: InkWell(
                        onTap: () async {
                          HomeTelemetryService.generateInteractTelemetryData(
                            snapshot.data![index].contentId,
                            primaryCategory:
                                TelemetryIdentifier.externalContent,
                            clickId: TelemetryIdentifier.cardContent,
                            subType: TelemetrySubType.providers,
                          );
                          Navigator.pushNamed(
                            context,
                            AppUrl.externalCourseTocPage,
                            arguments: CourseTocModel(
                              courseId: snapshot.data![index].contentId,
                              externalId: snapshot.data![index].externalId,
                              contentType: snapshot.data?[index].courseCategory,
                            ),
                          );
                        },
                        child: CourseCard(course: snapshot.data![index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
