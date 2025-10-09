import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../models/index.dart';
import '../../../../../../util/index.dart';
import '../../models/composite_search_model.dart';
import '../../repository/search_repository.dart';
import '../../utils/search_helper.dart';
import '../widgets/community_search.dart';
import '../widgets/course_search.dart';
import '../widgets/events_search.dart';
import '../widgets/network_search.dart';
import '../widgets/resource_search.dart';

class SearchResultPage extends StatefulWidget {
  final String searchText;
  final bool showAll;
  final bool showPeople;
  final bool showEvent;
  final bool showContent;
  final bool showExternalContent;
  final bool showCommunity;
  final bool showResources;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? sortBy;
  final VoidCallback callBackOnContentEmptyResult;
  final VoidCallback callBackOnPeopleEmptyResult;
  final VoidCallback callBackOnEventsEmptyResult;
  final VoidCallback callBackOnCommunityEmptyResult;
  final VoidCallback callBackOnExternalContentEmptyResult;
  final VoidCallback callBackOnResourceEmptyResult;
  final SearchRepository searchRepository;
  final Function(List<Facet>) callBackWithFacet;
  final Function(String) changeSelectCategory;
  final List pills;

  SearchResultPage(
      {super.key,
      required this.searchText,
      this.showAll = true,
      this.showPeople = false,
      this.showEvent = false,
      this.showContent = false,
      this.showExternalContent = false,
      this.showCommunity = false,
      this.showResources = false,
      this.filters,
      this.sortBy,
      required this.callBackOnContentEmptyResult,
      required this.callBackOnPeopleEmptyResult,
      required this.callBackOnEventsEmptyResult,
      required this.callBackOnCommunityEmptyResult,
      required this.callBackOnExternalContentEmptyResult,
      SearchRepository? searchRepository,
      required this.callBackWithFacet,
      required this.changeSelectCategory,
      required this.callBackOnResourceEmptyResult,
      this.pills = const []})
      : searchRepository = searchRepository ?? SearchRepository();

  @override
  State<SearchResultPage> createState() => SearchResultPageState();
}

