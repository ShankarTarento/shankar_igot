import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:igot_ui_components/utils/hexcolor.dart';

import '../../../../../../constants/index.dart';
import '../model/microsite_insight_data_model.dart';
import 'microsite_insight_item.dart';

class MicroSiteInsight extends StatelessWidget {
  final double itemWidth;
  final double itemHeight;
  final BoxDecoration? itemBackground;
  final List<MicroSiteInsightsData> insightDataList;
  MicroSiteInsight(
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
      icon: Container(
        width: 26.w,
        height: 26.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ((microSiteInsightsData.valueColorV2 != null) ||
                  (microSiteInsightsData.valueColorV2 != ''))
              ? HexColor(microSiteInsightsData.valueColorV2 ?? '')
              : ModuleColors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(100.w),
          ),
        ),
        child: Container(
          width: 25.w,
          height: 25.w,
          padding: EdgeInsets.all(4).w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ((microSiteInsightsData.iconBackgroupColorV2 != null) ||
                    (microSiteInsightsData.iconBackgroupColorV2 != ''))
                ? HexColor(microSiteInsightsData.iconBackgroupColorV2 ?? '')
                : ModuleColors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(100.w),
            ),
          ),
          child: SvgPicture.network(
            microSiteInsightsData.icon ?? '',
            width: 20.w,
            height: 20.w,
            fit: BoxFit.fill,
          ),
        ),
      ),
      labelColor: ((microSiteInsightsData.labelColorV2 != null) ||
              (microSiteInsightsData.labelColorV2 != ''))
          ? HexColor(microSiteInsightsData.labelColorV2 ?? '')
          : ModuleColors.white,
      valueColor: ((microSiteInsightsData.valueColorMobV2 != null) ||
              (microSiteInsightsData.valueColorMobV2 != ''))
          ? HexColor(microSiteInsightsData.valueColorMobV2 ?? '')
          : ModuleColors.white,
      iconColor: ((microSiteInsightsData.iconColor != null) ||
              (microSiteInsightsData.iconColor != ''))
          ? HexColor(microSiteInsightsData.iconColor ?? '')
          : ModuleColors.white,
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
