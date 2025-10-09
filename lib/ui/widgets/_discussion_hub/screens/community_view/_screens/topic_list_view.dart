import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_topic_listing_card_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/topic_list_skeleton.dart';

class TopicListView extends StatefulWidget {
  final String? title;
  final List<TopicFacet>? communityTopicItemList;

  TopicListView({Key? key, this.title, this.communityTopicItemList})
      : super(key: key);
  TopicListViewState createState() => TopicListViewState();
}

class TopicListViewState extends State<TopicListView>
    with TickerProviderStateMixin {
  Future<List<TopicFacet>?>? _communityTopicFuture;
  List<TopicFacet> _communityTopicItemList = [];
  bool _isLoading = false;
  final _textController = TextEditingController();
  FocusNode _textFocusNode = FocusNode();
  String _previousSearchText = '';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_filterCommunities);
    _communityTopicFuture = _getCommunityTopics(context, '');
  }

  _filterCommunities() {
    if (_textFocusNode.hasFocus &&
        _textController.text != _previousSearchText) {
      setState(() {
        _previousSearchText = _textController.text;
        _communityTopicFuture =
            _getCommunityTopics(context, _textController.text);
      });
    }
  }

  Future<List<TopicFacet>> _getCommunityTopics(
      context, String searchQuery) async {
    try {
      _isLoading = true;
      if (widget.communityTopicItemList != null) {
        _communityTopicItemList =
            await widget.communityTopicItemList!.where((community) {
          if (searchQuery.isEmpty) {
            return true;
          } else {
            return community.value
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
          }
        }).toList();
        _isLoading = false;
        return Future.value(_communityTopicItemList);
      } else {
        _isLoading = false;
        return Future.value([]);
      }
    } catch (err) {
      _isLoading = false;
      return Future.value([]);
    }
  }

  @override
  void dispose() async {
    super.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: buildBody(),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: kToolbarHeight.w,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp, color: AppColors.greys60),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Wrap(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 16).w,
              child: Text(
                widget.title ?? '',
                style: GoogleFonts.lato(
                    color: AppColors.greys87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    letterSpacing: 0.12.w),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ));
  }

  Widget buildBody() {
    return SingleChildScrollView(
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
          _searchBarView(),
          FutureBuilder(
            future: _communityTopicFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return (_isLoading)
                    ? TopicListSkeleton(
                        itemCount: 10,
                        horizontalMargin: 0.w,
                      )
                    : Container();
              }
              return Wrap(
                alignment: WrapAlignment.start,
                children: [
                  if (_communityTopicItemList.isNotEmpty)
                    _buildTopicListView(_communityTopicItemList),
                  if (_isLoading)
                    TopicListSkeleton(
                      itemCount: 10,
                      horizontalMargin: 0.w,
                    ),
                  if (!_isLoading && (_communityTopicItemList).isEmpty)
                    Container(
                      child: NoDataWidget(
                          message: AppLocalizations.of(context)!
                              .mDiscussionNoCommunityTopicsFound),
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopicListView(List<TopicFacet> communityTopicItemList) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16).r,
      width: double.maxFinite,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: communityTopicItemList.length,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                    child: CommunityTopicListingCardWidget(
                  communityTopicItemData: communityTopicItemList[index],
                )),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _searchBarView() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).w,
        child: Container(
          height: 40.w,
          child: TextFormField(
              controller: _textController,
              focusNode: _textFocusNode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.lato(fontSize: 14.0.sp),
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
                hintText: AppLocalizations.of(context)!.mDiscussionSearchTopic,
                hintStyle: GoogleFonts.lato(
                    color: AppColors.greys60,
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w400),
                counterStyle: TextStyle(
                  height: double.minPositive,
                ),
                counterText: '',
              )),
        ));
  }
}
