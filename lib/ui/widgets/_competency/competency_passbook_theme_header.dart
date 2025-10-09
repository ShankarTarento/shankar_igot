import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/widget_helper.dart';
import '../../../models/_models/competency_data_model.dart';

class CompetencyPassbookThemeHeader extends StatelessWidget {
  const CompetencyPassbookThemeHeader({
    Key? key,
    required this.competencyTheme,
  }) : super(key: key);

  final CompetencyTheme competencyTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 1.sw - 105.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                competencyTheme.theme?.name ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: GoogleFonts.montserrat(
                    height: 1.5.w,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                competencyTheme.courses?.first.completedOn != null
                    ? '${AppLocalizations.of(context)!.mCourseLastUpdatedOn} ${DateTimeHelper.getDateTimeInFormat(competencyTheme.courses!.first.completedOn!, desiredDateFormat: 'MMM yyyy')}'
                    : '',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                    height: 1.5.w,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        SvgPicture.asset(
          WidgetHelper.getCompetencyImageUrl(competencyTheme.competencyArea!.name ?? ""),
          width: 95.0.w,
          height: 60.0.w,
        )
      ],
    );
  }
}
