import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/skeleton/index.dart';
import 'package:karmayogi_mobile/ui/widgets/silverappbar_delegate.dart';

class EditProfileSkeletonPage extends StatelessWidget {
  const EditProfileSkeletonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  pinned: false,
                  leading: BackButton(color: AppColors.greys60),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsets.fromLTRB(40.0, 0.0, 10.0, 18.0).r,
                    title: Padding(
                      padding: EdgeInsets.only(left: 13.0, top: 3.0).r,
                      child: Text(
                        AppLocalizations.of(context)!.mEditProfile,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontFamily: GoogleFonts.montserrat().fontFamily,
                            ),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: SilverAppBarDelegate(
                    TabBar(
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      indicator: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.darkBlue,
                            width: 2.0.w,
                          ),
                        ),
                      ),
                      indicatorColor: AppColors.appBarBackground,
                      labelPadding: EdgeInsets.only(top: 0.0).r,
                      unselectedLabelColor: AppColors.greys60,
                      labelColor: AppColors.darkBlue,
                      labelStyle:
                          Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                      unselectedLabelStyle:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                              ),
                      tabs: [
                        for (var i = 0; i < 2; i++)
                          Container(
                            padding:
                                const EdgeInsets.only(left: 16, right: 16).r,
                            child: Tab(
                              child: Padding(
                                padding: EdgeInsets.all(5.0).r,
                                child: ContainerSkeleton(
                                  height: 30.w,
                                  width: 0.45.sw,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  pinned: true,
                  floating: false,
                ),
              ];
            },
            // TabBar view
            body: TabBarView(
              children: [
                for (var i = 0; i < 2; i++)
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0).r,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          i == 0
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                            top: 16, bottom: 16)
                                        .r,
                                    child: ContainerSkeleton(
                                      radius: 200.r,
                                      width: 150.w,
                                      height: 150.w,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          for (var i = 0; i < 8; i++)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8).r,
                                  child: ContainerSkeleton(
                                    width: 100.w,
                                    height: 20.w,
                                    color: AppColors.grey08,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 16)
                                          .r,
                                  child: ContainerSkeleton(
                                    width: double.infinity.w,
                                    height: 50.w,
                                  ),
                                )
                              ],
                            )
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
