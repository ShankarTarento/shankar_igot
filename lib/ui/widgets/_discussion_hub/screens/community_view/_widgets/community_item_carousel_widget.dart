
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_card_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_item_carousel_widget_skeleton.dart';
import 'package:provider/provider.dart';

class CommunityItemCarouselWidget extends StatefulWidget {
  final TopicFacet topicFacet;
  final Function? onClickShowAll;

  CommunityItemCarouselWidget({Key? key, required this.topicFacet, this.onClickShowAll}) : super(key: key);
  CommunityItemCarouselWidgetState createState() => CommunityItemCarouselWidgetState();
}

class CommunityItemCarouselWidgetState extends State<CommunityItemCarouselWidget> {

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
      CommunityModel? response = await Provider.of<DiscussionRepository>(context, listen: false)
          .getCommunity(pageNumber: 1, pageSize: 3, topicName: widget.topicFacet.value??'');
      if (response != null) {
        communityResponseData = response;
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
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Container(
      margin: EdgeInsets.only(bottom: 16).w,
      child: FutureBuilder(
        future: _communityFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return (_isLoading)
                ? CommunityItemCarouselWidgetSkeleton()
                : Container();
          }
          return Wrap(
            alignment: WrapAlignment.start,
            children: [
              if ((communityResponseData?.data??[]).isNotEmpty)
                _communityListView(communityResponseData?.data??[]),
              if (_isLoading)
                CommunityItemCarouselWidgetSkeleton(),
              if (!_isLoading && (communityResponseData?.data??[]).isEmpty)
                Container(
                  child: NoDataWidget(
                      message: AppLocalizations.of(context)!.mDiscussionNoCommunityFound),
                )
            ],
          );
        },
      ),
    );
  }

  Widget _communityListView(List<CommunityItemData> communityItemList) {
    return Column(
      children: [
        if (widget.topicFacet.value != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 16).r,
            child: Row(
              children: [
                SizedBox(
                  width: (widget.onClickShowAll != null) ? 0.6.sw : 0.86.sw,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.topicFacet.value ?? '',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        ' (${widget.topicFacet.count ?? ''})',
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
                if (widget.onClickShowAll != null)
                  Spacer(),
                if (widget.onClickShowAll != null)
                  InkWell(
                      onTap: () {
                        widget.onClickShowAll!();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2.0).r,
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.mCommonShowAll,
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: AppColors.darkBlue,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp,
                                letterSpacing: 0.12,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.darkBlue,
                              size: 18.sp,
                            )
                          ],
                        ),
                      ))
              ],
            ),
          ),
        Container(
          height: 242.w,
          width: double.maxFinite,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: BouncingScrollPhysics(),
            itemCount: communityItemList.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 475),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: EdgeInsets.only(left: (index == 0) ? 16.w : 8.w, right: (index < (communityItemList.length - 1)) ? 0 : 16).w,
                      child: CommunityCardWidget(
                        communityItemModel: communityItemList[index],
                        additionalInfo: getCreatorInfo(communityResponseData?.additionalInfo??[],communityItemList[index].orgId??''),
                      ),
                    )
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  AdditionalInfo? getCreatorInfo(List<AdditionalInfo> list, String orgId) {
    return list.isNotEmpty
        ? list.firstWhere(
            (info) => (info.id ?? '').toString() == orgId
    )
        : null;
  }

}
