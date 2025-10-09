import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_discover.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/community_list_view.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_screens/topic_list_view.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_filter_button_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_topics_carousel_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_item_carousel_widget_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_topics_carousel_widget_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/popular_community_widget_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:provider/provider.dart';

class CommunityExplore extends StatefulWidget {
  const CommunityExplore({Key? key}) : super(key: key);

  @override
  CommunityExploreState createState() => CommunityExploreState();
}

class CommunityExploreState extends State<CommunityExplore> {
  final _textController = TextEditingController();
  Future<CommunityModel?>? _categoryFuture;
  CommunityModel? categoryResponseData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategoryList();
  }

  Future<void> _loadCategoryList() async {
    _categoryFuture = _getCategoryList(context);
  }

  Future<CommunityModel?> _getCategoryList(context) async {
    try {
      _isLoading = true;
      CommunityModel? response =
          await Provider.of<DiscussionRepository>(context, listen: false)
              .getCommunity(
                  pageNumber: 1,
                  searchQuery: '',
                  pageSize: 1,
                  facets: ["topicName"]);
      if (response != null) {
        categoryResponseData = response;
        _isLoading = false;
        return Future.value(categoryResponseData);
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
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: buildLayout(),
    );
  }

  Widget buildLayout() {
    return FutureBuilder(
      future: _categoryFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return (_isLoading) ? communityViewSkeleton() : Container();
        } else {
          return communityExplore();
        }
      },
    );
  }

  Widget communityViewSkeleton() {
    return SingleChildScrollView(
        child: Container(
      child: Column(
        children: [
          CommunityTopicsCarouselWidgetSkeleton(),
          PopularCommunityWidgetSkeleton(),
          CommunityItemCarouselWidgetSkeleton(),
          CommunityItemCarouselWidgetSkeleton(),
          CommunityItemCarouselWidgetSkeleton(),
        ],
      ),
    ));
  }

  Widget communityExplore() {
    return Column(
      children: [
        _toolBarView(),
        if ((categoryResponseData?.facets?.topicName ?? []).isNotEmpty)
          _communityTopicListView(
              categoryResponseData?.facets?.topicName ?? []),
        CommunityDiscover(
          communityTopics: categoryResponseData?.facets?.topicName ?? [],
        ),
      ],
    );
  }

  Widget _toolBarView() {
    return Container(
      height: 40.w,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 0.8.sw,
            height: double.maxFinite,
            child: TextFormField(
                controller: _textController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                style: GoogleFonts.lato(fontSize: 14.0.sp),
                readOnly: true,
                onTap: () {
                  Navigator.push(
                      context,
                      FadeRoute(
                          page: CommunityListView(
                        title: AppLocalizations.of(context)!
                            .mDiscussionSearchCommunities,
                        isSearch: true,
                      )));
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.appBarBackground,
                  prefixIcon: Icon(
                    Icons.search,
                    size: 24.w,
                    color: AppColors.disabledGrey,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8).w,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100.w),
                    borderSide: BorderSide(
                      color: AppColors.appBarBackground,
                      width: 1.0.w,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100.w),
                    borderSide: BorderSide(color: AppColors.appBarBackground),
                  ),
                  hintText: AppLocalizations.of(context)!
                      .mDiscussionSearchCommunities,
                  hintStyle: GoogleFonts.lato(
                      color: AppColors.greys60,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w400),
                  counterStyle: TextStyle(
                    height: double.minPositive,
                  ),
                  counterText: '',
                )),
          ),
          CommunityFilterButtonWidget(
            width: 0.09.sw,
            height: double.maxFinite,
            borderRadius: BorderRadius.all(Radius.circular(4.w)),
            onTap: () {
              Navigator.push(
                  context,
                  FadeRoute(
                      page: CommunityListView(
                    title: AppLocalizations.of(context)!
                        .mDiscussionSearchCommunities,
                    isFilter: true,
                  )));
            },
          ),
        ],
      ),
    );
  }

  Widget _communityTopicListView(List<TopicFacet> communityTopics) {
    return Container(
      child: CommunityTopicsCarouselWidget(
        communityTopicList: communityTopics,
        heading:
            "${AppLocalizations.of(context)!.mDiscussionAllTopics} (${communityTopics.length})",
        onClickShowAll:
            (communityTopics.length > COMMUNITY_TOPIC_CARD_DISPLAY_LIMIT)
                ? () {
                    Navigator.push(
                        context,
                        FadeRoute(
                            page: TopicListView(
                                title:
                                    "${AppLocalizations.of(context)!.mDiscussionAllTopics}",
                                communityTopicItemList: communityTopics)));
                  }
                : null,
      ),
    );
  }
}
