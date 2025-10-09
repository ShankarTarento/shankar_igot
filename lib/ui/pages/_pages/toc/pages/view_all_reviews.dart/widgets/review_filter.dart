import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class ReviewFilter extends StatefulWidget {
  final ValueChanged<int> onChanged;
  final int selectedIndex;
  const ReviewFilter(
      {Key? key, required this.onChanged, required this.selectedIndex})
      : super(key: key);

  @override
  State<ReviewFilter> createState() => _ReviewFilterState();
}

class _ReviewFilterState extends State<ReviewFilter> {
  @override
  void initState() {
    selectedIndex = widget.selectedIndex;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    filter = [
      AppLocalizations.of(context)!.mStaticLatestReviews,
      AppLocalizations.of(context)!.mStaticTopReviews
    ];
  }

  int? selectedIndex;

  List<String> filter = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 315.0.w,
      color: AppColors.appBarBackground,
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 8.w,
            margin: EdgeInsets.only(top: 24, bottom: 24).r,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(60).r,
                color: AppColors.greys60),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0).r,
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.mStaticFilterResults,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: AppColors.black40,
          ),
          ...List.generate(
            2,
            (index) => GestureDetector(
              onTap: () {
                selectedIndex = index;
                setState(() {});
              },
              child: ratingFilter(
                index: index,
                title: filter[index],
              ),
            ),
          ),
          Divider(
            color: AppColors.black40,
          ),
          SizedBox(
            height: 12.w,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 160.w,
                height: 40.w,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.appBarBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(63.0).w,
                      side: BorderSide(color: AppColors.darkBlue, width: 1.0.w),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.mStaticCancel,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 160.w,
                height: 40.w,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onChanged(selectedIndex!);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(63.0).w,
                      side: BorderSide(color: AppColors.darkBlue, width: 1.0.w),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!
                        .mCompetenciesContentTypeApplyFilters,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.appBarBackground,
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget ratingFilter({required String title, required int index}) {
    return Padding(
      padding: const EdgeInsets.all(8.0).r,
      child: Container(
        width: 1.sw,
        color: Colors.transparent,
        height: 25,
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 8, right: 8).r,
              height: 18.w,
              width: 18.w,
              padding: EdgeInsets.all(2).r,
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedIndex == index
                      ? AppColors.darkBlue
                      : AppColors.greys60,
                ),
                borderRadius: BorderRadius.circular(9).r,
              ),
              child: Container(
                height: 16.w,
                width: 16.w,
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? AppColors.darkBlue
                      : AppColors.appBarBackground,
                  borderRadius: BorderRadius.circular(8).r,
                ),
              ),
            ),
            Text(
              title,
              style: selectedIndex == index
                  ? GoogleFonts.lato(
                      color: AppColors.darkBlue,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    )
                  : GoogleFonts.lato(
                      color: AppColors.greys60,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
