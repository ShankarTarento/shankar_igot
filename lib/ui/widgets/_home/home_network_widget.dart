import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/route_observer.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/recommended_user.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/network_card.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/widgets/network_card_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import '../../../constants/index.dart';
import '../../../util/faderoute.dart';
import '../../network_hub/models/user_connection_request.dart';

class HomeNetworkWidget extends StatefulWidget {
  final VoidCallback generateShowAllTelemetry;

  const HomeNetworkWidget({
    super.key,
    required this.generateShowAllTelemetry,
  });

  @override
  State<HomeNetworkWidget> createState() => _HomeNetworkWidgetState();
}

class _HomeNetworkWidgetState extends State<HomeNetworkWidget> with RouteAware {
  final NetworkHubRepository _networkHubRepository = NetworkHubRepository();
  late Future<List<RecommendedUser>> _recommendedUsersFuture;
  late Future<int> _connectionRequestsCountFuture;
  bool _isSubscribedToRouteObserver = false;
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    _recommendedUsersFuture = _fetchRecommendedUsers();
    _connectionRequestsCountFuture = _fetchConnectionRequestsCount();
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
  void didPopNext() {
    if (mounted && !_isReloading) {
      _isReloading = true;
      _recommendedUsersFuture = _fetchRecommendedUsers();
      _connectionRequestsCountFuture = _fetchConnectionRequestsCount();
      setState(() {});
      _isReloading = false;
    }
  }

  Future<List<RecommendedUser>> _fetchRecommendedUsers() {
    return _networkHubRepository.getRecommendedConnections(offset: 0, size: 10);
  }

  Future<int> _fetchConnectionRequestsCount() async {
    final List<NetworkUser> requests =
        await _networkHubRepository.getMyConnections(offset: 0, size: 20);
    return requests.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRecommendedUsersSection(),
        _buildConnectionRequestCard(),
      ],
    );
  }

  Widget _buildRecommendedUsersSection() {
    return FutureBuilder<List<RecommendedUser>>(
      future: _recommendedUsersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildRecommendedSkeleton();
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return _buildRecommendedList(snapshot.data!);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecommendedSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(AppLocalizations.of(context)!.mNetworkHub),
        _sectionSubtitle(AppLocalizations.of(context)!.mHomeSuggestedForYou,
            onTap: () {}),
        SizedBox(height: 8.w),
        SizedBox(
          height: 200.w,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(left: 16.0).r,
              child: NetworkCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedList(List<RecommendedUser> users) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(AppLocalizations.of(context)!.mNetworkHub),
        _sectionSubtitle(AppLocalizations.of(context)!.mHomeSuggestedForYou,
            onTap: () {
          Navigator.push(
            context,
            FadeRoute(page: NetworkHubV2(initialIndex: 2)),
          );
        }),
        SizedBox(height: 8.w),
        SizedBox(
          height: 200.w,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length.clamp(0, 5),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(left: 16.0).r,
              child: NetworkCard(
                user: users[index],
                telemetrySubType: TelemetrySubType.networkHubPeopleYouMayKnow,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionRequestCard() {
    return FutureBuilder<int>(
      future: _connectionRequestsCountFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              FadeRoute(
                  page: NetworkHubV2(
                initialIndex: 1,
                currentSubTabIndex: 1,
              )),
            ),
            child: Container(
              margin: EdgeInsets.only(left: 16, right: 16, bottom: 50).w,
              padding: EdgeInsets.fromLTRB(31, 16, 17, 16).w,
              height: 80.w,
              decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(
                        color: AppColors.orangeBackground, width: 4.0.w)),
                color: AppColors.orangeShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/img/network_people_icon.svg',
                        width: 48.0.w,
                        height: 48.0.w,
                      ),
                      SizedBox(width: 16.w),
                      SizedBox(
                        width: 0.5.sw,
                        child: Text(
                          '${snapshot.data} ${AppLocalizations.of(context)!.mStaticConnectionsRequestsWaiting}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                    'assets/img/swipe_right.svg',
                    width: 24.0.w,
                    height: 24.0.w,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8).w,
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          color: AppColors.greys87,
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
          letterSpacing: 0.12,
        ),
      ),
    );
  }

  Widget _sectionSubtitle(String title, {required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 15).r,
      child: TitleWidget(
        title: title,
        showAllCallBack: onTap,
      ),
    );
  }
}
