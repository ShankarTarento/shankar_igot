import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/events_filter_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class EventsFilterCheckbox extends StatefulWidget {
  final String title;
  final List<EventFilterModel> checkListItems;
  final ValueChanged<List<String>> onChanged;
  final List<String> selectedItems;
  final bool showSelectAll;

  final bool showSearchBar;

  const EventsFilterCheckbox({
    super.key,
    required this.title,
    required this.selectedItems,
    required this.checkListItems,
    required this.onChanged,
    this.showSearchBar = true,
    this.showSelectAll = true,
  });

  @override
  State<EventsFilterCheckbox> createState() => _EventsFilterCheckboxState();
}

class _EventsFilterCheckboxState extends State<EventsFilterCheckbox> {
  List<EventFilterModel> filteredItems = [];
  List<String> selectedItems = [];

  void getCheckboxData() {
    filteredItems = [];
    for (var e in widget.checkListItems) {
      filteredItems.add(
        EventFilterModel(
          title: e.title,
          isSelected: selectedItems
              .map((s) => s.toLowerCase())
              .contains(e.title.id.toLowerCase()),
        ),
      );
    }
    setState(() {});
  }

  void _filterList(String query) {
    filteredItems = widget.checkListItems;

    setState(() {
      filteredItems = filteredItems
          .where((item) =>
              item.title.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void didUpdateWidget(covariant EventsFilterCheckbox oldWidget) {
    selectedItems = widget.selectedItems;

    getCheckboxData();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    selectedItems = widget.selectedItems;
    getCheckboxData();
    super.didChangeDependencies();
  }

  bool showAll = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.w),
        Text(
          widget.title,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 12.w),
        // Search Bar
        widget.showSearchBar
            ? SizedBox(
                height: 45.w,
                width: 1.sw,
                child: TextField(
                  onChanged: _filterList,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.appBarBackground,
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: ModuleColors.grey08, width: 1),
                      borderRadius: BorderRadius.circular(40.0).r,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: ModuleColors.grey08, width: 1),
                      borderRadius: BorderRadius.circular(40.0).r,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: ModuleColors.grey08, width: 1),
                      borderRadius: BorderRadius.circular(40.0).r,
                    ),
                    contentPadding:
                        const EdgeInsets.only(left: 12, right: 12).r,
                    hintText: Helper.capitalizeEachWordFirstCharacter(
                        AppLocalizations.of(context)!.mSearchEvent),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: ModuleColors.greys60,
                    ),
                    hintStyle: GoogleFonts.lato(
                      fontSize: 12.sp,
                      color: ModuleColors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
            : SizedBox(),
        // Checkbox Items
        filteredItems.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: List.generate(
                      filteredItems.length > 5 && !showAll
                          ? 5
                          : filteredItems.length,
                      (index) {
                        return InkWell(
                          onTap: () {
                            filteredItems[index].isSelected =
                                !filteredItems[index].isSelected;
                            setState(() {
                              if (selectedItems
                                  .contains(filteredItems[index].title.id)) {
                                selectedItems
                                    .remove(filteredItems[index].title.id);
                              } else {
                                selectedItems
                                    .add(filteredItems[index].title.id);
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
                              side:
                                  const BorderSide(color: ModuleColors.black40),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(
                                filteredItems[index].title.text,
                                style: GoogleFonts.lato(
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w700,
                                  color: ModuleColors.greys60,
                                ),
                              ),
                              value: filteredItems[index].isSelected,
                              onChanged: (value) {
                                filteredItems[index].isSelected =
                                    !filteredItems[index].isSelected;
                                setState(() {
                                  if (selectedItems.contains(
                                      filteredItems[index].title.id)) {
                                    selectedItems
                                        .remove(filteredItems[index].title.id);
                                  } else {
                                    selectedItems
                                        .add(filteredItems[index].title.id);
                                  }
                                });
                                widget.onChanged(selectedItems);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Show All / View Less Button
                  filteredItems.length > 5
                      ? TextButton(
                          onPressed: () {
                            setState(() {
                              showAll = !showAll;
                            });
                          },
                          style: TextButton.styleFrom(
                              splashFactory: NoSplash.splashFactory),
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
                padding: const EdgeInsets.only(top: 20.0, bottom: 20).r,
                child: Text(AppLocalizations.of(context)!.mMsgNoDataFound),
              )),
        SizedBox(height: 16.w)
      ],
    );
  }
}
