import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../util/index.dart';
import '../../../../../widgets/index.dart';
import '../../../../index.dart';
import '../../models/composite_search_model.dart';
import '../../repository/search_repository.dart';
import '../../utils/search_filter_params.dart';
import '../../utils/search_helper.dart';
import '../skeleton/course_search_skeleton.dart';
import '../widgets/options_panel.dart';
import '../widgets/recent_search_widget.dart';
import '../widgets/search_category_section.dart';
import '../widgets/search_nodata_widget.dart';
import '../widgets/search_sort_widget.dart';
import '../widgets/search_suggestion_widget.dart';
import 'search_filter_page.dart';

class SearchPage extends StatefulWidget {
  final int? categoryIndex;

  const SearchPage({super.key, this.categoryIndex});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  // Controllers
  final TextEditingController searchController = TextEditingController();

  // UI State
  int? selectedCategoryIndex;
  int initialCategoryIndex = 0;
  String selectedOption = SortBy.mostRelevant;
  bool showSearchResult = false;
  bool showRecentSearch = false;
  bool showAllResult = false;
  bool showContent = true;
  bool showEvents = false;
  bool showPeople = false;
  bool showExternalContent = false;
  bool showCommunities = false;
  bool showResources = false;

  // Data
  List<Facet> facets = [];
  Map<String, dynamic>? filters;
  Map<String, dynamic> sortBy = {};
  List<SearchCategoryData> categoryFilter = [];
  Future<Map<String, dynamic>>? futureSearchConfig;

  // State Notifiers
  final ValueNotifier<Map<String, dynamic>> updateFacetFilter =
      ValueNotifier({});
  final ValueNotifier<bool> isContentEmpty = ValueNotifier(false);
  final ValueNotifier<bool> isEventEmpty = ValueNotifier(false);
  final ValueNotifier<bool> isPeopleEmpty = ValueNotifier(false);
  final ValueNotifier<bool> isCommunityEmpty = ValueNotifier(false);
  final ValueNotifier<bool> isExternalContentEmpty = ValueNotifier(false);
  final ValueNotifier<bool> isResourceEmpty = ValueNotifier(false);
  final ValueNotifier<bool> isAnyEmpty = ValueNotifier(false);
  FocusNode searchFieldFocus = FocusNode();

  StateSetter? filterBottomSheetState;

