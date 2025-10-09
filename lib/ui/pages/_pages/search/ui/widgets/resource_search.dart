import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:igot_ui_components/constants/color_constants.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../models/_models/gyaan_karmayogi_resource_details.dart';
import '../../../../../../models/index.dart';
import '../../../../../../util/faderoute.dart';
import '../../../../../widgets/_home/course_card_banner.dart';
import '../../../../../widgets/index.dart';
import '../../../gyaan_karmayogi_v2/pages/details_screen/details_screen.dart';
import '../../../gyaan_karmayogi_v2/services/gyaan_karma_yogi_helper.dart';
import '../../models/composite_search_model.dart';
import '../../models/resource_search_model.dart';
import '../../repository/search_repository.dart';
import '../../utils/search_helper.dart';
import '../skeleton/course_search_skeleton.dart';
import '../view_model/resource_search_view_model.dart';

class ResourceSearch extends StatefulWidget {
  final String searchText;
  final bool showAll;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? sortBy;
  final VoidCallback? changeSelectedCategory;
  final VoidCallback callBackOnEmptyResult;
  final Function(List<Facet>) callBackWithFacet;
  final Function(TelemetryDataModel)? onTelemetryCallBack;
  final SearchRepository searchRepository;

  ResourceSearch(
      {super.key,
      required this.searchText,
      this.showAll = true,
      this.filters,
      this.sortBy,
      this.changeSelectedCategory,
      required this.callBackOnEmptyResult,
      required this.callBackWithFacet,
      this.onTelemetryCallBack,
      SearchRepository? searchRepository})
      : searchRepository = searchRepository ?? SearchRepository();

  @override
  State<ResourceSearch> createState() => _ResourceSearchState();
}

