import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';
import '../../utils/profile_helper.dart';

final dropdownKey = GlobalKey<DropdownWithSearchState>();

class DropdownWithSearch extends StatefulWidget {
  final String hintText;
  final String query;
  final String? defaultItem;
  final List<String> optionList;
  final String? selectedOption;
  final Function(String)? callback;
  final bool isDisabled;
  final bool isPaginated;
  final VoidCallback? disableCallback;
  final Function(String)? onSearchChanged;
  final BuildContext parentContext;
  final double borderRadius;
  final Color? borderColor;

  const DropdownWithSearch({
    super.key,
    required this.hintText,
    required this.query,
    this.defaultItem,
    required this.optionList,
    this.selectedOption,
    this.callback,
    this.isDisabled = false,
    this.isPaginated = false,
    this.disableCallback,
    this.onSearchChanged,
    required this.parentContext,
    this.borderRadius = 63.0,
    this.borderColor,
  });

  @override
  DropdownWithSearchState createState() => DropdownWithSearchState();
}

class DropdownWithSearchState extends State<DropdownWithSearch> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedOption;
  }

  @override
  void didUpdateWidget(DropdownWithSearch oldWidget) {
    if (widget.selectedOption == null &&
        selectedValue != null &&
        !widget.optionList.contains(selectedValue)) {
      selectedValue = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.isDisabled
          ? widget.disableCallback != null
              ? widget.disableCallback!()
              : null
          : widget.optionList.isNotEmpty
              ? widget.isPaginated
                  ? ProfileHelper().showSearchableBottomSheet(
                      context: context,
                      parentContext: widget.parentContext,
                      items: widget.optionList,
                      defaultItem: widget.defaultItem,
                      onFetchMore: (String query) async {
                        if (widget.onSearchChanged != null) {
                          return widget.onSearchChanged!(query);
                        } else {
                          return [];
                        }
                      },
                      onItemSelected: (String value) async {
                        widget.callback!(value);
                        selectedValue = value;
                      })
                  : showBottomSheetDropdown(context)
              : null,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: AppColors.greys),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.labelLarge,
            isDense: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius).r),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius).r,
              borderSide: widget.borderColor != null
                  ? BorderSide(color: widget.borderColor!)
                  : BorderSide(),
            ),
            suffixIcon: Icon(
              Icons.arrow_drop_down,
              size: 24.sp,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16).r,
          ),
          controller: TextEditingController(text: selectedValue ?? ''),
        ),
      ),
    );
  }

  void showBottomSheetDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        List<String> filteredItems = List.from(widget.optionList);

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.mStaticSearch,
                        hintStyle: Theme.of(context).textTheme.labelLarge,
                        prefixIcon:
                            Icon(Icons.search, color: AppColors.darkBlue),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(63).r,
                          borderSide: BorderSide(color: AppColors.darkBlue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(63).r,
                          borderSide: BorderSide(color: AppColors.darkBlue),
                        ),
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppColors.greys),
                      onChanged: (value) {
                        setSheetState(() {
                          filteredItems = widget.optionList
                              .where((item) => item
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  Container(
                    height: 300.h,
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(horizontal: 0, vertical: -4),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16).r,
                          title: Text(
                            filteredItems[index],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          onTap: () {
                            if (widget.callback != null) {
                              widget.callback!(filteredItems[index]);
                            }
                            selectedValue = filteredItems[index];
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
