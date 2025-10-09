import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/competency_data_model.dart'
    as CompetencyTheme;
import 'package:karmayogi_mobile/util/widget_helper.dart';

import '../index.dart';

class CompetencyPassbookCardWidget extends StatelessWidget {
  final CompetencyTheme.CompetencyTheme themeItem;
  final VoidCallback callBack;
  const CompetencyPassbookCardWidget(
      {Key? key, required this.themeItem, required this.callBack})
      : super(key: key);

  final double leftPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callBack,
      child: Container(
        width: double.infinity.w,
        padding: EdgeInsets.all(0.5).r,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20).r,
            color: WidgetHelper.getCompetencyAreaColor(themeItem.competencyArea?.name??'')
        ),
        child: Container(
            width: double.infinity.w,
            margin: EdgeInsets.only(
              top: 10,
            ).r,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20).r,
                color: AppColors.appBarBackground),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(leftPadding).r,
                        child: Text(
                          themeItem.theme?.name ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18.sp,
                                height: 1.5.w,
                                fontFamily: GoogleFonts.montserrat().fontFamily,
                              ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: leftPadding, right: leftPadding)
                              .r,
                      child: SvgPicture.asset(
                        WidgetHelper.getCompetencyImageUrl(themeItem.competencyArea?.name ?? ""),
                        width: 74.0.w,
                        height: 46.0.w,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(left: leftPadding, right: leftPadding)
                              .r,
                      child: SvgPicture.asset(
                        'assets/img/Learn.svg',
                        colorFilter: ColorFilter.mode(
                            AppColors.darkBlue, BlendMode.srcIn),
                        width: 24.0.w,
                        height: 24.0.w,
                      ),
                    ),
                    Text(
                      themeItem.courses?.length.toString() ?? "",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            height: 1.5.w,
                          ),
                    ),
                    Spacer(),
                  ],
                ),
                Divider(
                  height: 30.w,
                  thickness: 1,
                  color: AppColors.grey08,
                ),
                themeItem.competencySubthemes != null &&
                        themeItem.competencySubthemes!.isNotEmpty
                    ? CompetencyPassbookSubtheme(
                        competencySubthemes: themeItem.competencySubthemes!)
                    : Text('==============kkkk'),
                SizedBox(
                  height: 20.w,
                )
              ],
            )),
      ),
    );
  }
}
