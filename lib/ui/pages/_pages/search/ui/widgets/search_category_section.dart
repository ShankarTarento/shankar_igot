import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';
import '../../utils/search_filter_params.dart';

class SearchCategorySection extends StatefulWidget {
  final Function(String) changeSelectCategory;
  final int? selectedFilterIndex;
  final List<SearchCategoryData> categoryList;

  SearchCategorySection(
      {super.key,
      required this.changeSelectCategory,
      this.selectedFilterIndex,
      this.categoryList = const []});

  @override
  State<SearchCategorySection> createState() => _SearchCategorySectionState();
}

class _SearchCategorySectionState extends State<SearchCategorySection> {
  final ScrollController scrollController = ScrollController();
  bool shouldTriggerUpdate = false;
  Locale? locale;
  @override
  void initState() {
    shouldTriggerUpdate = widget.selectedFilterIndex != 0;
    if (shouldTriggerUpdate) {
      triggerCategoryUpdate(widget.categoryList);
    }
    super.initState();
  }

  void triggerCategoryUpdate(List<SearchCategoryData> categoryList) {
    Future.delayed(Duration.zero, () {
      SearchCategoryData? category = categoryList
          .cast<SearchCategoryData?>()
          .firstWhere(
              (element) =>
                  element != null &&
                  element.tabIndex == widget.selectedFilterIndex,
              orElse: () => null);
      if (category != null) {
        widget.changeSelectCategory(category.id);
      }
      shouldTriggerUpdate = false;
    });
  }

  @override
  void didUpdateWidget(SearchCategorySection oldWidget) {
    if (oldWidget.selectedFilterIndex != widget.selectedFilterIndex) {
      scrollToSelected(widget.selectedFilterIndex ?? 0);
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
    locale = Localizations.localeOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50.w,
          margin: EdgeInsets.symmetric(vertical: 8).r,
          child: ListView.builder(
            shrinkWrap: true,
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.categoryList.length,
            itemBuilder: (context, index) {
              SearchCategoryData filter = widget.categoryList[index];
              return InkWell(
                onTap: () {
                  widget.changeSelectCategory(filter.id);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4).r,
                  margin: EdgeInsets.only(
                          left: index == 0 ? 16 : 8,
                          top: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 8
                              : 24,
                          bottom: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 8
                              : 24,
                          right:
                              index == widget.categoryList.length - 1 ? 16 : 0)
                      .r,
                  decoration: BoxDecoration(
                      color: index == widget.selectedFilterIndex
                          ? AppColors.darkBlue
                          : AppColors.appBarBackground,
                      borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? 20
                                  : 26)
                          .r),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      filter.tabIcon != null
                          ? Padding(
                              padding: const EdgeInsets.only(right: 8.0).r,
                              child: Icon(filter.tabIcon,
                                  size: MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? 20.sp
                                      : 16.sp,
                                  color: index == widget.selectedFilterIndex
                                      ? AppColors.appBarBackground
                                      : AppColors.greys60),
                            )
                          : SizedBox(),
                      Text(getLocaleBasedText(filter),
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(
                                  color: index == widget.selectedFilterIndex
                                      ? AppColors.appBarBackground
                                      : AppColors.btnSecondaryColor)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void scrollToSelected(int index) {
    double itemWidth = 100.0; // Approximate width of an item
    double screenWidth = MediaQuery.of(context).size.width;

    // Calculate the target scroll position
    double targetScroll = index * itemWidth - (screenWidth - itemWidth) / 2;
    targetScroll =
        targetScroll.clamp(0, scrollController.position.maxScrollExtent);

    scrollController.animateTo(
      targetScroll,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String getLocaleBasedText(SearchCategoryData data) {
    return locale != null && locale!.languageCode == 'hi'
        ? data.tabNameHi
        : data.tabNameEn;
  }
}
