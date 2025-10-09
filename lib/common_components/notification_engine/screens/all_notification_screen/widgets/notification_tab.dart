import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_stats.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class NotificationTab extends StatelessWidget {
  final TabController tabController;
  final List<NotificationSubtypeStats> tabItems;
  const NotificationTab(
      {super.key, required this.tabController, required this.tabItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.only(top: 4.h, left: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.w, color: AppColors.grey08),
        ),
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.darkBlue,
              width: 2.0.w,
            ),
          ),
        ),
        unselectedLabelColor: AppColors.greys60,
        labelColor: AppColors.greys87,
        labelStyle: GoogleFonts.lato(
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.lato(
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w400,
        ),
        tabs: tabItems.map((type) => Tab(text: type.name)).toList(),
      ),
    );
  }
}
