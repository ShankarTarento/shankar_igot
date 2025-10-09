import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/rounded_button.dart';
import 'package:karmayogi_mobile/util/telemetry_db_helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import '../../../models/index.dart';
import './../../../constants/index.dart';
import '../../pages/_pages/home_page/home_page.dart';
import './../../../ui/widgets/_home/home_silver_list.dart';
import './../../../ui/widgets/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/homeScreen';
  final int? index;
  final Profile? profileInfo;
  final profileParentAction;
  final GlobalKey<ScaffoldState>? drawerKey;
  HomeScreen(
      {Key? key,
      this.index,
      this.profileInfo,
      this.profileParentAction,
      this.drawerKey})
      : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  _onBackPressed() {
    return showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8).r),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: context,
        builder: (context) => SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 20).r,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20).r,
                            height: 6.w,
                            width: 0.25.sw,
                            decoration: BoxDecoration(
                              color: AppColors.grey16,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16).r),
                            ),
                          ),
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.only(top: 5, bottom: 15).r,
                            child: Text(
                              AppLocalizations.of(context)!.mHomeExitApp,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                            )),
                        Container(
                          padding: const EdgeInsets.only(top: 5, bottom: 15).r,
                          child: GestureDetector(
                            onTap: () async {
                              String? userId =
                                  await TelemetryRepository().getUserId();
                              if (userId != null) {
                                await TelemetryDbHelper.triggerEvents(userId,
                                    forceTrigger: true);
                              }
                              try {
                                SystemNavigator.pop();
                              } catch (e) {
                                Navigator.of(context).pop(true);
                              }
                            },
                            child: RoundedButton(
                                buttonLabel: AppLocalizations.of(context)!
                                    .mHomeComfirmExit,
                                bgColor: AppColors.appBarBackground,
                                textColor: AppColors.darkBlue),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 0, bottom: 15).r,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: RoundedButton(
                                buttonLabel: AppLocalizations.of(context)!
                                    .mHomeCancelExit,
                                bgColor: AppColors.darkBlue,
                                textColor: AppColors.appBarBackground),
                          ),
                        ),
                      ])),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.index == 0
        ? PopScope(
            child: Scaffold(
              body: Container(
                color: AppColors.whiteGradientOne,
                child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: <Widget>[
                    HomeAppBarNew(
                        index: widget.index!,
                        profileParentAction: widget.profileParentAction,
                        navigateCallBack: () {},
                        drawerKey: widget.drawerKey),
                    HomeSilverList(
                      child: Container(
                        color: Color.fromRGBO(241, 244, 244, 1),
                        child: widget.index == 0
                            ? HomePage(
                                index: widget.index,
                              )
                            : Center(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                return;
              }
              _onBackPressed();
            })
        : Center();
  }
}
