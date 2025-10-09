import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/recommended_user.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/screens/mentors/widgets/discover_mentors_card.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/empty_state.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/network_card.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/network_card/widgets/network_card_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkMentors extends StatefulWidget {
  const NetworkMentors({super.key});

  @override
  State<NetworkMentors> createState() => _NetworkMentorsState();
}

class _NetworkMentorsState extends State<NetworkMentors> {
  final int _pageSize = 30;
  int _pageNumber = 0;
  bool _isLoading = false;
  bool _hasMoreData = true;
  List<RecommendedUser> _mentors = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchMentors();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMoreData) {
        _fetchMentors();
      }
    });
  }

  Future<void> _fetchMentors() async {
    setState(() => _isLoading = true);

    try {
      final List<RecommendedUser> fetched = await NetworkHubRepository()
          .getRecommendedMentors(offset: _pageNumber, size: _pageSize);

      setState(() {
        if (fetched.length < _pageSize) {
          _hasMoreData = false;
        }
        _mentors.addAll(fetched);
        _pageNumber++;
      });
    } catch (e) {
      _hasMoreData = false;

      debugPrint("Error fetching mentors: $e");
    } finally {
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
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DiscoverMentorsCard(),
            SizedBox(height: 16.w),
            Text(
              AppLocalizations.of(context)!.mMentors,
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.w),
            if (_mentors.isNotEmpty)
              _buildNetworkCard(recommendedMentors: _mentors)
            else if (_isLoading)
              _buildNetworkCardSkeleton()
            else
              Padding(
                padding: const EdgeInsets.only(top: 80.0).r,
                child: Center(
                    child: EmptyConnectionState(
                  message: AppLocalizations.of(context)!.mNoMentorsFound,
                )),
              ),
            if (_isLoading && _mentors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0).r,
                child: Center(child: _buildNetworkCardSkeleton()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkCard(
      {required List<RecommendedUser> recommendedMentors}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 24.h,
          ),
          itemCount: recommendedMentors.length,
          itemBuilder: (context, index) {
            return NetworkCard(
              height: 200.w,
              width: 185.w,
              radius: 78.w,
              contentHeight: 165.w,
              user: recommendedMentors[index],
              telemetrySubType: TelemetrySubType.networkHubMentors,
            );
          },
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildNetworkCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(12.0).r,
      child: Column(
        children: [
          SizedBox(height: 20.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 24.h,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return const NetworkCardSkeleton();
            },
          ),
        ],
      ),
    );
  }
}
