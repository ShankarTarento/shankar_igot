import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:karmayogi_mobile/util/app_config.dart';

class ChatBotBottomBar extends StatefulWidget {
  final TabController tabController;
  final String loggedInStatus;

  const ChatBotBottomBar({
    super.key,
    required this.tabController,
    required this.loggedInStatus,
  });

  @override
  State<ChatBotBottomBar> createState() => _ChatBotBottomBarState();
}

class _ChatBotBottomBarState extends State<ChatBotBottomBar> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 500)),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return BottomAppBar(
            padding: EdgeInsets.zero,
            child: Container(
              color: AppColors.appBarBackground,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                      color: AppColors.verifiedBadgeIconColor,
                      width: 3.0,
                    )),
                    color: Color.fromARGB(255, 243, 232, 209)),
                labelColor: AppColors.verifiedBadgeIconColor,
                unselectedLabelColor: AppColors.greys60,
                tabs: <Widget>[
                  if (AppConfiguration.iGOTAiConfig.iGOTAI &&
                      widget.loggedInStatus != EnglishLang.NotLoggedIn)
                    Padding(
                      padding: const EdgeInsets.all(4).r,
                      child: Tab(
                          child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 1, top: 2).r,
                            height: 22.w,
                            width: 22.w,
                            padding: EdgeInsets.all(3).r,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.botBackgroundColor),
                            child: Image.asset(
                              'assets/img/bot body.png',
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.mIgotAi,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5.r,
                                ),
                          )
                        ],
                      )),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(4).r,
                    child: Tab(
                        child: Column(
                      children: [
                        Icon(Icons.info_rounded, size: 24.sp),
                        Text(
                          AppLocalizations.of(context) != null
                              ? AppLocalizations.of(context)!.mStaticInformation
                              : EnglishLang.information,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5.r,
                              ),
                        )
                      ],
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4).r,
                    child: Tab(
                        child: Column(
                      children: [
                        Icon(Icons.warning_rounded, size: 24.sp),
                        Text(
                          AppLocalizations.of(context) != null
                              ? AppLocalizations.of(context)!.mStaticIssues
                              : EnglishLang.issues,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.5.r),
                        )
                      ],
                    )),
                  )
                ],
                controller: widget.tabController,
                onTap: (value) {
                  setState(() {});
                },
              ),
            ),
          );
        });
  }
}
