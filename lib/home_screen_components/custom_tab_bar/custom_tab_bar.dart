import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/models/_models/multilingual_text.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/content_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<MultiLingualText> tabTitles;
  final Function(int) onTabChange;

  const CustomTabBar({
    required this.tabController,
    required this.tabTitles,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.only(top: 4, left: 16).r,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.w, color: AppColors.grey08),
        ),
      ),
      child: TabBar(
        tabAlignment: TabAlignment.start,
        onTap: (value) {
          onTabChange(value);
        },
        isScrollable: true,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.darkBlue,
              width: 2.0.w,
            ),
          ),
        ),
        indicatorColor: AppColors.appBarBackground,
        labelPadding: EdgeInsets.only(top: 0.0).w,
        unselectedLabelColor: AppColors.greys60,
        labelColor: AppColors.greys87,
        labelStyle: GoogleFonts.lato(
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.lato(
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.greys60,
        ),
        tabs: List.generate(
          tabTitles.length,
          (index) => Container(
            padding: EdgeInsets.symmetric(horizontal: 16).r,
            child: Tab(
              child: Padding(
                padding: EdgeInsets.all(5.0).r,
                child: tabTitles[index].id == WidgetConstants.igotAi
                    ? Row(
                        children: [
                          ImageWidget(
                            imageUrl: ApiUrl.baseUrl +
                                '/assets/images/sakshamAI/ai-icon.svg',
                            height: 20.sp,
                            width: 20.sp,
                          ),
                          SizedBox(
                            width: 6.w,
                          ),
                          Text(
                            tabTitles[index].getText(context),
                          ),
                          ContentInfo(
                              infoMessage: AppLocalizations.of(context)!
                                  .mIgotAIDrivenRecommendation,
                              size: 20.sp,
                              color: AppColors.greys60)
                        ],
                      )
                    : Text(
                        tabTitles[index].getText(context),
                      ),
              ),
            ),
          ),
        ),
        controller: tabController,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
