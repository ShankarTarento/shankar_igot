import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' show Client;

import '../../../../../constants/index.dart';
import '../../../../../models/_arguments/index.dart';
import '../../../../../models/index.dart';
import '../../../../../util/index.dart';
import '../../../../skeleton/index.dart';
import '../../../../widgets/index.dart';

class IgotAI extends StatefulWidget {
  final IgotAIRepository igotAIRepository;
  final LearnRepository learnRepository;
  final bool showAll;
  final ValueNotifier<bool> shareFeedbackCardVisibility;
  final Client? client;

  IgotAI(
      {super.key,
      IgotAIRepository? igotAIRepository,
      LearnRepository? learnRepository,
      this.showAll = false,
      required this.shareFeedbackCardVisibility,
      Client? client})
      : igotAIRepository = igotAIRepository ?? IgotAIRepository(),
        learnRepository = learnRepository ?? LearnRepository(),
        client = client;

  @override
  State<IgotAI> createState() => IgotAIState();
}

class IgotAIState extends State<IgotAI> {
  late IgotAIRepository igotAIRepository;
  late LearnRepository learnRepository;
  late String recommendationId;
  Future<List<Course>>? recommendedCourseList;
  late ValueNotifier<bool> shareFeedbackCardVisibility;
  ValueNotifier<bool> isNonRelevantFeedbackVisible = ValueNotifier(false);
  late Course selectedCourse;
  @override
  void initState() {
    super.initState();
    igotAIRepository = widget.igotAIRepository;
    learnRepository = widget.learnRepository;
    shareFeedbackCardVisibility = widget.shareFeedbackCardVisibility;
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: recommendedCourseList,
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.none ||
              snapShot.connectionState == ConnectionState.waiting) {
            return AiCourseLoaderWidget();
          }
          if (snapShot.hasData) {
            List<Course> courseList = snapShot.data ?? [];
            if (courseList.isNotEmpty) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Flexible(
                        child: Container(
                          height: 358.w,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: courseList.length,
                              itemBuilder: (contxt, index) {
                                return IgotAICourseCardView(
                                    course: courseList[index],
                                    onTap: () async {
                                      await doActionOnCard(
                                          TelemetryDataModel(
                                              id: courseList[index].id,
                                              contentType: courseList[index]
                                                  .courseCategory),
                                          courseId: courseList[index].id,
                                          isFeedbackPending:
                                              courseList[index].isRelevant ==
                                                  null);
                                      fetchData();
                                    },
                                    onReleventBtnPressed: () async {
                                      String response =
                                          await igotAIRepository.saveFeedback(
                                              courseId: courseList[index].id,
                                              recommendationId:
                                                  recommendationId,
                                              feedback: EnglishLang.good,
                                              rating: 1);
                                      if (response == EnglishLang.success) {
                                        Helper.showSnackbarWithCloseIcon(
                                            contxt,
                                            AppLocalizations.of(context)!
                                                .mIgotAIThanksForFeedback);
                                      }
                                    },
                                    onNonReleventBtnPressed: () async {
                                      selectedCourse = courseList[index];
                                      isNonRelevantFeedbackVisible.value = true;
                                    });
                              }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16).r,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16).r,
                              child: SvgPicture.network(
                                ApiUrl.baseUrl +
                                    '/assets/images/sakshamAI/ai-icon.svg',
                                httpClient: widget.client,
                                placeholderBuilder: (context) => Container(),
                                height: 20.sp,
                                width: 20.sp,
                              ),
                            ),
                            Text(
                                AppLocalizations.of(context)!
                                    .mIgotAIGeneratedRecommendation,
                                style: Theme.of(context).textTheme.labelMedium)
                          ],
                        ),
                      )
                    ],
                  ),
                  ValueListenableBuilder<bool>(
                      valueListenable: shareFeedbackCardVisibility,
                      builder: (context, value, _) {
                        return IgotAIOverlayCard(
                            isVisible: value,
                            updateVisiblity: () =>
                                shareFeedbackCardVisibility.value = false);
                      }),
                  ValueListenableBuilder<bool>(
                      valueListenable: isNonRelevantFeedbackVisible,
                      builder: (context, value, _) {
                        return FeedbackOverlayCard(
                            isVisible: value,
                            color: AppColors.greys87.withValues(alpha: 0.8),
                            submitPressed: (feedback) async {
                              await igotAIRepository.saveFeedback(
                                  courseId: selectedCourse.id,
                                  recommendationId: recommendationId,
                                  feedback: feedback,
                                  rating: 0);
                              ;
                              setState(() {
                                selectedCourse.isRelevant = false;
                              });
                              isNonRelevantFeedbackVisible.value = false;
                            },
                            cancelPressed: () {
                              isNonRelevantFeedbackVisible.value = false;
                            });
                      })
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 16),
                child: CourseCardSkeletonPage(),
              );
            }
          }
          return Center();
        });
  }

  Future<void> fetchData() async {
    // Get recommendation id
    recommendationId = await igotAIRepository.generateRecommendation();
    if (recommendationId.isNotEmpty) {
      // Get recommended course doId based on user feedback
      Map<String, dynamic> coursedoIdMap = await igotAIRepository
          .getAIRecommentationWithFeedbackDoId(id: recommendationId);

      // Remove non relevat doId's
      if (coursedoIdMap['nonRelevantDoIdList'].isNotEmpty) {
        (coursedoIdMap['doIdList'] as List<String>).removeWhere((doId) =>
            (coursedoIdMap['nonRelevantDoIdList'] as List<String>)
                .contains(doId));
      }

      if (coursedoIdMap['doIdList'].isNotEmpty) {
        // get courses based on doId from composite search
        recommendedCourseList = Future.value(await learnRepository
            .getRecommendationWithDoId(coursedoIdMap['doIdList'],
                relevantDoId: coursedoIdMap['relevantDoIdList'],
                pointToProd: true));
        if (mounted) {
          Future.delayed(Duration.zero, () {
            setState(() {});
          });
        }
      }
    }
  }

  Future<void> doActionOnCard(TelemetryDataModel value,
      {required String courseId, bool isFeedbackPending = false}) async {
    await _generateInteractTelemetryData(value.id,
        primaryCategory: value.contentType);
    await Navigator.pushNamed(context, AppUrl.courseTocPage,
        arguments: CourseTocModel.fromJson({
          'courseId': courseId,
          'isFeedbackPending': isFeedbackPending,
          'pointToProd': true,
          'recommendationId': recommendationId
        }));
  }

  Future<void> _generateInteractTelemetryData(String contentId,
      {String? primaryCategory, String? objectType}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.appHomePagePageId,
        contentId: contentId,
        subType: TelemetrySubType.igotAI,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null ? primaryCategory : objectType,
        clickId: TelemetryClickId.cardContent);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
