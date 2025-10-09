import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class SearchInternetCard extends StatefulWidget {
  final Function()? searchInternet;
  const SearchInternetCard({super.key, this.searchInternet});

  @override
  State<SearchInternetCard> createState() => _SearchInternetCardState();
}

class _SearchInternetCardState extends State<SearchInternetCard> {
  bool displayCard = true;

  @override
  Widget build(BuildContext context) {
    return displayCard
        ? Column(
            children: [
              Container(
                  constraints: BoxConstraints(maxWidth: 0.65.sw),
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.blue209,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ).r,
                  ),
                  child: Text(
                    "I couldn't find an answer to that. Would you like me to search the web, or would you like to rephrase your question?",
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.4,
                      color: Colors.black,
                    ),
                  )),
              _buildSearchButtons(),
            ],
          )
        : SizedBox();
  }

  Widget _buildSearchButtons() {
    final ButtonStyle outlinedWhiteButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: AppColors.darkBlue),
      ),
      elevation: 0,
    );

    return SizedBox(
      height: 50.h,
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              if (widget.searchInternet != null) {
                widget.searchInternet!();
              }
            },
            style: outlinedWhiteButtonStyle,
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 16.sp,
                  color: AppColors.darkBlue,
                ),
                SizedBox(width: 4.w),
                Text(
                  "Search the web",
                  style: GoogleFonts.lato(
                    color: AppColors.darkBlue,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: () {
              setState(() {
                displayCard = false;
              });
            },
            style: outlinedWhiteButtonStyle,
            child: Row(
              children: [
                Icon(
                  Icons.close,
                  size: 16.sp,
                  color: AppColors.darkBlue,
                ),
                SizedBox(width: 4.w),
                Text(
                  "No",
                  style: GoogleFonts.lato(
                    color: AppColors.darkBlue,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
