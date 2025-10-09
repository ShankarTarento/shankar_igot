import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_member_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_list_skeleton.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_members_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CommunityMembers extends StatefulWidget {
  final String communityId;
  CommunityMembers({Key? key, required this.communityId}) : super(key: key);
  CommunityMembersState createState() => CommunityMembersState();
}

class CommunityMembersState extends State<CommunityMembers>
    with TickerProviderStateMixin {
  Future<CommunityMemberModel?>? _communityFuture;
  CommunityMemberModel? _communityMemberModel;
  bool _isLoading = false;
  int pageNo = 1;
  final _textController = TextEditingController();
  FocusNode _textFocusNode = FocusNode();
  String _previousSearchText = '';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_searchDiscussion);
    _loadCommunity();
  }

  _searchDiscussion() {
    if (_textFocusNode.hasFocus &&
        _textController.text != _previousSearchText) {
      setState(() {
        _previousSearchText = _textController.text;
        if (_textController.text.length > SEARCH_START_LIMIT ||
            _textController.text.isEmpty) {
          pageNo = 1;
          _communityMemberModel = null;
          _loadCommunity(searchQuery: _textController.text);
        }
      });
    }
  }

  Future<void> _loadCommunity({String? searchQuery}) async {
    _communityFuture = _getCommunityMembers(context, searchQuery ?? '');
  }

  Future<CommunityMemberModel?> _getCommunityMembers(
      context, String searchQuery) async {
    try {
      _isLoading = true;
      CommunityMemberModel? response;
      if (searchQuery.isEmpty) {
        response =
            await Provider.of<DiscussionRepository>(context, listen: false)
                .getCommunityMembers(
                    pageNumber: pageNo,
                    searchQuery: searchQuery,
                    communityId: widget.communityId);
      } else {
        response =
            await Provider.of<DiscussionRepository>(context, listen: false)
                .searchCommunityMembers(
                    pageNumber: pageNo,
                    searchQuery: searchQuery,
                    communityId: widget.communityId);
      }
      if (pageNo == 1) {
        if (response != null) {
          _communityMemberModel = response;
        }
      } else {
        List<MemberDetails>? memberList =
            _communityMemberModel?.userDetails ?? [];
        if (response != null) {
          memberList.addAll(response.userDetails ?? []);
          CommunityMemberModel discussionModel = CommunityMemberModel(
            totalCount: _communityMemberModel?.totalCount,
            userDetails: memberList,
          );
          _communityMemberModel = discussionModel;
        }
      }
      if (_communityMemberModel != null) {
        _isLoading = false;
        return Future.value(_communityMemberModel);
      } else {
        _isLoading = false;
        return null;
      }
    } catch (err) {
      _isLoading = false;
      return null;
    }
  }

  _loadMore() {
    if (_communityMemberModel != null) {
      if ((_communityMemberModel?.userDetails ?? []).length <
          (_communityMemberModel?.totalCount ?? 0)) {
        setState(() {
          pageNo = pageNo + 1;
          _loadCommunity(searchQuery: _textController.text);
        });
      }
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
    return SafeArea(child: buildBody());
  }

  Widget buildBody() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (!_isLoading) {
            _loadMore();
          }
        }
        return true;
      },
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: buildUI(),
      ),
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
            future: _communityFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return (_isLoading)
                    ? CommunityListSkeleton(
                        itemCount: 10,
                      )
                    : Container();
              }
              return Wrap(
                alignment: WrapAlignment.start,
                children: [
                  if ((_communityMemberModel?.userDetails ?? []).isNotEmpty)
                    _memberListView(_communityMemberModel?.userDetails ?? []),
                  if (_isLoading)
                    CommunityListSkeleton(
                      itemCount: 10,
                    ),
                  if (!_isLoading &&
                      (_communityMemberModel?.userDetails ?? []).isEmpty)
                    Container(
                      child: NoDataWidget(
                          message: AppLocalizations.of(context)!
                              .mDiscussionNoCommunityMemberFound),
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _memberListView(List<MemberDetails> communityItemList) {
    return AnimationLimiter(
      child: Container(
        margin: EdgeInsets.only(left: 16, right: 16).r,
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: (communityItemList.length / 2).ceil(),
          itemBuilder: (context, index) {
            int firstItemIndex = index * 2;
            int secondItemIndex = firstItemIndex + 1;
            bool isLastRowWithOneItem =
                secondItemIndex >= communityItemList.length;

            return Container(
              child: Row(
                mainAxisAlignment: isLastRowWithOneItem
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  CommunityMembersItem(
                    memberDetails: communityItemList[firstItemIndex],
                  ),
                  if (secondItemIndex < communityItemList.length)
                    CommunityMembersItem(
                      memberDetails: communityItemList[secondItemIndex],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _searchBarView() {
    return Container(
      height: 40.w,
      margin: const EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16).w,
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
            hintText: AppLocalizations.of(context)!.mCommonSearch,
            hintStyle: GoogleFonts.lato(
                color: AppColors.greys60,
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w400),
            counterStyle: TextStyle(
              height: double.minPositive,
            ),
            counterText: '',
          )),
    );
  }
}
