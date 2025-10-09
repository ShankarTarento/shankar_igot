import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/models/_models/competency_data_model.dart' as competencyThemes;
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:provider/provider.dart';
import '../../../respositories/_respositories/learn_repository.dart';
import '../../skeleton/index.dart';
import '../../widgets/index.dart';
import './../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompetencyThemeScreen extends StatefulWidget {
  final competencyThemes.CompetencyTheme competencyTheme;
  const CompetencyThemeScreen({Key? key, required this.competencyTheme})
      : super(key: key);
  @override
  _CompetencyThemeScreenState createState() {
    return _CompetencyThemeScreenState();
  }
}

class _CompetencyThemeScreenState extends State<CompetencyThemeScreen> {
  bool isLoad = false;
  competencyThemes.CompetencyTheme? competencyTheme;
  final double leftPadding = 20.0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoad) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      competencyTheme = args['competencyTheme'];
      isLoad = true;
    }
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          toolbarHeight: kToolbarHeight.w,
          leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(Icons.arrow_back, size: 24.sp)),
          title: Row(children: [
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadeRoute(page: ContactUs()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8).r,
                child: SvgPicture.asset(
                  'assets/img/help_icon.svg',
                  width: 56.0.w,
                  height: 56.0.w,
                ),
              ),
            ),
          ]),
        ),
        body: SafeArea(child: SingleChildScrollView(
          child:
              Consumer<LearnRepository>(builder: (context, learnRepository, _) {
            var competency = learnRepository.competency;
            if (competency != null &&
                competencyTheme != null &&
                competencyTheme!.courses!.isNotEmpty) {
              return Container(
                padding: const EdgeInsets.all(10).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.w,
                    ),
                    CompetencyPassbookThemeHeader(
                        competencyTheme: competencyTheme!),
                    Container(
                      width: double.infinity.w,
                      margin: const EdgeInsets.only(top: 20.0, bottom: 12.0).r,
                      padding: const EdgeInsets.all(12.0).r,
                      decoration: BoxDecoration(
                          color: AppColors.appBarBackground,
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0).r)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context)!.mCompetencySubTheme} ${competencyTheme!.competencySubthemes!.length}',
                              style: GoogleFonts.montserrat(
                                  height: 1.5.w,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 16.w),
                            CompetencyPassbookSubtheme(
                                competencySubthemes:
                                    competencyTheme!.competencySubthemes!),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0).r,
                      child: Text(
                        '${AppLocalizations.of(context)!.mCompetencyAssociatedCertificate} ${competencyTheme!.courses!.length} ',
                        style: GoogleFonts.montserrat(
                            height: 1.5.w,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: competencyTheme!.courses!.length,
                      itemBuilder: (context, index) {
                        return CompetencyPassbookCertificateCard(
                            courseInfo: competencyTheme!.courses![index],
                            isCertificateProvided: (competencyTheme!.courses?[index].certificateId != null));
                      },
                    )
                  ],
                ),
              );
            } else {
              return const CompetencyPassbookThemeSkeletonPage();
            }
          }),
        )));
  }
}
