import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/microsites_training_calender_data_model.dart';

class MicroSitesSelectMonthBottomSheet extends StatefulWidget {
  final List<MicroSitesTrainingCalenderMonthData>? monthList;
  final MicroSitesTrainingCalenderMonthData? month;
  final ValueChanged<MicroSitesTrainingCalenderMonthData>? applyMonth;
  MicroSitesSelectMonthBottomSheet(
      {Key? key, this.monthList, this.month, this.applyMonth})
      : super(key: key);

  @override
  State<MicroSitesSelectMonthBottomSheet> createState() =>
      _MicroSitesSelectMonthBottomSheetState();
}

class _MicroSitesSelectMonthBottomSheetState
    extends State<MicroSitesSelectMonthBottomSheet> {
  MicroSitesTrainingCalenderMonthData? selectedMonth;

  @override
  void initState() {
    selectedMonth = widget.month;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 24, bottom: 24).w,
            width: 80.w,
            height: 8.w,
            decoration: BoxDecoration(
                color: AppColors.grey40,
                borderRadius: BorderRadius.circular(16)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0).w,
          child: Text(
            AppLocalizations.of(context)!.mMicroSiteMonth,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
        ),
        Divider(
          color: AppColors.darkGrey,
          thickness: 1.w,
        ),
        widget.monthList!.isNotEmpty
            ? Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                        widget.monthList!.length,
                        (index) => GestureDetector(
                              onTap: () {
                                selectedMonth = widget.monthList![index];
                                setState(() {});
                                widget.applyMonth!(widget.monthList![index]);
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                        top: 12.0,
                                        bottom: 12,
                                        left: 16,
                                        right: 16)
                                    .w,
                                child: Text(
                                    "${Helper.capitalizeFirstLetter(widget.monthList![index].monthName!)} ${widget.monthList![index].yearOfMonth}",
                                    style: selectedMonth ==
                                            widget.monthList![index]
                                        ? GoogleFonts.lato(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.darkBlue,
                                            height: 1.5.w)
                                        : GoogleFonts.lato(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.greys,
                                            height: 1.5.w,
                                          )),
                              ),
                            )),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(
                        top: 12.0, bottom: 12, left: 16, right: 16)
                    .w,
                child:
                    Text(AppLocalizations.of(context)!.mMicroSiteNoMonthFound,
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greys,
                          height: 1.5.w,
                        )),
              ),
      ],
    );
  }
}
