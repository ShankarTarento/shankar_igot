import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RequestSuccessfullyRegisteredPage extends StatefulWidget {
  @override
  State<RequestSuccessfullyRegisteredPage> createState() =>
      _RequestSuccessfullyRegisteredPageState();
}

class _RequestSuccessfullyRegisteredPageState
    extends State<RequestSuccessfullyRegisteredPage> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: AppColors.appBarBackground,
          body: SafeArea(
            child: Container(
              width: double.infinity.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40).r,
                    child: Container(
                      child: SvgPicture.asset(
                        "assets/img/Karmayogi_bharat_logo_horizontal.svg",
                        height: 40.w,
                        width: 88.w,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 130).r,
                            child: SvgPicture.asset(
                              'assets/img/approved.svg',
                              width: 24.w,
                              height: 24.w,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 12).r,
                          child: Text(
                            AppLocalizations.of(context)!.mStaticThankYou,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  letterSpacing: 0.12,
                                  height: 1.5.w,
                                ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 12).r,
                          child: Text(
                            AppLocalizations.of(context)!.mStaticRequestLogged,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  letterSpacing: 0.12,
                                  height: 1.5.w,
                                ),
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(top: 12, left: 46, right: 46).r,
                          child: Text(
                            AppLocalizations.of(context)!
                                .mStaticRequestSentConfirmation,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  letterSpacing: 0.25,
                                  height: 1.8.w,
                                  fontSize: 14.sp,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40).r,
                    child: Container(
                      width: 182.w,
                      height: 48.w,
                      child: ButtonTheme(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            Navigator.of(context).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.appBarBackground,
                            side: BorderSide(
                                width: 1.w, color: AppColors.primaryThree),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4).r,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!
                                .mStaticOk
                                .toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  letterSpacing: 0.5,
                                  height: 1.5.w,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
