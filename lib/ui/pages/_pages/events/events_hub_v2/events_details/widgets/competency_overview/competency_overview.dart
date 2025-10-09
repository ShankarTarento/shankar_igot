import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/competency_passbook_model.dart';
import 'package:karmayogi_mobile/models/_models/new_competency_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/events_details/widgets/competency_overview/widgets/event_competency_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class CompetencyOverview extends StatefulWidget {
  final List<CompetencyPassbook> competencies;
  const CompetencyOverview({super.key, required this.competencies});

  @override
  State<CompetencyOverview> createState() => _CompetencyOverviewState();
}

class _CompetencyOverviewState extends State<CompetencyOverview>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;

  @override
  void initState() {
    getCompetencies();
    super.initState();
  }

  CompetencyArea? selectedCompetencyArea;
  int selectedIndex = 0;
  bool showAllItems = false;

  List<CompetencyArea> competencyAreas = [];
  void getCompetencies() {
    for (var competency in widget.competencies) {
      // Find or create CompetencyArea
      CompetencyArea? existingArea;
      for (var area in competencyAreas) {
        if (area.name == competency.competencyArea) {
          existingArea = area;
          break;
        }
      }

      if (existingArea == null) {
        existingArea = CompetencyArea(
          name: competency.competencyArea,
          id: competency.competencyAreaId.toString(),
          competencyTheme: [],
        );
        competencyAreas.add(existingArea);
      }

      // Find or create CompetencyTheme within existingArea
      CompetencyTheme? existingTheme;
      if (existingArea.competencyTheme != null) {
        for (var theme in existingArea.competencyTheme!) {
          if (theme.name == competency.competencyTheme) {
            existingTheme = theme;
            break;
          }
        }
      } else {
        existingArea.competencyTheme = [];
      }

      if (existingTheme == null) {
        existingTheme = CompetencyTheme(
          id: competency.competencyThemeId.toString(),
          name: competency.competencyTheme,
          subTheme: [],
        );
        existingArea.competencyTheme!.add(existingTheme);
      }

      // Create CompetencySubTheme and add to existingTheme
      var subTheme = CompetencySubTheme(
        id: competency.competencySubThemeId.toString(),
        name: competency.competencySubTheme,
      );
      existingTheme.subTheme!.add(subTheme);
    }
    selectedCompetencyArea = competencyAreas[0];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appBarBackground,
      child: ExpansionTile(
        textColor: AppColors.greys,
        iconColor: AppColors.greys,
        trailing: Transform.rotate(
          angle: isExpanded ? 3.14159 / 2 : 0,
          child: Icon(
            Icons.chevron_right,
            size: 24.sp,
            color: AppColors.greys87,
          ),
        ),
        onExpansionChanged: (bool expanding) => setState(() {
          isExpanded = expanding;
        }),
        title: Row(
          children: [
            Text(
              Helper.capitalizeEachWordFirstCharacter(
                  AppLocalizations.of(context)!.mCompetencyOverview),
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        tilePadding: EdgeInsets.only(left: 8, right: 8).r,
        childrenPadding: EdgeInsets.all(8).r,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 16.w,
          ),
          SizedBox(
              height: 32.w,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      competencyAreas.length,
                      (index) => InkWell(
                        onTap: () {
                          selectedIndex = index;
                          selectedCompetencyArea = competencyAreas[index];
                          setState(() {});
                        },
                        child: Container(
                            margin: EdgeInsets.only(right: 16).w,
                            padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 16)
                                .r,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedIndex == index
                                    ? AppColors.darkBlue
                                    : Color.fromRGBO(0, 0, 0, 1)
                                        .withValues(alpha: 0.08),
                                width: 1.w,
                              ),
                              borderRadius: BorderRadius.circular(18).w,
                            ),
                            child: Center(
                              child: Text(
                                competencyAreas[index].name ?? "",
                                style: GoogleFonts.lato(
                                  fontSize: 14.sp,
                                  fontWeight: selectedIndex == index
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: selectedIndex == index
                                      ? AppColors.darkBlue
                                      : AppColors.greys.withValues(alpha: 0.6),
                                ),
                              ),
                            )),
                      ),
                    )),
              )),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
                competencyAreas[selectedIndex].competencyTheme!.length,
                (index) => EventCompetencyCard(
                      competencyAreas: competencyAreas,
                      index: index,
                      selectedIndex: selectedIndex,
                    )),
          ),
        ],
      ),
    );
  }
}
