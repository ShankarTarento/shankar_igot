import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/event_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/events/events_hub_v2/widgets/events_card/show_all_screen_card.dart';
import 'package:karmayogi_mobile/ui/pages/index.dart';
import 'package:karmayogi_mobile/ui/widgets/silverappbar_delegate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/index.dart';

class ShowAllMyEvents extends StatefulWidget {
  final List<Event> pastEvents;
  final List<Event> upcomingEvents;
  final List<Event> todaysEvents;
  final int initialIndex;
  const ShowAllMyEvents(
      {super.key,
      required this.pastEvents,
      required this.initialIndex,
      required this.upcomingEvents,
      required this.todaysEvents});

  @override
  State<ShowAllMyEvents> createState() => _ShowAllMyEventsState();
}

class _ShowAllMyEventsState extends State<ShowAllMyEvents>
    with SingleTickerProviderStateMixin {
  List<String> tabItems = [];
  late TabController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tabItems = [
      "${AppLocalizations.of(context)!.mStaticToday} (${widget.todaysEvents.length})",
      "${AppLocalizations.of(context)!.mStaticUpcoming} (${widget.upcomingEvents.length})",
      "${AppLocalizations.of(context)!.mStaticPast} (${widget.pastEvents.length})"
    ];

    _controller = TabController(
        length: 3, vsync: this, initialIndex: widget.initialIndex);
  }

  List<Event> getEventsForSelectedTab(index) {
    switch (index) {
      case 0:
        return widget.todaysEvents;
      case 1:
        return widget.upcomingEvents;
      case 2:
        return widget.pastEvents;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGradientOne,
      body: DefaultTabController(
          length: tabItems.length,
          child: SafeArea(
              child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                appBarWidget(),
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
                        for (var tabItem in tabItems)
                          Container(
                            width: 0.33.sw,
                            padding:
                                const EdgeInsets.only(left: 16, right: 16).r,
                            child: Tab(
                              child: Text(
                                Helper.capitalize(tabItem),
                                style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                      ],
                      controller: _controller,
                    ),
                  ),
                  pinned: true,
                  floating: false,
                ),
              ];
            },
            body: TabBarView(
                controller: _controller,
                children: List.generate(tabItems.length,
                    (index) => tabBody(getEventsForSelectedTab(index)))),
          ))),
    );
  }

  Widget appBarWidget() {
    return SliverAppBar(
      shadowColor: Colors.transparent,
      toolbarHeight: 60.w,
      leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(Icons.arrow_back, size: 24.sp)),
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: EdgeInsets.fromLTRB(60.0, 0.0, 10.0, 0.0).r,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                Helper.capitalizeEachWordFirstCharacter(
                    AppLocalizations.of(context)!.mMyEvents),
                style: GoogleFonts.lato(
                    fontSize: 18.sp, fontWeight: FontWeight.w600)),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  FadeRoute(page: ContactUs()),
                );
              },
              child: SvgPicture.asset(
                'assets/img/help_icon.svg',
                width: 56.0.w,
                height: 56.0.w,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget tabBody(List<Event> allEvents) {
    return allEvents.isNotEmpty
        ? AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allEvents.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: ShowAllScreenCard(event: allEvents[index]),
                    ),
                  ),
                );
              },
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: NoDataWidget(
              message: AppLocalizations.of(context)!.mNoResourcesFound,
            ),
          );
  }
}
