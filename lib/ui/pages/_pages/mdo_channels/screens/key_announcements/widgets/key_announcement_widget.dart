import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../constants/_constants/color_constants.dart';

class KeyAnnouncementView extends StatefulWidget {
  final double width;
  final double height;
  final String title;
  final String? iconUrl;
  final bool showPrefixIcon;
  final bool showPostfixIcon;
  final VoidCallback? onTap;

  KeyAnnouncementView({
    required this.width,
    required this.height,
    required this.title,
    this.iconUrl,
    required this.showPrefixIcon,
    required this.showPostfixIcon,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _KeyAnnouncementViewState createState() {
    return _KeyAnnouncementViewState();
  }
}

class _KeyAnnouncementViewState extends State<KeyAnnouncementView>
    with SingleTickerProviderStateMixin {
  late AnimationController _announcementAnimationController;
  late Animation<double> _announcementAnimation;

  @override
  void initState() {
    super.initState();
    _announcementAnimationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _announcementAnimation =
        Tween<double>(begin: widget.width, end: widget.width + 20.w)
            .animate(CurvedAnimation(
      parent: _announcementAnimationController,
      curve: Curves.easeInOut,
    ));
    _announcementAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _announcementAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _announcementWidget();
  }

  Widget _announcementWidget() {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        child: AnimatedBuilder(
          animation: _announcementAnimation,
          builder: (context, child) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16).w,
              width: _announcementAnimation.value,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.all(Radius.circular(100.w)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.showPrefixIcon)
                    (widget.iconUrl != '')
                        ? SvgPicture.network(
                            widget.iconUrl ?? '',
                            width: 24.w,
                            height: 24.w,
                          )
                        : SvgPicture.asset(
                            'assets/img/mdo_channel_announcement_icon.svg',
                            width: 24.w,
                            height: 24.w,
                          ),
                  Padding(
                    padding: EdgeInsets.only(left: 8).w,
                    child: Text(
                      widget.title,
                      style: GoogleFonts.montserrat(
                        color: AppColors.appBarBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.showPostfixIcon)
                    Container(
                        margin: EdgeInsets.only(left: 16).w,
                        child: Icon(
                          Icons.arrow_forward_ios_sharp,
                          color: AppColors.appBarBackground,
                          size: 12.sp,
                        )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
