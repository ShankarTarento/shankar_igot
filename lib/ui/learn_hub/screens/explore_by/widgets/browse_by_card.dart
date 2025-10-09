import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/browse_by_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BrowseByCard extends StatefulWidget {
  final BrowseBy browseBy;

  BrowseByCard({required this.browseBy});

  @override
  _BrowseByCardState createState() => _BrowseByCardState();
}

class _BrowseByCardState extends State<BrowseByCard> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildItems() {
    List<Widget> rowElements = [];
    rowElements.add(Text(
      widget.browseBy.title,
      style: GoogleFonts.lato(
          color: AppColors.primaryThree,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          height: 1.429.w,
          letterSpacing: 0.5),
    ));
    if (widget.browseBy.comingSoon) {
      rowElements.add(Padding(
        padding: const EdgeInsets.only(left: 120).r,
        child: Container(
          padding: const EdgeInsets.all(3).r,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.all(Radius.circular(4)).r,
          ),
          child: Text(
            AppLocalizations.of(context)!.mStaticComingSoon,
            style: GoogleFonts.lato(color: AppColors.greys60, fontSize: 10.sp),
          ),
        ),
      ));
    }
    return rowElements;
  }

  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).primaryColor,
      child: Container(
        height: 84.w,
        width: 1.sw,
        margin: EdgeInsets.only(bottom: 16).r,
        child: ClipPath(
          child: Stack(fit: StackFit.passthrough, children: <Widget>[
            SvgPicture.asset(
              widget.browseBy.svgImage,
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 4,
              left: 16,
              child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16).r,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _buildItems(),
                      ),
                      SizedBox(
                        height: 4.w,
                      ),
                      Text(
                        widget.browseBy.description,
                        style: GoogleFonts.lato(
                            color: AppColors.greys60,
                            height: 1.2.w,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                            fontSize: 10.sp),
                      ),
                    ],
                  )),
            ),
          ]),
          clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8).r)),
        ),
      ),
    );
  }
}
