import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/field_name_widget.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/text_input_field.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // For localization
import 'package:intl/intl.dart';

class CustomDatePicker extends StatefulWidget {
  final String title;
  final bool isMandatory;
  final TextEditingController controller;
  final bool showNA;
  final GlobalKey<FormState> formKey;
  const CustomDatePicker(
      {super.key,
      required this.controller,
      required this.title,
      required this.formKey,
      this.showNA = false,
      required this.isMandatory});

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? _dobDate;
  bool enableNA = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = _dobDate ?? DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );

    if (pickedDate != null) {
      setState(() {
        _dobDate = pickedDate;
        widget.controller.text = DateTimeHelper.convertDateFormat(pickedDate.toString(),
            inputFormat: IntentType.dateFormat4,
            desiredFormat: IntentType.dateFormat);
      });
    }
  }

  String convertDateFormat(String dateString) {
    DateFormat inputFormat = DateFormat(IntentType.dateFormat);
    DateFormat outputFormat = DateFormat(IntentType.dateFormat4);

    DateTime dateTime = inputFormat.parse(dateString);

    return outputFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 0.85.sw,
          child: FieldNameWidget(
              isMandatory: widget.isMandatory, fieldName: widget.title),
        ),
        SizedBox(
          height: 8.w,
        ),
        SizedBox(
          child: TextInputField(
              controller: widget.controller,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              isDate: true,
              hintText: widget.controller.text.isNotEmpty
                  ? widget.controller.text
                  : AppLocalizations.of(context)!.mEditProfileChooseDate,
              suffixIcon: Icon(
                Icons.date_range,
                size: 24.sp,
              ),
              validatorFuntion: (value) {
                if (widget.isMandatory) {
                  if (enableNA) {
                    return null;
                  }
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.mThisFieldIsRequired;
                  }
                  return null;
                }
                return null;
              },
              onTap: () {
                if (enableNA) {
                  enableNA = !enableNA;
                }
                _selectDate(context);
                setState(() {});
              }),
        ),
        widget.showNA
            ? Column(
                children: [
                  SizedBox(
                    height: 12.w,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        enableNA = !enableNA;
                        widget.controller.clear();
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
                                enableNA = !enableNA;
                                widget.controller.clear();
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
            : SizedBox(),
      ],
    );
  }
}
