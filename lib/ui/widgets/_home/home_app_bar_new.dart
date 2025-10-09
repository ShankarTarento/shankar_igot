import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/notification_icon.dart';
import 'package:karmayogi_mobile/ui/widgets/language_dropdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants/index.dart';
import '../../../models/index.dart';
import '../../screens/_screens/profile/ui/widgets/profile_picture.dart';

class HomeAppBarNew extends StatelessWidget implements PreferredSizeWidget {
  final Profile? profileInfo;
  final int index;
  final AppBar? appBar;
  final SliverAppBar? silverAppBar;
  final profileParentAction;
  final bool isSearch;
  final BuildContext? searchContext;
  final Function() navigateCallBack;
  final GlobalKey<ScaffoldState>? drawerKey;
  const HomeAppBarNew(
      {Key? key,
      this.profileInfo,
      this.appBar,
      this.searchContext,
      this.silverAppBar,
      this.index = 0,
      required this.navigateCallBack,
      this.profileParentAction,
      this.isSearch = false,
      this.drawerKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.appBarBackground,
      toolbarHeight: (kToolbarHeight + 8).w,
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8).w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(children: [
              isSearch
                  ? GestureDetector(
                      onTap: () {
                        navigateCallBack();
                      },
                      child: Icon(Icons.arrow_back, size: 24.sp))
                  : ProfilePicture(
                      profileParentAction: profileParentAction,
                      drawerKey: drawerKey,
                    ),
              SizedBox(width: 8.w),
              SizedBox(
                width: index == 0 ? 0 : 120.w,
                child: Text(
                  index == 1
                      ? AppLocalizations.of(context)!.mStaticExplore
                      : index == 2
                          ? AppLocalizations.of(context)!.mCommonSearch
                          : index == 3
                              ? AppLocalizations.of(context)!.mTabMyLearnings
                              : '',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      letterSpacing: 0.12,
                      color: AppColors.greys87),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ]),
            Spacer(),
            LanguageDropdown(
              isHomePage: true,
            ),
            SizedBox(width: 12.w),
            NotificationIcon(),
          ],
        ),
      ),
      floating: true,
      automaticallyImplyLeading: false,
      // pinned: true,
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar!.preferredSize.height);
}