class SearchResultPageState extends State<SearchResultPage> {
  Future<String>? futureKeyword;
  final ScrollController scrollController = ScrollController();
  TelemetryRepository telemetryRepository = TelemetryRepository();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(SearchResultPage oldWidget) {
    if (oldWidget.showAll != widget.showAll) {
      scrollToTop();
    }
    if (oldWidget.searchText != widget.searchText) {
      fetchData();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: widget.showAll ? 16 : 0).r,
      height: 1.0.sh,
      child: FutureBuilder(
          future: futureKeyword,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                String keyword = snapshot.data!.isNotEmpty
                    ? snapshot.data!
                    : widget.searchText;
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.searchText.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(
                                        left: 16, right: 16, bottom: 16)
                                    .r,
                                child: RichText(
                                    text: TextSpan(
                                        text: AppLocalizations.of(context)!
                                            .mSearchResultFor,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                                height: 1.5.w,
                                                letterSpacing: 0.12,
                                                color: AppColors.greys60),
                                        children: [
                                      TextSpan(
                                          text: '“${widget.searchText}”',
                                          style: TextStyle(
                                              color: AppColors.darkBlue))
                                    ])),
                              )
                            : SizedBox(),
                        showResultView(keyword),
                        SizedBox(height: 250.w)
                      ]),
                );
              }
            } else {
              return Center();
            }
            return Center();
          }),
    );
  }

  Widget showResultView(String keyword) {
    if (widget.showAll) {
      return Column(children: [
        CourseSearch(
            searchText: keyword,
            callBackOnEmptyResult: widget.callBackOnContentEmptyResult,
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            changeSelectedCategory: () =>
                widget.changeSelectCategory(SearchCategories.content),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value),
            showExternalContent: false,
            showContent: true),
        SizedBox(height: 8.w),
        EventsSearch(
            searchText: keyword,
            callBackOnEmptyResult: widget.callBackOnEventsEmptyResult,
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            changeSelectedCategory: () =>
                widget.changeSelectCategory(SearchCategories.events),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value)),
        SizedBox(height: 8.w),
        NetworkSearch(
            searchText: keyword,
            callBackOnEmptyResult: widget.callBackOnPeopleEmptyResult,
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            changeSelectedCategory: () =>
                widget.changeSelectCategory(SearchCategories.people),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value)),
        SizedBox(height: 8.w),
        CourseSearch(
            searchText: keyword,
            callBackOnEmptyResult: widget.callBackOnExternalContentEmptyResult,
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            changeSelectedCategory: () =>
                widget.changeSelectCategory(SearchCategories.externalContent),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value),
            showExternalContent: true,
            showContent: false),
        SizedBox(height: 8.w),
        CommunitySearch(
            searchText: keyword,
            callBackOnEmptyResult: widget.callBackOnCommunityEmptyResult,
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            changeSelectedCategory: () =>
                widget.changeSelectCategory(SearchCategories.communities),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value)),
        SizedBox(height: 8.w),
        ResourceSearch(
            searchText: keyword,
            callBackOnEmptyResult: widget.callBackOnResourceEmptyResult,
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            changeSelectedCategory: () =>
                widget.changeSelectCategory(SearchCategories.resources),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value)),
        SizedBox(height: 250.w)
      ]);
    } else if (widget.showContent || widget.showExternalContent) {
      return Column(children: [
        CourseSearch(
            searchText: keyword,
            showContent: widget.showContent,
            showExternalContent: widget.showExternalContent,
            showAll: widget.showAll,
            filters: widget.filters,
            sortBy: widget.sortBy,
            callBackOnEmptyResult: () => widget.showContent
                ? widget.callBackOnContentEmptyResult()
                : widget.callBackOnExternalContentEmptyResult(),
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value)),
        SizedBox(height: 250.w)
      ]);
    } else if (widget.showPeople) {
      return Column(children: [
        NetworkSearch(
            searchText: keyword,
            callBackOnEmptyResult: widget.callBackOnPeopleEmptyResult,
            showAll: widget.showAll,
            filters: widget.filters,
            sortBy: widget.sortBy,
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value)),
        SizedBox(height: 250.w)
      ]);
    } else if (widget.showEvent) {
      return Column(children: [
        EventsSearch(
            searchText: keyword,
            showAll: widget.showAll,
            filters: widget.filters,
            sortBy: widget.sortBy,
            callBackOnEmptyResult: widget.callBackOnEventsEmptyResult,
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value)),
        SizedBox(height: 250.w)
      ]);
    } else if (widget.showCommunity) {
      return Column(children: [
        CommunitySearch(
            searchText: keyword,
            showAll: widget.showAll,
            filters: widget.filters,
            sortBy: widget.sortBy,
            callBackOnEmptyResult: widget.callBackOnCommunityEmptyResult,
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value)),
        SizedBox(height: 250.w)
      ]);
    } else if (widget.showResources) {
      return Column(children: [
        ResourceSearch(
            searchText: keyword,
            showAll: widget.showAll,
            filters: widget.filters,
            sortBy: widget.sortBy,
            callBackOnEmptyResult: widget.callBackOnResourceEmptyResult,
            callBackWithFacet: (value) => widget.callBackWithFacet(value),
            onTelemetryCallBack: (value) =>
                generateInteractTelemetryData(value)),
        SizedBox(height: 250.w)
      ]);
    } else {
      return SizedBox();
    }
  }

  Future<void> fetchData() async {
    List keywordList =
        await widget.searchRepository.nlpSearch(widget.searchText);
    String keyword = keywordList.isNotEmpty
        ? getHighestPriorityKeyword(keywordList)
        : widget.searchText;
    futureKeyword = Future.value(keyword);
    // Call createRecentSuggestion with keyword, searchText, and category
    await widget.searchRepository.createRecentSuggestion(
        nlpSearchQuery: keyword,
        searchQuery: widget.searchText,
        searchCategory: getRecentSearchCategory());
    if (mounted) {
      Future.delayed(Duration.zero, () {
        setState(() {});
      });
    }
  }

  String getRecentSearchCategory() {
    if (widget.showContent) return RecentSearchCategory.course;
    if (widget.showPeople) return RecentSearchCategory.people;
    if (widget.showEvent) return RecentSearchCategory.events;
    if (widget.showExternalContent) return RecentSearchCategory.externalContent;
    if (widget.showCommunity) return RecentSearchCategory.community;
    if (widget.showResources) return RecentSearchCategory.resource;
    return RecentSearchCategory.all;
  }

  String getHighestPriorityKeyword(List list) {
    Map<String, dynamic>? priorityItem =
        list.where((keyItem) => keyItem['priority'] == 1).firstOrNull;
    return priorityItem != null ? priorityItem['keyword'] : '';
  }

  void scrollToTop() {
    Future.delayed(Duration.zero, () {
      scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void generateInteractTelemetryData(TelemetryDataModel data) async {
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: data.pageId ?? '',
        contentId: data.id,
        subType: data.subType,
        env: TelemetryEnv.home,
        objectType: data.objectType,
        clickId: data.clickId ?? '');
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
