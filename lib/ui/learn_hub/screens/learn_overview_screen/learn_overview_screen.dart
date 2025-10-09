import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/common_components/content_strips/course_strip_widget/course_strip_widget.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/learn_hub/constants/learn_hub_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LearnOverviewScreen extends StatefulWidget {
  final Function()? scrollToTop;
  final Function()? switchIntoYourLearningTab;
  const LearnOverviewScreen(
      {super.key, this.scrollToTop, this.switchIntoYourLearningTab});

  @override
  State<LearnOverviewScreen> createState() => _LearnOverviewScreenState();
}

class _LearnOverviewScreenState extends State<LearnOverviewScreen> {
  List<Widget> learnHubWidgets = [];
  @override
  void initState() {
    getLearnHubWidgets();
    super.initState();
  }

  void getLearnHubWidgets() {
    Map learnHubConfig = LearnHubConfig().getLearnHubConfig();
    List<Map> data = learnHubConfig['data'];
    for (var item in data) {
      if (item['type'] == WidgetConstants.courseStrip && item['enabled']) {
        learnHubWidgets.add(buildCourseStripWidget(item, item['type']));
      } else if (item['type'] == WidgetConstants.featuredCourseStrip &&
          item['enabled']) {
        learnHubWidgets.add(buildCourseStripWidget(item, item['type']));
      } else if (item['type'] == WidgetConstants.enrollmentCourseStrip &&
          item['enabled']) {
        learnHubWidgets.add(buildCourseStripWidget(item, item['type']));
      }
    }
  }

  Widget buildCourseStripWidget(dynamic e, String type) {
    try {
      return Container(
        child: CourseStripWidget(
          courseStripData: ContentStripModel.fromMap(e),
          type: type,
          onTapShowAll: type == WidgetConstants.enrollmentCourseStrip
              ? widget.switchIntoYourLearningTab
              : null,
        ),
      );
    } catch (e) {
      debugPrint('Error in CourseStripWidget: $e');
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 200).r,
        child: Column(
          children: [
            ...learnHubWidgets,
            GestureDetector(
              onTap: widget.scrollToTop,
              child: Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 32).r,
                child: Column(
                  children: [
                    Container(
                      height: 48.w,
                      width: 48.w,
                      margin: EdgeInsets.only(bottom: 8).r,
                      decoration: BoxDecoration(
                        color: AppColors.appBarBackground,
                        borderRadius:
                            BorderRadius.all(const Radius.circular(50).r),
                      ),
                      child: Center(
                          child: Icon(
                        Icons.arrow_upward,
                        color: AppColors.greys60,
                        size: 24.sp,
                      )),
                    ),
                    Text(
                      AppLocalizations.of(context)!.mStaticBackToTop,
                      style: GoogleFonts.lato(
                        color: AppColors.greys60,
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        letterSpacing: 0.12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
