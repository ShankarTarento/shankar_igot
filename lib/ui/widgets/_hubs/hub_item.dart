import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/util/custom_animations.dart';
import './../../../constants/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HubItem extends StatefulWidget {
  final int id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final bool comingSoon;
  final String url;
  final String svgIcon;
  final bool svg;
  final bool isDoMore;
  final bool isNew;

  HubItem(this.id, this.title, this.description, this.icon, this.iconColor,
      this.comingSoon, this.url, this.svgIcon, this.svg,
      {this.isDoMore = false, this.isNew = false});

  @override
  _HubItemState createState() => _HubItemState();
}

class _HubItemState extends State<HubItem>
    with TickerProviderStateMixin, CustomAnimations {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildItems() {
    List<Widget> rowElements = [];
    rowElements.add(Text(
      widget.title,
      style: GoogleFonts.lato(
        color: AppColors.greys87,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        height: 1.5.w,
      ),
    ));
    // if (widget.comingSoon) {
    //   rowElements.add(Container(
    //     // margin: const EdgeInsets.only(right: 10),
    //     padding: const EdgeInsets.all(3),
    //     decoration: BoxDecoration(
    //       color: AppColors.lightGrey,
    //       border: Border.all(color: AppColors.lightGrey),
    //       borderRadius: BorderRadius.all(Radius.circular(4)),
    //     ),
    //     child: Text(
    //        AppLocalizations.of(context)!.mStaticComingSoon,
    //       style: GoogleFonts.lato(color: AppColors.greys60, fontSize: 10),
    //     ),
    //   ));
    // }
    return rowElements;
  }

  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      child: Card(
        child: ClipPath(
          child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.comingSoon
                    ? AppColors.greys87.withValues(alpha: 0.1)
                    : AppColors.appBarBackground,
              ),
              padding: const EdgeInsets.fromLTRB(15, 15, 10, 15).r,
              child: Row(
                children: <Widget>[
                  Stack(
                    children: [
                      (widget.svg)
                          ? Container(
                              padding: const EdgeInsets.all(20).r,
                              decoration: BoxDecoration(
                                color: widget.comingSoon
                                    ? AppColors.appBarBackground
                                    : AppColors.lightGrey,
                                border: Border.all(color: AppColors.lightGrey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)).r,
                              ),
                              child: SvgPicture.asset(widget.svgIcon,
                                  width: 25.0.w,
                                  height: 25.0.w,
                                  colorFilter: ColorFilter.mode(
                                      widget.comingSoon || widget.isDoMore
                                          ? AppColors.greys60
                                          : AppColors.darkBlue,
                                      BlendMode.srcIn)),
                            )
                          : Container(
                              padding: const EdgeInsets.all(20).r,
                              decoration: BoxDecoration(
                                color: AppColors.lightGrey,
                                border: Border.all(color: AppColors.lightGrey),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)).r,
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.iconColor,
                                size: 25.w,
                              ),
                            ),
                      if (widget.isNew)
                        Positioned(
                            top: -1, right: -1, child: newWithAnimation()),
                    ],
                  ),
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.only(left: 15, right: 5).r,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: _buildItems(),
                              ),
                              Text(
                                widget.description,
                                maxLines: 5,
                                style: GoogleFonts.lato(
                                    color: AppColors.greys60,
                                    height: 1.5.w,
                                    fontSize: 12.sp),
                              ),
                            ],
                          ))),
                ],
              )),
          clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4).r)),
        ),
      ),
    );
  }

  Widget newWithAnimation() {
    return ScaleTransition(
      scale: scaleAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2).w,
        margin: EdgeInsets.only(right: 2).w,
        decoration: BoxDecoration(
          color: AppColors.negativeLight,
          borderRadius: BorderRadius.circular(0),
        ),
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.of(context)!.mStaticNew,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontSize: 8.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.appBarBackground),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
