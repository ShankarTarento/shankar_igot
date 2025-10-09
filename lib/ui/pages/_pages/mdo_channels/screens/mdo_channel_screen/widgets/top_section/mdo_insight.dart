import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:igot_ui_components/models/microsite_insight_data_model.dart';
import '../../../../../../../../constants/index.dart';
import '../../../../../../../../util/hexcolor.dart';
import '../../../../../microsites/generic/widgets/microsite_insight_item.dart';

class MDOInsight extends StatelessWidget {
  final double itemWidth;
  final double itemHeight;
  final BoxDecoration? itemBackground;
  final List<MicroSiteInsightsData> insightDataList;
  MDOInsight(
      {required this.itemWidth,
      required this.itemHeight,
      this.itemBackground,
      required this.insightDataList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: insightDataList.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
              position: index,
              child: SlideAnimation(
                horizontalOffset: 50,
                child: FadeInAnimation(
                    child: Container(
                  margin: EdgeInsets.only(left: (index == 0) ? 16 : 0).w,
                  child: _microSiteInsightItem(
                      microSiteInsightsData: insightDataList[index]),
                )),
              ));
        });
  }

  Widget _microSiteInsightItem(
      {required MicroSiteInsightsData microSiteInsightsData}) {
    return MicroSiteInsightItem(
      width: itemWidth,
      height: itemHeight,
      label: microSiteInsightsData.label ?? '',
      value: microSiteInsightsData.value ?? '0.0',
      icon: SvgPicture.network(
        microSiteInsightsData.icon ?? '',
        width: 24.w,
        height: 24.w,
        fit: BoxFit.fill,
        colorFilter: ColorFilter.mode(
            ((microSiteInsightsData.labelColor != null) ||
                    (microSiteInsightsData.labelColor != ''))
                ? HexColor(microSiteInsightsData.labelColor ?? '')
                : AppColors.appBarBackground,
            BlendMode.srcIn),
      ),
      labelColor: ((microSiteInsightsData.labelColor != null) ||
              (microSiteInsightsData.labelColor != ''))
          ? HexColor(microSiteInsightsData.labelColor ?? '')
          : AppColors.appBarBackground,
      valueColor: ((microSiteInsightsData.valueColor != null) ||
              (microSiteInsightsData.valueColor != ''))
          ? HexColor(microSiteInsightsData.valueColor ?? '')
          : AppColors.appBarBackground,
      iconColor: ((microSiteInsightsData.iconColor != null) ||
              (microSiteInsightsData.iconColor != ''))
          ? HexColor(microSiteInsightsData.iconColor ?? '')
          : AppColors.appBarBackground,
      labelTextSize: 14.sp,
      valueTextSize: 16.sp,
      background: itemBackground ??
          BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.tipsBackground,
                AppColors.verifiedBadgeIconColor
              ],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12.w)),
          ),
    );
  }
}
