import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_competency/competency_passbook_card.dart';
import 'package:provider/provider.dart';

import '../../../respositories/_respositories/learn_repository.dart';
import '../../pages/index.dart';

class CompetencyPassbookBodyWidget extends StatelessWidget {
  CompetencyPassbookBodyWidget();

  @override
  Widget build(BuildContext context) {
    return Consumer<LearnRepository>(builder: (context, learnRepository, _) {
      var allCompetencyTheme = learnRepository.competencyThemeList;
      if (allCompetencyTheme.runtimeType != String) {
        return allCompetencyTheme.length > 0
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.w),
                    Text(
                      AppLocalizations.of(context)!
                          .mCompetencyPassbookListTitle,
                      style: GoogleFonts.montserrat(
                          height: 1.5.w,
                          color: AppColors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 16.w),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            allCompetencyTheme.length > KARMAPOINT_DISPLAY_LIMIT
                                ? KARMAPOINT_DISPLAY_LIMIT
                                : allCompetencyTheme.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0).r,
                            child: CompetencyPassbookCardWidget(
                              themeItem: allCompetencyTheme[index],
                              callBack: () {
                                Navigator.pushNamed(
                                    context, AppUrl.competencyPassbookThemePage,
                                    arguments: {
                                      'competencyTheme':
                                          allCompetencyTheme[index],
                                    });
                              },
                            ),
                          );
                        }),
                    SizedBox(height: 30.w),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, AppUrl.competencyPassbookTabbedPage,
                              arguments: {'competency': allCompetencyTheme});
                        },
                        child: Text(
                          AppLocalizations.of(context)!.mCommonShowAll,
                          style: GoogleFonts.montserrat(
                              height: 1.5.w,
                              color: AppColors.darkBlue,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    SizedBox(height: 50.w),
                  ],
                ),
              )
            : NoDataWidget(
                message:
                    AppLocalizations.of(context)!.mStaticCompetencyNotFound,
              );
      } else {
        return Center();
      }
    });
  }
}
