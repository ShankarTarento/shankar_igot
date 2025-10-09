import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../models/_models/telemetry_data_model.dart';
import '../../pages/index.dart';
import '../index.dart';

class CourseCardWidget extends StatelessWidget {
  final List courseList;
  final String category;
  final String? subType;
  final String? clickID;
  final bool showAll;
  final Function(TelemetryDataModel)? onCallback;

  const CourseCardWidget(
      {super.key,
      required this.courseList,
      required this.category,
      this.onCallback,
      this.subType,
      this.clickID,
      this.showAll = false});
  @override
  Widget build(BuildContext context) {
    String message;
    message = getMessage(context);
    return courseList.length > 0
        ? Padding(
            padding: EdgeInsets.only(right: showAll ? 16 : 0).r,
            child: ListView.builder(
                scrollDirection: showAll ? Axis.vertical : Axis.horizontal,
                shrinkWrap: true,
                itemCount: courseList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      key: Key('courseCard${courseList[index].id}'),
                      onTap: () async {
                        if (onCallback != null) {
                          onCallback!(TelemetryDataModel(
                              id: courseList[index].id,
                              contentType: courseList[index].courseCategory,
                              subType: subType,
                              clickId: clickID));
                        }
                      },
                      child: showAll
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8).r,
                              child: BrowseCard(course: courseList[index]),
                            )
                          : CourseCard(course: courseList[index]));
                }),
          )
        : NoDataWidget(message: message);
  }

  String getMessage(BuildContext context) {
    if (category == AppLocalizations.of(context)!.mCourseAvailable) {
      return AppLocalizations.of(context)!.mCourseAvailableMessage;
    } else if (category == AppLocalizations.of(context)!.mCommoninProgress) {
      return AppLocalizations.of(context)!.mCourseInprogressMessage;
    } else if (category == AppLocalizations.of(context)!.mStaticUpcoming) {
      return AppLocalizations.of(context)!.mStaticSeeAllUpcoming;
    } else if (category == AppLocalizations.of(context)!.mCommoncompleted) {
      return AppLocalizations.of(context)!.mStaticSeeCompletedContent;
    } else {
      return AppLocalizations.of(context)!
          .mStaticSeeContentForWhichDueDatePassed;
    }
  }
}