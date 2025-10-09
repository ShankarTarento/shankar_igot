import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/utils/module_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/models/_models/gyaan_karmayogi_category_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../../../../constants/index.dart';

// ignore: must_be_immutable
class CustomRadioButton extends StatefulWidget {
  final String title;
  final List<FilterModel> checkListItems;
  final ValueChanged<String> onChanged;
  final bool isMandatory;
  String? selectedItem;
  final bool showNA;

  CustomRadioButton({
    super.key,
    required this.isMandatory,
    required this.title,
    required this.checkListItems,
    required this.onChanged,
    this.selectedItem,
    required this.showNA,
  });

  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  List<FilterModel> radioItems = [];

  @override
  void initState() {
    super.initState();
    radioItems = widget.checkListItems;
    if (widget.showNA) {
      radioItems.add(FilterModel(title: "N/A"));
    }
    widget.selectedItem;
  }

  bool enableNA = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldNameWidget(
            isMandatory: widget.isMandatory, fieldName: widget.title),
        SizedBox(
          height: 16.w,
        ),
        Column(
          children: List.generate(
            radioItems.length,
            (index) => InkWell(
              onTap: () {
                setState(() {
                  widget.selectedItem = radioItems[index].title;
                });
                widget.onChanged(radioItems[index].title);
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(bottom: 25).r,
                height: 20.w,
                child: Row(
                  children: [
                    Radio(
                      value: radioItems[index].title,
                      groupValue: widget.selectedItem,
                      onChanged: (String? value) {
                        setState(() {
                          widget.selectedItem = value;
                        });
                        widget.onChanged(value!);
                      },
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return ModuleColors.darkBlue;
                          }
                          return ModuleColors.black40;
                        },
                      ),
                    ),
                    Text(
                      radioItems[index].title,
                      style: GoogleFonts.lato(
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                        color: ModuleColors.greys60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.isMandatory &&
            (widget.selectedItem == null || widget.selectedItem == "")) ...[
          SizedBox(height: 8.w),
          Padding(
            padding: const EdgeInsets.only(left: 8.0).r,
            child: Text(
              AppLocalizations.of(context)!.mSelectAnOption,
              style: TextStyle(
                color: AppColors.mandatoryRed,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
