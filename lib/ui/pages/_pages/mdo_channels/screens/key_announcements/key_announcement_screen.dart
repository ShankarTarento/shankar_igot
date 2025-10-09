import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/components/view_more_text.dart';
import '../../../../../../constants/_constants/color_constants.dart';
import '../../model/mdo_announcement_section_data_model.dart';
import 'widgets/key_announcement_widget.dart';

class KeyAnnouncementScreen extends StatefulWidget {
  final AnnouncementDataModel? data;
  final List<AnnouncementListItemData> announcementList;

  KeyAnnouncementScreen({this.data, required this.announcementList});
  @override
  _KeyAnnouncementScreenState createState() => _KeyAnnouncementScreenState();
}

class _KeyAnnouncementScreenState extends State<KeyAnnouncementScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
        duration: Duration(seconds: 1), // Duration for the animation
        curve: Curves.fastOutSlowIn, // Animation curve (e.g., ease-in-out)
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? 1.sh
                : 1.sw,
            child: _buildUI(),
          ),
        ));
  }

  Widget _buildUI() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          child: Expanded(
              child: Stack(
            children: [
              Positioned(
                  child: Align(
                alignment: FractionalOffset.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, top: 38).w,
                  child: Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () async {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 36.w,
                          width: 36.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // color: AppColors.grey40,
                          ),
                          child: Icon(Icons.close,
                              color: AppColors.whiteGradientOne, size: 16.w),
                        ),
                      )),
                ),
              )),
              Positioned(
                child: Align(
                  alignment: FractionalOffset.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    width: 64.w,
                    height: 64.w,
                    alignment: Alignment.bottomCenter,
                    child: (widget.data != null && widget.data!.logoUrl != '')
                        ? SvgPicture.network(
                            widget.data!.logoUrl ?? '',
                            width: 64.w,
                            height: 64.w,
                            fit: BoxFit.fill,
                          )
                        : SvgPicture.asset(
                            'assets/img/mdo_channel_announcement_list_icon.svg',
                            width: 64.w,
                            height: 64.w,
                            fit: BoxFit.fill,
                          ),
                  ),
                ),
              ),
              Container(
                  width: double.infinity,
                  height: double.maxFinite,
                  margin:
                      EdgeInsets.only(bottom: 20, left: 8, right: 8, top: 100)
                          .w,
                  decoration: BoxDecoration(
                    color: AppColors.appBarBackground,
                    borderRadius: BorderRadius.all(Radius.circular(12).w),
                  ),
                  child: _buildAnnouncementList()),
              Positioned(
                child: Align(
                    alignment: FractionalOffset.topCenter,
                    child: Container(
                      height: 36.w,
                      width: double.maxFinite,
                      margin: EdgeInsets.only(top: 80).w,
                      child: KeyAnnouncementView(
                        height: 36.w,
                        width: 268.w,
                        title: widget.data?.title ??
                            AppLocalizations.of(context)!
                                .mMdoChannelKeyAnnouncements,
                        showPrefixIcon: false,
                        showPostfixIcon: false,
                      ),
                    )),
              ),
            ],
          )),
        )
      ],
    );
  }

  Widget _buildAnnouncementList() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16).w,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              ...List.generate(
                  widget.announcementList.length,
                  (index) => Container(
                      width: double.maxFinite,
                      margin: EdgeInsets.symmetric(vertical: 8).w,
                      padding: EdgeInsets.all(8).w,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.w)),
                          border: Border.all(color: AppColors.orangeTourText),
                          color: Color(0XFFFCEEDB)),
                      child: Padding(
                        padding: EdgeInsets.all(8).w,
                        child: ViewMoreText(
                          text:
                              widget.announcementList[index].description ?? '',
                          viewLessText:
                              AppLocalizations.of(context)!.mStaticViewLess,
                          viewMoreText:
                              AppLocalizations.of(context)!.mStaticViewMore,
                          maxLines: 3,
                          style: GoogleFonts.lato(
                            color: AppColors.greys87,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            height: 1.5.h,
                          ),
                          moreLessStyle: GoogleFonts.lato(
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            height: 1.5.h,
                          ),
                        ),
                      )))
            ],
          ),
        ));
  }
}
