import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../constants/index.dart';

class TourFinishWidget extends StatefulWidget {
  final Function returnCallback;

  TourFinishWidget({required this.returnCallback});
  @override
  State<TourFinishWidget> createState() => _TourWidgetState();
}

class _TourWidgetState extends State<TourFinishWidget> {
  final ProfileService profileService = ProfileService();

  bool showGetStart = true;

  @override
  void initState() {
    super.initState();
    autoClose();
  }

  void autoClose() {
    Future.delayed(Duration(milliseconds: GetStarted.autoCloseDuration),
        () async {
      if (showGetStart) {
        await finishGetStarted();
      }
    });
  }

  Future<void> finishGetStarted() async {
    final _storage = FlutterSecureStorage();
    setState(() {
      showGetStart = !showGetStart;
    });
    try {
      var response = await profileService.updateGetStarted();
      if (response['params']['status'].toString().toLowerCase() == 'success') {
        _storage.write(key: Storage.getStarted, value: GetStarted.finished);
      }
    } catch (e) {}
    widget.returnCallback();
  }

  @override
  Widget build(BuildContext context) {
    return showGetStart
        ? GestureDetector(
            onTap: finishGetStarted,
            child: Container(
                height: 1.sh,
                color: AppColors.greys.withValues(alpha: 0.7),
                child: SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16).r,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(0).r,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Center(
                                            child: Column(children: [
                                          Image(
                                            image: AssetImage(
                                                'assets/img/karmasahayogi.png'),
                                            height: 160.w,
                                          ),
                                          Column(children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(4),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          4))
                                                          .r,
                                                  color: AppColors.darkBlue,
                                                ),
                                                child: Column(children: [
                                                  Container(
                                                    width: 500.w,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                              .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          4),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          4))
                                                          .r,
                                                      color: AppColors
                                                          .appBarBackground,
                                                    ),
                                                    child: Image(
                                                      image: AssetImage(
                                                          'assets/img/karmayogi_bharat_symbol.png'),
                                                      height: 160.w,
                                                      width: double.infinity.w,
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                              47, 10, 47, 20)
                                                          .r,
                                                      child: Column(children: [
                                                        Text(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .mLearnCongratulations,
                                                            style: GoogleFonts.montserrat(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        0.95),
                                                                fontSize: 20.sp,
                                                                letterSpacing:
                                                                    0.12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                height: 1.5.w)),
                                                        SizedBox(height: 5.w),
                                                        Text(
                                                            AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .mStaticCongratulationsDesc,
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts.lato(
                                                                decoration:
                                                                    TextDecoration
                                                                        .none,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        0.95),
                                                                fontSize: 14.sp,
                                                                letterSpacing:
                                                                    0.25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                height: 1.5.w))
                                                      ]))
                                                ]))
                                          ])
                                        ]))
                                      ]))
                            ])))))
        : Center();
  }
}
