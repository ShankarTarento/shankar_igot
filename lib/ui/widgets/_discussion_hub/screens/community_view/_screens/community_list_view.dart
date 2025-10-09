import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/no_data_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/search/models/composite_search_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/search/ui/pages/search_filter_page.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/search/utils/search_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/helper/discussion_const.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/repositories/discussion_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_card_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_filter_button_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/community_list_skeleton.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../pages/_pages/search/models/community_search_model.dart';

class CommunityListView extends StatefulWidget {
  final String? title;
  final String? searchQuery;
  final bool? isSearch;
  final bool? isFilter;
  final String? topicName;
  final String orderBy;
  final String orderDirection;

  CommunityListView(
      {Key? key,
      this.title,
      this.searchQuery,
      this.isSearch,
      this.isFilter,
      this.topicName,
      this.orderBy = '',
      this.orderDirection = ''})
      : super(key: key);
  CommunityListViewState createState() => CommunityListViewState();
}

class CommunityListViewState extends State<CommunityListView>
    with TickerProviderStateMixin {
  Future<CommunitySearchModel?>? _communityFuture;
  CommunitySearchModel? communityResponseData;
  bool _isLoading = false;
  int pageNo = 1;
  final _textController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _previousSearchText = '';
  final ValueNotifier<bool>? isFiltered = ValueNotifier(true);
  Map<String, dynamic>? filters;
  List<Facet> facets = [];
  bool _openFilter = false;

  @override
  void initState() {
    super.initState();
    _initSearchData();
    _loadCommunity();
  }

  void _initSearchData() {
    if (widget.isSearch ?? false) {
      if ((widget.searchQuery ?? '') != '') {
        _textController.text = widget.searchQuery ?? '';
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Future.delayed(Duration(milliseconds: 300), () {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        });
      });
    }
    _openFilter = widget.isFilter ?? false;
    _textController.addListener(_filterCommunities);
  }

  _filterCommunities() {
    if (_searchFocusNode.hasFocus &&
        _textController.text != _previousSearchText) {
      setState(() {
        _previousSearchText = _textController.text;
        if (_textController.text.length > SEARCH_START_LIMIT ||
            _textController.text.isEmpty) {
          pageNo = 1;
          _loadCommunity(searchQuery: _textController.text);
        }
      });
    }
  }

  Future<void> _loadCommunity({String? searchQuery}) async {
    _communityFuture = _getCommunity(context, searchQuery ?? '');
  }

  Future<CommunitySearchModel?> _getCommunity(
      context, String searchQuery) async {
    try {
      _isLoading = true;
      CommunitySearchModel? response =
          await Provider.of<DiscussionRepository>(context, listen: false)
              .searchCommunity(
                  pageNumber: pageNo,
                  searchQuery: searchQuery,
                  facets: [
                    SearchFilterFacet.competencyArea,
                    SearchFilterFacet.topicName,
                    SearchFilterFacet.orgName
                  ],
                  filters: filters,
                  topicName: widget.topicName,
                  orderBy: widget.orderBy,
                  orderDirection: widget.orderDirection);

      if (response != null) {
        if (pageNo == 1) {
          if (filters == null) {
            response = await updateFacetOnCompetency(
                community: response, pageNo: pageNo, searchQuery: searchQuery);
          }
          communityResponseData = response;
        } else {
          List<CommunityItemData>? discussionList =
              communityResponseData?.community ?? [];
          List<AdditionalInfo> additionalInfo =
              communityResponseData?.additionalInfo ?? [];
          if ((response.additionalInfo ?? []).isNotEmpty)
            additionalInfo.addAll(response.additionalInfo ?? []);
          discussionList.addAll(response.community);
          CommunitySearchModel discussionModel = CommunitySearchModel(
              community: discussionList,
              facets: response.facets,
              count: response.count,
              additionalInfo: additionalInfo);
          communityResponseData = discussionModel;
        }
        if (filters == null) {
          facets = communityResponseData?.facets ?? [];
        }
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

  _loadMore() {
    if (communityResponseData != null) {
      if ((communityResponseData?.community ?? []).length <
          (communityResponseData?.count ?? 0)) {
        setState(() {
          pageNo = pageNo + 1;
          _loadCommunity(searchQuery: _textController.text);
        });
      }
    }
  }

  AdditionalInfo? getCreatorInfo(List<AdditionalInfo> list, String orgId) {
    return list.isNotEmpty
        ? list.firstWhere((info) => (info.id ?? '').toString() == orgId)
        : null;
  }

  CommunitySearchModel updateFacetOnCompetency(
      {required CommunitySearchModel community,
      required int pageNo,
      required String searchQuery}) {
    if (widget.topicName != null)
      community.facets
          .removeWhere((facet) => facet.name == SearchFilterFacet.topicName);

    Facet? competencyAreaFacet = community.facets
        .where((facet) => facet.name == SearchFilterFacet.competencyArea)
        .firstOrNull;

    if (competencyAreaFacet == null) return community;

    // Extract values list
    List<Value> valuesList = competencyAreaFacet.values;
    valuesList.forEach((value) async {
      Map<String, dynamic> updatedFilter = {};
      updatedFilter[SearchFilterFacet.competencyArea] = [value.name];

      CommunitySearchModel? result =
          await Provider.of<DiscussionRepository>(context, listen: false)
              .searchCommunity(
                  pageNumber: pageNo,
                  pageSize: 100,
                  filters: updatedFilter,
                  searchQuery: searchQuery,
                  topicName: widget.topicName,
                  facets: [
            SearchFilterFacet.competencyArea,
            SearchFilterFacet.competencyTheme
          ]);

      if (result != null && result.facets.isNotEmpty) {
        Facet? updatedCompetencyThemeFacet = result.facets
            .where((facet) => facet.name == SearchFilterFacet.competencyTheme)
            .firstOrNull;
        if (updatedCompetencyThemeFacet != null) {
          value.subFacet = updatedCompetencyThemeFacet;
        }
      }
    });
    return community;
  }

  void _loadFilterView() {
    if (_openFilter) {
      _openFilter = false;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Future.delayed(Duration(milliseconds: 300), () {
          showFilterOptions();
        });
      });
    }
  }

  @override
  void dispose() async {
    super.dispose();
    _textController.dispose();
    _searchFocusNode.dispose();
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
              if (facets.isNotEmpty) {
                _loadFilterView();
              }
              return Wrap(
                alignment: WrapAlignment.start,
                children: [
                  _searchBarView(),
                  if ((communityResponseData?.community ?? []).isNotEmpty)
                    _buildCommunityListView(
                        communityResponseData?.community ?? []),
                  if (_isLoading)
                    CommunityListSkeleton(
                      itemCount: 10,
                    ),
                  if (!_isLoading &&
                      (communityResponseData?.community ?? []).isEmpty)
                    Container(
                      child: NoDataWidget(
                          message: AppLocalizations.of(context)!
                              .mDiscussionNoCommunityFound),
                    )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityListView(List<CommunityItemData> communityItemList) {
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
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
                    child: CommunityCardWidget(
                      communityItemModel: communityItemList[firstItemIndex],
                      additionalInfo: getCreatorInfo(
                          communityResponseData?.additionalInfo ?? [],
                          communityItemList[firstItemIndex].orgId ?? ''),
                    ),
                  ),
                  if (secondItemIndex < communityItemList.length)
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
                      child: CommunityCardWidget(
                        communityItemModel: communityItemList[secondItemIndex],
                        additionalInfo: getCreatorInfo(
                            communityResponseData?.additionalInfo ?? [],
                            communityItemList[secondItemIndex].orgId ?? ''),
                      ),
                    )
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16).w,
        child: Container(
          height: 40.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 0.8.sw,
                height: double.maxFinite,
                child: TextFormField(
                    controller: _textController,
                    focusNode: _searchFocusNode,
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
                        borderSide:
                            BorderSide(color: AppColors.appBarBackground),
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
                isFiltered: (filters != null && filters!.isNotEmpty),
                onTap: () async {
                  if (facets.isNotEmpty) {
                    await showFilterOptions();
                  }
                },
              ),
            ],
          ),
        ));
  }

  Future showFilterOptions() {
    BuildContext parentContext = context;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return SearchFilterPage(
            filters: facets,
            callBackWithFilter: (value) {
              setState(() {
                filters = value;
                pageNo = 1;
                _loadCommunity(searchQuery: _textController.text);
              });
            },
            callBackUpdate: (value) => facets = value,
            parentContext: parentContext);
      },
    );
  }
}
