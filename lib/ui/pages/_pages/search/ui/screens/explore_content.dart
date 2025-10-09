import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../respositories/_respositories/settings_repository.dart';
import '../../../../../widgets/index.dart';
import '../../models/composite_search_model.dart';
import '../../utils/search_helper.dart';
import '../pages/search_filter_page.dart';
import '../widgets/course_search.dart';
import '../widgets/options_panel.dart';
import '../widgets/search_sort_widget.dart';

class ExploreContent extends StatefulWidget {
  @override
  State<ExploreContent> createState() => _ExploreContentState();
}

class _ExploreContentState extends State<ExploreContent> {
  bool isEmpty = false;
  ValueNotifier<List<Facet>> facetsValueNotifier = ValueNotifier<List<Facet>>([]);
  Map<String, dynamic>? filters;
  Map<String, dynamic> sortBy = {};
  String selectedOption = SortBy.mostRelevant;
  bool isBackPressed = false;
  bool isTablet = false;
  @override
  void initState() {
    super.initState();
    isTablet =
        Provider.of<SettingsRepository>(context, listen: false).itsTablet;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.whiteGradientOne,
        body: Container(
          width: 1.0.sw,
          color: AppColors.whiteGradientOne,
          child: Column(
            children: [
              Container(
                color: AppColors.appBarBackground,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16).r,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (!isBackPressed) {
                                isBackPressed = true;
                                Navigator.of(context).pop();
                              }
                            },
                            child: SizedBox(
                              width: 0.1.sw,
                              child: Icon(Icons.arrow_back_ios,
                                  color: AppColors.greys, size: 20.sp),
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!
                                .mSearchExploreAllTheContent,
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: AppColors.greys),
                          )
                        ],
                      ),
                    ),
                    OptionsPanel(
                        hasActiveFilters:
                            filters != null && filters!.isNotEmpty,
                        filterCallback: () async => await showFilterOptions(),
                        sortCallback: () async => await showSortOptions())
                  ],
                ),
              ),
              SizedBox(height: 16.w),
              Expanded(
                child: Container(
                  child: isEmpty
                      ? Column(children: [
                          SizedBox(height: 0.25.sh),
                          SvgPicture.network(
                              ApiUrl.baseUrl + '/assets/icons/no-data.svg',
                              height: 90.w,
                              width: 130.w,
                              placeholderBuilder: (context) => Image.asset(
                                  'assets/img/image_placeholder.jpg',
                                  height: 90.w,
                                  width: 130.w,
                                  fit: BoxFit.fill)),
                          SizedBox(height: 16.w),
                          Text(
                            AppLocalizations.of(context)!
                                .mExploreContentSorryMessage,
                            style: Theme.of(context).textTheme.displayLarge,
                            textAlign: TextAlign.center,
                          )
                        ])
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              CourseSearch(
                                  searchText: '',
                                  showContent: true,
                                  showAll: false,
                                  filters: filters,
                                  sortBy: sortBy,
                                  height: isTablet
                                      ? MediaQuery.of(context).orientation ==
                                              Orientation.portrait
                                          ? 0.85
                                          : 0.7
                                      : 0.78,
                                  callBackOnEmptyResult: () {
                                    setState(() {
                                      isEmpty = true;
                                    });
                                  },
                                  callBackWithFacet: (value) {
                                    facetsValueNotifier.value = SearchHelper().facetUpdate(initialFacet: facetsValueNotifier.value, newFacet: value);
                                  },
                                  onTelemetryCallBack: (value) {})
                            ],
                          ),
                        ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomBar(),
      ),
    );
  }

  Future showFilterOptions() {
    BuildContext parentContext = context;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return ValueListenableBuilder<List<Facet>>(
            valueListenable: facetsValueNotifier,
            builder: (context, facetsValue, _) {
              return SearchFilterPage(
                  filters: facetsValue,
                  callBackWithFilter: (value) {
                    setState(() {
                      isEmpty = false;
                      filters = value;
                    });
                  },
                  callBackUpdate: (value) => facetsValueNotifier.value = value,
                  parentContext: parentContext
              );
            }
        );
      },
    );
  }

  Future showSortOptions() {
    return showModalBottomSheet(
        context: context,
        isDismissible: false,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16), topRight: Radius.circular(16))
                .r),
        builder: (context) {
          return SearchSortWidget(
            isContent: true,
            selectedOption: selectedOption,
            callBackWithSortBy: (String value) {
              Navigator.of(context).pop(false);
              setState(() {
                isEmpty = false;
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
        });
  }
}
