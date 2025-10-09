import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/common_components/filter_pill/filter_pills.dart';
import 'package:karmayogi_mobile/common_components/my_learning_card/course_complete_card.dart';
import 'package:karmayogi_mobile/common_components/my_learning_card/course_inprogress_card.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_v2.dart/services/my_learning_service.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/pages/course_toc_page.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_progress_skeleton_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class MyLearningContent extends StatefulWidget {
  final int? index;
  const MyLearningContent({super.key, this.index});

  @override
  State<MyLearningContent> createState() => _MyLearningContentState();
}

class _MyLearningContentState extends State<MyLearningContent> {
  List<MultiLingualText> tabItems = [];
  int selectedIndex = 0;
  late Future<List<Course>> enrolledCourses;

  @override
  void initState() {
    selectedIndex = widget.index ?? 0;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    tabItems = [
      MultiLingualText(
          id: WidgetConstants.inProgress,
          enText: AppLocalizations.of(context)!.mStaticInprogress,
          hiText: AppLocalizations.of(context)!.mStaticInprogress),
      MultiLingualText(
          id: WidgetConstants.myLearningCompleted,
          enText: AppLocalizations.of(context)!.mStaticCompleted,
          hiText: AppLocalizations.of(context)!.mStaticCompleted),
    ];
    _getCourses();
    super.didChangeDependencies();
  }

  void _getCourses() {
    enrolledCourses =
        MyLearningService.getEnrolledCourses(type: tabItems[selectedIndex].id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0).r,
          child: _buildTabPills(),
        ),
        FutureBuilder(
          future: enrolledCourses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) =>
                      const CourseProgressSkeletonPage(),
                  itemCount: 5,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                ),
              );
            }
            if (snapshot.data == null) {
              return NoDataWidget(
                  message: AppLocalizations.of(context)!.mNoResourcesFound);
            }
            if (snapshot.data != null) {
              List<Course> courses = snapshot.data!;
              return courses.isNotEmpty
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16).r,
                        child: AnimationLimiter(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: courses.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: InkWell(
                                      onTap: () {
                                        onTapCard(courses[index]);
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 16.0)
                                                .r,
                                        child: getCourseCard(
                                            type: tabItems[selectedIndex].id,
                                            course: courses[index]),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 80.0).r,
                      child: NoDataWidget(
                          message:
                              AppLocalizations.of(context)!.mNoResourcesFound),
                    );
            }

            return SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildTabPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
            tabItems.length,
            (index) => FilterPills(
                  fontSize: 14,
                  isSelected: selectedIndex == index,
                  filterText:
                      Helper.capitalizeFirstLetter(tabItems[index].enText),
                  onClickedFilterText: (filterText) {
                    setState(() {
                      selectedIndex = index;
                      _getCourses();
                    });
                  },
                )),
      ),
    );
  }

  Widget getCourseCard({required String type, required Course course}) {
    switch (type) {
      case WidgetConstants.myLearningCompleted:
        return CourseCompleteCard(course: course);

      case WidgetConstants.inProgress:
        return CourseInprogressCard(course: course);

      default:
        return SizedBox();
    }
  }

  void onTapCard(Course course) {
    HomeTelemetryService.generateInteractTelemetryData(course.raw['courseId'],
        primaryCategory: course.courseCategory,
        subType: TelemetrySubType.myLearning,
        clickId: TelemetryIdentifier.cardContent);
    if (course.raw['content']['status'] == 'Live') {
      Navigator.push(
          context,
          FadeRoute(
              page: CourseTocPage(
                  arguments:
                      CourseTocModel.fromJson({'courseId': course.id}))));
    } else {
      Helper.showSnackBarMessage(
          context: context,
          text:
              "This ${course.raw['content']['primaryCategory']} has been archived and is no longer available.",
          bgColor: AppColors.darkBlue);
    }
  }
}
