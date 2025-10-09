import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../constants/index.dart';

class CompetitiveV2Analysis extends StatefulWidget {
  const CompetitiveV2Analysis({Key? key, required this.competitiveAnalysisData})
      : super(key: key);

  final List<Map<String, String>> competitiveAnalysisData;

  @override
  State<CompetitiveV2Analysis> createState() => _CompetitiveV2AnalysisState();
}

class _CompetitiveV2AnalysisState extends State<CompetitiveV2Analysis> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
        title: Text(
          AppLocalizations.of(context)!.mAssessmentCompetitiveAnalysis,
          style: GoogleFonts.inter(
            color: isExpanded ? AppColors.darkBlue : AppColors.greys,
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          isExpanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: isExpanded ? AppColors.darkBlue : AppColors.greys,
          size: 35.sp,
        ),
        onExpansionChanged: (value) {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
        children: [
          Column(
            children: [
              Table(
                columnWidths: {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          color: AppColors.grey04,
                          child: Text(
                            AppLocalizations.of(context)!.mStaticSubject,
                            style: GoogleFonts.lato(
                                color: AppColors.greys60,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          color: AppColors.grey04,
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalizations.of(context)!.mStaticYourScore,
                            style: GoogleFonts.lato(
                                color: AppColors.greys60,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          color: AppColors.grey04,
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalizations.of(context)
                                !.mAssessmentTopperScore,
                            style: GoogleFonts.lato(
                                color: AppColors.greys60,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  ),
                  for (var row in widget.competitiveAnalysisData)
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.grey16),
                        ),
                      ),
                      children: [
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              row['Column 1'] ?? '',
                              style: GoogleFonts.lato(
                                  color: AppColors.blackLegend,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: Text(row['Column 2'] ?? '',
                                style: GoogleFonts.lato(
                                    color: AppColors.blackLegend,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: Text(row['Column 3'] ?? '',
                                style: GoogleFonts.lato(
                                    color: AppColors.blackLegend,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          )
        ]);
  }
}
