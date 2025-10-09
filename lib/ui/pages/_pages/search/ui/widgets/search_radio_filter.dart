import 'package:flutter/material.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../util/index.dart';
import '../../models/composite_search_model.dart';

class SearchRadioFilterWidget extends StatefulWidget {
  final List<Value> values;
  final ValueChanged<List<Value>> onChanged;

  const SearchRadioFilterWidget(
      {super.key, required this.values, required this.onChanged});

  @override
  State<SearchRadioFilterWidget> createState() =>
      _SearchRadioFilterWidgetState();
}

class _SearchRadioFilterWidgetState extends State<SearchRadioFilterWidget> {
  List<Value> filteredItems = [];
  String? selectedItem;
  @override
  void initState() {
    super.initState();
    filteredItems = widget.values;
    getSelectedItem();
  }

  @override
  void didUpdateWidget(SearchRadioFilterWidget oldWidget) {
    bool isSelsected = false;
    widget.values.forEach((element) {
      if (element.isChecked) {
        isSelsected = true;
      }
    });
    if (widget.values.length != oldWidget.values.length) {
      filteredItems = widget.values;
    }
    if (!isSelsected) {
      selectedItem = null;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 16.w,
        ),
        Column(
          children: List.generate(
            filteredItems.length,
            (index) => InkWell(
              onTap: () {
                updateFilter(filteredItems[index].name, index);
                setState(() {
                  selectedItem = filteredItems[index].name;
                });
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(bottom: 25).r,
                height: 20.w,
                child: Row(
                  children: [
                    Radio(
                      value: filteredItems[index].name,
                      groupValue: selectedItem,
                      onChanged: (String? value) {
                        updateFilter(value, index);
                        setState(() {
                          selectedItem = value!;
                        });
                      },
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return ModuleColors.darkBlue;
                          }
                          return ModuleColors.black40;
                        },
                      )
                    ),
                    Text(
                      filteredItems[index].count > 0
                          ? '${Helper().capitalizeFirstCharacter(filteredItems[index].name)} (${filteredItems[index].count})'
                          : Helper().capitalizeFirstCharacter(
                              filteredItems[index].name),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: AppColors.greys60),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 16.w,
        )
      ],
    );
  }

  void updateFilter(String? value, int index) {
    if (selectedItem != value) {
      filteredItems = [
        ...filteredItems.map((value) => value.copyWith(isChecked: false)),
      ];
      filteredItems[index].isChecked = true;
      widget.onChanged(filteredItems);
    }
  }

  void getSelectedItem() {
    Value? value =
        filteredItems.where((values) => values.isChecked).firstOrNull;

    if (value != null) {
      selectedItem = value.name;
    }
  }
}
