import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class YearSliderFilter extends StatefulWidget {
  final String? title;
  final String startYear;
  final String endYear;
  final String startValue;
  final String endValue;
  final Function(Map) values;
  const YearSliderFilter(
      {super.key,
      this.title,
      required this.values,
      required this.startValue,
      required this.endValue,
      required this.startYear,
      required this.endYear});

  @override
  State<YearSliderFilter> createState() => _YearSliderFilterState();
}

class _YearSliderFilterState extends State<YearSliderFilter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: 16.0).r,
                child: Text(
                  widget.title!,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              )
            : SizedBox(),
        FlutterSlider(
          values: [
            double.parse(widget.startValue),
            double.parse(widget.endValue)
          ],
          max: double.parse(widget.endYear),
          min: double.parse(widget.startYear),
          rangeSlider: true,
          handler: FlutterSliderHandler(
            decoration: BoxDecoration(color: Colors.transparent),
            child: indicator(isLeft: true),
          ),
          rightHandler: FlutterSliderHandler(
            decoration: BoxDecoration(color: Colors.transparent),
            child: indicator(isLeft: false),
          ),
          trackBar: FlutterSliderTrackBar(
            activeTrackBar: BoxDecoration(color: AppColors.darkBlue),
          ),
          tooltip: FlutterSliderTooltip(
            custom: (value) {
              return Container(
                padding: EdgeInsets.all(3).r,
                decoration: BoxDecoration(
                    color: AppColors.learnerTipsColor2,
                    borderRadius: BorderRadius.circular(3).r),
                child: Text(
                  "${value.toInt()}",
                  style: GoogleFonts.lato(
                    fontSize: 12.sp,
                    color: AppColors.greys,
                  ),
                ),
              );
            },
            alwaysShowTooltip: true,
          ),
          onDragCompleted: (handlerIndex, lowerValue, upperValue) {
            widget.values(
                {'years': getRange(start: lowerValue, end: upperValue)});
            print(getRange(start: lowerValue, end: upperValue));
          },
        ),
      ],
    );
  }

  Widget indicator({required bool isLeft}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7).r,
      height: 18.r,
      width: 22.r,
      decoration: BoxDecoration(
        color: AppColors.primaryOne,
        borderRadius: isLeft
            ? BorderRadius.only(
                topLeft: Radius.circular(10).r,
                bottomLeft: Radius.circular(10).r,
              ).r
            : BorderRadius.only(
                topRight: Radius.circular(10).r,
                bottomRight: Radius.circular(10).r,
              ).r,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...List.generate(
            4,
            (index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                3,
                (index) => CircleAvatar(
                  backgroundColor: AppColors.appBarBackground,
                  radius: 1.r,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<String> getRange({required double start, required double end}) {
    List<String> numbers = [];
    for (double i = start; i <= end; i += 1) {
      numbers.add(i.toInt().toString());
    }
    return numbers;
  }
}
