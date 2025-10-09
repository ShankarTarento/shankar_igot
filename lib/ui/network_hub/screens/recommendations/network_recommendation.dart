import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/recommended_user.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/empty_state.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/network_card.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/widgets/network_card_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class NetworkRecommendation extends StatefulWidget {
  const NetworkRecommendation({super.key});

  @override
  State<NetworkRecommendation> createState() => _NetworkRecommendationState();
}

class _NetworkRecommendationState extends State<NetworkRecommendation> {
  final ScrollController _scrollController = ScrollController();

  List<RecommendedUser> _recommendedUsers = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _pageNumber = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchRecommendations();
      }
    });
  }

  Future<void> _fetchRecommendations() async {
    setState(() => _isLoading = true);
    try {
      final List<RecommendedUser> result =
          await NetworkHubRepository().getRecommendedConnections(
        offset: _pageNumber,
        size: _limit,
      );

      setState(() {
        _recommendedUsers.addAll(result);
        _isLoading = false;
        _pageNumber += 1;
        if (result.length < _limit) _hasMore = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Text(
              Helper.capitalizeEachWordFirstCharacter(
                AppLocalizations.of(context)!.mMsgPeopleYouMayKnow,
              ),
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            if (_recommendedUsers.isEmpty && _isLoading)
              _buildNetworkCardSkeleton()
            else
              _buildNetworkCard(_recommendedUsers),
            if (_isLoading && _recommendedUsers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 30.0).r,
                child: _buildNetworkCardSkeleton(),
              ),
            if (!_isLoading && _recommendedUsers.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 80.0).r,
                child: Center(child: EmptyConnectionState()),
              ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkCard(List<RecommendedUser> recommendedUsers) {
    return Align(
      alignment: Alignment.center,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 24.h,
          childAspectRatio: 185.w / 200.w,
        ),
        itemCount: recommendedUsers.length,
        itemBuilder: (context, index) {
          return NetworkCard(
            height: 200.w,
            width: 185.w,
            radius: 78.w,
            contentHeight: 165.w,
            user: recommendedUsers[index],
            telemetrySubType: TelemetrySubType.networkHubPeopleYouMayKnow,
          );
        },
      ),
    );
  }

  Widget _buildNetworkCardSkeleton() {
    return Align(
      alignment: Alignment.center,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 24.h,
          childAspectRatio: 185.w / 200.w,
        ),
        itemBuilder: (context, index) {
          return const NetworkCardSkeleton();
        },
      ),
    );
  }
}
