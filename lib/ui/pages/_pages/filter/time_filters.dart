import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import './../../../../constants/index.dart';
import './../../../../ui/pages/index.dart';
import './../../../../ui/widgets/index.dart';

class TimeFilters extends StatefulWidget {
  @override
  _TimeFiltersState createState() {
    return new _TimeFiltersState();
  }
}

class _TimeFiltersState extends State<TimeFilters> {
  TabController? _controller;
  List tabNames = ['Presets', 'Custom'];

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // leading: Container(
          //   child: IconButton(
          //       icon: Icon(
          //         Icons.close,
          //         color: AppColors.greys87,
          //       ),
          //       onPressed: () {
          //         Navigator.pop(context);
          //       }),
          // ),
          elevation: 0,
          // titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Container(
                child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.greys87,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0).r,
                child: Text(
                  'Time',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontFamily: GoogleFonts.montserrat().fontFamily,
                      ),
                ),
              )
            ],
          ),
        ),
        // Tab controller
        body: DefaultTabController(
            length: tabNames.length,
            child: SafeArea(
                child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverPersistentHeader(
                    delegate: SilverAppBarDelegate(
                      TabBar(
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        indicator: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.primaryThree,
                              width: 2.0.w,
                            ),
                          ),
                        ),
                        indicatorColor: AppColors.appBarBackground,
                        labelPadding: EdgeInsets.only(top: 0.0).r,
                        unselectedLabelColor: AppColors.greys60,
                        labelColor: AppColors.primaryThree,
                        labelStyle: GoogleFonts.lato(
                          fontSize: 10.0.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: GoogleFonts.lato(
                          fontSize: 10.0.sp,
                          fontWeight: FontWeight.normal,
                        ),
                        tabs: [
                          for (var tabItem in tabNames)
                            Container(
                              width: 1.sw / 2,
                              // padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Tab(
                                child: Text(
                                  tabItem,
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                ),
                              ),
                            ),
                        ],
                        controller: _controller,
                      ),
                    ),
                    pinned: true,
                    floating: false,
                  ),
                ];
              },

              // TabBar view
              body: Container(
                color: AppColors.lightBackground,
                child: TabBarView(
                  controller: _controller,
                  children: [
                    // Ratings(),
                    // FeedbackSubpage(),
                    PresetsTimeFilter(),
                    CustomTimeFilter(),
                  ],
                ),
              ),
            ))),
        bottomNavigationBar: BottomAppBar(
            child: Container(
          height: 60.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Reset to default',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Container(
                width: 180.w,
                color: AppColors.primaryThree,
                child: TextButton(
                  onPressed: null,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primaryThree,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8).r,
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}
