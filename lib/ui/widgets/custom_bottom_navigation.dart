import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/profile_dashboard.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import '../pages/index.dart';
import './../../ui/screens/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomBottomNavigation {
  final Widget page;
  final String title;
  final Icon icon;
  final String svgIcon;
  final String unselectedSvgIcon;
  final int index;
  final String telemetryId;

  CustomBottomNavigation({
    required this.page,
    required this.title,
    required this.icon,
    required this.svgIcon,
    required this.unselectedSvgIcon,
    required this.index,
    required this.telemetryId,
  });

  static List<CustomBottomNavigation> itemsWithVegaDisabled(
      {required BuildContext context}) {
    return [
      CustomBottomNavigation(
          page: HomeScreen(),
          title: AppLocalizations.of(context)!.mStaticHome,
          icon: Icon(
            Icons.home,
          ),
          svgIcon: 'assets/img/kb_home_icon.svg',
          unselectedSvgIcon: 'assets/img/kb_home_icon.svg',
          index: 0,
          telemetryId: TelemetryIdentifier.home),
      CustomBottomNavigation(
          page: HubScreen(),
          title: AppLocalizations.of(context)!.mStaticExplore,
          icon: Icon(
            Icons.apps,
          ),
          svgIcon: 'assets/img/grid_blue.svg',
          unselectedSvgIcon: 'assets/img/grid.svg',
          index: 1,
          telemetryId: TelemetryIdentifier.explore),
      CustomBottomNavigation(
          page: SearchPage(
              // navigateCallBack: () {},
              // profileParentAction: () {},
              ),
          title: AppLocalizations.of(context)!.mStaticSearch,
          icon: Icon(
            Icons.search,
          ),
          svgIcon: 'assets/img/search_selected.svg',
          unselectedSvgIcon: 'assets/img/search_icon.svg',
          index: 2,
          telemetryId: TelemetryIdentifier.search),
      CustomBottomNavigation(
          page: ProfileDashboard(type: ProfileConstants.currentUser),
          title: AppLocalizations.of(context)!.mStaticMyLearning,
          icon: Icon(
            Icons.account_circle,
          ),
          svgIcon: 'assets/img/learn_active.svg',
          unselectedSvgIcon: 'assets/img/learn_inactive.svg',
          index: 3,
          telemetryId: TelemetryIdentifier.myLearnings)
    ];
  }
}
