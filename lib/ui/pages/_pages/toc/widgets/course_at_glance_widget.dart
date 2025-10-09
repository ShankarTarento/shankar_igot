import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../constants/index.dart';
import '../../../../../models/index.dart';

class CourseAtGlanceWidget extends StatelessWidget {
  CourseAtGlanceWidget(
      {Key? key,
      required this.courseInfo,
      required this.courseHierarchyInfo,
      required this.isExpanded,
      this.itemCount = 0,
      this.duration,
      this.isCourse = true})
      : super(key: key);
  final courseInfo;
  final CourseHierarchyModel? courseHierarchyInfo;
  final bool isExpanded, isCourse;
  final int itemCount;
  final String? duration;

  @override
  Widget build(BuildContext context) {
    int moduleCount = 0;
    return Container(
      padding: EdgeInsets.only(top: 8).r,
      child: Wrap(
        children: [getItemCounts(context, moduleCount)],
      ),
    );
  }

  Widget getItemCounts(BuildContext context, int moduleCount) {
    Map mimeTypesCount = {};
    int moduleItemCount = 0;
    dynamic courseWithId;
    if (courseHierarchyInfo != null && courseHierarchyInfo!.children != null) {
      courseWithId = findCourseUnitWithLeafNode(
          courseHierarchyInfo!.children!, courseInfo.identifier);
      if (courseWithId != null &&
          courseWithId.isNotEmpty &&
          courseWithId is CourseHierarchyModelChild &&
          courseWithId.mimeTypesCount.isNotEmpty) {
        mimeTypesCount = jsonDecode(courseWithId.mimeTypesCount);
      }
    }
    if (isCourse &&
        mimeTypesCount[EMimeTypes.collection] != null &&
        mimeTypesCount[EMimeTypes.collection] > 0) {
      moduleCount = mimeTypesCount[EMimeTypes.collection];
    }
    if (!isCourse && courseWithId != null) {
      moduleItemCount =
          courseWithId.leafNodes != null ? courseWithId.leafNodes!.length : 0;
    }

    return Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SvgPicture.asset(
              height: 16.w,
              width: 16.w,
              isCourse
                  ? 'assets/img/course_icon.svg'
                  : 'assets/img/icons-file-types-module.svg',
              colorFilter: ColorFilter.mode(
                  isExpanded && isCourse
                      ? AppColors.appBarBackground
                      : AppColors.greys60,
                  BlendMode.srcIn)),
          Padding(
            padding: const EdgeInsets.only(left: 8).r,
            child: textWidget(duration != null
                ? duration
                : courseInfo.courseDuration != null
                    ? courseInfo.courseDuration
                    : courseWithId != null
                        ? courseWithId.duration
                        : ''),
          ),
          if (moduleCount > 0 && isCourse) ...[
            textWidget(
                '  \u2022  $moduleCount ${AppLocalizations.of(context)!.mLearnModules}'),
          ],
          if (itemCount > 0) ...[
            isCourse
                ? textWidget(
                    '  \u2022  $itemCount ${AppLocalizations.of(context)!.mStaticItems}')
                : moduleItemCount > 0
                    ? textWidget(
                        '  \u2022  $moduleItemCount ${AppLocalizations.of(context)!.mStaticItems}')
                    : SizedBox.shrink()
          ] else if (courseWithId != null &&
              courseWithId.leafNodesCount != null &&
              courseWithId.leafNodesCount.isNotEmpty &&
              int.parse(courseWithId.leafNodesCount) > 0) ...[
            textWidget(
                '  \u2022  ${int.parse(courseWithId.leafNodesCount)} ${AppLocalizations.of(context)!.mStaticItems}'),
          ],
        ]);
  }

  Text textWidget(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.lato(
          height: 1.33.w,
          letterSpacing: 0.25,
          color: isExpanded && isCourse
              ? AppColors.appBarBackground
              : AppColors.greys60,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400),
    );
  }

  dynamic findCourseUnitWithLeafNode(
      List<dynamic> children, String identifier) {
    for (final child in children) {
      if (child is FluffyChild) {
        return null;
      }
      if ((isCourse || child.contentType == 'CourseUnit') &&
          child.leafNodes != null &&
          child.leafNodes!.contains(identifier)) {
        return child;
      }
      if (child.children != null && child.children!.isNotEmpty) {
        final found = findCourseUnitWithLeafNode(child.children!, identifier);
        if (found != null) return found;
      }
    }
    return null;
  }
}
