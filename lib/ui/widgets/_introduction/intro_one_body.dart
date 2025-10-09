import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../constants/index.dart';
import '../../../respositories/_respositories/settings_repository.dart';
import 'signin_btn_widget.dart';

class IntroOneBody extends StatefulWidget {
  const IntroOneBody({Key? key}) : super(key: key);

  @override
  State<IntroOneBody> createState() => _IntroOneBodyState();
}

class _IntroOneBodyState extends State<IntroOneBody>
    with TickerProviderStateMixin {
  late AnimationController _igotTextController;
  late Animation<double> _igotTextAnimation;
  late AnimationController _descriptionEntryController;
  late AnimationController _descriptionExitController;
  late Animation<double> _descriptionEntryAnimation;
  late Animation<double> _descriptionExitAnimation;
  List<String> descriptionList = [];
  int currentIndex = 0;
  bool isExit = false;
  bool isTablet = false;

  @override
  void initState() {
    super.initState();
    isTablet =
        Provider.of<SettingsRepository>(context, listen: false).itsTablet;
    _igotTextController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _igotTextAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _igotTextController, curve: Curves.easeInOut),
    );
    _descriptionEntryController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _descriptionExitController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _descriptionEntryAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _descriptionEntryController, curve: Curves.easeInOut),
    );
    _descriptionExitAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _descriptionExitController, curve: Curves.easeInOut),
    );
    _startiGotTextAnimation();
  }

  @override
  void dispose() {
    _igotTextController.dispose();
    _descriptionEntryController.dispose();
    _descriptionExitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    descriptionList = [
      AppLocalizations.of(context)!.mStaticCompetencyDrivenCapacityBuilding,
      AppLocalizations.of(context)!.mStaticVisionToMission,
      AppLocalizations.of(context)!.mStaticTransGovtOfficails,
      AppLocalizations.of(context)!.mStaticRuleBasedToRoleBasedGovernance,
      AppLocalizations.of(context)!.mStaticTransformingAndEmpoweringOfficials,
      AppLocalizations.of(context)!.mStaticKarmachariToKarmayogi
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Stack(
          children: [
            Image.network(
              ApiUrl.baseUrl + '/assets/mobile_app/banners/landing_page.webp',
              height: isTablet ? 0.5.sh : 0.33.sh,
              width: 1.0.sw,
              fit: BoxFit.fill,
              errorBuilder: (contxt, obj, stack) => SvgPicture.network(
                  ApiUrl.baseUrl +
                      '/assets/mobile_app/assets/mobile_banner_bg.svg',
                  height: 0.75.sw,
                  placeholderBuilder: (contxt) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      )),
            ),
            Positioned(
                bottom: isTablet
                    ? MediaQuery.of(context).orientation == Orientation.portrait
                        ? 0.07.sh
                        : 0.05.sh
                    : 56.r,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedBuilder(
                          animation: _igotTextAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                                offset: Offset(
                                    MediaQuery.of(context).size.width *
                                        _igotTextAnimation.value,
                                    0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8)
                                      .r,
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .mStaticKarmayogiBharat,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          color: AppColors.appBarBackground,
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.w700)),
                                ));
                          }),
                      Container(
                          width: 1.0.sw,
                          color: AppColors.orangeBackground,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              Visibility(
                                visible: !isExit,
                                child: AnimatedBuilder(
                                  animation: _descriptionEntryController,
                                  builder: (context, child) {
                                    double entryPosition =
                                        _descriptionEntryAnimation.value;
                                    return Transform.translate(
                                      offset: Offset(
                                          MediaQuery.of(context).size.width *
                                              entryPosition,
                                          0),
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                                top: 4, bottom: 4)
                                            .r,
                                        alignment: Alignment.center,
                                        child: Text(
                                            descriptionList[currentIndex],
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                                color: AppColors.greys87,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w800)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Visibility(
                                visible: isExit,
                                child: AnimatedBuilder(
                                  animation: _descriptionExitController,
                                  builder: (context, child) {
                                    double exitPosition =
                                        _descriptionExitAnimation.value;
                                    return Transform.translate(
                                      offset: Offset(
                                          MediaQuery.of(context).size.width *
                                              exitPosition,
                                          0),
                                      child: Container(
                                          padding: const EdgeInsets.only(
                                                  top: 4, bottom: 4)
                                              .r,
                                          alignment: Alignment.center,
                                          child: Text(
                                              descriptionList[currentIndex],
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                  color: AppColors.greys87,
                                                  fontSize: 16.sp,
                                                  fontWeight:
                                                      FontWeight.w800))),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ))
                    ]))
          ],
        ),
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 17).r,
                child: Text(
                  AppLocalizations.of(context)!.mStaticWelcomeintrotext,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      height: 1.5.w,
                      letterSpacing: 0.25,
                      fontSize: 18.0.sp,
                      fontWeight: FontWeight.w400),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 24.0).r,
                child: SigninBtnWidget(),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _startiGotTextAnimation() {
    _igotTextController.reset();
    _igotTextController.forward().then((_) {
      _startDescriptionAnimation();
    });
  }

  void _startDescriptionAnimation() {
    _descriptionEntryController.reset();
    _descriptionExitController.reset();
    if (currentIndex < descriptionList.length) {
      _descriptionEntryController.forward().then((_) {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            isExit = true;
          });
          _descriptionExitController.forward().then((_) {
            setState(() {
              isExit = false;
              currentIndex = (currentIndex + 1);
            });

            _startDescriptionAnimation();
          });
        });
      });
    } else {
      setState(() {
        currentIndex = 0;
        _startiGotTextAnimation();
      });
    }
  }
}
