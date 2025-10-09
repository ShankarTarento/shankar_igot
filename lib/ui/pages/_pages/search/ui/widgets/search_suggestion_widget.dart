import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../respositories/index.dart';
import '../../../../../widgets/_discussion_hub/repositories/discussion_repository.dart';
import '../../models/community_search_model.dart';
import '../../models/composite_search_model.dart';
import '../../models/event_search_model.dart';
import '../../models/people_search_model.dart';
import '../../repository/search_repository.dart';
import '../../utils/search_helper.dart';

class SearchSuggestionWidget extends StatefulWidget {
  final int selectedCategoryIndex;
  final bool showAll;
  final bool showContent;
  final bool showExternalContent;
  final bool showPeople;
  final bool showEvent;
  final bool showCommunity;
  final String searchText;
  final Map<String, dynamic>? filters;
  final Map<String, dynamic>? sortBy;
  final Function(String) updateSearchText;
  final LearnRepository learnRepository;
  final EventRepository eventRepository;
  final SearchRepository searchRepository;
  final DiscussionRepository discussionRepository;
  final int? minAutoSearchLength;
  SearchSuggestionWidget(
      {super.key,
      required this.selectedCategoryIndex,
      this.showAll = true,
      this.showContent = false,
      this.showExternalContent = false,
      this.showPeople = false,
      this.showEvent = false,
      this.showCommunity = false,
      this.searchText = '',
      this.filters,
      this.sortBy,
      required this.updateSearchText,
      LearnRepository? learnRepository,
      EventRepository? eventRepository,
      SearchRepository? searchRepository,
      DiscussionRepository? discussionRepository,
      this.minAutoSearchLength})
      : learnRepository = learnRepository ?? LearnRepository(),
        eventRepository = eventRepository ?? EventRepository(),
        searchRepository = searchRepository ?? SearchRepository(),
        discussionRepository = discussionRepository ?? DiscussionRepository();

  @override
  State<SearchSuggestionWidget> createState() => _SearchSuggestionWidgetState();
}

class _SearchSuggestionWidgetState extends State<SearchSuggestionWidget> {
  List<String> contentSuggestion = [];
  List<String> eventSuggestion = [];
  List<String> peopleSuggestion = [];
  List<String> communitySuggestion = [];
  List<String> externalContentSuggestion = [];

  @override
  void initState() {
    super.initState();
    if (widget.searchText.length >
        (widget.minAutoSearchLength ?? SearchConstants.minSearchLength)) {
      fetchData();
    }
  }

