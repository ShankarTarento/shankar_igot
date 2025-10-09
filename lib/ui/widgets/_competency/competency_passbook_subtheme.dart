import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/index.dart';
import '../index.dart';

class CompetencyPassbookSubtheme extends StatefulWidget {
  final List competencySubthemes;
  const CompetencyPassbookSubtheme(
      {Key? key, required this.competencySubthemes})
      : super(key: key);

  @override
  State<CompetencyPassbookSubtheme> createState() =>
      _CompetencyPassbookSubthemeState();
}

class _CompetencyPassbookSubthemeState
    extends State<CompetencyPassbookSubtheme> {
  final double leftPadding = 20.0.r;
  bool viewMore = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: leftPadding).r,
      child: Wrap(
        runSpacing: 20,
        spacing: 10,
        alignment: WrapAlignment.start,
        children: [
          ...widget.competencySubthemes
              .take(viewMore
                  ? widget.competencySubthemes.length
                  : widget.competencySubthemes.length > SUBTHEME_VIEW_COUNT
                      ? SUBTHEME_VIEW_COUNT
                      : widget.competencySubthemes.length)
              .map<Widget>((subthemes) => CompetencyPassbookThemeChipsWidget(
                  chipText: subthemes.name ?? "=============ffff"))
              .toList(),
          GestureDetector(
            onTap: () {
              setState(() {
                viewMore = !viewMore;
              });
            },
            child: widget.competencySubthemes.length > SUBTHEME_VIEW_COUNT
                ? Container(
                    padding: EdgeInsets.all(8).r,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20).r),
                    child: Text(
                      viewMore
                          ? AppLocalizations.of(context)!.mCompetencyViewMoreTxt
                          : AppLocalizations.of(context)!
                              .mCompetencyViewLessTxt,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            decoration: TextDecoration.underline,
                            fontSize: 12.sp,
                          ),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
