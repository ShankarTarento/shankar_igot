import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/_constants/learn_compatibility_constants.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../feedback/pages/_pages/_cbpSurvey/content_feedback.dart';
import '../../../../../widgets/index.dart';
import '../../../../../widgets/_learn/_contentPlayers/course_youtube_player.dart';
import '../update_message.dart';

class TocContentPlayer extends StatelessWidget {
  final ValueChanged<bool> changeLayout;
  final ValueChanged<Map> showLatestProgress;
  final bool fullScreen, isFeatured, isCuratedProgram;
  final resourceNavigateItems;
  final CourseHierarchyModel courseHierarchyData;
  final String batchId, primaryCategory;
  final List navigationItems;
  final ValueChanged<bool> playNextResource;
  final bool updatePlayerProgress;
  final int? startAt;
  final String courseCategory;
  final bool isPreRequisite;

  TocContentPlayer(
      {Key? key,
      required this.changeLayout,
      this.fullScreen = false,
      required this.resourceNavigateItems,
      required this.courseHierarchyData,
      this.isFeatured = false,
      this.isCuratedProgram = false,
      required this.batchId,
      required this.showLatestProgress,
      required this.primaryCategory,
      required this.navigationItems,
      required this.playNextResource,
      this.startAt,
      required this.courseCategory,
      required this.updatePlayerProgress,
      this.isPreRequisite = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isCompatible()
        ? UpdateMessage()
        : Container(
            height: fullScreen ? 1.sh - 100.w : 250.w,
            width: 1.sw,
            color: const Color.fromARGB(221, 0, 0, 0),
            child: resourceNavigateItems is List
                ? Center()
                : resourceNavigateItems.mimeType == EMimeTypes.pdf
                    ? TocPlayerPdfScreen(
                        player: CoursePdfPlayer(
                            identifier: resourceNavigateItems.identifier,
                            batchId: isCuratedProgram
                                ? resourceNavigateItems.parentBatchId
                                : batchId,
                            parentCourseId: isCuratedProgram
                                ? resourceNavigateItems.parentCourseId
                                : courseHierarchyData.identifier,
                            isFeaturedCourse: isFeatured,
                            updateProgress: showLatestProgress,
                            primaryCategory: primaryCategory,
                            playNextResource: playNextResource,
                            resourceNavigateItems: resourceNavigateItems,
                            isPreRequisite: isPreRequisite,
                            language: resourceNavigateItems.language),
                        resourcename: resourceNavigateItems.name ?? '')
                    : (resourceNavigateItems.mimeType == EMimeTypes.mp4 ||
                            resourceNavigateItems.mimeType == EMimeTypes.m3u8)
                        ? CourseVideoPlayer(
                            startAt: startAt,
                            identifier: resourceNavigateItems.identifier,
                            batchId: isCuratedProgram
                                ? resourceNavigateItems.parentBatchId
                                : batchId,
                            parentCourseId: isCuratedProgram
                                ? resourceNavigateItems.parentCourseId
                                : courseHierarchyData.identifier,
                            parentAction: showLatestProgress,
                            isFeatured: isFeatured,
                            playNextResource: playNextResource,
                            resourceNavigateItems: resourceNavigateItems,
                            isPlayer: true,
                            isPreRequisite: isPreRequisite,
                            language: resourceNavigateItems.language)
                        : resourceNavigateItems.mimeType == EMimeTypes.mp3
                            ? CourseAudioPlayer(
                                identifier: resourceNavigateItems.identifier,
                                updateProgress: true,
                                batchId: isCuratedProgram
                                    ? resourceNavigateItems.parentBatchId
                                    : batchId,
                                parentCourseId: isCuratedProgram
                                    ? resourceNavigateItems.parentCourseId
                                    : courseHierarchyData.identifier,
                                parentAction: showLatestProgress,
                                isFeaturedCourse: isFeatured,
                                playNextResource: playNextResource,
                                resourceNavigateItems: resourceNavigateItems,
                                updatePlayerProgress: updatePlayerProgress,
                                isPreRequisite: isPreRequisite,
                                language: resourceNavigateItems.language)
                            : resourceNavigateItems.mimeType == EMimeTypes.html
                                ? TocPlayerInNewScreen(
                                    player: CourseHtmlPlayer(
                                        courseHierarchyData,
                                        resourceNavigateItems.identifier,
                                        isCuratedProgram
                                            ? resourceNavigateItems
                                                .parentBatchId
                                            : batchId,
                                        changeLayout,
                                        parentAction3: showLatestProgress,
                                        isFeaturedCourse: isFeatured,
                                        parentCourseId: isCuratedProgram
                                            ? resourceNavigateItems
                                                .parentCourseId
                                            : courseHierarchyData.identifier,
                                        resourceNavigateItems:
                                            resourceNavigateItems,
                                        isPreRequisite: isPreRequisite,
                                        language:
                                            resourceNavigateItems.language),
                                    resourcename:
                                        resourceNavigateItems.name ?? '')
                                : resourceNavigateItems.mimeType == EMimeTypes.externalLink ||
                                        resourceNavigateItems.mimeType ==
                                            EMimeTypes.youtubeLink
                                    ? TocPlayerInNewScreen(
                                        player: CourseYoutubePlayer(
                                            contentId: resourceNavigateItems.identifier,
                                            batchId: (isPreRequisite)
                                                ? ''
                                                : isCuratedProgram ? resourceNavigateItems.parentBatchId : batchId,
                                            isFeaturedCourse: isFeatured,
                                            updateContentProgress:
                                                showLatestProgress,
                                            identifier: isCuratedProgram
                                                ? resourceNavigateItems
                                                    .parentCourseId
                                                : courseHierarchyData
                                                    .identifier,
                                            resourceNavigateItems:
                                                resourceNavigateItems,
                                            duration:
                                                courseHierarchyData.duration,
                                            isPreRequisite: isPreRequisite,
                                            language:
                                                resourceNavigateItems.language),
                                        isYoutubeContent: true,
                                        resourcename:
                                            resourceNavigateItems.name ?? '',
                                      )
                                    : resourceNavigateItems.mimeType ==
                                            EMimeTypes.survey
                                        ? (!isFeatured
                                            ? resourceNavigateItems.status == 2 ||
                                                    resourceNavigateItems
                                                            .completionPercentage ==
                                                        100
                                                ? Center(
                                                    child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .mSurveySubmitted,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineSmall!
                                                            .copyWith(
                                                                color: AppColors
                                                                    .appBarBackground)),
                                                  )
                                                : TocPlayerInNewScreen(
                                                    player: ContentFeedback(
                                                      resourceNavigateItems
                                                              .artifactUrl ??
                                                          '',
                                                      resourceNavigateItems
                                                              .name ??
                                                          '',
                                                      courseHierarchyData,
                                                      resourceNavigateItems
                                                          .identifier,
                                                      isCuratedProgram
                                                          ? resourceNavigateItems
                                                                  .parentBatchId ??
                                                              ''
                                                          : batchId,
                                                      updateContentProgress:
                                                          showLatestProgress,
                                                      parentCourseId: isCuratedProgram
                                                          ? resourceNavigateItems
                                                              .parentCourseId
                                                          : courseHierarchyData
                                                              .identifier,
                                                      playNextResource: playNextResource,
                                                      resourceNavigateItems: resourceNavigateItems,
                                                      isFeaturedCourse: isFeatured,
                                                      isPreRequisite: isPreRequisite,
                                                         language:
                                                            resourceNavigateItems
                                                                .language
                                                    ),
                                                    isSurvey: true,
                                                    resourcename:
                                                        resourceNavigateItems
                                                                .name ??
                                                            '',
                                                  )

                                            // Center(
                                            //     child: Text(
                                            //     resourceNavigateItems['status'] == 2
                                            //         ? 'Survey is already submitted'
                                            //         : 'Tap on the survey to start',
                                            //     textAlign: TextAlign.center,
                                            //     style: GoogleFonts.lato(
                                            //         height: 1.5,
                                            //         color: AppColors.greys87,
                                            //         fontSize: 16,
                                            //         fontWeight: FontWeight.w400),
                                            //   ))
                                            : Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                              32, 16, 32, 8)
                                                          .r,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .mDoSignInOrRegisterMessage,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: GoogleFonts.lato(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          height: 1.5.w,
                                                          fontSize: 16.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    // signInOrRegister(),
                                                  ],
                                                ),
                                              ))
                                        : (!isFeatured
                                            ? TocPlayerInNewScreen(
                                                player: CourseAssessmentPlayer(
                                                    courseHierarchyData,
                                                    resourceNavigateItems
                                                        .identifier,
                                                    showLatestProgress,
                                                    isCuratedProgram
                                                        ? resourceNavigateItems
                                                                .parentBatchId ??
                                                            ''
                                                        : batchId,
                                                    parentCourseId: isCuratedProgram
                                                        ? resourceNavigateItems
                                                            .parentCourseId
                                                        : courseHierarchyData.identifier,
                                                    playNextResource: playNextResource,
                                                    compatibilityLevel: resourceNavigateItems is! List ? resourceNavigateItems.compatibilityLevel : 0,
                                                    resourceNavigateItems: resourceNavigateItems,
                                                    isFeatured: isFeatured,
                                                    courseCategory: courseCategory,
                                                    isPreRequisite: isPreRequisite),
                                                resourcename: resourceNavigateItems.name ?? '',
                                                isAssessment: true,
                                                isLocked: resourceNavigateItems.isLocked)
                                            : Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                              32, 16, 32, 8)
                                                          .r,
                                                      child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .mCourseTapOnAssessment,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: GoogleFonts.lato(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColors
                                                              .appBarBackground,
                                                          fontSize: 16.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    // signInOrRegister(),
                                                  ],
                                                ),
                                              )));
  }

  bool isCompatible() {
    return courseHierarchyData.compatibilityLevel >
            ResourceCategoryVersion.contentCompatibility.version ||
        (Widget is! List &&
            resourceNavigateItems.compatibilityLevel != null &&
            (resourceNavigateItems.compatibilityLevel! >
                ResourceCategoryVersion.navigationCompatibility.version));
  }
}
