import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_banner_carousel_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/popular_community_widget_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PopularCommunityWidget extends StatefulWidget {

  PopularCommunityWidget({Key? key,}) : super(key: key);
  PopularCommunityWidgetState createState() => PopularCommunityWidgetState();
}

class PopularCommunityWidgetState extends State<PopularCommunityWidget> with TickerProviderStateMixin {

  Future<CommunityModel?>? _communityFuture;
  CommunityModel? communityResponseData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCommunity();
  }

  Future<void> _loadCommunity({String? searchQuery}) async {
    _communityFuture = _getCommunity(context, searchQuery??'');
  }

  Future<CommunityModel?> _getCommunity(context, String searchQuery) async {
    try {
      _isLoading = true;
      CommunityModel? response = await Provider.of<DiscussionRepository>(context, listen: false).getPopularCommunity();
      if (response != null) {
        communityResponseData = response;
      }
      if (communityResponseData != null) {
        _isLoading = false;
        return Future.value(communityResponseData);
      } else {
        _isLoading = false;
        return null;
      }
    } catch (err) {
      _isLoading = false;
      return null;
    }
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _communityFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return (_isLoading)
              ? PopularCommunityWidgetSkeleton()
              : Container();
        }
        return Wrap(
          alignment: WrapAlignment.start,
          children: [
            if ((communityResponseData?.data??[]).isNotEmpty)
              _buildCommunityCarousel(communityResponseData?.data??[]),
            if (_isLoading)
              PopularCommunityWidgetSkeleton(),
            if (!_isLoading && (communityResponseData?.data??[]).isEmpty)
              SizedBox.shrink()
          ],
        );
      },
    );
  }

  Widget _buildCommunityCarousel(List<CommunityItemData> communityList) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
      child: CommunityBannerCarouselWidget(
        communityList: communityList,
        heading: '${AppLocalizations.of(context)!.mDiscussionPopularCommunities} (${communityList.length})',
      ),
    );
  }
}
