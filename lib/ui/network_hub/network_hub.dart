import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:karmayogi_mobile/common_components/custom_bottom_bar/custom_bottom_bar.dart';
import 'package:karmayogi_mobile/common_components/custom_bottom_bar/models/bottom_bar_model.dart';
import 'package:karmayogi_mobile/common_components/custom_bottom_bar/widgets/bottom_bar_item.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/route_observer.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/user_connection_request.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/screens/connections/network_connections.dart';
import 'package:karmayogi_mobile/ui/network_hub/screens/explore_network/explore_network.dart';
import 'package:karmayogi_mobile/ui/network_hub/screens/mentors/network_mentors.dart';
import 'package:karmayogi_mobile/ui/network_hub/screens/recommendations/network_recommendation.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_hub_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/hubs_custom_app_bar.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import '../../constants/_constants/app_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkHubV2 extends StatefulWidget {
  final int? initialIndex;
  final int? currentSubTabIndex;
  const NetworkHubV2({super.key, this.initialIndex, this.currentSubTabIndex});

  @override
  State<NetworkHubV2> createState() => _NetworkHubV2State();

  static void setTabItem({
    required BuildContext context,
    required int index,
    int? subTabIndex,
  }) {
    final _NetworkHubV2State? state =
        context.findAncestorStateOfType<_NetworkHubV2State>();
    state?._setTab(index: index, subTabIndex: subTabIndex);
  }
}

class _NetworkHubV2State extends State<NetworkHubV2> with RouteAware {
  int selectedIndex = 0;
  int currentSubTabIndex = 0;
  late String route;
  late Future<List<BottomBarModel>> _bottomBarFuture;
  List<BottomBarModel> _bottomBarItems = [];
  bool _isSubscribedToRouteObserver = false;
  bool _isReloading = false;
  Key? rebuildKey;

  @override
  void initState() {
    super.initState();
    currentSubTabIndex = widget.currentSubTabIndex ?? 0;
    selectedIndex = widget.initialIndex ?? 0;
    route = AppUrl.networkExplore;
    _bottomBarFuture = _loadBottomBarItems();
    _generateImpressionTelemetryData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSubscribedToRouteObserver) {
      routeObserver.subscribe(this, ModalRoute.of(context)!);
      _isSubscribedToRouteObserver = true;
    }
  }

  @override
  void dispose() {
    if (_isSubscribedToRouteObserver) {
      routeObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    if (mounted && !_isReloading) {
      _isReloading = true;
      setState(() {
        rebuildKey = ValueKey(DateTime.now().millisecondsSinceEpoch);
      });
      _isReloading = false;
    }
  }

  Future<List<BottomBarModel>> _loadBottomBarItems() async {
    List<NetworkUser> connectionRequests =
        await NetworkHubRepository().getConnectionRequests(offset: 0, size: 5);

    return [
      BottomBarModel(
        widget: BottomBarItem(
          imageUrl: "assets/img/network_explore.svg",
          title: AppLocalizations.of(context)!.mExploreNetwork,
        ),
        route: AppUrl.networkExplore,
      ),
      BottomBarModel(
        widget: BottomBarItem(
          imageUrl: "assets/img/network_connections.svg",
          title: AppLocalizations.of(context)!.mStaticConnections,
          isActive: connectionRequests.isNotEmpty,
        ),
        route: AppUrl.networkConnections,
      ),
      BottomBarModel(
        widget: BottomBarItem(
          imageUrl: "assets/img/network_recommendations.svg",
          title: AppLocalizations.of(context)!.mRecommendation,
        ),
        route: AppUrl.networkRecommendation,
      ),
      BottomBarModel(
        widget: BottomBarItem(
          imageUrl: "assets/img/network_mentors.svg",
          title: AppLocalizations.of(context)!.mMentors,
        ),
        route: AppUrl.networkMentors,
      ),
    ];
  }

  void _setTab({required int index, int? subTabIndex = 0}) {
    if (index < 0 || index >= _bottomBarItems.length) return;

    if (selectedIndex == index && currentSubTabIndex == subTabIndex) return;

    setState(() {
      selectedIndex = index;
      route = _bottomBarItems[index].route;
      currentSubTabIndex = subTabIndex ?? 0;
    });
  }

  Widget _getScreenByRoute(String route) {
    final key = rebuildKey ?? ValueKey('default');

    switch (route) {
      case AppUrl.networkExplore:
        return ExploreNetwork(
          key: key,
        );
      case AppUrl.networkConnections:
        return NetworkConnections(
          tabIndex: currentSubTabIndex,
          key: key,
          onTabChanged: (index) {
            currentSubTabIndex = index;
          },
        );
      case AppUrl.networkRecommendation:
        return NetworkRecommendation(
          key: key,
        );
      case AppUrl.networkMentors:
        return NetworkMentors(
          key: key,
        );
      default:
        return const ExploreNetwork();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BottomBarModel>>(
      future: _bottomBarFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          _bottomBarItems = snapshot.data!;
          route = _bottomBarItems[selectedIndex].route;

          return Scaffold(
            backgroundColor: AppColors.whiteGradientOne,
            appBar: HubsCustomAppBar(
              title: AppLocalizations.of(context)!.mStaticNetwork,
              titlePrefixIcon: SvgPicture.asset(
                'assets/img/network_icon.svg',
                width: 24.0.w,
                height: 24.0.w,
                colorFilter:
                ColorFilter.mode(AppColors.darkBlue, BlendMode.srcIn),
              ),
            ),
            bottomNavigationBar: CustomBottomBar(
              currentIndex: selectedIndex,
              bottomBarItems: _bottomBarItems,
              onTap: (String tappedRoute) {
                final tappedIndex = _bottomBarItems
                    .indexWhere((item) => item.route == tappedRoute);
                if (tappedIndex != -1) {
                  _setTab(index: tappedIndex);
                }
              },
            ),
            body: _getScreenByRoute(route),
          );
        }

        return const NetworkHubSkeleton();
      },
    );
  }

  void _generateImpressionTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.networkHomePageId,
        telemetryType: TelemetryType.app,
        pageUri: TelemetryPageIdentifier.networkHomePageId,
        env: TelemetryEnv.network);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
