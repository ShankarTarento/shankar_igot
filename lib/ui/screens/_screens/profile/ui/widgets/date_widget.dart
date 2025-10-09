import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../constants/index.dart';
import '../../view_model/profile_service_history_view_model.dart';

class DateWidget extends StatelessWidget {
  final DateTime? date;
  final bool isDisabled;
  final Function(DateTime) updateDate;
  final DateTime? startDate;
  final DateTime? endDate;

  const DateWidget(
      {super.key,
      this.date,
      this.isDisabled = false,
      required this.updateDate,
      this.startDate,
      this.endDate});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled
          ? null
          : () async {
              DateTime? picked = await ProfileServiceHistoryViewModel()
                  .selectDate(context,
                      startDate: startDate,
                      endDate: endDate,
                      selectedDate: date);
              if (picked != null && picked != date) {
                updateDate(picked);
              }
            },
      child: Container(
        margin: EdgeInsets.only(top: 8).r,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16).r,
        decoration: BoxDecoration(
            color: isDisabled ? AppColors.grey04 : AppColors.appBarBackground,
            borderRadius: BorderRadius.circular(63).r,
            border: Border.all(color: AppColors.grey24)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                  date != null
                      ? DateFormat('dd MMM yyyy').format(date!)
                      : AppLocalizations.of(context)!.mProfileSelectDate,
                  style: date != null
                      ? Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: AppColors.greys)
                      : Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.date_range, size: 20),
          ],
        ),
      ),
    );
  }
}
