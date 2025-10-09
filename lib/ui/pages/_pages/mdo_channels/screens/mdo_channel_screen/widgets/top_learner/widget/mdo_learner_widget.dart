import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/feedback/constants.dart';
import '../../../../../../../../../util/helper.dart';
import '../../../../../model/mdo_learner_data_model.dart';

class MdoLearnerWidget extends StatefulWidget {
  final double itemWidth;
  final double itemHeight;
  final bool showKarmaPoints;
  final List<MdoLearnerData> learnerDataList;
  MdoLearnerWidget(
      {required this.itemWidth,
      required this.itemHeight,
      this.showKarmaPoints = true,
      required this.learnerDataList});

  @override
  _MdoLearnerWidgetState createState() {
    return _MdoLearnerWidgetState();
  }
}

class _MdoLearnerWidgetState extends State<MdoLearnerWidget> {
  final ScrollController _learnerScrollController = ScrollController();
  int _currentPage = 0;
  List<Color> _randomColors = [];

  @override
  void initState() {
    super.initState();
    _generateRandomColors();
    _learnerScrollController.addListener(_onScroll);
  }

  void _onScroll() {
    int page =
        (_learnerScrollController.position.pixels / widget.itemWidth).round();
    setState(() {
      _currentPage = page;
    });
  }

  void _generateRandomColors() {
    _randomColors = List.generate(widget.learnerDataList.length, (index) {
      return Colors.primaries[Random().nextInt(Colors.primaries.length)];
    });
  }

  @override
  void dispose() {
    super.dispose();
    _learnerScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          controller: _learnerScrollController,
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Container(
            height: widget.itemHeight,
            padding: EdgeInsets.only(top: 8, bottom: 8).w,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                (widget.learnerDataList.length).ceil(),
                (pageIndex) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (pageIndex == 0)
                          SizedBox(
                            width: 16.w,
                          ),
                        _mdoLearnerItem(
                            mdoLearnerData: widget.learnerDataList[pageIndex],
                            index: pageIndex),
                      ]);
                },
              ),
            ),
          ),
        ),
        _listIndicator(itemLength: widget.learnerDataList.length),
      ],
    );
  }

  Widget _mdoLearnerItem(
      {required MdoLearnerData mdoLearnerData, required int index}) {
    return Container(
      margin: const EdgeInsets.only(right: 16).w,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).w,
      width: widget.itemWidth,
      decoration: BoxDecoration(
        color: FeedbackColors.background,
        borderRadius: BorderRadius.all(Radius.circular(8.w)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ((mdoLearnerData.profileImage ?? '') != '')
                  ? MicroSiteImageView(
                      imgUrl: mdoLearnerData.profileImage ?? '',
                      height: 32.w,
                      width: 32.w,
                      fit: BoxFit.fill,
                      radius: 100.r,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(100.w),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(2).w,
                        child: Container(
                          height: 32.w,
                          width: 32.w,
                          decoration: BoxDecoration(
                            color: _randomColors[index],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              Helper.getInitialsNew(
                                  mdoLearnerData.fullname ?? ''),
                              style: GoogleFonts.lato(
                                  color: AppColors.avatarText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.0.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
              Container(
                  width: 0.52.sw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JustTheTooltip(
                        showDuration: const Duration(seconds: 3),
                        tailBaseWidth: 16,
                        triggerMode: TooltipTriggerMode.longPress,
                        backgroundColor:
                            AppColors.appBarBackground.withValues(alpha: 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8).w,
                          child: Text(
                            mdoLearnerData.fullname ?? '',
                            style: GoogleFonts.lato(
                              color: AppColors.greys87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        content: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)).r,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12.0).r,
                            child: Text(
                              mdoLearnerData.fullname ?? '',
                              style: GoogleFonts.lato(
                                color: AppColors.greys87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        margin: EdgeInsets.all(40).r,
                      ),
                      if ((mdoLearnerData.designation ?? '') != '')
                        JustTheTooltip(
                          showDuration: const Duration(seconds: 3),
                          tailBaseWidth: 16,
                          triggerMode: TooltipTriggerMode.longPress,
                          backgroundColor:
                              AppColors.appBarBackground.withValues(alpha: 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4)
                                .w,
                            child: Text(
                              mdoLearnerData.designation!,
                              style: GoogleFonts.lato(
                                color: AppColors.greys60,
                                fontWeight: FontWeight.w400,
                                fontSize: 10.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          content: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)).r,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0).r,
                              child: Text(
                                mdoLearnerData.designation!,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys60,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                          margin: EdgeInsets.all(40).r,
                        ),
                      if ((mdoLearnerData.orgName ?? '') != '')
                        JustTheTooltip(
                          showDuration: const Duration(seconds: 3),
                          tailBaseWidth: 16,
                          triggerMode: TooltipTriggerMode.longPress,
                          backgroundColor:
                              AppColors.appBarBackground.withValues(alpha: 1),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                    left: 8, right: 8, bottom: 4)
                                .w,
                            child: Text(
                              mdoLearnerData.orgName!,
                              style: GoogleFonts.lato(
                                color: AppColors.greys60,
                                fontWeight: FontWeight.w400,
                                fontSize: 10.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          content: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)).r,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12.0).r,
                              child: Text(
                                mdoLearnerData.orgName!,
                                style: GoogleFonts.lato(
                                  color: AppColors.greys60,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ),
                          ),
                          margin: EdgeInsets.all(40).r,
                        ),
                    ],
                  )),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 2, top: 8).w,
                child: Text(
                  mdoLearnerData.rowNum != null
                      ? '${Helper.numberWithSuffix(mdoLearnerData.rowNum!)}'
                      : '',
                  style: GoogleFonts.montserrat(
                    color: AppColors.verifiedBadgeIconColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 24.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          widget.showKarmaPoints
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: SvgPicture.asset(
                        'assets/img/kp_icon.svg',
                        width: 18.w,
                        height: 18.w,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 4),
                      child: Text(
                        '${(mdoLearnerData.totalPoints ?? 0).toString()}',
                        style: GoogleFonts.montserrat(
                          color: AppColors.darkBlue,
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                )
              : SizedBox()
        ],
      ),
    );
  }

  Widget _listIndicator({required int itemLength}) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16).w,
      child: _buildPageIndicator(itemLength),
    );
  }

  Widget _buildPageIndicator(int count) {
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
                : AppColors.black,
          ),
        );
      }),
    );
  }
}
