import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/text_input_field.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventsFilterDates extends StatefulWidget {
  final String title;
  final String? startDate;
  final String? endDate;
  final Function(Map<String, String>) onChanged;
  const EventsFilterDates(
      {super.key,
      required this.title,
      required this.onChanged,
      this.startDate,
      this.endDate});

  @override
  State<EventsFilterDates> createState() => _EventsFilterDatesState();
}

class _EventsFilterDatesState extends State<EventsFilterDates> {
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();

  bool isStartDateSelected = false;

  @override
  void didUpdateWidget(covariant EventsFilterDates oldWidget) {
    startDateController.text =
        widget.startDate != null && widget.startDate != ""
            ? DateTimeHelper.convertDateFormat(widget.startDate!,
                desiredFormat: IntentType.dateFormat,
                inputFormat: getDateFormat(widget.startDate!))
            : "";
    isStartDateSelected = startDateController.text.isNotEmpty ? true : false;
    endDateController.text = widget.endDate != null && widget.endDate != ""
        ? DateTimeHelper.convertDateFormat(widget.endDate!,
            desiredFormat: IntentType.dateFormat,
            inputFormat: getDateFormat(widget.endDate!))
        : "";

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    startDateController.text =
        widget.startDate != null && widget.startDate != ""
            ? DateTimeHelper.convertDateFormat(widget.startDate!,
                desiredFormat: IntentType.dateFormat,
                inputFormat: IntentType.dateFormat4)
            : "";
    isStartDateSelected = startDateController.text.isNotEmpty ? true : false;
    endDateController.text = widget.endDate != null && widget.endDate != ""
        ? DateTimeHelper.convertDateFormat(widget.endDate!,
            desiredFormat: IntentType.dateFormat,
            inputFormat: IntentType.dateFormat4)
        : "";

    super.initState();
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate({
    required BuildContext context,
    required TextEditingController controller,
    required String dateType,
    DateTime? startDate,
  }) async {
    DateTime initialDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: startDate ?? initialDate,
      firstDate: startDate ?? DateTime(1900),
      lastDate: DateTime(2200),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateTimeHelper.convertDateFormat(pickedDate.toString(),
            inputFormat: IntentType.dateFormat4,
            desiredFormat: IntentType.dateFormat);
      });
    }

    widget.onChanged({
      "startDate":
          startDateController.text.isNotEmpty ? startDateController.text : "",
      "endDate":
          endDateController.text.isNotEmpty ? endDateController.text : "",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(
          height: 8.w,
        ),
        Text(
          "From:",
          style: GoogleFonts.lato(fontSize: 14.sp, color: AppColors.greys87),
        ),
        SizedBox(
          height: 70.w,
          child: TextInputField(
              controller: startDateController,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              isDate: true,
              hintText: startDateController.text.isNotEmpty
                  ? startDateController.text
                  : Helper.capitalizeEachWordFirstCharacter(
                      AppLocalizations.of(context)!.mEditProfileChooseDate),
              suffixIcon: Icon(
                Icons.date_range,
                size: 24.sp,
                color: AppColors.greys60,
              ),
              onTap: () {
                _selectDate(
                    context: context,
                    controller: startDateController,
                    dateType: 'startDate');
                setState(() {
                  endDateController.text = "";
                  isStartDateSelected = true;
                });
              }),
        ),
        SizedBox(
          height: 4.w,
        ),
        Text(
          "To:",
          style: GoogleFonts.lato(fontSize: 14.sp, color: AppColors.greys87),
        ),
        SizedBox(
          height: 70.w,
          child: TextInputField(
              controller: endDateController,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              isDate: true,
              hintText: endDateController.text.isNotEmpty
                  ? endDateController.text
                  : Helper.capitalizeEachWordFirstCharacter(
                      AppLocalizations.of(context)!.mEditProfileChooseDate),
              suffixIcon: Icon(
                Icons.date_range,
                size: 24.sp,
                color: AppColors.greys60,
              ),
              onTap: isStartDateSelected
                  ? () {
                      _selectDate(
                        startDate: startDateController.text.isNotEmpty
                            ? DateTimeHelper.convertDDMMYYYYtoDateTime(
                                startDateController.text)
                            : null,
                        context: context,
                        controller: endDateController,
                        dateType: 'endDate',
                      );
                    }
                  : null),
        ),
      ],
    );
  }

  String getDateFormat(String dateString) {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateString)) {
      return IntentType.dateFormat4;
    }

    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(dateString)) {
      return IntentType.dateFormat;
    }

    return 'Unknown Format';
  }
}
