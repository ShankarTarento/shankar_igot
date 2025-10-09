import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import './../../../constants/index.dart';
import './../../../util/helper.dart';

class Author extends StatelessWidget {
  final String name;
  final String designation;

  Author({required this.name, required this.designation});

  @override
  Widget build(BuildContext context) {
    // print('name:' + name);
    return Container(
      width: 1.sw,
      color: AppColors.black40.withValues(alpha: 0.1),
      margin: EdgeInsets.only(bottom: 5.0, left: 16, right: 16).r,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom:
                    BorderSide(color: AppColors.lightBackground, width: 2.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(15.0).r,
                  child: Container(
                    height: 48.w,
                    width: 48.w,
                    decoration: BoxDecoration(
                      color: AppColors.positiveLight,
                      borderRadius:
                          BorderRadius.all(const Radius.circular(4.0).r),
                    ),
                    child: Center(
                      child: Text(
                        Helper.getInitialsNew(name),
                        style:
                            GoogleFonts.lato(color: AppColors.appBarBackground),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 0.65.sw,
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.displayLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0).r,
                          child: Text(
                            designation,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
