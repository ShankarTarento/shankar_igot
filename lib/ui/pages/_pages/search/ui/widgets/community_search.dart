import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../models/index.dart';
import '../../../../../widgets/_discussion_hub/repositories/discussion_repository.dart';
import '../../../../../widgets/_discussion_hub/screens/community_view/_models/community_model.dart';
import '../../../../../widgets/_discussion_hub/screens/community_view/_widgets/community_card_widget.dart';
import '../../models/community_search_model.dart';
import '../../models/composite_search_model.dart';
import '../skeleton/community_search_skeleton.dart';
import '../../utils/search_helper.dart';

class CommunitySearch extends StatefulWidget {
  final String searchText;
  final bool showAll;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? sortBy;
  final VoidCallback? changeSelectedCategory;
  final VoidCallback callBackOnEmptyResult;
  final Function(List<Facet>) callBackWithFacet;
  final Function(TelemetryDataModel)? onTelemetryCallBack;
  final DiscussionRepository discussionRepository;
  CommunitySearch(
      {super.key,
      required this.searchText,
      this.showAll = true,
      this.filters,
      this.sortBy,
      this.changeSelectedCategory,
      required this.callBackOnEmptyResult,
      required this.callBackWithFacet,
      this.onTelemetryCallBack,
      DiscussionRepository? discussionRepository})
      : discussionRepository = discussionRepository ?? DiscussionRepository();
  @override
  State<CommunitySearch> createState() => CommunitySearchState();
}

