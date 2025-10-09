import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/mdo_leaderboard.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/slw_repository/slw_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_mdo_leaderboard/widgets/slw_mdo_leaderboard_list.dart';
import 'package:karmayogi_mobile/ui/widgets/_learn/content_info.dart';

class SlwMdoLeaderboard extends StatefulWidget {
  final String title;
  final String mdoOrgId;
  final String? infoText;
  final Map<String, dynamic> leaderboardData;

  const SlwMdoLeaderboard({
    super.key,
    required this.title,
    this.infoText,
    required this.mdoOrgId,
    required this.leaderboardData,
  });

  @override
  State<SlwMdoLeaderboard> createState() => _SlwMdoLeaderboardState();
}

class _SlwMdoLeaderboardState extends State<SlwMdoLeaderboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MDOLeaderboardData> mdoLeaderBoardData = [];

  List<List<MDOLeaderboardData>> categorizedData = List.generate(5, (_) => []);
  List<String> tabsData = [];
  List<String> categoriesList = [];

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    final options = widget.leaderboardData['data']['options'] as List<dynamic>?;

    categoriesList =
        options?.map<String>((e) => e['value'].toString()).toList() ?? [];
    tabsData =
        options?.map<String>((e) => e['label'].toString()).toList() ?? [];
    categorizedData = List.generate(categoriesList.length, (_) => []);
    _tabController = TabController(length: tabsData.length, vsync: this);
    _fetchMdoData();
  }

  // Fetch MDO leaderboard data
  Future<void> _fetchMdoData() async {
    try {
      mdoLeaderBoardData =
          await SlwRepository().getMdoLeaderBoardData(mdoId: widget.mdoOrgId);
      _categorizeMdoData();
    } catch (e) {
      debugPrint('Error fetching MDO leaderboard data: $e');
    }
  }

  void _categorizeMdoData() {
    final Map<String, List<MDOLeaderboardData>> tempCategories = {
      for (var category in categoriesList) category: [],
    };

    for (var data in mdoLeaderBoardData) {
      if (tempCategories.containsKey(data.size)) {
        tempCategories[data.size]?.add(data);
      }
    }

    setState(() {
      categorizedData =
          categoriesList.map((category) => tempCategories[category]!).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return tabsData.isNotEmpty
        ? Container(
            color: AppColors.blue209,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8).r,
            child: ExpansionTile(
              textColor: AppColors.greys,
              iconColor: AppColors.greys,
              trailing: Icon(
                _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              ),
              onExpansionChanged: (bool expanding) => setState(() {
                _isExpanded = expanding;
              }),
              title: _buildTitle(),
              children: [
                Stack(
                  children: [
                    _buildLeaderboardContainer(),
                    _buildIndicator(),
                  ],
                ),
              ],
            ),
          )
        : SizedBox();
  }

  // Build the leaderboard container with tabs and list views
  Widget _buildLeaderboardContainer() {
    return Container(
      margin: EdgeInsets.all(6).r,
      padding: EdgeInsets.only(bottom: 0, top: 10).r,
      height: 600.w,
      width: 1.sw,
      decoration: BoxDecoration(
        color: AppColors.keyHighlightBackground,
        borderRadius: BorderRadius.circular(8).r,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                tabsData.length,
                (index) => SlwMdoLeaderboardList(
                  searchHintText: widget.leaderboardData['data']['searchHint'],
                  mdoLeaderBoardData: categorizedData[index],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the tab bar for the different size categories
  Widget _buildTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22).r,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.darkBlue, width: 2.0),
          ),
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: 8).r,
        unselectedLabelColor: AppColors.greys60,
        labelColor: AppColors.darkBlue,
        labelStyle:
            GoogleFonts.lato(fontSize: 14.0.sp, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.lato(fontSize: 14.0.sp),
        onTap: (value) {},
        tabs: List.generate(
          tabsData.length,
          (index) => Tab(text: tabsData[index]),
        ),
      ),
    );
  }

  // Build the indicator at the top of the container
  Widget _buildIndicator() {
    return Center(
      child: Container(
        height: 20.w,
        width: 40.w,
        padding: EdgeInsets.all(5).r,
        decoration: BoxDecoration(
          color: AppColors.keyHighlightBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16).r,
            topRight: Radius.circular(16).r,
          ),
        ),
        child: CircleAvatar(
          radius: 2,
          backgroundColor: AppColors.slwLeaderboardCircleColor,
        ),
      ),
    );
  }

  // Build the title section with optional info text
  Widget _buildTitle() {
    return Row(
      children: [
        Text(
          widget.title,
          style: GoogleFonts.lato(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        if (widget.infoText != null) ContentInfo(infoMessage: widget.infoText!),
      ],
    );
  }
}
