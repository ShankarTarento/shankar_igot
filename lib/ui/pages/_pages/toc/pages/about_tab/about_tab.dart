import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/utils/fade_route.dart';
import 'package:karmayogi_mobile/constants/index.dart';

import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/details_screen/widgets/sector_subsector_view.dart';
import 'package:karmayogi_mobile/ui/widgets/_tips_for_learning/repository/tips_repository.dart';
import 'package:provider/provider.dart';
import '../../../../../widgets/index.dart';
import '../../../../index.dart';
import 'widgets/countdown.dart';

class AboutTab extends StatefulWidget {
  final Course courseRead;
  final Course? enrolledCourse;
  final CourseHierarchyModel courseHierarchy;
  final bool isBlendedProgram;
  final bool highlightRating;
  final bool showCertificate;
  final bool isFeaturedCourse;
  final Widget? aiTutorStrip;

  AboutTab(
      {Key? key,
      required this.courseRead,
      required this.isBlendedProgram,
      this.enrolledCourse,
      this.aiTutorStrip,
      required this.courseHierarchy,
      this.highlightRating = false,
      this.isFeaturedCourse = false,
      this.showCertificate = false})
      : super(key: key);

  final dataKey = new GlobalKey();
  @override
  State<AboutTab> createState() => _AboutTabState();
}