  void didUpdateWidget(SearchSuggestionWidget oldWidget) {
    if (oldWidget.searchText != widget.searchText) {
      if (widget.searchText.length >
          (widget.minAutoSearchLength ?? SearchConstants.minSearchLength)) {
        fetchData();
      } else {
        contentSuggestion.clear();
        eventSuggestion.clear();
        peopleSuggestion.clear();
        communitySuggestion.clear();
        externalContentSuggestion.clear();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (contentSuggestion.isNotEmpty)
                Text(AppLocalizations.of(context)!.mStaticContent,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.grey36_65)),
              if (contentSuggestion.isNotEmpty)
                SuggestionListWidget(contentSuggestion),
              if (eventSuggestion.isNotEmpty)
                Text(AppLocalizations.of(context)!.mStaticEvents,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.grey36_65)),
              if (eventSuggestion.isNotEmpty)
                SuggestionListWidget(eventSuggestion),
              if (peopleSuggestion.isNotEmpty)
                Text(AppLocalizations.of(context)!.mStaticPeople,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.grey36_65)),
              if (peopleSuggestion.isNotEmpty)
                SuggestionListWidget(peopleSuggestion),
              if (communitySuggestion.isNotEmpty)
                Text(AppLocalizations.of(context)!.mSearchCommunities,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.grey36_65)),
              if (communitySuggestion.isNotEmpty)
                SuggestionListWidget(communitySuggestion),
              if (externalContentSuggestion.isNotEmpty)
                Text(AppLocalizations.of(context)!.mSearchExternalContents,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: AppColors.grey36_65)),
              if (externalContentSuggestion.isNotEmpty)
                SuggestionListWidget(externalContentSuggestion)
            ],
          ),
        )
      ],
    );
  }

  Padding SuggestionListWidget(List<String> suggestionList) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0).r,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0).r,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      widget.updateSearchText(suggestionList[index]);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            size: 16.sp, color: AppColors.grey36_1),
                        SizedBox(width: 4.w),
                        SizedBox(
                          width: 0.7.sw,
                          child: Text(suggestionList[index],
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(color: AppColors.grey36_1)),
                        ),
                      ],
                    ),
                  ),
                ]),
          );
        },
      ),
    );
  }

  Future<void> fetchData() async {
    await fetchContentSuggestion();
    await fetchEventSuggestion();
    await fetchPeopleSuggestion();
    await fetchCommunitySuggestion();
    await fetchExternalContentSuggestion();
    setState(() {});
  }

  Future<void> fetchCommunitySuggestion() async {
    if (widget.showAll || widget.showCommunity) {
      communitySuggestion = await getCommunityTitleList();
    }
  }

  Future<void> fetchPeopleSuggestion() async {
    if (widget.showAll || widget.showPeople) {
      peopleSuggestion = await getNetworkTitleList();
    }
  }

  Future<void> fetchEventSuggestion() async {
    if (widget.showAll || widget.showEvent) {
      eventSuggestion = await getEventTitleList();
    }
  }

  Future<void> fetchContentSuggestion() async {
    if (widget.showAll || widget.showContent) {
      contentSuggestion = await getCourseTitleList();
    }
  }

  Future<void> fetchExternalContentSuggestion() async {
    if (widget.showAll || widget.showExternalContent) {
      contentSuggestion = await getExternalCourseTitleList();
    }
  }

  Future<List<String>> getCourseTitleList() async {
    List<String> categories = [];
    List<String> contentTitle = [];
    addCategories(categories);
    CompositeSearchModel? result = await widget.learnRepository
        .getCompositeSearchData(0, widget.searchText, categories, [], [],
            filters: null,
            ttl: ApiTtl.search,
            facets: [],
            sortBy: {},
            limit: 3);
    if (result != null && result.content.isNotEmpty) {
      result.content.forEach((content) {
        contentTitle.add(content.name);
      });
      return contentTitle;
    } else {
      return [];
    }
  }

  Future<List<String>> getExternalCourseTitleList() async {
    List<String> categories = [];
    List<String> contentTitle = [];
    addCategories(categories);
    CompositeSearchModel? result = await widget.searchRepository
        .searchExternalCourses(
            query: widget.searchText,
            facet: [],
            offset: 0,
            filters: null,
            limit: 3,
            sortBy: '');
    if (result != null && result.content.isNotEmpty) {
      result.content.forEach((content) {
        contentTitle.add(content.name);
      });
      return contentTitle;
    } else {
      return [];
    }
  }

  Future<List<String>> getEventTitleList() async {
    List<String> contentTitle = [];
    EventSearchModel? result = await widget.eventRepository
        .compositeEventsSearch(
            searchText: widget.searchText,
            limit: 3,
            offset: 0,
            facets: [],
            filters: null,
            sortBy: {});
    if (result != null && result.events.isNotEmpty) {
      result.events.forEach((content) {
        if (content.name != null) {
          contentTitle.add(content.name!);
        }
      });
      return contentTitle;
    } else {
      return [];
    }
  }

  Future<List<String>> getNetworkTitleList() async {
    List<String> contentTitle = [];
    PeopleSearchModel? result = await widget.searchRepository.peopleSearch(
        query: widget.searchText,
        facets: [],
        filters: null,
        offset: 0,
        sortBy: {},
        limit: 3);
    if (result != null && result.people.isNotEmpty) {
      result.people.forEach((content) {
        contentTitle.add('${content.firstName} ${content.lastName}');
      });
      return contentTitle;
    } else {
      return [];
    }
  }

  Future<List<String>> getCommunityTitleList() async {
    List<String> contentTitle = [];
    CommunitySearchModel? result = await widget.discussionRepository
        .searchCommunity(
            pageNumber: 1,
            searchQuery: widget.searchText,
            facets: [],
            filters: null,
            sortBy: {},
            pageSize: 3);
    if (result != null && result.community.isNotEmpty) {
      result.community.forEach((content) {
        if (content.communityName != null) {
          contentTitle.add(content.communityName!);
        }
      });
      return contentTitle;
    } else {
      return [];
    }
  }

  void addCategories(List<String> categories) {
    if (widget.showContent) {
      categories.addAll([
        PrimaryCategory.course.toLowerCase(),
        PrimaryCategory.moderatedCourses.toLowerCase(),
        PrimaryCategory.curatedProgram,
        PrimaryCategory.program.toLowerCase(),
        PrimaryCategory.blendedProgram.toLowerCase(),
        PrimaryCategory.moderatedProgram.toLowerCase(),
        PrimaryCategory.inviteOnlyProgram.toLowerCase(),
        PrimaryCategory.standaloneAssessment.toLowerCase(),
        PrimaryCategory.inviteOnlyAssessment.toLowerCase(),
        PrimaryCategory.moderatedAssessment.toLowerCase(),
        PrimaryCategory.caseStudy.toLowerCase()
      ]);
    }
  }
}