class CommunitySearchState extends State<CommunitySearch> {
  Future<CommunitySearchModel?>? futureCommunityList;
  CommunitySearchModel? communityResponseData;
  bool isLoading = false;
  int pageNo = 1;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(CommunitySearch oldWidget) {
    if (SearchHelper.hasFilterChanged(
            oldFilter: oldWidget.filters, newFilter: widget.filters) ||
        widget.searchText != oldWidget.searchText ||
        SearchHelper.hasSortByChanged(
            oldSortBy: oldWidget.sortBy, newSortBy: widget.sortBy)) {
      pageNo = 1;
      futureCommunityList = null;
      communityResponseData = null;
      fetchData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (!isLoading) {
            loadMore();
          }
        }
        return true;
      },
      child: FutureBuilder(
          future: futureCommunityList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                CommunitySearchModel communityData = snapshot.data!;
                List<CommunityItemData> communityItemList =
                    communityData.community;
                return communityItemList.isNotEmpty
                    ? !widget.showAll
                        ? Container(
                            height: 0.85.sh,
                            padding: EdgeInsets.zero,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
                                  if (!isLoading) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    loadMore();
                                  }
                                }
                                return true;
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                        bottom: widget.showAll ? 0 : 100)
                                    .r,
                                child: ContentWidget(context, communityItemList,
                                    communityData.count),
                              ),
                            ),
                          )
                        : ContentWidget(
                            context, communityItemList, communityData.count)
                    : SizedBox();
              } else {
                return SizedBox();
              }
            } else {
              return CommunitySearchSkeleton();
            }
          }),
    );
  }

  Column ContentWidget(BuildContext context,
      List<CommunityItemData> communityItemList, int count) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16).r,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${AppLocalizations.of(context)!.mSearchCommunities} (${count})',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: AppColors.blackLegend)),
              communityItemList.length > SHOW2 && widget.showAll
                  ? InkWell(
                      onTap: () => widget.changeSelectedCategory!(),
                      child: Row(
                        children: [
                          Text(
                              AppLocalizations.of(context)!
                                  .mSearchShowAllResults,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            color: AppColors.darkBlue,
                            size: 10.sp,
                          )
                        ],
                      ),
                    )
                  : Center()
            ],
          ),
        ),
        SizedBox(height: 8.w),
        widget.showAll
            ? ContentListView(communityItemList)
            : Expanded(child: ContentListView(communityItemList))
      ],
    );
  }

  ListView ContentListView(List<CommunityItemData> communityItemList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: widget.showAll
          ? NeverScrollableScrollPhysics()
          : ClampingScrollPhysics(),
      itemCount: communityItemList.length > SHOW2 && widget.showAll
          ? (SHOW2 / 2).ceil()
          : (communityItemList.length / 2).ceil(),
      itemBuilder: (context, index) {
        int firstItemIndex = index * 2;
        int secondItemIndex = firstItemIndex + 1;
        bool isLastRowWithOneItem = secondItemIndex >=
            (communityItemList.length > SHOW2 && widget.showAll
                ? SHOW2
                : communityItemList.length);

        return Padding(
          padding: EdgeInsets.only(
              bottom: (communityItemList.length / 2).ceil() - 1 == index
                  ? 200.w
                  : 0),
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
                  doCallTelemetry: () {
                    widget.onTelemetryCallBack!(TelemetryDataModel(
                        id: communityItemList[firstItemIndex].communityId ?? '',
                        clickId:
                            '${TelemetryClickId.searchCard}-${firstItemIndex + 1}',
                        subType: TelemetrySubType.learnSearch,
                        pageId: TelemetryPageIdentifier.globalSearchCardPageId,
                        objectType: TelemetryObjectType.community));
                  },
                ),
              ),
              if (secondItemIndex < communityItemList.length)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8).r,
                  child: CommunityCardWidget(
                      communityItemModel: communityItemList[secondItemIndex],
                      additionalInfo: getCreatorInfo(
                          communityResponseData?.additionalInfo ?? [],
                          communityItemList[secondItemIndex].orgId ?? ''),
                      doCallTelemetry: () {
                        widget.onTelemetryCallBack!(TelemetryDataModel(
                            id: communityItemList[secondItemIndex]
                                    .communityId ??
                                '',
                            clickId:
                                '${TelemetryClickId.searchCard}-${secondItemIndex + 1}',
                            subType: TelemetrySubType.learnSearch,
                            pageId:
                                TelemetryPageIdentifier.globalSearchCardPageId,
                            objectType: TelemetryObjectType.community));
                      }),
                )
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchData() async {
    // Get events based on search keyword
    futureCommunityList = Future.value(await getCommunities());
    if (mounted) {
      setState(() {});
    }
  }

  Future<CommunitySearchModel?>? getCommunities() async {
    try {
      isLoading = true;
      CommunitySearchModel? response = await getCommunityData(
          pageNo: pageNo,
          facets: [
            SearchFilterFacet.competencyArea,
            SearchFilterFacet.competencyTheme,
            SearchFilterFacet.competencySubTheme,
            SearchFilterFacet.topicName,
            SearchFilterFacet.orgName
          ],
          filters: widget.filters);
      if (pageNo == 1) {
        if (response != null) {
          communityResponseData = response;
        }
      } else {
        List<CommunityItemData>? discussionList =
            communityResponseData?.community ?? [];
        List<AdditionalInfo> additionalInfo =
            communityResponseData?.additionalInfo ?? [];
        if ((response?.additionalInfo ?? []).isNotEmpty)
          additionalInfo.addAll(response?.additionalInfo ?? []);
        if (response != null) {
          discussionList.addAll(response.community);
          CommunitySearchModel discussionModel = CommunitySearchModel(
              community: discussionList,
              facets: response.facets,
              count: response.count,
              additionalInfo: additionalInfo);
          communityResponseData = discussionModel;
        }
      }
      if (communityResponseData != null &&
          communityResponseData!.facets.isNotEmpty &&
          communityResponseData!.community.isNotEmpty) {
        Future.delayed(Duration.zero,
            () => widget.callBackWithFacet(communityResponseData!.facets));
      }
      if (communityResponseData != null) {
        isLoading = false;
        if (communityResponseData!.community.isEmpty) {
          doCallback();
        }
        return communityResponseData;
      } else {
        doCallback();
        isLoading = false;
        return null;
      }
    } catch (err) {
      doCallback();
      isLoading = false;
      return null;
    }
  }

  void doCallback() {
    Future.delayed(Duration.zero, () {
      widget.callBackOnEmptyResult();
    });
  }

  loadMore() {
    if (communityResponseData != null) {
      if ((communityResponseData?.community ?? []).length <
          (communityResponseData?.count ?? 0)) {
        setState(() {
          pageNo = pageNo + 1;
          fetchData();
        });
      }
    }
  }

  AdditionalInfo? getCreatorInfo(List<AdditionalInfo> list, String orgId) {
    return list.isNotEmpty
        ? list.firstWhere((info) => (info.id ?? '').toString() == orgId)
        : null;
  }

  Future<CommunitySearchModel?> getCommunityData(
      {required int pageNo,
      Map<String, dynamic>? filters,
      required List<String> facets}) async {
    // Fetch search data
    CommunitySearchModel? result = await widget.discussionRepository
        .searchCommunity(
            pageNumber: pageNo,
            pageSize: 100,
            searchQuery: widget.searchText,
            facets: facets,
            filters: filters,
            sortBy: widget.sortBy ?? {});

    return result;
  }
}
