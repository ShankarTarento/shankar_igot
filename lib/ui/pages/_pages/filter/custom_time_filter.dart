import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import './../../../../constants/index.dart';

class CustomTimeFilter extends StatefulWidget {
  @override
  _CustomTimeFilterState createState() => _CustomTimeFilterState();
}

class _CustomTimeFilterState extends State<CustomTimeFilter> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      // dateTimeRangePicker();
    });
  }

  dateTimeRangePicker() async {
    await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: DateTimeRange(
        end: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 2),
        start: DateTime.now(),
      ),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.greys87, //Head background
            dialogBackgroundColor: AppColors.appBarBackground,
            colorScheme: ColorScheme.light().copyWith(
              primary: AppColors.greys87,
            ), //Background color
          ),
          child: Center(),
        );
      },
    );
    // String _selectedDate = new DateFormat.yMMMd('en_US').format(picked).toString();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {dateTimeRangePicker()},
      child: Center(
        child: Container(
          width: 180.w,
          color: AppColors.greys87,
          child: TextButton(
            onPressed: null,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryThree,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8).r,
              ),
            ),
            child: Text(
              'Select date range',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ),
      ),
    );
  }
}
