import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/competency_passbook_model.dart';
import 'package:karmayogi_mobile/models/_models/new_competency_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_competencies_card.dart';

import '../../../../../../constants/index.dart';

class CommunityCompetencies extends StatefulWidget {
  final List<CompetencyPassbook> competencies;
  const CommunityCompetencies({Key? key, required this.competencies})
      : super(key: key);

  @override
  State<CommunityCompetencies> createState() => CommunityCompetenciesState();
}

class CommunityCompetenciesState extends State<CommunityCompetencies> {
  initState() {
    super.initState();
    if (widget.competencies.isNotEmpty) {
      getCompetencies();

      selectedCompetencyArea = competencyAreas[0];
    }
  }

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
  }

  CompetencyTheme? nullCompetencyTheme() {
    return null; // or return a default CompetencyTheme object
  }

  CompetencyArea? selectedCompetencyArea;
  int selectedIndex = 0;
  bool showAllItems = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.mCompetencies,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
        ),
        SizedBox(
          height: 16.w,
        ),
        widget.competencies.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 32.w,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: competencyAreas.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => GestureDetector(
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
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                        competencyAreas[selectedIndex].competencyTheme!.length,
                        (index) => CommunityCompetenciesCard(
                              competencyAreas: competencyAreas,
                              index: index,
                              selectedIndex: selectedIndex,
                            )),
                  )
                ],
              )
            : Padding(
                padding: EdgeInsets.only(top: 8.0).r,
                child:
                    Text(AppLocalizations.of(context)!.mMsgNoCompetenciesFound),
              )
      ],
    );
  }
}
