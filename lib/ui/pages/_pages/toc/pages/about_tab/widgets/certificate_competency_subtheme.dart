import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

import '../../../../../../../constants/_constants/app_constants.dart';

class CertificateCompetencySubtheme extends StatefulWidget {
  final List competencySubthemes;
  const CertificateCompetencySubtheme(
      {Key? key, required this.competencySubthemes})
      : super(key: key);

  @override
  State<CertificateCompetencySubtheme> createState() =>
      _CertificateCompetencySubthemeState();
}

class _CertificateCompetencySubthemeState
    extends State<CertificateCompetencySubtheme> {
  final double leftPadding = 8.0;
  bool viewMore = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: leftPadding).r,
      child: Wrap(
        runSpacing: 5,
        spacing: 8,
        alignment: WrapAlignment.start,
        children: [
          ...widget.competencySubthemes
              .take(
                viewMore
                    ? widget.competencySubthemes.length
                    : widget.competencySubthemes.length > SUBTHEME_VIEW_COUNT
                        ? SUBTHEME_VIEW_COUNT
                        : widget.competencySubthemes.length,
              )
              .map<Widget>((subthemes) => Container(
                    padding: EdgeInsets.all(6).r,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12).r,
                        border:
                            Border.all(width: 1.w, color: AppColors.darkBlue)),
                    child: Text(
                      subthemes.competencySubTheme,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 9.sp,
                          ),
                    ),
                  ))
              .toList(),
          GestureDetector(
            onTap: () {
              setState(() {
                viewMore = !viewMore;
              });
            },
            child: widget.competencySubthemes.length > SUBTHEME_VIEW_COUNT
                ? Container(
                    padding: EdgeInsets.all(6).r,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12).r),
                    child: Text(
                      viewMore
                          ? AppLocalizations.of(context)!.mStaticViewMore
                          : AppLocalizations.of(context)!.mStaticViewLess,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 12.sp,
                            decoration: TextDecoration.underline,
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
