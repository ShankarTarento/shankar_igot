import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' show Client;

import '../../constants/index.dart';
import '../../localization/index.dart';
import '../../models/index.dart';
import '../pages/_pages/toc/widgets/language_count_widget.dart';
import '_common/rating_widget.dart';
import '_home/course_card_banner.dart';
import '_home/course_card_description_widget.dart';
import 'index.dart';

class IgotAICourseCardView extends StatefulWidget {
  final Course course;
  final VoidCallback onTap;
  final VoidCallback onReleventBtnPressed;
  final VoidCallback onNonReleventBtnPressed;
  final Client? client;

  const IgotAICourseCardView(
      {super.key,
      required this.course,
      required this.onTap,
      required this.onReleventBtnPressed,
      required this.onNonReleventBtnPressed,
      Client? client})
      : client = client;

  @override
  State<IgotAICourseCardView> createState() => _IgotAICourseCardViewState();
}

class _IgotAICourseCardViewState extends State<IgotAICourseCardView>
    with SingleTickerProviderStateMixin {
  late AnimationController relevantController;
  late Animation<double> relevantAnimation;

  @override
  void initState() {
    super.initState();
    relevantController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    relevantAnimation =
        Tween<double>(begin: COURSE_CARD_WIDTH, end: 0.0).animate(
      CurvedAnimation(parent: relevantController, curve: Curves.easeInOut),
    );
    relevantController.forward();
  }

  @override
  void dispose() {
    relevantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.course.isRelevant != null && !(widget.course.isRelevant!)
        ? Center()
        : InkWell(
            onTap: () => widget.onTap(),
            child: Container(
              width: COURSE_CARD_WIDTH.w,
              margin: EdgeInsets.only(left: 16, top: 16).r,
              decoration: BoxDecoration(
                color: AppColors.appBarBackground,
                border: Border.all(color: AppColors.grey08),
                borderRadius: BorderRadius.circular(12).r,
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Image
                      CourseCardBanner(
                          appIcon: widget.course.appIcon,
                          redirectUrl: widget.course.redirectUrl,
                          creatorIcon: widget.course.creatorIcon,
                          duration: widget.course.duration,
                          isFeatured: false,
                          isExternalCourse: widget.course.isExternalCourse,
                          isBlendedProgram:
                              (widget.course.courseCategory).toLowerCase() ==
                                  (EnglishLang.blendedProgram).toLowerCase(),
                          isCourseCompleted:
                              widget.course.completionPercentage ==
                                  COURSE_COMPLETION_PERCENTAGE,
                          programDuration: widget.course.programDuration,
                          endDate: widget.course.endDate,
                          pointToProd: true,
                      ),
                      //Primary type
                      widget.course.isExternalCourse
                          ? SizedBox()
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8).r,
                              child: PrimaryCategoryWidget(
                                  contentType: widget.course.courseCategory),
                            ),
                      CourseCardDescriptionWidget(
                          course: widget.course, isFeatured: false),
                      widget.course.languageMap.languages.isNotEmpty
                          ? LanguageCountWidget(
                              languages: widget.course.languageMap.languages,
                              padding:
                                  EdgeInsets.only(left: 16, top: 6, bottom: 6)
                                      .r)
                          : Center(),
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 5, bottom: 4).r,
                        child: RatingWidget(
                          rating: widget.course.rating.toString(),
                          additionalTags: widget.course.additionalTags,
                        ),
                      ),
                      Flexible(
                          child: widget.course.isRelevant == null
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 16, 16),
                                  child: RelevanceChoiceButtons(
                                      onReleventBtnPressed: () {
                                        widget.onReleventBtnPressed();
                                        setState(() {
                                          widget.course.isRelevant = true;
                                        });
                                      },
                                      onNonReleventBtnPressed:
                                          widget.onNonReleventBtnPressed),
                                )
                              : widget.course.isRelevant!
                                  ? AnimatedBuilder(
                                      animation: relevantController,
                                      builder: (context, child) {
                                        return ClipRect(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 16, 16),
                                            child: Transform.translate(
                                              offset: Offset(
                                                  -relevantAnimation.value, 0),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16)
                                                                .r,
                                                        child:
                                                            SvgPicture.network(
                                                          ApiUrl.baseUrl +
                                                              '/assets/images/sakshamAI/ai-icon-success.svg',
                                                          httpClient:
                                                              widget.client,
                                                          placeholderBuilder:
                                                              (context) =>
                                                                  Container(),
                                                          height: 20.sp,
                                                          width: 20.sp,
                                                        )),
                                                    Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .mCommonRelevant,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayLarge!
                                                          .copyWith(
                                                              color: AppColors
                                                                  .positiveLight),
                                                    )
                                                  ]),
                                            ),
                                          ),
                                        );
                                      })
                                  : Center())
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
