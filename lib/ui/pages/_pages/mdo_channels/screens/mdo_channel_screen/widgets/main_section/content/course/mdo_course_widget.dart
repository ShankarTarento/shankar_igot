import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/microsite_icon_button/microsite_icon_button.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/contents_screen/mdo_all_content_screen.dart';
import '../../../../../../../../../../constants/index.dart';
import '../../../../../../../../../../models/_arguments/index.dart';
import '../../../../../../../../../../models/index.dart';
import '../../../../../../../../../../util/faderoute.dart';
import '../../../../../../../../../../util/telemetry_repository.dart';
import '../../../../../../../../../widgets/_home/course_card.dart';
import '../../../../../../../../../widgets/title_semibold_size16.dart';

class MdoCourseWidget extends StatefulWidget {
  final List<Course> trendingList;
  final bool showHeader;
  final String title;
  final String? orgId;
  final String? type;
  final bool showShowAll;
  final String telemetrySubType;
  final double titleFontSize;
  final double viewAllFontSize;

  MdoCourseWidget({
    Key? key,
    required this.trendingList,
    this.showHeader = false,
    required this.title,
    this.orgId,
    this.type,
    this.showShowAll = true,
    required this.telemetrySubType,
    this.titleFontSize = 16,
    this.viewAllFontSize = 14,
  }) : super(key: key);

  @override
  _MdoCourseWidgetState createState() {
    return _MdoCourseWidgetState();
  }
}

class _MdoCourseWidgetState extends State<MdoCourseWidget> {
  String courseId = '';
  String batchId = '';
  String sessionId = '';

  int _currentPage = 0;
  final ScrollController _courseScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _courseScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _courseScrollController.dispose();
  }

  void _onScroll() {
    int page =
        (_courseScrollController.position.pixels / COURSE_CARD_WIDTH.w).round();
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showHeader)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 15).w,
            child: Row(
              children: [
                Container(
                    child: TitleSemiboldSize16(
                  widget.title,
                  maxLines: 2,
                  fontSize: widget.titleFontSize,
                )),
                Spacer(),
                widget.trendingList.length > SHOW_ALL_DISPLAY_COUNT
                    ? Visibility(
                        visible: widget.showShowAll,
                        child: Container(
                          width: 60.w,
                          child: InkWell(
                              onTap: () {
                                _generateInteractTelemetryData(
                                    TelemetryIdentifier.showAll,
                                    subType: widget.telemetrySubType,
                                    isObjectNull: true);
                                Navigator.push(
                                  context,
                                  FadeRoute(
                                      page: MdoAllContentScreen(
                                    title: widget.title,
                                    orgId: widget.orgId,
                                    type: widget.type,
                                  )),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!.mStaticShowAll,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.lato(
                                  color: AppColors.darkBlue,
                                  fontWeight: FontWeight.w400,
                                  fontSize: widget.viewAllFontSize,
                                  letterSpacing: 0.12.w,
                                ),
                              )),
                        ),
                      )
                    : Center()
              ],
            ),
          ),
        Container(
          height: 300.w,
          width: double.infinity,
          margin: const EdgeInsets.only(left: 0, top: 5, bottom: 16).w,
          child: Stack(
            children: [
              _courseListView(),
              if (widget.trendingList.length > 1)
                Positioned(
                  child: Align(
                    alignment: FractionalOffset.centerLeft,
                    child: MicroSiteIconButton(
                      onTap: () {
                        _courseScrollController.animateTo(
                          _courseScrollController.offset - COURSE_CARD_WIDTH.w,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      backgroundColor: AppColors.black,
                      icon: Icons.arrow_back_ios_sharp,
                      iconColor: AppColors.appBarBackground,
                    ),
                  ),
                ),
              if (widget.trendingList.length > 1)
                Positioned(
                  child: Align(
                      alignment: FractionalOffset.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8).w,
                        child: MicroSiteIconButton(
                          onTap: () {
                            _courseScrollController.animateTo(
                              _courseScrollController.offset +
                                  COURSE_CARD_WIDTH.w,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
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
        _listIndicator(
          count: widget.trendingList.length < SHOW_ALL_CHECK_COUNT
              ? widget.trendingList.length
              : SHOW_ALL_CHECK_COUNT,
        ),
      ],
    );
  }

  Widget _courseListView() {
    return Container(
        height: 300.w,
        width: double.infinity,
        child: ListView.builder(
          controller: _courseScrollController,
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: !widget.showShowAll
              ? widget.trendingList.length
              : widget.trendingList.length < SHOW_ALL_CHECK_COUNT
                  ? widget.trendingList.length
                  : SHOW_ALL_CHECK_COUNT,
          itemBuilder: (context, index) {
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (index == 0)
                    SizedBox(
                      width: 8.w,
                    ),
                  InkWell(
                      onTap: () async {
                        _generateInteractTelemetryData(
                            widget.trendingList[index].id,
                            subType: widget.telemetrySubType,
                            primaryCategory:
                                widget.trendingList[index].courseCategory,
                            clickId: TelemetryIdentifier.cardContent);
                        Navigator.pushNamed(context, AppUrl.courseTocPage,
                            arguments: CourseTocModel.fromJson(
                                {'courseId': widget.trendingList[index].id}));
                      },
                      child: CourseCard(course: widget.trendingList[index])),
                  if (index ==
                      (widget.trendingList.length < SHOW_ALL_CHECK_COUNT
                              ? widget.trendingList.length
                              : SHOW_ALL_CHECK_COUNT) -
                          1)
                    SizedBox(
                      width: 24.w,
                    ),
                ]);
          },
        ));
  }

  Widget _listIndicator({required int count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 2.0).w,
          height: 4.w,
          width: _currentPage == index ? 12.w : 4.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(50.w)),
            color: _currentPage == index
                ? AppColors.orangeTourText
                : AppColors.grey16,
          ),
        );
      }),
    );
  }

  void _generateInteractTelemetryData(String contentId,
      {required String subType,
      String? primaryCategory,
      bool isObjectNull = false,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null
            ? primaryCategory
            : (isObjectNull ? null : subType),
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
