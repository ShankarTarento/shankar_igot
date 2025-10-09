import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/localization/_langs/english_lang.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../constants/_constants/color_constants.dart';
import '../../../models/index.dart';
import '../../../respositories/_respositories/settings_repository.dart';
import '../../screens/_screens/profile/ui/widgets/profile_picture.dart';

class RoundedBlueClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(
        0,
        size.height -
            120); // Adjust the value to increase or decrease curvature
    path.quadraticBezierTo(size.width / 2, size.height, size.width,
        size.height - 120); // Adjust the value here as well
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class TourWidget extends StatefulWidget {
  final String title;
  final String description;
  final String insidetitle;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isTapped;
  final VoidCallback onPerviousTap;
  final bool isProfileTapped;
  final bool isDiscussTapped;
  final bool isBottomTapped;
  final String? image;
  final VoidCallback onCloseTap;
  final Profile? profileInfo;

  TourWidget(
      {required this.title,
      required this.description,
      required this.insidetitle,
      required this.onPerviousTap,
      required this.onTap,
      required this.onCloseTap,
      this.icon,
      this.isTapped = false,
      this.isProfileTapped = false,
      this.isDiscussTapped = false,
      this.isBottomTapped = false,
      this.image,
      this.profileInfo});
  @override
  State<TourWidget> createState() => _TourWidgetState();
}

class _TourWidgetState extends State<TourWidget> {
  bool isTablet = false;
  @override
  void initState() {
    super.initState();
    isTablet =
        Provider.of<SettingsRepository>(context, listen: false).itsTablet;
  }

  @override
  Widget build(BuildContext context) {
    return widget.isBottomTapped == true
        ? Container()
        : ClipPath(
            clipper: RoundedBlueClipper(),
            child: Container(
              padding: EdgeInsets.zero.r,
              height: widget.isProfileTapped ? 420.w : 450.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                        bottomLeft: (Radius.elliptical(100, 80)),
                        bottomRight: Radius.elliptical(100, 80))
                    .r,
                color: AppColors.darkBlue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isProfileTapped
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4).r,
                              child: Transform.translate(
                                offset: Offset(-10,
                                    0), // Offset to compensate for clipping
                                child: Container(
                                  width: 120.w,
                                  height: 120.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.verifiedBadgeIconColor,
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
                                            child: widget.profileInfo != null
                                                ? ProfilePicture()
                                                : Icon(
                                                    widget.icon,
                                                    size: 30.sp,
                                                    color: AppColors.black40,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            closeWidget()
                          ],
                        )
                      : closeWidget(),
                  Padding(
                    padding: widget.isProfileTapped
                        ? const EdgeInsets.only(top: 0, left: 0).r
                        : isTablet
                            ? EdgeInsets.only(top: 40.w, left: 0.27.sw)
                            : const EdgeInsets.symmetric(horizontal: 16).r,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.isTapped
                            ? Container(
                                width: 120.w,
                                height: 120.w,
                                margin: const EdgeInsets.only(left: 48).r,
                                decoration: BoxDecoration(
                                  color: AppColors.verifiedBadgeIconColor,
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
                                          child: getHubIconWidget(widget.image),
                                        ),
                                        Center(
                                          child: Text(widget.insidetitle,
                                              style: GoogleFonts.lato(
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: AppColors.greys,
                                                  fontSize: 14.sp,
                                                  letterSpacing: 0.12,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.5.w)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : widget.isProfileTapped == false
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 104).r,
                                    child: Container(
                                      width: 120.w,
                                      height: 120.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.verifiedBadgeIconColor,
                                        borderRadius:
                                            BorderRadius.circular(100).r,
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: Container(
                                              width: 80.w,
                                              height: 80.w,
                                              decoration: BoxDecoration(
                                                  color: AppColors
                                                      .appBarBackground,
                                                  borderRadius:
                                                      BorderRadius.circular(100)
                                                          .r),
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                  child: getHubIconWidget(
                                                      widget.image)),
                                              Center(
                                                child: Text(widget.insidetitle,
                                                    style: GoogleFonts.lato(
                                                        decoration:
                                                            TextDecoration.none,
                                                        color: AppColors.greys,
                                                        fontSize: 14.sp,
                                                        letterSpacing: 0.12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.5.w)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                        SizedBox(height: 5.w),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35).r,
                          child: Text(widget.title,
                              style: GoogleFonts.lato(
                                  decoration: TextDecoration.none,
                                  color: Color.fromRGBO(255, 255, 255, 0.95),
                                  fontSize: 20.sp,
                                  letterSpacing: 0.12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5.w)),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 35, top: 8, right: 10)
                                  .r,
                          child: Text(widget.description,
                              style: GoogleFonts.lato(
                                  decoration: TextDecoration.none,
                                  color: Color.fromRGBO(255, 255, 255, 0.95),
                                  fontSize: 14.sp,
                                  letterSpacing: 0.12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5.w)),
                        ),
                        SizedBox(height: 25.w),
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
                                      color:
                                          Color.fromRGBO(255, 255, 255, 0.95),
                                      fontSize: 14.sp,
                                      letterSpacing: 0.12,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5.w)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                widget.isTapped
                                    ? Container(
                                        width: 15.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.verifiedBadgeIconColor,
                                          borderRadius:
                                              BorderRadius.circular(100).r,
                                        ),
                                      )
                                    : Container(
                                        width: 8.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.black40,
                                          borderRadius:
                                              BorderRadius.circular(100).r,
                                        ),
                                      ),
                                SizedBox(width: 5),
                                widget.isDiscussTapped
                                    ? Container(
                                        width: 15.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.verifiedBadgeIconColor,
                                          borderRadius:
                                              BorderRadius.circular(100).r,
                                        ),
                                      )
                                    : Container(
                                        width: 8.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.black40,
                                          borderRadius:
                                              BorderRadius.circular(100).r,
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
                                widget.isProfileTapped
                                    ? Container(
                                        width: 15.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.verifiedBadgeIconColor,
                                          borderRadius:
                                              BorderRadius.circular(100).r,
                                        ),
                                      )
                                    : Container(
                                        width: 8.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.black40,
                                          borderRadius:
                                              BorderRadius.circular(100).r,
                                        ),
                                      ),
                              ],
                            ),
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Text(
                                  widget.title == EnglishLang.profile
                                      ? AppLocalizations.of(context)!
                                          .mTourFinish
                                      : AppLocalizations.of(context)!.mTourNext,
                                  style: GoogleFonts.lato(
                                      decoration: TextDecoration.none,
                                      color: AppColors.verifiedBadgeIconColor,
                                      fontSize: 14.sp,
                                      letterSpacing: 0.12,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5.w)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget getHubIconWidget(image) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.appBarBackground,
        border: Border.all(
          width: 1,
          color: AppColors.darkBlue,
          style: BorderStyle.solid,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0).r,
        child: SvgPicture.asset(
          image,
          colorFilter: ColorFilter.mode(AppColors.darkBlue, BlendMode.srcIn),
          width: 24.0.w,
          height: 24.0.w,
        ),
      ),
    );
  }

  Widget closeWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 8, right: 10).r,
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
