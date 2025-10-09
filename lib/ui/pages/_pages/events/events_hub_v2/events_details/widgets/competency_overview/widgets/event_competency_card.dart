import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/new_competency_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/widget_helper.dart';

class EventCompetencyCard extends StatefulWidget {
  final List<CompetencyArea> competencyAreas;
  final int selectedIndex;
  final int index;
  const EventCompetencyCard(
      {Key? key,
      required this.competencyAreas,
      required this.index,
      required this.selectedIndex})
      : super(key: key);

  @override
  State<EventCompetencyCard> createState() => _EventCompetencyCardState();
}

class _EventCompetencyCardState extends State<EventCompetencyCard> {
  bool showAllItems = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15).r,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8).r,
          color: WidgetHelper.getCompetencyAreaColor(
              widget.competencyAreas[widget.selectedIndex].name ?? '')),
      child: Container(
        width: 1.sw,
        margin: EdgeInsets.only(
          top: 4,
        ).r,
        padding: EdgeInsets.only(top: 8, bottom: 16, left: 6, right: 6).r,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8).r,
            border: Border.all(color: AppColors.greys.withValues(alpha: 0.04)),
            color: AppColors.appBarBackground),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            widget.competencyAreas[widget.selectedIndex]
                .competencyTheme![widget.index].name!,
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(
            width: 1.sw,
            child: Wrap(
              alignment: !showAllItems
                  ? WrapAlignment.spaceBetween
                  : WrapAlignment.start,
              children: [
                ...List.generate(
                  showAllItems
                      ? widget.competencyAreas[widget.selectedIndex]
                          .competencyTheme![widget.index].subTheme!.length
                      : 1,
                  (subthemeIndex) => Container(
                    margin: EdgeInsets.only(top: 8, right: 16).r,
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8).r,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.darkBlue),
                      borderRadius: BorderRadius.circular(16).r,
                    ),
                    child: Text(
                      widget
                              .competencyAreas[widget.selectedIndex]
                              .competencyTheme![widget.index]
                              .subTheme![subthemeIndex]
                              .name ??
                          "",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 12.sp,
                          ),
                    ),
                  ),
                ),
                widget.competencyAreas[widget.selectedIndex]
                            .competencyTheme![widget.index].subTheme!.length >
                        1
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            showAllItems = !showAllItems;
                          });
                        },
                        child: Text(
                            showAllItems
                                ? AppLocalizations.of(context)!
                                    .mCompetencyViewLessTxt
                                : AppLocalizations.of(context)!
                                    .mCompetencyViewMoreTxt,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontSize: 12.sp,
                                      height: 2.5.w,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 1.0.w,
                                    )),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
