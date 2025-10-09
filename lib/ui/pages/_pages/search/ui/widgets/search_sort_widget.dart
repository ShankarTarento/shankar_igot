import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';
import '../../utils/search_helper.dart';

class SearchSortWidget extends StatefulWidget {
  final Function(String) callBackWithSortBy;
  final String selectedOption;
  final bool isEvent;
  final bool isPeople;
  final bool isCommunity;
  final bool isContent;
  final bool isExternalContent;
  final bool isResource;

  const SearchSortWidget(
      {super.key,
      required this.callBackWithSortBy,
      required this.selectedOption,
      this.isEvent = false,
      this.isPeople = false,
      this.isCommunity = false,
      this.isContent = false,
      this.isExternalContent = false,
      this.isResource = false});
  @override
  State<SearchSortWidget> createState() => SearchSortWidgetState();
}

class SearchSortWidgetState extends State<SearchSortWidget> {
  String selectedOption = SortBy.mostRelevant;
  Map<String, dynamic> sortBy = {};

  @override
  void initState() {
    selectedOption = widget.selectedOption;
    super.initState();
  }

  @override
  void didUpdateWidget(SearchSortWidget oldWidget) {
    if (!(oldWidget.isEvent == widget.isEvent &&
        oldWidget.isCommunity == widget.isCommunity &&
        oldWidget.isContent == widget.isContent &&
        oldWidget.isExternalContent == widget.isExternalContent &&
        oldWidget.isPeople == widget.isPeople &&
        oldWidget.isResource == widget.isResource)) {
      selectedOption = SortBy.mostRelevant;
    } else if (oldWidget.selectedOption != widget.selectedOption) {
      selectedOption = widget.selectedOption;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
            padding: EdgeInsets.all(16).r,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.mCommonSortBy,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: AppColors.greys),
                  ),
                  InkWell(
                    onTap: () {
                      widget.callBackWithSortBy(selectedOption);
                    },
                    child: Container(
                      width: 0.3.sw,
                      padding: EdgeInsets.symmetric(vertical: 6).r,
                      child: Text(
                        AppLocalizations.of(context)!.mCommonClose,
                        textAlign: TextAlign.right,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColors.negativeLight),
                      ),
                    ),
                  )
                ])),
        Container(
          width: 1.0.sw,
          height: 2.w,
          color: AppColors.grey08,
        ),
        Padding(
          padding: EdgeInsets.all(16).r,
          child: Column(
            children: [
              sortOptionWidget(
                  context: context,
                  setState: setState,
                  title: AppLocalizations.of(context)!.mSearchMostRelevant,
                  value: SortBy.mostRelevant),
              if (widget.isPeople)
                sortOptionWidget(
                    context: context,
                    setState: setState,
                    title: 'A-Z',
                    value: SortBy.aToZ),
              if (widget.isPeople)
                sortOptionWidget(
                    context: context,
                    setState: setState,
                    title: 'Z-A',
                    value: SortBy.zToA),
              sortOptionWidget(
                  context: context,
                  setState: setState,
                  title: AppLocalizations.of(context)!.mSearchRecentlyAdded,
                  value:
                      widget.isPeople ? SortBy.createdDate : SortBy.createdOn),
              if (!(widget.isEvent ||
                  widget.isCommunity ||
                  widget.isPeople ||
                  widget.isResource ||
                  widget.isExternalContent))
                sortOptionWidget(
                    context: context,
                    setState: setState,
                    title: AppLocalizations.of(context)!.mSearchHighestRated,
                    value: SortBy.avgRating)
            ],
          ),
        )
      ],
    );
  }

  RadioListTile<String> sortOptionWidget(
      {required BuildContext context,
      required StateSetter setState,
      required String title,
      required String value}) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: AppColors.greys60),
      ),
      value: value,
      groupValue: selectedOption,
      activeColor: AppColors.darkBlue,
      onChanged: (value) {
        setState(() {
          selectedOption = value!;
        });
      },
    );
  }
}