class _AboutTabState extends State<AboutTab>
    with AutomaticKeepAliveClientMixin {
  ValueNotifier<bool> showKarmaPointClaimButton = ValueNotifier(false);
  ValueNotifier<bool> showKarmaPointCongratsMessageCard = ValueNotifier(true);
  late Future<String> cbpFuture;
  @override
  void initState() {
    cbpFuture = getCBPEnddate();
    super.initState();
  }

  List<CompetencyPassbook> getCompetencies() {
    List<CompetencyPassbook> competencies = [];
    if (widget.courseRead.competenciesV5 != null) {
      competencies = widget.courseRead.competenciesV5!;
    }
    return competencies;
  }

  Future<String> getCBPEnddate() async {
    if (widget.isFeaturedCourse) return "";
    cbpList = await LearnRepository().getCbplan();
    if(cbpList == null) return '';
    if (cbpList?.content == null) return '';

    for (final cbpCourse in cbpList!.content!) {
      final contentList = cbpCourse.contentList;
      if (contentList == null) continue;

      for (final item in contentList) {
        if (item.id == widget.courseRead.id) {
          return cbpCourse.endDate ?? '';
        }
      }
    }

    return '';
  }

  CbPlanModel? cbpList;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.highlightRating) {
      Future.delayed(Duration.zero, () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Scrollable.ensureVisible(widget.dataKey.currentContext!,
              curve: Curves.easeInOutBack);
        });
      });
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.aiTutorStrip ?? SizedBox(),
          if (widget.courseRead.courseCategory != PrimaryCategory.caseStudy)
            (widget.enrolledCourse != null &&
                        widget.enrolledCourse!.completionPercentage ==
                            COURSE_COMPLETION_PERCENTAGE) ||
                    widget.showCertificate
                ? CourseCompleteCertificate(
                    courseInfo: widget.enrolledCourse != null
                        ? widget.enrolledCourse!
                        : widget.courseRead,
                    competencies: getCompetencies(),
                    isCertificateProvided: widget.enrolledCourse != null &&
                        (widget.enrolledCourse!.issuedCertificates.isNotEmpty))
                : SizedBox(),
          widget.isBlendedProgram
              ? Consumer<TocServices>(
                  builder: (context, tocServices, _) {
                    return tocServices.batch != null
                        ? Column(
                            children: [
                              BlendedProgramLocation(
                                selectedBatch: tocServices.batch!,
                              ),
                              BlendedProgramDetails(
                                batch: tocServices.batch!,
                              ),
                              Countdown(
                                batch: tocServices.batch!,
                              ),
                            ],
                          )
                        : SizedBox();
                  },
                )
              : SizedBox(),
          //  widget.isBlendedProgram ?  : SizedBox(),

          ValueListenableBuilder(
              valueListenable: showKarmaPointClaimButton,
              builder: (BuildContext context, bool value, Widget? child) {
                return value
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16).r,
                        child: ClaimKarmaPoints(
                          courseId: widget.courseRead.id,
                          claimedKarmaPoint: (bool value) {
                            showKarmaPointCongratsMessageCard.value = true;
                            showKarmaPointClaimButton.value = false;
                          },
                        ),
                      )
                    : Center();
              }),
          SizedBox(
            height: 10.w,
          ),
          FutureBuilder<String>(
              future: cbpFuture,
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.all(16.0).r,
                  child: OverviewIcons(
                    duration: widget.courseRead.duration,
                    course: widget.courseHierarchy,
                    cbpDate: snapshot.data ?? '',
                    courseDetails: widget.courseRead,
                  ),
                );
              }),
          Padding(
            padding: const EdgeInsets.all(16.0).r,
            child: SummaryWidget(
              details: widget.courseRead.description,
              title: AppLocalizations.of(context)!.mStaticSummary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0).r,
            child: DescriptionWidget(
              course: widget.courseRead,
              details: widget.courseRead.instructions,
              title: AppLocalizations.of(context)!.mStaticDescription,
            ),
          ),
          widget.courseRead.competenciesV5 != null
              ? Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, top: 16, bottom: 16).r,
                  child: Competency(
                    competencies: getCompetencies(),
                    courseId: widget.courseRead.id,
                  ),
                )
              : SizedBox(),
          widget.courseHierarchy.keywords.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0).r,
                  child: Tags(
                    keywords: widget.courseHierarchy.keywords,
                    title: AppLocalizations.of(context)!.mStaticTags,
                  ),
                )
              : SizedBox(),
          widget.courseRead.sectorDetails.isNotEmpty
              ? SectorSubsectorView(
                  sectorDetails: widget.courseRead.sectorDetails)
              : SizedBox(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16, bottom: 16).r,
            child: ValueListenableBuilder(
                valueListenable: showKarmaPointCongratsMessageCard,
                builder: (BuildContext context, bool value, Widget? child) {
                  return MessageCards(
                      course: widget.courseRead,
                      showCourseCongratsMessage:
                          showKarmaPointCongratsMessageCard.value,
                      showKarmaPointClaimButton: (bool value) {
                        showKarmaPointClaimButton.value = value;
                        showKarmaPointCongratsMessageCard.value = false;
                      },
                      isEnrolled: widget.enrolledCourse != null);
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0).r,
            child: AuthorsCurators(
              curators: widget.courseHierarchy.curators,
              authors: widget.courseHierarchy.authors,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 8,
            ),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.mTipsForLearners,
                  style: GoogleFonts.montserrat(
                      fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                Spacer(),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        FadeRoute(
                          page: ViewAllTips(
                            tips: TipsRepository.getTips(),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.mCommonReadMore,
                          style: GoogleFonts.lato(
                              fontSize: 14.sp,
                              color: AppColors.darkBlue,
                              fontWeight: FontWeight.w400),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.darkBlue,
                          size: 20,
                        )
                      ],
                    ))
              ],
            ),
          ),
          TipsDisplayCard(
            tips: TipsRepository.getTips(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0).r,
            child: CourseProvider(
              courseDetails: widget.courseRead,
            ),
          ),

          Consumer<LearnRepository>(
            builder: (context, toc, child) {
              return toc.overallRating != null
                  ? Container(
                      color: AppColors.darkBlue.withValues(alpha: 0.18),
                      child: Column(
                        children: [
                          Ratings(
                            ratingAndReview: toc.overallRating!,
                          ),
                          SizedBox(
                            height: 16.w,
                          ),
                          Reviews(
                            reviewAndRating: toc.overallRating!,
                            course: widget.courseRead,
                          ),
                        ],
                      ),
                    )
                  : SizedBox();
            },
          ),
          SizedBox(
            key: widget.dataKey,
            height: 280.w,
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