class _ResourceSearchState extends State<ResourceSearch> {
  Future<ResourceSearchModel?>? futureResourceList;
  bool isLoading = true;
  int pageNo = 0;
  int resourceCount = 0;
  List<Facet> initialFacet = [];
  bool isUpdateData = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(covariant ResourceSearch oldWidget) {
    if (SearchHelper.hasFilterChanged(
            oldFilter: oldWidget.filters, newFilter: widget.filters) ||
        widget.searchText != oldWidget.searchText ||
        SearchHelper.hasSortByChanged(
            oldSortBy: oldWidget.sortBy, newSortBy: widget.sortBy)) {
      futureResourceList = null;
      pageNo = 0;
      resourceCount = 0;
      setState(() {
        isLoading = true;
        isUpdateData = true;
      });
      fetchData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureResourceList,
        builder: (context, snapshot) {
          if (snapshot.hasData && !isUpdateData) {
            if (snapshot.data != null && snapshot.data!.resource.isNotEmpty) {
              List<ResourceDetails> resourceList = snapshot.data!.resource;
              return !widget.showAll
                  ? Container(
                      height: 0.68.sh,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                            if (!isLoading && !widget.showAll) {
                              isLoading = true;
                              loadMore();
                            }
                          }
                          return true;
                        },
                        child: SingleChildScrollView(
                          physics: widget.showAll
                              ? NeverScrollableScrollPhysics()
                              : ClampingScrollPhysics(),
                          child: ContentWidget(context, snapshot, resourceList),
                        ),
                      ),
                    )
                  : ContentWidget(context, snapshot, resourceList);
            } else {
              return SizedBox();
            }
          } else {
            return CourseSearchSkeleton();
          }
        });
  }

  Padding ContentWidget(
      BuildContext context,
      AsyncSnapshot<ResourceSearchModel?> snapshot,
      List<ResourceDetails> resourceList) {
    return Padding(
      padding:
          EdgeInsets.only(left: 16, right: 16, bottom: widget.showAll ? 0 : 100)
              .r,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${AppLocalizations.of(context)!.mSearchResources} (${snapshot.data!.count})',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: AppColors.blackLegend)),
              resourceList.length > SHOW4 && widget.showAll
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
          SizedBox(height: 8.w),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: (widget.showAll && resourceList.length > SHOW3)
                ? SHOW3
                : resourceList.length,
            itemBuilder: (context, index) {
              ResourceDetails resource = resourceList[index];
              return InkWell(
                onTap: () {
                  if (resource.identifier != null) {
                    widget.onTelemetryCallBack!(TelemetryDataModel(
                        id: resource.identifier!,
                        clickId: '${TelemetryClickId.searchCard}-${index + 1}',
                        subType: TelemetrySubType.learnSearch,
                        pageId: TelemetryPageIdentifier.globalSearchCardPageId,
                        objectType: resource.resourceCategory));
                    Navigator.push(
                        context,
                        FadeRoute(
                            page: ResourceDetailsScreenV2(
                          resourceId: resource.identifier!,
                        )));
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 16).r,
                  padding: EdgeInsets.all(16).r,
                  decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      borderRadius: BorderRadius.circular(16).r),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(children: [
                          SizedBox(
                            width: 0.3.sw,
                            height: 75.w,
                            child: CourseCardBanner(
                                appIcon: resource.appIcon ?? '',
                                creatorIcon: '',
                                duration: resource.duration,
                                language: resource.language != null &&
                                        resource.language!.isNotEmpty
                                    ? resource.language!.first
                                    : '',
                                bottomRadius: 12,
                                createdOn: resource.createdOn),
                          )
                        ]),
                        Container(
                          width: 0.53.sw,
                          padding: EdgeInsets.only(left: 16).r,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              resource.mimeType != null
                                  ? Container(
                                      padding: EdgeInsets.all(4).r,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16).r,
                                          color: AppColors.darkBlue),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            color: AppColors.darkBlue,
                                            child: GyaanKarmaYogiHelper()
                                                .checkContentTypeIcon(
                                                    mimeType:
                                                        resource.mimeType!),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                    left: 6, right: 6)
                                                .r,
                                            child: Text(
                                              GyaanKarmaYogiHelper()
                                                  .checkContentType(
                                                      mimeType:
                                                          resource.mimeType!),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                      fontSize: 12.sp,
                                                      color: AppColors
                                                          .appBarBackground),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Center(),
                              SizedBox(height: 8.w),
                              Text(
                                resource.name ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                              SizedBox(height: 8.w),
                              Text(
                                resource.description ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(color: AppColors.greys60),
                              ),
                              SizedBox(height: 8.w),
                              resource.source != null
                                  ? Row(
                                      children: [
                                        Container(
                                          height: 24.w,
                                          width: 24.w,
                                          padding: const EdgeInsets.all(3).r,
                                          margin:
                                              const EdgeInsets.only(right: 8).r,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: ModuleColors.black16),
                                          ),
                                          child: Image.asset(
                                            "assets/img/igot_creator_icon.png",
                                            package: "igot_ui_components",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 0.4.sw,
                                          child: Text(
                                            'By ' + resource.source!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .copyWith(
                                                    color: AppColors.greys60),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Center()
                            ],
                          ),
                        )
                      ]),
                ),
              );
            },
          ),
          isLoading && !widget.showAll
              ? Container(
                  height: 40,
                  width: 80,
                  margin: EdgeInsets.symmetric(vertical: 16).r,
                  child: PageLoader())
              : SizedBox()
        ],
      ),
    );
  }

  Future<void> fetchData() async {
    ResourceSearchModel? existingData = await futureResourceList;
    ResourceSearchModel? resourceData = await ResourceSearchViewModel()
        .getResourceData(
            facets: [
          SearchFilterFacet.resourceCategory,
          SearchFilterFacet.sector,
          SearchFilterFacet.subSector,
          SearchFilterFacet.years,
          SearchFilterFacet.contextStateOrUTs,
          SearchFilterFacet.contextSDGs
        ],
            sortBy: widget.sortBy,
            filters: widget.filters,
            limit: 100,
            pageNo: pageNo,
            searchText: widget.searchText);
    if (resourceData != null) {
      if (existingData != null && resourceData.resource.isNotEmpty) {
        existingData.resource.addAll(resourceData.resource);
      } else {
        if (resourceData.facets.isNotEmpty) {
          updateFilter(resourceData);
        }
        existingData = resourceData;
      }
    }
    if (resourceData != null &&
        resourceData.facets.isNotEmpty &&
        resourceData.resource.isNotEmpty) {
      Future.delayed(
          Duration.zero, () => widget.callBackWithFacet(resourceData.facets));
    }
    futureResourceList = Future.value(existingData);
    setState(() {
      isUpdateData = false;
      isLoading = false;
      checkIsEmpty(resourceData != null ? resourceData.resource : []);
    });
  }

  void checkIsEmpty(List<ResourceDetails> resources) {
    if (resources.isEmpty) {
      Future.delayed(Duration.zero, () {
        widget.callBackOnEmptyResult();
      });
    }
  }

  void updateFilter(ResourceSearchModel data) {
    data.facets.removeWhere((facet) => facet.values.isEmpty);
  }

  Future<void> loadMore() async {
    ResourceSearchModel? resourceData = await futureResourceList;
    if (resourceData != null) {
      if (resourceData.resource.length < (resourceData.count)) {
        setState(() {
          pageNo = pageNo + 1;
          fetchData();
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}
