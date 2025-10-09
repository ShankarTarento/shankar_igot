import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/competency_passbook_model.dart';
import 'package:karmayogi_mobile/models/_models/new_competency_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../../constants/index.dart';
import 'competency_card.dart';

class Competency extends StatefulWidget {
  final List<CompetencyPassbook> competencies;
  final String courseId;
  const Competency(
      {Key? key, required this.competencies, required this.courseId})
      : super(key: key);

  @override
  State<Competency> createState() => _CompetencyState();
}

class _CompetencyState extends State<Competency> {
  initState() {
    super.initState();
    updateCompetency();
  }

  void updateCompetency() {
    if (widget.competencies.isNotEmpty) {
      getCompetencies();

      selectedCompetencyArea = competencyAreas[0];
    }
  }

  @override
  void didUpdateWidget(covariant Competency oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.courseId != oldWidget.courseId) {
      updateCompetency();
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
          style: GoogleFonts.lato(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                          competencyAreas[selectedIndex]
                              .competencyTheme!
                              .length,
                          (index) => CompetencyCard(
                                competencyAreas: competencyAreas,
                                index: index,
                                selectedIndex: selectedIndex,
                              )),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child:
                    Text(AppLocalizations.of(context)!.mMsgNoCompetenciesFound),
              )
      ],
    );
  }
}
