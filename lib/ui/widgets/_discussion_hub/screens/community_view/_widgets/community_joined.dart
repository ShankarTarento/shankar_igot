import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_card_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_list_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class CommunityJoined extends StatefulWidget {

  CommunityJoined({Key? key}) : super(key: key);
  CommunityJoinedState createState() => CommunityJoinedState();
}

class CommunityJoinedState extends State<CommunityJoined> with TickerProviderStateMixin {

  Future<List<CommunityItemData>?>? _communityFuture;
  bool _isLoading = false;
  List<CommunityItemData> _userJoinedCommunities = [];

  @override
  void initState() {
    super.initState();
    _loadCommunity();
  }

  Future<void> _loadCommunity() async {

    _communityFuture = _getCommunity();
  }

  Future<List<CommunityItemData>> _getCommunity() async {
    List<CommunityItemData> response = [];
    try {
      _isLoading = true;
      response = await Provider.of<DiscussionRepository>(context, listen: false).getUserJoinedCommunitiesListData();
      _userJoinedCommunities = await response;
      _isLoading = false;
      return Future.value(_userJoinedCommunities);
    } catch (err) {
      _isLoading = false;
      return [];
    }
  }

  AdditionalInfo? getCreatorInfo(CommunityItemData communityItemData) {
    return AdditionalInfo(
      id: communityItemData.orgId,
      orgname: communityItemData.orgName,
      logo: communityItemData.orgLogo
    );
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: buildBody()
    );
  }

  Widget buildBody() {
    return SingleChildScrollView (
      physics: BouncingScrollPhysics(),
      child: buildUI(),
    );
  }

  Widget buildUI() {
    return Container(
      margin: EdgeInsets.only(top: 16, bottom: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: _communityFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return (_isLoading)
                    ? CommunityListSkeleton(
                  itemCount: 10,
                ) : Container();
              }
              return Wrap(
                alignment: WrapAlignment.start,
                children: [
                  if (_userJoinedCommunities.isNotEmpty)
                    _buildCommunityJoined(_userJoinedCommunities),
                  if (_isLoading)
                    CommunityListSkeleton(
                      itemCount: 10,
                    ),
                  if (!_isLoading && (_userJoinedCommunities.isEmpty))
                    Container(
                      child: NoDataWidget(
                          message: AppLocalizations.of(context)!.mDiscussionNoJoinedCommunityFound),
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityJoined(List<CommunityItemData> communityItemList) {
    return Column(
      children: [
        Container(
          width: double.maxFinite,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  AppLocalizations.of(context)?.mDiscussionYourCommunities??'',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                ' (${communityItemList.length})',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        AnimationLimiter(
          child: Container(
            margin: EdgeInsets.only(left: 16, right: 16).r,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: (communityItemList.length / 2).ceil(),
              itemBuilder: (context, index) {
                int firstItemIndex = index * 2;
                int secondItemIndex = firstItemIndex + 1;
                bool isLastRowWithOneItem = secondItemIndex >= communityItemList.length;

                return Container(
                  child: Row(
                    mainAxisAlignment: isLastRowWithOneItem
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
                        child: CommunityCardWidget(
                          communityItemModel: communityItemList[firstItemIndex],
                          additionalInfo: getCreatorInfo(communityItemList[firstItemIndex]),
                        ),
                      ),
                      if (secondItemIndex < communityItemList.length)
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
                          child: CommunityCardWidget(
                            communityItemModel: communityItemList[secondItemIndex],
                            additionalInfo: getCreatorInfo(communityItemList[secondItemIndex]),
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
