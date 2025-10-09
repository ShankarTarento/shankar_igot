import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../constants/index.dart';
import '../../../../../../util/index.dart';
import '../../models/composite_search_model.dart';

class ExpandableCheckboxList extends StatefulWidget {
  final String title;
  final bool value;
  final Function(Value?) onChanged;
  final Function(bool?) onExpanded;
  final Function(bool?) onShowMoreTap;
  final Facet? subFacet;
  final bool isExpanded;
  final bool showMore;
  final bool isExpandable;
  final Value subFilter;

  const ExpandableCheckboxList(
      {super.key,
      required this.title,
      required this.value,
      required this.onChanged,
      required this.onExpanded,
      required this.onShowMoreTap,
      required this.isExpanded,
      required this.showMore,
      required this.subFilter,
      this.subFacet,
      this.isExpandable = false});

  @override
  State<ExpandableCheckboxList> createState() => ExpandableCheckboxListState();
}

class ExpandableCheckboxListState extends State<ExpandableCheckboxList> {
  TextEditingController searchController = TextEditingController();
  ValueNotifier<String> searchQuery = ValueNotifier<String>('');

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Value updatingSubFilter = widget.subFilter;
    return widget.subFacet == null && !widget.isExpandable
        ? getListTile(
            value: widget.value,
            onChanged: (value) {
              if (value != null) {
                updatingSubFilter.isChecked = value;
                widget.onChanged(updatingSubFilter);
              }
            },
            title: widget.title,
            context: context,
          )
        : Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    Checkbox(
                        value: widget.value,
                        activeColor: AppColors.darkBlue,
                        onChanged: (value) {
                          if (value != null) {
                            updatingSubFilter.isChecked = value;
                            if (updatingSubFilter.subFacet != null) {
                              updatingSubFilter.subFacet!.values
                                  .forEach((val) => val.isChecked = value);
                            }
                            widget.onChanged(updatingSubFilter);
                          }
                        }),
                    SizedBox(width: 8),
                    SizedBox(
                      width: 0.4.sw,
                      child: Text(
                        widget.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: AppColors.greys60),
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  widget.isExpanded
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                ),
                onTap: () {
                  if (widget.isExpanded) {
                    searchController.text = '';
                  }
                  widget.onExpanded(!widget.isExpanded);
                },
              ),
              if (widget.isExpanded && widget.subFacet == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24).r,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10).r,
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.darkBlue,
                        minHeight: 3.w,
                      )),
                ),
              if (widget.isExpanded && widget.subFacet != null)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16).r,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8).r,
                    color: AppColors.grey04,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Show Search Bar only when more than 3 items
                      if (widget.subFacet!.values.length >= SHOW2)
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: InputDecorationTheme(
                                prefixIconColor:
                                    WidgetStateColor.resolveWith((states) {
                                  if (states.contains(WidgetState.focused)) {
                                    return AppColors
                                        .darkBlue; // Color when focused
                                  }
                                  return Colors.grey; // Default color
                                }),
                              ),
                            ),
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
                        ),

                      ValueListenableBuilder<String>(
                        valueListenable: searchQuery,
                        builder: (context, query, _) {
                          List<Value> filteredValues = widget.subFacet!.values
                              .where((item) => getSubFilterName(item.name)
                                  .toLowerCase()
                                  .contains(query.toLowerCase()))
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true, // Allows dynamic expansion
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: widget.showMore
                                    ? filteredValues.length
                                    : filteredValues.length.clamp(0, SHOW3),
                                itemBuilder: (context, index) {
                                  Value item = filteredValues[index];
                                  return getListTile(
                                    value: item.isChecked,
                                    onChanged: (value) {
                                      if (value != null) {
                                        filteredValues[index].isChecked = value;
                                        widget.onChanged(updatingSubFilter);
                                      }
                                    },
                                    title:
                                        '${Helper().capitalizeFirstCharacter(getSubFilterName(item.name))} (${item.count})',
                                    context: context,
                                  );
                                },
                              ),
                              if (filteredValues.length > SHOW3)
                                InkWell(
                                  onTap: () =>
                                      widget.onShowMoreTap(!widget.showMore),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8).r,
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 16)
                                              .r,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: AppColors.darkBlue),
                                        ),
                                      ),
                                      child: Text(
                                        !widget.showMore
                                            ? AppLocalizations.of(context)!
                                                .mMsgSeeMore
                                            : AppLocalizations.of(context)!
                                                .mMsgSeeLess,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: AppColors.darkBlue),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ),
            ],
          );
  }

  ListTile getListTile(
      {required bool value,
      required Function(bool?) onChanged,
      required String title,
      required BuildContext context}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Checkbox(
            value: value,
            activeColor: AppColors.darkBlue,
            onChanged: onChanged,
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 0.45.sw,
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: AppColors.greys60),
            ),
          )
        ],
      ),
      onTap: () => onChanged(!value),
    );
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
}
