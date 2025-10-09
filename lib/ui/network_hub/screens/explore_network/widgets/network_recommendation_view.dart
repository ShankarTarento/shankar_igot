import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/recommended_user.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/empty_state.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/network_card.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/widgets/network_card_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkRecommendationView extends StatefulWidget {
  const NetworkRecommendationView({super.key});

  @override
  State<NetworkRecommendationView> createState() =>
      _NetworkRecommendationViewState();
}

class _NetworkRecommendationViewState extends State<NetworkRecommendationView> {
  @override
  void initState() {
    futureRecommendedConnections =
        NetworkHubRepository().getRecommendedConnections(offset: 0, size: 6);
    super.initState();
  }

  Future<List<RecommendedUser>>? futureRecommendedConnections;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8).r,
      ),
      child: FutureBuilder<List<RecommendedUser>>(
          future: futureRecommendedConnections,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildNetworkCardSkeleton();
            }
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return _buildNetworkCard(snapshot.data!);
            }
            return Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 32).r,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 32).r,
                    child: _buildTitle(showAll: false),
                  ),
                  EmptyConnectionState(),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildNetworkCard(List<RecommendedUser> recommendedUsers) {
    return Padding(
      padding: const EdgeInsets.all(12.0).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          _buildTitle(showAll: true),
          SizedBox(height: 20.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 24.h,
            ),
            itemCount: recommendedUsers.length,
            itemBuilder: (context, index) {
              return NetworkCard(
                user: recommendedUsers[index],
                telemetrySubType: TelemetrySubType.networkHubPeopleYouMayKnow,
              );
            },
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildNetworkCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(12.0).r,
      child: Column(
        children: [
          SizedBox(height: 8.h),
          _buildTitle(),
          SizedBox(height: 20.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 24.h,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return NetworkCardSkeleton();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitle({bool showAll = false}) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.mStaticPeopleYouMayKnow,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        showAll
            ? InkWell(
                onTap: () {
                  NetworkHubV2.setTabItem(context: context, index: 2);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0).r,
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.mNetworkShowAll,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 16.sp, color: AppColors.darkBlue),
                    ],
                  ),
                ))
            : SizedBox()
      ],
    );
  }
}
