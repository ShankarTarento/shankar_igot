import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_models/mdo_leaderboard.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/services/national_learning_week_view_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/mdo_leaderboard/widgets/mdo_leaderboard_list.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import '../../../../../widgets/_learn/content_info.dart';

class MdoLeaderboard extends StatefulWidget {
  final String title;
  final String? infoText;

  const MdoLeaderboard({super.key, required this.title, this.infoText});

  @override
  State<MdoLeaderboard> createState() => _MdoLeaderboardState();
}

class _MdoLeaderboardState extends State<MdoLeaderboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MDOLeaderboardData> mdoLeaderBoardData = [];

  final List<List<MDOLeaderboardData>> categorizedData =
      List.generate(5, (_) => []);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _fetchMdoData();
  }

  void _fetchMdoData() async {
    mdoLeaderBoardData =
        await NationalLearningWeekViewModel().getMdoLeaderBoardData();
    _categorizeMdoData();
  }

  void _generateInteractTelemetryData(String contentId,
      {String subType = '',
      String? primaryCategory,
      bool isObjectNull = false,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.nationalLearningWeekUri,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.nationalLearningWeek,
        objectType: primaryCategory != null
            ? primaryCategory
            : (isObjectNull ? null : subType),
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void _categorizeMdoData() {
    for (var data in mdoLeaderBoardData) {
      switch (data.size) {
        case 'XL':
          categorizedData[0].add(data);
          break;
        case 'L':
          categorizedData[1].add(data);
          break;
        case 'M':
          categorizedData[2].add(data);
          break;
        case 'S':
          categorizedData[3].add(data);
          break;
        case 'XS':
          categorizedData[4].add(data);
          break;
      }
    }
    setState(() {});
  }

  List<String> tabsData = [
    ' > 50K ',
    '10K-50K',
    '1K-10K',
    '500-1K',
    ' < 500  ',
  ];
  List<String> telemetry = [
    'greater-than-50k-tab',
    '10k-50k-tab',
    '1k-10k-tab',
    '500-1k-tab',
    'less-than-500-tab',
  ];
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blue209,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8).r,
      child: ExpansionTile(
        textColor: AppColors.greys,
        iconColor: AppColors.greys,
        trailing:
            Icon(_isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
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
    );
  }

  Widget _buildLeaderboardContainer() {
    return Container(
      margin: EdgeInsets.all(6).r,
      padding: EdgeInsets.only(bottom: 0, top: 10).r,
      height: 700.w,
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
                  5,
                  (index) => MdoLeaderboardList(
                      mdoLeaderBoardData: categorizedData[index])),
            ),
          ),
        ],
      ),
    );
  }

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
        onTap: (value) {
          _generateInteractTelemetryData(
            telemetry[value],
            subType: TelemetrySubType.mdoLeaderboard,
            isObjectNull: true,
          );
        },
        tabs: List.generate(
            tabsData.length, (index) => Tab(text: tabsData[index])),
      ),
    );
  }

  Widget _buildIndicator() {
    return Center(
      child: Container(
        height: 20.w,
        width: 40.w,
        padding: EdgeInsets.all(5).r,
        decoration: BoxDecoration(
          color: AppColors.keyHighlightBackground,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16).r, topRight: Radius.circular(16).r),
        ),
        child: CircleAvatar(
          radius: 2,
          backgroundColor: AppColors.slwLeaderboardCircleColor,
        ),
      ),
    );
  }

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
