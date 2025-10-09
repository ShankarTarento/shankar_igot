import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/discussion/add_discussion/_widgets/field_title_widget.dart';

class SimpleDropdownFormField extends StatefulWidget {
  final List<String>? items;
  final String? selectedItem;
  final ValueChanged<String>? parentAction;
  final bool? isMandatory;
  final String? helperText;
  final String? fieldTitle;

  SimpleDropdownFormField({Key? key, this.items, this.selectedItem,
    this.parentAction, this.isMandatory = false, this.helperText, this.fieldTitle}) : super(key: key);

  @override
  _SimpleDropdownFormFieldState createState() => _SimpleDropdownFormFieldState();
}

class _SimpleDropdownFormFieldState extends State<SimpleDropdownFormField> {
  late String dropdownValue;
  late List<String> dropdownItems;

  @override
  void initState() {
    super.initState();
    dropdownItems = widget.items?.toSet().toList() ?? [];
    initializeDropdown();
  }

  void initializeDropdown() {
    setState(() {
      dropdownValue = widget.selectedItem ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.fieldTitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8).r,
            child: FieldTitleWidget(
                fieldName: widget.fieldTitle!,
                isMandatory: widget.isMandatory!
            ),
          ),
        DropdownButtonFormField<String>(
          value: dropdownValue.isNotEmpty ? dropdownValue : null,
          icon: Icon(Icons.keyboard_arrow_down_sharp),
          iconSize: 24.w,
          elevation: 16,
          style: TextStyle(
            color: AppColors.greys87,
            overflow: TextOverflow.ellipsis,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(
                color: AppColors.grey24,
                width: 1.r,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(
                color: AppColors.grey24,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(
                color: AppColors.darkBlue,
                width: 2,
              ),
            ),
          ),
          selectedItemBuilder: (BuildContext context) {
            return dropdownItems.map<Widget>((String item) {
              return Container(
                width: 0.7.sw,
                child: Row(
                  children: [
                    SizedBox(
                      width: 0.7.sw,
                      child: HtmlWidget(
                        item,
                        textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          onChanged: (String? newValue) {
            setState(() {
              dropdownValue = newValue ?? '';
              if (newValue != null) {
                widget.parentAction?.call(newValue);
              }
            });
          },
          items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: HtmlWidget(value),
            );
          }).toList(),
        ),
        if (widget.helperText != null)
          Container(
              width: double.maxFinite,
              padding: EdgeInsets.only(top: 4.0, bottom: 4.0).w,
              child: Text(
                widget.helperText!,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.grey40,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.0.sp,
                ),
              )
          )
      ],
    );
  }
}
