import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../util/index.dart';
import '../../models/composite_search_model.dart';
import '../../utils/search_helper.dart';
import '../widgets/expandable_checkbox_widget.dart';
import '../widgets/search_radio_filter.dart';

class SearchFilterPage extends StatefulWidget {
  final List<Facet> filters;
  final Function(Map<String, dynamic>) callBackWithFilter;
  final Function(List<Facet>) callBackUpdate;
  final Function(Map<String, dynamic>)? getSubFacet;
  final BuildContext parentContext;

  const SearchFilterPage(
      {super.key,
      required this.filters,
      required this.callBackWithFilter,
      required this.callBackUpdate,
      required this.parentContext,
      this.getSubFacet});
  @override
  SearchFilterPageState createState() => SearchFilterPageState();
}

class SearchFilterPageState extends State<SearchFilterPage> {
  int selectedFilterIndex = 0;
  List<Facet> filters = [];
  bool enableApplyFilter = false;
  TextEditingController searchController = TextEditingController();
  ValueNotifier<String> searchQuery = ValueNotifier<String>('');
  final ScrollController scrollController = ScrollController();
  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    filters = widget.filters.map((facet) => facet.copy()).toList();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    filters.sort((a, b) => (SearchHelper.getFacetName(a.name, context))
        .compareTo(SearchHelper.getFacetName(b.name, context)));
  }

  @override
  void didUpdateWidget(SearchFilterPage oldWidget) {
    List<Facet> newFilter = widget.filters.map((facet) => facet.copy()).toList()
      ..sort((a, b) => (SearchHelper.getFacetName(a.name, context))
          .compareTo(SearchHelper.getFacetName(b.name, context)));
    selectedFilterIndex = updateSelectedFilterIndex(filters, newFilter);
    filters = syncFilterStatus(filters, newFilter);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: AppColors.grey08))),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16).r,
                        child: Text(
                          AppLocalizations.of(context)!.mStaticFilterBy,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: AppColors.greys),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          bool isChangedValue = false;
                          filters.forEach((filter) {
                            filter.count = 0;
                            filter.values.forEach((value) {
                              if (!isChangedValue && value.isChecked) {
                                isChangedValue = true;
                              }
                              value.isChecked = false;
                              if (value.subFacet != null) {
                                value.subFacet!.values.forEach((val) {
                                  if (!isChangedValue && val.isChecked) {
                                    isChangedValue = true;
                                  }
                                  val.isChecked = false;
                                });
                              }
                            });
                          });
                          updateFilters();
                          setState(() {
                            if (isChangedValue) {
                              enableApplyFilter = true;
                            }
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16).r,
                          child: Text(
                            AppLocalizations.of(context)!.mStaticClearAll,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: AppColors.negativeLight),
                          ),
                        ),
                      )
                    ])),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120.w,
                    height: 1.0.sh,
                    decoration: BoxDecoration(
                        border: Border(
                            right: BorderSide(
                                color: AppColors.grey08, width: 1.w))),
                    child: ListView.builder(
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              filters[index].count != 0
                                  ? Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12).r,
                                      child: Icon(
                                        Icons.circle,
                                        size: 10.sp,
                                        color: AppColors.negativeLight,
                                      ),
                                    )
                                  : SizedBox(),
                              Flexible(
                                child: Text(
                                    filters[index].count != 0
                                        ? '${SearchHelper.getFacetName(filters[index].name, context)} (${filters[index].count})'
                                        : SearchHelper.getFacetName(
                                            filters[index].name, context),
                                    style: selectedFilterIndex == index
                                        ? Theme.of(context).textTheme.bodyLarge
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: AppColors.greys60)),
                              )
                            ],
                          ),
                          shape: Border(
                              bottom: BorderSide(
                                  color: AppColors.grey08, width: 1.w)),
                          tileColor: selectedFilterIndex == index
                              ? AppColors.appBarBackground
                              : null,
                          onTap: () {
                            setState(() {
                              selectedFilterIndex = index;
                              searchController.text = '';
                              searchQuery.value = '';
                              FocusManager.instance.primaryFocus?.unfocus();
                            });
                            scrollToTop();
                          },
                        );
                      },
                    ),
                  ),

                  // Right: Sub-filter List
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                                  left: 16, right: 16, top: 16)
                              .r,
                          child: Text(
                            SearchHelper.getFacetName(
                                filters[selectedFilterIndex].name, context),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        if (filters[selectedFilterIndex].values.length >= SHOW2)
                          Padding(
                            padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 16)
                                .r,
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                searchQuery.value = value;
                              },
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .mHomePlaceholderSearch,
                                  hintStyle:
                                      Theme.of(context).textTheme.labelLarge,
                                  prefixIcon: Icon(Icons.search),
                                  prefixIconColor: AppColors.grey40,
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0)
                                          .r,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: AppColors.darkBlue,
                                          width: 1.0))),
                            ),
                          ),
                        Flexible(
                          child: ValueListenableBuilder<String>(
                              valueListenable: searchQuery,
                              builder: (context, query, _) {
                                List<Value> filteredValues =
                                    filters[selectedFilterIndex]
                                        .values
                                        .where((item) =>
                                            getSubFilterName(item.name)
                                                .toLowerCase()
                                                .contains(query.toLowerCase()))
                                        .toList();
                                if (filters[selectedFilterIndex]
                                    .useSingleChoice) {
                                  return SearchRadioFilterWidget(
                                      values: filteredValues,
                                      onChanged: (List<Value>? value) {
                                        if (value != null) {
                                          setState(() {
                                            enableApplyFilter = true;
                                            filters[selectedFilterIndex]
                                                .values = value;
                                            for (Value val in value) {
                                              if (val.isChecked) {
                                                filters[selectedFilterIndex]
                                                    .count = val.count;
                                                break;
                                              }
                                            }
                                          });

                                          updateFilters();
                                        }
                                      });
                                }
                                return ListView.builder(
                                  itemCount: filteredValues.length,
                                  controller: scrollController,
                                  shrinkWrap:
                                      true, // Allow ListView to fit inside the scroll view
                                  physics: ClampingScrollPhysics(),
                                  itemBuilder: (contxt, index) {
                                    Value subFilter = filteredValues[index];
                                    if (subFilter.name.isEmpty)
                                      return SizedBox();
                                    return ExpandableCheckboxList(
                                      title:
                                          '${Helper().capitalizeFirstCharacter(getSubFilterName(subFilter.name))} (${subFilter.count})',
                                      value: subFilter.isChecked,
                                      subFacet: subFilter.subFacet,
                                      isExpanded: subFilter.isExpanded,
                                      showMore: subFilter.showMore,
                                      subFilter: subFilter,
                                      isExpandable: subFilter.isExpandable,
                                      onChanged: (Value? value) {
                                        if (value != null) {
                                          if (value.isChecked) {
                                            SearchHelper().showOverlayMessage(
                                                AppLocalizations.of(context)!
                                                    .mSearchFilterAppliedMessage,
                                                widget.parentContext);
                                          }
                                          setState(() {
                                            updateFilters();
                                            enableApplyFilter = true;
                                            subFilter = value;
                                            getCountofFilteredFacet();
                                          });
                                        }
                                      },
                                      onExpanded: (value) {
                                        if (value != null &&
                                            subFilter.isExpanded != value) {
                                          if (value &&
                                              subFilter.subFacet == null &&
                                              subFilter.isExpandable &&
                                              widget.getSubFacet != null) {
                                            widget.getSubFacet!({
                                              'facetName':
                                                  filters[selectedFilterIndex]
                                                      .name,
                                              'valueName': subFilter.name
                                            });
                                          }
                                          setState(() {
                                            subFilter.isExpanded = value;
                                            if (!value) {
                                              subFilter.showMore = false;
                                            }
                                          });
                                        }
                                      },
                                      onShowMoreTap: (value) {
                                        if (value != null &&
                                            subFilter.showMore != value) {
                                          setState(() {
                                            subFilter.showMore = value;
                                          });
                                        }
                                      },
                                    );
                                  },
                                );
                              }),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.grey08))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Container(
                      width: 0.5.sw - 1.w,
                      padding: EdgeInsets.symmetric(vertical: 24.r),
                      alignment: Alignment.center,
                      child: Text(
                          AppLocalizations.of(context)!.mSearchCloseFilter,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                  fontSize: 12.sp,
                                  color: AppColors.negativeLight)),
                    ),
                  ),
                  Container(
                    width: 2.w,
                    height: 30.w,
                    color: AppColors.grey08,
                  ),
                  InkWell(
                    onTap: () => enableApplyFilter
                        ? Navigator.of(context).pop(false)
                        : null,
                    child: Container(
                        width: 0.5.sw - 1.w,
                        padding: EdgeInsets.symmetric(vertical: 24.r),
                        alignment: Alignment.center,
                        child: Text(
                            AppLocalizations.of(context)!.mSearchApplyFilter,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                    fontSize: 12.sp,
                                    color: enableApplyFilter
                                        ? AppColors.darkBlue
                                        : AppColors.grey40))),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void getCountofFilteredFacet() {
    int count = 0;
    filters[selectedFilterIndex].values.forEach((value) {
      if (value.isChecked) {
        count = count + value.count;
      } else if (value.subFacet != null) {
        value.subFacet!.values.forEach((subValue) {
          if (subValue.isChecked) {
            count = count + subValue.count;
          }
        });
      }
    });
    filters[selectedFilterIndex].count = count;
  }

  void updateFilters() {
    final Map<String, List<String>> updatedFilter = {};

    for (var filter in filters) {
      for (var subFilter in filter.values) {
        if (subFilter.isChecked) {
          updatedFilter.putIfAbsent(filter.name, () => []).add(subFilter.name);
        } else if (subFilter.subFacet != null) {
          bool isChecked = false;
          for (var innerFilter in subFilter.subFacet!.values) {
            if (innerFilter.isChecked) {
              if (!isChecked) {
                isChecked = innerFilter.isChecked;
              }
              updatedFilter
                  .putIfAbsent(subFilter.subFacet!.name, () => [])
                  .add(innerFilter.name);
            }
          }
          if (isChecked) {
            updatedFilter
                .putIfAbsent(filter.name, () => [])
                .add(subFilter.name);
          }
        }
      }
    }

    widget.callBackUpdate(filters);
    widget.callBackWithFilter(updatedFilter);
  }

  String getSubFilterName(String name) {
    switch (name) {
      case '4.5':
        return AppLocalizations.of(context)!.mSearchFournHalfAndUp;
      case '4.0':
        return AppLocalizations.of(context)!.mSearchFourAndUp;
      case '3.5':
        return AppLocalizations.of(context)!.mSearchThreenHalfAndUp;
      case '3.0':
        return AppLocalizations.of(context)!.mSearchThreeAndUp;
      default:
        return name;
    }
  }

  List<Facet> syncFilterStatus(List<Facet> filters, List<Facet> newFilter) {
    for (final newFacet in newFilter) {
      final matchingFacet = filters.cast<Facet?>().firstWhere(
            (facet) => facet != null && facet.name == newFacet.name,
            orElse: () => null,
          );

      if (matchingFacet == null) continue;

      for (final newValue in newFacet.values) {
        final matchingValue = matchingFacet.values.cast<Value?>().firstWhere(
              (value) => value != null && value.name == newValue.name,
              orElse: () => null,
            );

        if (matchingValue == null) continue;

        newValue.isChecked = matchingValue.isChecked;

        // Handle nested subFacets recursively
        if (newValue.subFacet != null && matchingValue.subFacet != null) {
          syncFilterStatus(
            [matchingValue.subFacet!],
            [newValue.subFacet!],
          );
        } else if (newValue.subFacet != null && newValue.isChecked) {
          if (newValue.subFacet!.values.isNotEmpty) {
            newValue.subFacet!.values.forEach((val) => val.isChecked = true);
          }
        }
      }
    }
    return newFilter;
  }

  int updateSelectedFilterIndex(List<Facet> filters, List<Facet> newFilter) {
    String expandedCategory = filters[selectedFilterIndex].name;
    int selectedFacetIndex =
        newFilter.indexWhere((facet) => facet.name == expandedCategory);
    if (selectedFacetIndex == -1) {
      return 0;
    } else {
      return selectedFacetIndex;
    }
  }
}
