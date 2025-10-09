import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/competency_data_model.dart';
import 'package:provider/provider.dart';
import '../../../respositories/_respositories/learn_repository.dart';
import '../../../util/helper.dart';
import './../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetencyPassbookHeaderWidget extends StatelessWidget {
  final List<CompetencyDataModel> competency;

  final leftPadding = 10.0.r;
  final fontColor = AppColors.appBarBackground;

  CompetencyPassbookHeaderWidget({required this.competency});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity.w,
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0),
          ).r,
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(leftPadding, 6, 8, 0).r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.mStaticlearningHistory,
                    style: GoogleFonts.montserrat(
                        height: 1.5.w,
                        color: fontColor,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600),
                  ),
                  // IconButton(
                  //     icon: Icon(
                  //       Icons.filter_list,
                  //       color: fontColor,
                  //     ),
                  //     onPressed: () {}),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(width: leftPadding),
                Text(
                  getAllCompetency(),
                  style: GoogleFonts.montserrat(
                      height: 1.5.w,
                      color: fontColor,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: EdgeInsets.all(leftPadding).r,
                  child: Text(
                    AppLocalizations.of(context)!.mCompetencyPassbookSubtitle,
                    style: GoogleFonts.montserrat(
                        height: 1.5.w,
                        color: fontColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: leftPadding).r,
              child: Divider(
                height: 30.w,
                thickness: 1,
                color: AppColors.white016,
              ),
            ),
            Consumer<LearnRepository>(builder: (context, learnRepository, _) {
              var allCompetencyTheme = learnRepository.competencyThemeList;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  competencyThemesWidget(
                      getCount(CompetencyAreas.behavioural, allCompetencyTheme),
                      Helper().capitalizeFirstCharacter(
                          AppLocalizations.of(context)!
                              .mStaticCompetencyPassbookTabBehavioural),
                      () => navigateToTabScreen(allCompetencyTheme, context, 1),
                      context),
                  competencyThemesWidget(
                      getCount(CompetencyAreas.functional, allCompetencyTheme),
                      Helper().capitalizeFirstCharacter(
                          AppLocalizations.of(context)!
                              .mStaticCompetencyPassbookTabFunctional),
                      () => navigateToTabScreen(allCompetencyTheme, context, 2),
                      context),
                  competencyThemesWidget(
                      getCount(CompetencyAreas.domain, allCompetencyTheme),
                      Helper().capitalizeFirstCharacter(
                          AppLocalizations.of(context)!
                              .mStaticCompetencyPassbookTabDomain),
                      () => navigateToTabScreen(allCompetencyTheme, context, 3),
                      context),
                ],
              );
            }),
            SizedBox(
              height: 40.w,
            )
          ],
        ));
  }

  void navigateToTabScreen(
      allCompetencyTheme, BuildContext context, int index) {
    if (allCompetencyTheme != null &&
        allCompetencyTheme.runtimeType != String &&
        allCompetencyTheme.length > 0) {
      Navigator.pushNamed(context, AppUrl.competencyPassbookTabbedPage,
          arguments: {'competency': allCompetencyTheme, 'index': index});
    }
  }

  String getCount(String category, List<CompetencyTheme> allCompetency) {
    int length = 0;

    allCompetency.forEach((element) {
      if (element.competencyArea?.name?.toLowerCase() == category) {
        length++;
      }
    });

    return length.toString();
  }

  Widget competencyThemesWidget(
      String title, String subTitle, VoidCallback onClick, context) {
    return InkWell(
        onTap: onClick,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                      height: 1.5.w,
                      color: fontColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      subTitle,
                      style: GoogleFonts.montserrat(
                          height: 1.5.w,
                          color: fontColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400),
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: fontColor,
                      size: 12.sp,
                    )
                  ],
                ),
              ],
            )
          ],
        ));
  }

  String getAllCompetency() {
    int count = 0;

    competency.forEach((element) {
      if (element.competencyThemes != null) {
        count += element.competencyThemes!.length;
      }
    });

    return count.toString();
  }
}
