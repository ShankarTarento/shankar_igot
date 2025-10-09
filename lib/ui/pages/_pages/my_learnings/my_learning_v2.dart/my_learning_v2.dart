import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_v2.dart/widgets/my_learning_app_bar_content.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_v2.dart/widgets/my_learning_content/my_learning_content.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/my_learnings/my_learning_v2.dart/widgets/my_learning_events/my_learning_events.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/my_learn_main_tab.dart';

class MyLearningV2 extends StatefulWidget {
  final profileParentAction;
  final GlobalKey<ScaffoldState>? drawerKey;
  final int? tabIndex;
  final int? pillIndex;

  const MyLearningV2(
      {super.key,
      this.profileParentAction,
      this.drawerKey,
      this.pillIndex,
      this.tabIndex});

  @override
  State<MyLearningV2> createState() => _MyLearningV2State();
}

class _MyLearningV2State extends State<MyLearningV2>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  List<MyLearnMainTab> tabs = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tabs = MyLearnMainTab.items(context: context);
    _controller = TabController(
        length: tabs.length, vsync: this, initialIndex: widget.tabIndex ?? 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: MyLearningAppBarContent(
          drawerKey: widget.drawerKey,
          profileParentAction: widget.profileParentAction,
        ),
        bottom: TabBar(
          controller: _controller,
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
          labelPadding: EdgeInsets.only(top: 10.0).r,
          unselectedLabelColor: AppColors.greys60,
          labelColor: AppColors.darkBlue,
          labelStyle: GoogleFonts.lato(
            fontSize: 10.0.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.lato(
            fontSize: 10.0.sp,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            for (var tabItem in tabs)
              Container(
                width: 0.5.sw,
                padding: EdgeInsets.symmetric(horizontal: 16.0).r,
                child: Tab(
                  child: Text(
                    tabItem.title,
                    style: GoogleFonts.lato(
                      color: AppColors.greys87,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          MyLearningContent(
            index: widget.pillIndex,
          ),
          MyLearningEvents(index: widget.pillIndex),
        ],
      ),
    );
  }
}
