import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class CustomDropDown extends StatefulWidget {
  String? value;
  final String title;
  final bool isMandatory;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final GlobalKey<FormState> formKey;

  CustomDropDown(
      {Key? key,
      this.value,
      required this.title,
      required this.isMandatory,
      required this.items,
      required this.onChanged,
      required this.formKey})
      : super(key: key);

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  bool enableNA = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 1.sw,
          child: FieldNameWidget(
              isMandatory: widget.isMandatory, fieldName: widget.title),
        ),
        SizedBox(
          height: 16.w,
        ),
        SizedBox(
          // height: 45.w,
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            decoration: InputDecoration(
              fillColor: AppColors.appBarBackground,
              contentPadding: const EdgeInsets.only(bottom: 6).r,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.grey16),
                  borderRadius: BorderRadius.circular(5).r),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.grey16),
                  borderRadius: BorderRadius.circular(5).r),
              filled: true,
            ),
            selectedItemBuilder: (context) => widget.items
                .map((item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        Helper.capitalize(item),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            value: widget.value,
            items: widget.items.isNotEmpty
                ? widget.items
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            Helper.capitalize(item),
                            style: GoogleFonts.lato(
                              color: widget.value == item
                                  ? AppColors.darkBlue
                                  : AppColors.greys,
                              fontSize: 14.sp,
                              fontWeight: widget.value == item
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ))
                    .toList()
                : [],
            onChanged: (value) {
              widget.value = value;
              widget.onChanged(value);

              setState(() {
                widget.formKey.currentState?.validate() ?? false;
              });
            },
            style: GoogleFonts.lato(
                color: AppColors.greys,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400),
            buttonStyleData: ButtonStyleData(
                height: 40.w, padding: EdgeInsets.symmetric(horizontal: 10).r),
            iconStyleData: const IconStyleData(
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.black45),
                iconSize: 20),
            dropdownStyleData: DropdownStyleData(
                padding: const EdgeInsets.symmetric(horizontal: 10).r,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5).r,
                    border: Border.all(color: AppColors.grey16))),
            menuItemStyleData:
                const MenuItemStyleData(padding: EdgeInsets.all(0)),
            hint: Text(AppLocalizations.of(context)!.mStaticSelectHere),
            validator: (value) {
              if (widget.isMandatory &&
                  (widget.value == null || widget.value == "")) {
                if (enableNA) {
                  return null;
                }
                return AppLocalizations.of(context)!.mSelectAnOption;
              }
              return null;
            },
          ),
        ),
        Column(
          children: [
            SizedBox(
              height: 12.w,
            ),
            InkWell(
              onTap: () {
                setState(() {
                  widget.value = null;
                  enableNA = !enableNA;
                });
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
                          widget.value = null;
                          enableNA = !enableNA;
                        });
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
      ],
    );
  }
}
