import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/microsite_icon_button/microsite_icon_button.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/contents_screen/mdo_all_content_screen.dart';
import 'package:karmayogi_mobile/ui/skeleton/pages/course_card_skeleton_page.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/course_card.dart';
import 'package:karmayogi_mobile/ui/widgets/title_semibold_size16.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../../../../../../models/_models/course_model.dart';
import '../../../../../../../../../../util/telemetry_repository.dart';

class MdoCertificateOfWeek extends StatefulWidget {
  final String? orgId;
  final String? title;
  final List<Course>? certificateOfWeekList;
  final bool showShowAll;
  MdoCertificateOfWeek(
      {Key? key,
      this.certificateOfWeekList,
      this.orgId,
      this.title,
      this.showShowAll = false})
      : super(key: key);

  @override
  _MdoCertificateOfWeekState createState() => _MdoCertificateOfWeekState();
}

class _MdoCertificateOfWeekState extends State<MdoCertificateOfWeek> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.certificateOfWeekList == null
        ? CourseCardSkeletonPage()
        : widget.certificateOfWeekList.runtimeType == String
            ? Center()
            : widget.certificateOfWeekList!.isEmpty
                ? Center()
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16).w,
                        child: Row(
                          children: [
                            TitleSemiboldSize16(
                              widget.title ??
                                  AppLocalizations.of(context)!
                                      .mStaticCertificateOfWeek,
                              fontSize: 16.sp,
                            ),
                            Spacer(),
                            widget.certificateOfWeekList!.length >
                                    SHOW_ALL_DISPLAY_COUNT
                                ? Visibility(
                                    visible: widget.showShowAll,
                                    child: InkWell(
                                        onTap: () {
                                          _generateInteractTelemetryData(
                                              TelemetryIdentifier.showAll,
                                              subType:
                                                  TelemetrySubType.mdoChannel,
                                              primaryCategory:
                                                  TelemetryObjectType
                                                      .certificate);
                                          Navigator.push(
                                            context,
                                            FadeRoute(
                                                page: MdoAllContentScreen(
                                              title: widget.title,
                                              orgId: widget.orgId,
                                              type:
                                                  'sectionCertificationsOfWeeks',
                                            )),
                                          );
                                        },
                                        child: SizedBox(
                                          width: 60.w,
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .mCommonShowAll,
                                            style: GoogleFonts.lato(
                                              color: AppColors.darkBlue,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              letterSpacing: 0.12,
                                            ),
                                          ),
                                        )),
                                  )
                                : Center()
                          ],
                        ),
                      ),
                      Container(
                        height: 310.w,
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 5, bottom: 4).w,
                        child: Stack(
                          children: [
                            courseView(),
                            if (widget.certificateOfWeekList!.length > 1)
                              Positioned(
                                child: Align(
                                  alignment: FractionalOffset.centerLeft,
                                  child: MicroSiteIconButton(
                                    onTap: () {
                                      if (_currentPage > 0) {
                                        _currentPage--;
                                        if (_pageController.hasClients &&
                                            mounted) {
                                          _pageController.animateToPage(
                                            _currentPage,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      } else {
                                        _currentPage = widget
                                                .certificateOfWeekList!.length -
                                            1;
                                        if (_pageController.hasClients &&
                                            mounted) {
                                          _pageController.animateToPage(
                                            _currentPage,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      }
                                    },
                                    backgroundColor: AppColors.black,
                                    icon: Icons.arrow_back_ios_sharp,
                                    iconColor: AppColors.appBarBackground,
                                  ),
                                ),
                              ),
                            if (widget.certificateOfWeekList!.length > 1)
                              Positioned(
                                child: Align(
                                    alignment: FractionalOffset.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: MicroSiteIconButton(
                                        onTap: () {
                                          if (_currentPage <
                                              (widget.certificateOfWeekList!
                                                              .length <
                                                          CERTIFICATE_COUNT
                                                      ? widget
                                                          .certificateOfWeekList!
                                                          .length
                                                      : CERTIFICATE_COUNT) -
                                                  1) {
                                            _currentPage++;
                                            if (_pageController.hasClients &&
                                                mounted) {
                                              _pageController.animateToPage(
                                                _currentPage,
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          } else {
                                            _currentPage = 0;
                                            if (_pageController.hasClients &&
                                                mounted) {
                                              _pageController.animateToPage(
                                                _currentPage,
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          }
                                        },
                                        backgroundColor: AppColors.black,
                                        icon: Icons.arrow_forward_ios_sharp,
                                        iconColor: AppColors.appBarBackground,
                                      ),
                                    )),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      widget.certificateOfWeekList!.isNotEmpty
                          ? SmoothPageIndicator(
                              controller: _pageController,
                              count: widget.certificateOfWeekList!.length < 4
                                  ? widget.certificateOfWeekList!.length
                                  : 4,
                              effect: ExpandingDotsEffect(
                                  activeDotColor: AppColors.orangeTourText,
                                  dotColor: AppColors.profilebgGrey20,
                                  dotHeight: 4,
                                  dotWidth: 4,
                                  spacing: 4),
                            )
                          : Center()
                    ],
                  );
  }

  Widget courseView() {
    return Container(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemCount: widget.certificateOfWeekList!.length < CERTIFICATE_COUNT
            ? widget.certificateOfWeekList!.length
            : CERTIFICATE_COUNT,
        itemBuilder: (context, index) {
          return courseCardWidget(_currentPage);
        },
      ),
    );
  }

  Widget courseCardWidget(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 24.0).r,
      child: InkWell(
          onTap: () async {
            _generateInteractTelemetryData(
                widget.certificateOfWeekList![index].id,
                subType: TelemetrySubType.mdoChannel,
                primaryCategory: TelemetryObjectType.certificate);
            Navigator.pushNamed(context, AppUrl.courseTocPage,
                arguments: CourseTocModel.fromJson(
                    {'courseId': widget.certificateOfWeekList![index].id}));
          },
          child: CourseCard(course: widget.certificateOfWeekList![index])),
    );
  }

  void _generateInteractTelemetryData(String contentId,
      {required String subType,
      String? primaryCategory,
      bool isObjectNull = false}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null
            ? primaryCategory
            : (isObjectNull ? null : subType));
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
