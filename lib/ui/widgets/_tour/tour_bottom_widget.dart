import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../respositories/_respositories/settings_repository.dart';

class TourBottomWidget extends StatefulWidget {
  final String title;
  final String description;
  final String insidetitle;
  final VoidCallback onTap;
  final bool isTapped;
  final bool isPreviousTapped;
  final VoidCallback onPerviousTap;
  final IconData icon;
  final VoidCallback onCloseTap;

  TourBottomWidget(
      {required this.title,
      required this.description,
      required this.insidetitle,
      required this.onTap,
      required this.onPerviousTap,
      required this.icon,
      this.isTapped = false,
      this.isPreviousTapped = false,
      required this.onCloseTap});
  @override
  State<TourBottomWidget> createState() => _TourBottomWidgetState();
}

class _TourBottomWidgetState extends State<TourBottomWidget> {
  bool isTablet = false;
  @override
  void initState() {
    super.initState();
    isTablet =
        Provider.of<SettingsRepository>(context, listen: false).itsTablet;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.94.sh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          closeWidget(),
          ClipPath(
            clipper: BottomClipper(),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.zero.r,
                    height: 430.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                              bottomLeft: (Radius.elliptical(100, 0)),
                              bottomRight: Radius.elliptical(100, 0))
                          .r,
                      color: AppColors.darkBlue,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 130.w),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35).r,
                          child: Text(widget.title,
                              style: GoogleFonts.lato(
                                  decoration: TextDecoration.none,
                                  color: AppColors.avatarText,
                                  fontSize: 20.sp,
                                  letterSpacing: 0.12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5.w)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 8)
                              .r,
                          child: Text(widget.description,
                              maxLines: 2,
                              style: GoogleFonts.lato(
                                  decoration: TextDecoration.none,
                                  color: AppColors.avatarText,
                                  fontSize: 14.sp,
                                  letterSpacing: 0.12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5.w)),
                        ),
                        SizedBox(height: 20.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: widget.onPerviousTap,
                              child: Text(
                                  AppLocalizations.of(context)!.mTourPrevious,
                                  style: GoogleFonts.lato(
                                      decoration: TextDecoration.none,
                                      color: AppColors.avatarText,
                                      fontSize: 14.sp,
                                      letterSpacing: 0.12,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5.w)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.black40,
                                    borderRadius: BorderRadius.circular(100).r,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.black40,
                                    borderRadius: BorderRadius.circular(100).r,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Container(
                                  width: 15.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.verifiedBadgeIconColor,
                                    borderRadius: BorderRadius.circular(100).r,
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.black40,
                                    borderRadius: BorderRadius.circular(100).r,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text(
                                  AppLocalizations.of(context)!.mTourNext,
                                  style: GoogleFonts.lato(
                                      decoration: TextDecoration.none,
                                      color: AppColors.orangeTourText,
                                      fontSize: 14.sp,
                                      letterSpacing: 0.12,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5.w)),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.w),
                        Padding(
                          padding:
                              EdgeInsets.only(right: isTablet ? 0.3.sw : 87.w),
                          child: Transform.translate(
                            offset: Offset(0, 10),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                width: 120.w,
                                height: 120.w,
                                decoration: BoxDecoration(
                                  color: AppColors.orangeTourText,
                                  borderRadius: BorderRadius.circular(100).r,
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 80.w,
                                        height: 80.w,
                                        decoration: BoxDecoration(
                                            color: AppColors.appBarBackground,
                                            borderRadius:
                                                BorderRadius.circular(100).r),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                            child: Icon(
                                          widget.icon,
                                          size: 25.sp,
                                          color: AppColors.black40,
                                        )),
                                        Text(widget.insidetitle,
                                            style: GoogleFonts.lato(
                                                decoration: TextDecoration.none,
                                                color: AppColors.black40,
                                                fontSize: 14.sp,
                                                letterSpacing: 0.12,
                                                fontWeight: FontWeight.w400,
                                                height: 1.5.w)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget closeWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 30, right: 10).r,
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
                color: AppColors.black40,
                borderRadius: BorderRadius.circular(100).r),
            child: IconButton(
                padding: EdgeInsets.zero.r,
                onPressed: widget.onCloseTap,
                icon: Icon(
                  Icons.close,
                  size: 15.sp,
                  color: AppColors.appBarBackground,
                ))),
      ),
    );
  }
}

class BottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height); // Start from the bottom-left corner
    path.lineTo(size.width, size.height); // Move to the bottom-right corner
    path.lineTo(size.width,
        120); // Create a straight line at a desired height from the bottom
    path.quadraticBezierTo(size.width / 2, 0, 0,
        120); // Create a curve connecting to the top-left corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class SemiCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = new Path();
    path.lineTo(0.0, size.height / 1.4);
    path.lineTo(size.width, size.height / 1.4);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
