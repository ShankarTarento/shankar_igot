import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:karmayogi_mobile/respositories/_respositories/tab_state_repository.dart';
import 'package:provider/provider.dart';
import './../../../constants/index.dart';
import '../../widgets/index.dart';

class BottomBar extends StatefulWidget {
  BottomBar();

  _BottomBarState createState() => _BottomBarState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _BottomBarState extends State<BottomBar> {
  int _unSeenNotificationsCount = 0;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
      decoration: BoxDecoration(color: AppColors.appBarBackground, boxShadow: [
        BoxShadow(
          color: AppColors.grey08,
          blurRadius: 6.0.r,
          spreadRadius: 0.r,
          offset: Offset(
            0,
            -3,
          ),
        ),
      ]),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            for (final tabItem in (CustomBottomNavigation.itemsWithVegaDisabled(
                context: context)))
              InkWell(
                  onTap: () {
                    Provider.of<TabStateRepository>(context, listen: false)
                        .updateCustomTabIndex(tabItem.index);
                    Navigator.pop(context);
                  },
                  child: Stack(children: <Widget>[
                    SizedBox(
                      height: Platform.isIOS ? 72.0.w : 62.0.w,
                      child: Container(
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0).r,
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 8, 20, 5).r,
                                child: SvgPicture.asset(
                                  tabItem.unselectedSvgIcon,
                                  width: 24.0.w,
                                  height: 24.0.w,
                                ),
                              ),
                              Text(
                                tabItem.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 10.sp,
                                    ),
                              )
                            ],
                          )),
                    ),
                    (tabItem.index == 3 && _unSeenNotificationsCount > 0)
                        ? Positioned(
                            top: 5,
                            right: 0,
                            child: Container(
                              height: 20.w,
                              child: CircleAvatar(
                                  backgroundColor: AppColors.negativeLight,
                                  child: Center(
                                    child: Text(
                                      _unSeenNotificationsCount.toString(),
                                      style: GoogleFonts.lato(
                                          fontSize: 10.0.sp,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  )),
                            ),
                          )
                        : Positioned(
                            child: Text(''),
                          ),
                  ]))
          ]),
    );
  }
}