  @override
  void initState() {
    initialCategoryIndex = widget.categoryIndex ?? 0;
    fetchData();
    setupListeners();
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFieldFocus.dispose();
    isContentEmpty.dispose();
    isEventEmpty.dispose();
    isPeopleEmpty.dispose();
    isCommunityEmpty.dispose();
    isExternalContentEmpty.dispose();
    isResourceEmpty.dispose();
    isAnyEmpty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: FutureBuilder(
          future: futureSearchConfig,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return _buildScaffold(context, snapshot);
            } else {
              return Scaffold(
                body: Container(
                  padding: EdgeInsets.symmetric(vertical: 24).r,
                  child: CourseSearchSkeleton(),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Scaffold _buildScaffold(
      BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
            showSearchResult && !showAllResult ? 110.sp : 60.sp),
        child: _buildAppBar(context, snapshot),
      ),
      body: Container(
        height: 1.0.sh,
        width: 1.0.sw,
        color: AppColors.whiteGradientOne,
        child: ValueListenableBuilder<bool>(
          valueListenable: isAnyEmpty,
          builder: (context, emptyValue, child) {
            return shouldShowEmptyWidget(
              contentEmpty: isContentEmpty.value,
              eventEmpty: isEventEmpty.value,
              peopleEmpty: isPeopleEmpty.value,
              communityEmpty: isCommunityEmpty.value,
              externalContentEmpty: isExternalContentEmpty.value,
              resourceEmpty: isResourceEmpty.value,
            )
                ? _buildEmptyWidget(snapshot)
                : _buildSearchResults(snapshot);
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? 8
                          : 24,
                      horizontal: 16)
                  .r,
              width: double.infinity,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(63).r),
              child: InkWell(
                onTap: () {
                  resetEmptyFlag();
                  isAnyEmpty.value = false;
                  searchFieldFocus.requestFocus();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.appBarBackground,
                  ),
                  child: CustomPaint(
                    painter: GradientBorderPainter(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16).r,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.blue54, AppColors.blue49],
                              ).createShader(bounds);
                            },
                            child: Icon(Icons.search,
                                color: AppColors.appBarBackground),
                          ),
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8).r,
                              child: TextField(
                                controller: searchController,
                                focusNode: searchFieldFocus,
                                textInputAction: TextInputAction.search,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  counter: Offstage(),
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintText: AppLocalizations.of(context)!
                                      .mSearchSearchForAnything,
                                  hintStyle:
                                      Theme.of(context).textTheme.labelLarge,
                                ),
                                onTap: () => setState(() {
                                  resetEmptyFlag();
                                  isAnyEmpty.value = false;
                                }),
                                onSubmitted: (value) {
                                  if (value.length >=
                                      getMinSearchLengthResult(snapshot)) {
                                    _generateInteractTelemetryData(value);
                                    setState(() {
                                      showRecentSearch = false;
                                      showSearchResult = true;
                                      resetEmptyFlag();
                                    });
                                  } else {
                                    SearchHelper().showOverlayMessage(
                                      AppLocalizations.of(context)!
                                          .mSearchSearchCharacterLimit(
                                              '${getMinSearchLengthResult(snapshot)}'),
                                      context,
                                    );
                                  }
                                },
                                onChanged: (value) {
                                  showSearchResult = false;
                                  if (value.isNotEmpty &&
                                      !showRecentSearch &&
                                      searchController.text.length >
                                          (snapshot.data != null &&
                                                  snapshot.data![
                                                          'minLengthAutoSearch'] !=
                                                      null
                                              ? snapshot
                                                  .data!['minLengthAutoSearch']
                                              : SearchConstants
                                                  .minSearchLength)) {
                                    showRecentSearch = true;
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          searchController.text.isNotEmpty
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      searchController.clear();
                                      showRecentSearch = false;
                                      showSearchResult = false;
                                      resetEmptyFlag();
                                      selectedCategoryIndex = 0;
                                      final setter = flagSetters[
                                          categoryFilter[selectedCategoryIndex!]
                                              .id];
                                      setter?.call();
                                      showContent = true;
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      key: Key(KeyConstants.searchFieldClose),
                                      Icons.close,
                                      size: 24.sp,
                                    ),
                                  ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: ApiUrl.baseUrl +
                                      '/assets/images/sakshamAI/saksham_ai_loader-2.gif',
                                  placeholder: (context, url) => Container(),
                                  errorWidget: (context, url, error) =>
                                      Container(),
                                  height: 160.sp,
                                  width: 40.sp,
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: showSearchResult && !showAllResult,
            child: OptionsPanel(
              hasActiveFilters: filters != null && filters!.isNotEmpty,
              filterCallback: () async => facets.isNotEmpty
                  ? await showFilterOptions()
                  : SearchHelper().showOverlayMessage(
                      AppLocalizations.of(context)!.mSearchSearchResultEmpty,
                      context),
              sortCallback: () async => facets.isNotEmpty
                  ? await showSortOptions()
                  : SearchHelper().showOverlayMessage(
                      AppLocalizations.of(context)!.mSearchSearchResultEmpty,
                      context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    return Container(
      height: 1.0.sh,
      width: 1.0.sw,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SearchCategorySection(
              selectedFilterIndex: getCategoryIndex(),
              changeSelectCategory: (value) {
                updateCategory(
                    value, context, getMinSearchLengthResult(snapshot));
              },
              categoryList: categoryFilter,
            ),
            SearchNoDataWidget(searchText: searchController.text),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    if (showSearchResult && showAllResult && !searchFieldFocus.hasFocus) {
      return _buildAllResults(snapshot);
    } else if (showSearchResult &&
        !showAllResult &&
        !searchFieldFocus.hasFocus) {
      return _buildFilteredResults(snapshot);
    } else {
      return _buildSuggestions(snapshot);
    }
  }

  Widget _buildAllResults(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SearchCategorySection(
            selectedFilterIndex: getCategoryIndex(),
            changeSelectCategory: (value) {
              updateCategory(
                  value, context, getMinSearchLengthResult(snapshot));
            },
            categoryList: categoryFilter,
          ),
          ValueListenableBuilder(
            valueListenable: updateFacetFilter,
            builder: (context, value, _) {
              return SearchResultPage(
                searchText: searchController.text,
                callBackOnContentEmptyResult: () => isContentEmpty.value = true,
                callBackOnEventsEmptyResult: () => isEventEmpty.value = true,
                callBackOnPeopleEmptyResult: () => isPeopleEmpty.value = true,
                callBackOnCommunityEmptyResult: () =>
                    isCommunityEmpty.value = true,
                callBackOnExternalContentEmptyResult: () =>
                    isExternalContentEmpty.value = true,
                callBackOnResourceEmptyResult: () =>
                    isResourceEmpty.value = true,
                callBackWithFacet: (value) {
                  facets = SearchHelper()
                      .facetUpdate(initialFacet: facets, newFacet: value);
                  setState(() {
                    filterBottomSheetState?.call(() {
                      updateFacetFilter.value = {};
                    });
                  });
                },
                changeSelectCategory: (value) => onCategoryChange(value),
                pills: snapshot.data?['pills'] ?? [],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredResults(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchCategorySection(
          changeSelectCategory: (value) {
            updateCategory(value, context, getMinSearchLengthResult(snapshot));
          },
          selectedFilterIndex: getCategoryIndex(),
          categoryList: categoryFilter,
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: updateFacetFilter,
            builder: (context, value, _) {
              return SearchResultPage(
                searchText: searchController.text,
                filters: filters,
                sortBy: sortBy,
                showAll: showAllResult,
                showContent: showContent,
                showExternalContent: showExternalContent,
                showCommunity: showCommunities,
                showEvent: showEvents,
                showPeople: showPeople,
                showResources: showResources,
                callBackOnContentEmptyResult: () => isContentEmpty.value = true,
                callBackOnEventsEmptyResult: () => isEventEmpty.value = true,
                callBackOnPeopleEmptyResult: () => isPeopleEmpty.value = true,
                callBackOnCommunityEmptyResult: () =>
                    isCommunityEmpty.value = true,
                callBackOnExternalContentEmptyResult: () =>
                    isExternalContentEmpty.value = true,
                callBackOnResourceEmptyResult: () =>
                    isResourceEmpty.value = true,
                callBackWithFacet: (value) {
                  facets = SearchHelper()
                      .facetUpdate(initialFacet: facets, newFacet: value);
                  setState(() {
                    filterBottomSheetState?.call(() {
                      updateFacetFilter.value = {};
                    });
                  });
                },
                changeSelectCategory: (value) => onCategoryChange(value),
                pills: snapshot.data?['pills'] ?? [],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    return Column(
      children: [
        SearchCategorySection(
          changeSelectCategory: (value) {
            updateCategory(value, context, getMinSearchLengthResult(snapshot));
          },
          selectedFilterIndex: getCategoryIndex(),
          categoryList: categoryFilter,
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SearchSuggestionWidget(
                searchText: searchController.text,
                selectedCategoryIndex: getCategoryIndex(),
                showAll: showAllResult,
                showContent: showContent,
                showExternalContent: showExternalContent,
                showCommunity: showCommunities,
                showEvent: showEvents,
                showPeople: showPeople,
                minAutoSearchLength: snapshot.data != null
                    ? snapshot.data!['minLengthAutoSearch']
                    : null,
                updateSearchText: (value) {
                  setState(() {
                    searchController.text = value;
                    showSearchResult = true;
                    showRecentSearch = false;
                    FocusManager.instance.primaryFocus?.unfocus();
                  });
                },
              ),
              RecentSearchWidget(updateSearchText: (value) {
                setState(() {
                  searchController.text = value;
                  showSearchResult = true;
                  showRecentSearch = false;
                  FocusManager.instance.primaryFocus?.unfocus();
                });
              }),
            ],
          ),
        )
      ],
    );
  }

  int getMinSearchLengthResult(AsyncSnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.data?['minSearchLengthResult'] ??
        SearchConstants.minSearchCharacter;
  }

  void updateCategory(
      String value, BuildContext context, int minCharacterLength) {
    if (searchController.text.length >= minCharacterLength) {
      onCategoryChange(value);
    } else if (selectedCategoryIndex != null) {
      SearchHelper().showOverlayMessage(
        AppLocalizations.of(context)!
            .mSearchSearchCharacterLimit('$minCharacterLength'),
        context,
      );
    } else {
      selectedCategoryIndex = initialCategoryIndex;
    }
  }

  int getCategoryIndex() => selectedCategoryIndex ?? initialCategoryIndex;

  void resetEmptyFlag() {
    isContentEmpty.value = false;
    isEventEmpty.value = false;
    isPeopleEmpty.value = false;
    isExternalContentEmpty.value = false;
    isCommunityEmpty.value = false;
    isResourceEmpty.value = false;
  }

  bool shouldShowEmptyWidget({
    required bool contentEmpty,
    required bool eventEmpty,
    required bool peopleEmpty,
    required bool communityEmpty,
    required bool externalContentEmpty,
    required bool resourceEmpty,
  }) {
    bool isEmpty = (showAllResult &&
            contentEmpty &&
            eventEmpty &&
            peopleEmpty &&
            communityEmpty &&
            externalContentEmpty &&
            resourceEmpty) ||
        (showEvents && eventEmpty) ||
        (showCommunities && communityEmpty) ||
        (showPeople && peopleEmpty) ||
        (showContent && contentEmpty) ||
        (showExternalContent && externalContentEmpty) ||
        (showResources && resourceEmpty);
    if (isEmpty) {
      Future.delayed(Duration.zero, () => setState(() {}));
    }
    return isEmpty;
  }

  Future showSortOptions() {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16))
            .r,
      ),
      builder: (context) {
        return SearchSortWidget(
          isEvent: showEvents,
          isPeople: showPeople,
          isCommunity: showCommunities,
          isContent: showContent,
          isExternalContent: showExternalContent,
          isResource: showResources,
          selectedOption: selectedOption,
          callBackWithSortBy: (String value) {
            Navigator.of(context).pop(false);
            setState(() {
              resetEmptyFlag();
              selectedOption = value;
              switch (value) {
                case SortBy.mostRelevant:
                  sortBy = {};
                  break;
                case SortBy.createdOn:
                  sortBy = {SortBy.createdOn: 'desc'};
                  break;
                case SortBy.avgRating:
                  sortBy = {SortBy.avgRating: 'desc'};
                  break;
                case SortBy.aToZ:
                  sortBy = {'firstName': 'asc'};
                  break;
                case SortBy.zToA:
                  sortBy = {'firstName': 'desc'};
                  break;
                case SortBy.createdDate:
                  sortBy = {SortBy.createdDate: 'desc'};
                  break;
                default:
                  sortBy = {};
                  break;
              }
            });
          },
        );
      },
    );
  }

  Future showFilterOptions() {
    BuildContext parentContext = context;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            filterBottomSheetState = setModalState;
            return SearchFilterPage(
              filters: facets,
              callBackWithFilter: (value) {
                setState(() {
                  resetEmptyFlag();
                  filters = value;
                });
              },
              callBackUpdate: (value) => facets = value,
              getSubFacet: (Map<String, dynamic> value) {
                updateFacetFilter.value = value;
              },
              parentContext: parentContext,
            );
          },
        );
      },
    );
  }

  void onCategoryChange(String value) {
    int index = categoryFilter.indexWhere((category) => category.id == value);
    if (selectedCategoryIndex != index) {
      facets = [];
      resetResultScreenVisibility();
      resetSortByOption();
      selectedCategoryIndex = index;
      FocusManager.instance.primaryFocus?.unfocus();
      final setter = flagSetters[categoryFilter[selectedCategoryIndex!].id];
      setter?.call();
      setState(() {
        if (!showSearchResult && selectedCategoryIndex != null) {
          if (selectedCategoryIndex! != 0) {
            showSearchResult = true;
          }
        }
      });
    }
  }

  void resetSortByOption() {
    sortBy = {};
    selectedOption = SortBy.mostRelevant;
  }

  void resetResultScreenVisibility() {
    showAllResult = false;
    showContent = false;
    showEvents = false;
    showPeople = false;
    showExternalContent = false;
    showCommunities = false;
    showResources = false;
    filters = null;
    resetEmptyFlag();
  }

  void updateIsAnyEmpty() {
    isAnyEmpty.value = false;
    isAnyEmpty.value = isContentEmpty.value ||
        isEventEmpty.value ||
        isPeopleEmpty.value ||
        isCommunityEmpty.value ||
        isExternalContentEmpty.value ||
        isResourceEmpty.value;
  }

  void setupListeners() {
    isContentEmpty.addListener(updateIsAnyEmpty);
    isEventEmpty.addListener(updateIsAnyEmpty);
    isPeopleEmpty.addListener(updateIsAnyEmpty);
    isCommunityEmpty.addListener(updateIsAnyEmpty);
    isExternalContentEmpty.addListener(updateIsAnyEmpty);
    isResourceEmpty.addListener(updateIsAnyEmpty);
  }

  Future<void> fetchData() async {
    Map<String, dynamic> searchConfig =
        await SearchRepository().getSearchConfig();
    futureSearchConfig = Future.value(searchConfig);

    List pills = searchConfig['pills'];
    categoryFilter = SearchCategoryData.filterParams(pills: pills);
    showContent = false;
    final setter = flagSetters[categoryFilter[initialCategoryIndex].id];
    setter?.call();
    Future.delayed(Duration.zero, () => setState(() {}));
  }

  Map<String, VoidCallback> get flagSetters => {
        SearchCategories.content: () => showContent = true,
        SearchCategories.events: () => showEvents = true,
        SearchCategories.people: () => showPeople = true,
        SearchCategories.externalContent: () => showExternalContent = true,
        SearchCategories.communities: () => showCommunities = true,
        SearchCategories.resources: () => showResources = true,
        SearchCategories.all: () => showAllResult = true,
      };

  void _generateInteractTelemetryData(String searchQuery) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.globalSearchPageId,
        subType: TelemetrySubType.search,
        env: TelemetryEnv.home,
        clickId: TelemetryClickId.search,
        contentId: '',
        pageUri:
            '${TelemetryPageIdentifier.globalSearchPageId}?q=${searchQuery}');
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
