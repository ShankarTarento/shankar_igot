import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/utils/helper.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_category_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FilterCheckboxV2 extends StatefulWidget {
  final String title;
  final List<FilterModel> checkListItems;
  final ValueChanged<List<String>> onChanged;
  final String searchHint;
  final List<String> selectedItems;

  const FilterCheckboxV2({
    super.key,
    required this.title,
    required this.selectedItems,
    required this.searchHint,
    required this.checkListItems,
    required this.onChanged,
  });

  @override
  State<FilterCheckboxV2> createState() => _FilterCheckboxV2State();
}

class _FilterCheckboxV2State extends State<FilterCheckboxV2> {
  List<FilterModel> filteredItems = [];
  List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    getCheckboxData();
  }

  void _filterList(String query) {
    getCheckboxData();
    setState(() {
      filteredItems = filteredItems
          .where(
              (item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  getCheckboxData() {
    filteredItems = [];
    for (var e in widget.checkListItems) {
      filteredItems.add(
        FilterModel(
          title: e.title,
          isSelected: widget.selectedItems.isEmpty ||
              widget.selectedItems
                  .map((s) => s.toLowerCase())
                  .contains(e.title.toLowerCase()),
        ),
      );
    }

    if (widget.selectedItems.isNotEmpty) {
      selectedItems = widget.selectedItems;
    } else {
      selectedItems.addAll(widget.checkListItems.map((e) => e.title).toList());
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant FilterCheckboxV2 oldWidget) {
    if (oldWidget.checkListItems != widget.checkListItems) {
      getCheckboxData();
    }

    super.didUpdateWidget(oldWidget);
  }

  bool showAll = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16.w,
        ),
        Text(
          widget.title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 12.w,
        ),
        SizedBox(
          height: 45.w,
          width: 1.sw,
          child: TextField(
            onChanged: _filterList,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.appBarBackground,
              border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: ModuleColors.grey08, width: 1),
                borderRadius: BorderRadius.circular(40.0).r,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: ModuleColors.grey08, width: 1),
                borderRadius: BorderRadius.circular(40.0).r,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: ModuleColors.grey08, width: 1),
                borderRadius: BorderRadius.circular(40.0).r,
              ),
              contentPadding: const EdgeInsets.only(left: 12, right: 12).r,
              hintText: widget.searchHint,
              prefixIcon: const Icon(
                Icons.search,
                color: ModuleColors.greys87,
              ),
              hintStyle: GoogleFonts.lato(
                fontSize: 12.sp,
                color: ModuleColors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        filteredItems.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: List.generate(
                      filteredItems.length > 5 && !showAll
                          ? 5
                          : filteredItems.length + 1,
                      (index) {
                        if (index == 0) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                bool allSelected = selectedItems.length ==
                                    filteredItems.length;
                                if (allSelected) {
                                  selectedItems.clear();
                                  for (var item in filteredItems) {
                                    item.isSelected = false;
                                  }
                                } else {
                                  selectedItems.clear();
                                  for (var item in filteredItems) {
                                    item.isSelected = true;
                                    selectedItems.add(item.title);
                                  }
                                }
                              });
                              widget.onChanged(selectedItems);
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 25).r,
                              height: 20.w,
                              child: CheckboxListTile(
                                activeColor: ModuleColors.darkBlue,
                                side: const BorderSide(
                                    color: ModuleColors.black40),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(
                                  'Select All',
                                  style: GoogleFonts.lato(
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w700,
                                    color: ModuleColors.greys60,
                                  ),
                                ),
                                value: selectedItems.length ==
                                    filteredItems.length,
                                onChanged: (value) {},
                              ),
                            ),
                          );
                        } else {
                          return InkWell(
                            onTap: () {
                              filteredItems[index - 1].isSelected =
                                  !filteredItems[index - 1].isSelected;

                              setState(() {
                                if (selectedItems
                                    .contains(filteredItems[index - 1].title)) {
                                  selectedItems
                                      .remove(filteredItems[index - 1].title);
                                } else {
                                  selectedItems
                                      .add(filteredItems[index - 1].title);
                                }
                              });
                              widget.onChanged(selectedItems);
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 25).r,
                              height: 20.w,
                              child: CheckboxListTile(
                                activeColor: ModuleColors.darkBlue,
                                side: const BorderSide(
                                    color: ModuleColors.black40),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(
                                  ModuleHelper.capitalize(
                                      filteredItems[index - 1].title),
                                  style: GoogleFonts.lato(
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w700,
                                    color: ModuleColors.greys60,
                                  ),
                                ),
                                value: filteredItems[index - 1].isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    filteredItems[index - 1].isSelected =
                                        value ?? false;
                                    if (selectedItems.contains(
                                            filteredItems[index - 1].title) &&
                                        !filteredItems[index - 1].isSelected) {
                                      selectedItems.remove(
                                          filteredItems[index - 1].title);
                                    } else if (filteredItems[index - 1]
                                            .isSelected ==
                                        true) {
                                      selectedItems
                                          .add(filteredItems[index - 1].title);
                                    }
                                  });
                                  widget.onChanged(selectedItems);
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  filteredItems.length > 5
                      ? TextButton(
                          onPressed: () {
                            showAll = showAll ? false : true;
                            setState(() {});
                          },
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          child: Text(
                            showAll
                                ? AppLocalizations.of(context)!
                                    .mCompetencyViewLessTxt
                                : AppLocalizations.of(context)!.mStaticViewAll,
                            style: GoogleFonts.lato(
                                color: AppColors.darkBlue,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                          ))
                      : SizedBox(),
                ],
              )
            : Center(
                child: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                child: Text(AppLocalizations.of(context)!.mMsgNoDataFound),
              )),
        SizedBox(
          height: 16.w,
        )
      ],
    );
  }
}
