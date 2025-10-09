import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../models/index.dart';
import '../../../../../../respositories/index.dart';
import '../../../../../../services/index.dart';
import '../../../../../../util/index.dart';
import '../../../../../widgets/index.dart';
import '../../models/composite_search_model.dart';
import '../../models/people_search_model.dart';
import '../../repository/search_repository.dart';
import '../skeleton/network_search_skeleton.dart';
import '../../utils/search_helper.dart';

class NetworkSearch extends StatefulWidget {
  final String searchText;
  final bool showAll;
  final VoidCallback callBackOnEmptyResult;
  final VoidCallback? changeSelectedCategory;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? sortBy;
  final Function(List<Facet>) callBackWithFacet;
  final Function(TelemetryDataModel)? onTelemetryCallBack;
  final SearchRepository searchRepository;

  NetworkSearch(
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
  State<NetworkSearch> createState() => NetworkSearchState();
}

class NetworkSearchState extends State<NetworkSearch> {
  Future<PeopleSearchModel>? futurePeopleData;
  int pageNo = 0;
  bool isLoading = true;
  List<dynamic> _requestedConnections = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(NetworkSearch oldWidget) {
    if (SearchHelper.hasFilterChanged(
            oldFilter: oldWidget.filters, newFilter: widget.filters) ||
        widget.searchText != oldWidget.searchText ||
        SearchHelper.hasSortByChanged(
            oldSortBy: oldWidget.sortBy, newSortBy: widget.sortBy)) {
      futurePeopleData = null;
      pageNo = 0;
      setState(() {
        isLoading = true;
      });
      fetchData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futurePeopleData,
        builder: (context, snapshot) {
          if (snapshot.hasData || !isLoading) {
            if (snapshot.data != null) {
              List<Suggestion> networkList = snapshot.data!.people;
              return networkList.isNotEmpty
                  ? !widget.showAll
                      ? Container(
                          height: 0.68.sh,
                          padding: EdgeInsets.zero,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo.metrics.pixels ==
                                  scrollInfo.metrics.maxScrollExtent) {
                                if (!isLoading && !widget.showAll) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  loadMore();
                                }
                              }
                              return true;
                            },
                            child: SingleChildScrollView(
                              physics: widget.showAll
                                  ? NeverScrollableScrollPhysics()
                                  : ClampingScrollPhysics(),
                              child: Padding(
                                  padding: EdgeInsets.only(
                                          bottom: widget.showAll ? 0 : 100)
                                      .r,
                                  child: ContentWidget(
                                      context, snapshot, networkList)),
                            ),
                          ),
                        )
                      : ContentWidget(context, snapshot, networkList)
                  : SizedBox();
            } else {
              return SizedBox();
            }
          } else {
            return NetworkSearchSkeleton();
          }
        });
  }

  Column ContentWidget(BuildContext context,
      AsyncSnapshot<PeopleSearchModel> snapshot, List<Suggestion> networkList) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 16, left: 16).r,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${AppLocalizations.of(context)!.mStaticPeople} (${snapshot.data!.count})',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: AppColors.blackLegend)),
              networkList.length > SHOW3 && widget.showAll
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
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: networkList.length > SHOW2 && widget.showAll
              ? (SHOW2 / 2).ceil()
              : (networkList.length / 2).ceil(),
          itemBuilder: (context, index) {
            int firstItemIndex = index * 2;
            int secondItemIndex = firstItemIndex + 1;
            bool isLastRowWithOneItem = secondItemIndex >=
                (networkList.length > SHOW2 && widget.showAll
                    ? SHOW2
                    : networkList.length);

            return Container(
              child: Row(
                mainAxisAlignment: isLastRowWithOneItem
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 8, top: 8, bottom: 8).r,
                    child: PeopleNetworkItem(
                        suggestion: networkList[firstItemIndex],
                        parentAction1: _createConnectionRequest,
                        parentAction2: _generateInteractTelemetryData,
                        requestedConnections: _requestedConnections,
                        cardWidth: 0.42.sw,
                        doCallTelemetry: () {
                          widget.onTelemetryCallBack!(TelemetryDataModel(
                              id: networkList[firstItemIndex].id,
                              clickId:
                                  '${TelemetryClickId.searchCard}-${firstItemIndex + 1}',
                              subType: TelemetrySubType.learnSearch,
                              pageId: TelemetryPageIdentifier
                                  .globalSearchCardPageId,
                              objectType: TelemetryObjectType.people));
                        },
                        updateViewCallBack: (connected) async {
                          if (connected) {
                            await _getRequestedConnections();
                          }
                        }
                    ),
                  ),
                  if (secondItemIndex < networkList.length)
                    Container(
                        margin: EdgeInsets.only(right: 8, top: 8, bottom: 8).r,
                        child: PeopleNetworkItem(
                            suggestion: networkList[secondItemIndex],
                            parentAction1: _createConnectionRequest,
                            parentAction2: _generateInteractTelemetryData,
                            requestedConnections: _requestedConnections,
                            cardWidth: 0.42.sw,
                            doCallTelemetry: () {
                              widget.onTelemetryCallBack!(TelemetryDataModel(
                                  id: networkList[secondItemIndex].id,
                                  clickId:
                                      '${TelemetryClickId.searchCard}-${secondItemIndex + 1}',
                                  subType: TelemetrySubType.learnSearch,
                                  pageId: TelemetryPageIdentifier
                                      .globalSearchCardPageId,
                                  objectType: TelemetryObjectType.people));
                            },
                            updateViewCallBack: (connected) async {
                              if (connected) {
                                await _getRequestedConnections();
                              }
                            }
                        )
                    )
                ],
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
    );
  }

  Future<void> fetchData({int offset = 0}) async {
    PeopleSearchModel? peopleData = await getUsersByText(offset);
    setState(() {
      isLoading = false;
      checkIsEmpty(peopleData == null ? [] : peopleData.people);
      futurePeopleData = Future.value(peopleData);
    });
  }

  Future<PeopleSearchModel?> getUsersByText(int offset) async {
    PeopleSearchModel? peopleData = await futurePeopleData;
    PeopleSearchModel? newPeopleData;
    newPeopleData = await widget.searchRepository.peopleSearch(
        query: widget.searchText,
        facets: [SearchFilterFacet.designation, SearchFilterFacet.organization],
        filters: widget.filters,
        offset: offset,
        sortBy: widget.sortBy ?? {});
    if (peopleData != null &&
        newPeopleData != null &&
        newPeopleData.people.isNotEmpty) {
      peopleData.people.addAll(newPeopleData.people);
    } else {
      peopleData = newPeopleData;
    }
    if (peopleData != null &&
        peopleData.facets.isNotEmpty &&
        peopleData.people.isNotEmpty) {
      Future.delayed(
          Duration.zero, () => widget.callBackWithFacet(peopleData!.facets));
    }
    return peopleData;
  }

  void checkIsEmpty(List<Suggestion> people) {
    if (people.isEmpty) {
      Future.delayed(Duration.zero, () {
        widget.callBackOnEmptyResult();
      });
    }
  }

  Future<void> _createConnectionRequest(id) async {
    var _response;
    try {
      List<Profile> profileDetailsFrom;
      profileDetailsFrom =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getProfileDetailsById('');
      List<Profile> profileDetailsTo;
      profileDetailsTo =
          await Provider.of<ProfileRepository>(context, listen: false)
              .getProfileDetailsById(id);
      _response = await NetworkService.postConnectionRequest(
          id, profileDetailsFrom, profileDetailsTo);

      if (_response['result']['status'] == 'CREATED') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.mStaticConnectionRequestSent),
            backgroundColor: AppColors.positiveLight,
          ),
        );
        await _getRequestedConnections();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.mStaticErrorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      setState(() {});
    } catch (err) {
      print(err);
    }
  }

  _getRequestedConnections() async {
    final response =
        await Provider.of<NetworkRespository>(context, listen: false)
            .getRequestedConnections();
    setState(() {
      _requestedConnections = response;
    });
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '',
      String? primaryCategory,
      bool isObjectNull = false,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: TelemetrySubType.userCard,
        env: TelemetryEnv.home,
        objectType: primaryCategory != null
            ? primaryCategory
            : TelemetrySubType.userCard,
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<void> loadMore() async {
    PeopleSearchModel? peopleData = await futurePeopleData;
    if (peopleData != null) {
      if (peopleData.people.length < peopleData.count) {
        pageNo = pageNo + 1;
        await fetchData(offset: pageNo);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
