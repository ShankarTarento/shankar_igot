import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/utils/helper.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_category_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomFilterCheckBox extends StatefulWidget {
  final String title;
  final List<FilterModel> checkListItems;
  final ValueChanged<List<String>> onChanged;
  final bool isMandatory;
  final bool showNA;

  const CustomFilterCheckBox({
    super.key,
    required this.title,
    required this.isMandatory,
    required this.checkListItems,
    required this.onChanged,
    required this.showNA,
  });

  @override
  State<CustomFilterCheckBox> createState() => _CustomFilterCheckBoxState();
}

class _CustomFilterCheckBoxState extends State<CustomFilterCheckBox> {
  List<FilterModel> filteredItems = [];
  List<String> selectedItems = [];
  bool isValid = true;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.checkListItems;
  }

  bool enableNA = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldNameWidget(
            isMandatory: widget.isMandatory, fieldName: widget.title),
        Column(
          children: List.generate(filteredItems.length, (index) {
            return InkWell(
              onTap: () {
                setState(() {
                  if (selectedItems.contains(filteredItems[index].title)) {
                    selectedItems.remove(filteredItems[index].title);
                  } else {
                    selectedItems.add(filteredItems[index].title);
                  }
                  if (selectedItems.isNotEmpty && enableNA) {
                    enableNA = !enableNA;
                  }
                  if (widget.isMandatory && selectedItems.isEmpty) {
                    isValid = false;
                  } else {
                    isValid = true;
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
                  side: const BorderSide(color: ModuleColors.black40),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    ModuleHelper.capitalize(filteredItems[index].title),
                    style: GoogleFonts.lato(
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w700,
                      color: ModuleColors.greys60,
                    ),
                  ),
                  value: selectedItems.contains(filteredItems[index].title),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedItems.add(filteredItems[index].title);
                      } else {
                        selectedItems.remove(filteredItems[index].title);
                      }
                      if (selectedItems.isNotEmpty && enableNA) {
                        enableNA = !enableNA;
                      }
                      if (widget.isMandatory && selectedItems.isEmpty) {
                        isValid = false;
                      } else {
                        isValid = true;
                      }
                    });
                    widget.onChanged(selectedItems);
                  },
                ),
              ),
            );
          }),
        ),
        widget.showNA
            ? Column(
                children: [
                  SizedBox(
                    height: 32.w,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        enableNA = !enableNA;

                        if (enableNA) {
                          filteredItems.forEach((item) {
                            item.isSelected = false;
                          });
                          selectedItems.clear();
                        }

                        if (widget.isMandatory && selectedItems.isEmpty) {
                          isValid = false;
                        } else {
                          isValid = true;
                        }
                      });
                      widget.onChanged(selectedItems);
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Container(
                      height: 20.w,
                      child: Row(
                        children: [
                          Radio(
                            value: true,
                            toggleable: true,
                            groupValue: enableNA,
                            onChanged: (bool? value) {
                              setState(() {
                                enableNA = !enableNA;

                                if (enableNA) {
                                  filteredItems.forEach((item) {
                                    item.isSelected = false;
                                  });
                                  selectedItems.clear();
                                }
                                if (widget.isMandatory &&
                                    selectedItems.isEmpty) {
                                  isValid = false;
                                } else {
                                  isValid = true;
                                }
                              });
                              widget.onChanged(selectedItems);
                            },
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                              (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.darkBlue;
                                }
                                return AppColors.black40;
                              },
                            ),
                          ),
                          Text(
                            "N/A",
                            style: GoogleFonts.lato(
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.greys60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            : SizedBox(),
        if (!isValid && widget.isMandatory)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8).r,
            child: Text(
              AppLocalizations.of(context)!.mThisFieldIsRequired,
              style: GoogleFonts.lato(
                fontSize: 11.0.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.mandatoryRed,
              ),
            ),
          ),
      ],
    );
  }
}
