import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_list_view.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_item_carousel_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_item_carousel_widget_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/popular_community_widget.dart';
import '../../../../../../util/faderoute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommunityDiscover extends StatefulWidget {
  final List<TopicFacet> communityTopics;

  CommunityDiscover({Key? key, required this.communityTopics}) : super(key: key);
  CommunityDiscoverState createState() => CommunityDiscoverState();
}

class CommunityDiscoverState extends State<CommunityDiscover> with TickerProviderStateMixin {

  Future<List<TopicFacet>?>? _communityFuture;
  List<TopicFacet> _communityTopics = [];
  final int _stripPageCount = 3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCommunity();
  }

  Future<void> _loadCommunity() async {
    _communityFuture = _getCommunity();
  }

  Future<List<TopicFacet>?> _getCommunity() async {
    try {
      _isLoading = true;
      if (widget.communityTopics.isNotEmpty) {
        int startIndex = _communityTopics.length;
        int endIndex = startIndex + _stripPageCount;
        if (startIndex < widget.communityTopics.length) {
          List<TopicFacet> newTopics = widget.communityTopics.sublist(
            startIndex,
            endIndex > widget.communityTopics.length ? widget.communityTopics.length : endIndex,
          );
          _communityTopics.addAll(newTopics);
        }
        _isLoading = false;
        return Future.value(_communityTopics);
      } else {
        _isLoading = false;
        return [];
      }
    } catch (err) {
      _isLoading = false;
      return [];
    }
  }

  void _loadMore() {
    if (_isLoading || _communityTopics.length >= widget.communityTopics.length) return;
    setState(() {
      _loadCommunity();
    });
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 8).r,
        child: AnimationLimiter(
          child: Column(
            children: [
              PopularCommunityWidget(),
              _buildCommunityListView(),
              if (!_isLoading && widget.communityTopics.length > _communityTopics.length)
                _loadMoreWidget(),
            ],
          ),
        )
    );
  }

  Widget _buildCommunityListView() {
    return FutureBuilder(
      future: _communityFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return (_isLoading)
              ? CommunityItemCarouselWidgetSkeleton() : Container();
        }
        return Wrap(
          alignment: WrapAlignment.start,
          children: [
            (_communityTopics.isNotEmpty)
              ? Container(
                width: double.maxFinite,
                child: AnimationLimiter(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: _communityTopics.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                              child: _communityListView(
                                _communityTopics[index],
                              )
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
              : Container(
              child: NoDataWidget(
                    message: AppLocalizations.of(context)!.mDiscussionNoCommunityComingSoon),
              ),
            if (_isLoading)
              CommunityItemCarouselWidgetSkeleton(),
            if (!_isLoading && _communityTopics.isEmpty)
              SizedBox.shrink()
          ],
        );
      },
    );
  }

  Widget _communityListView(TopicFacet communityTopic) {
    return ((communityTopic.count??0) > 0)
        ? CommunityItemCarouselWidget(
            topicFacet: communityTopic,
            onClickShowAll: ((communityTopic.count??0) > 2)
                ? () {
                    Navigator.push(
                        context,
                        FadeRoute(
                            page: CommunityListView(
                              title: communityTopic.value,
                              topicName: communityTopic.value,
                            )));
                  }
                : null,
          )
        : SizedBox.shrink();
  }

  Widget _loadMoreWidget() {
    return GestureDetector(
      onTap: () {
        _loadMore();
      },
      child: Container(
        width: double.maxFinite,
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16).r,
        padding: EdgeInsets.symmetric(vertical: 16).r,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.darkBlue),
          borderRadius: BorderRadius.all(const Radius.circular(50.0).r),
        ),
        child: Text(
          AppLocalizations.of(context)!.mStaticLoadMore,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w400,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
