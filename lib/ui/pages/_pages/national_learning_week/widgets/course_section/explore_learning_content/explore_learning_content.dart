import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/course_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/learn/widgets/course_card_strip.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/services/national_learning_week_view_model.dart';
import 'package:karmayogi_mobile/ui/skeleton/index.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExploreLearningContent extends StatefulWidget {
  final Map<String, dynamic> exploreContent;

  const ExploreLearningContent({super.key, required this.exploreContent});

  @override
  State<ExploreLearningContent> createState() => _ExploreLearningContentState();
}

class _ExploreLearningContentState extends State<ExploreLearningContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List tabs = [];
  Future<List<Course>>? playlistData;

  List<String> telemetryData = [
    'mts',
    'aso-to-us',
    'dir-ds-to-js',
    'js-and-above',
    'mts',
  ];

  @override
  void initState() {
    super.initState();
    generateTab();
  }

  void generateTab() {
    tabs = widget.exploreContent['strips']?.isNotEmpty == true &&
            widget.exploreContent['strips'][0]['tabs'] != null
        ? widget.exploreContent['strips'][0]['tabs']
        : [];

    _tabController = TabController(length: tabs.length, vsync: this);

    if (tabs.isNotEmpty &&
        tabs[0]['request']?['playlistRead']?['type'] != null) {
      fetchPlaylistData(tabs[0]['request']['playlistRead']['type']);
    }
  }

  Future<void> fetchPlaylistData(String type) async {
    try {
      playlistData =
          NationalLearningWeekViewModel().getLearningContent(type: type);
      setState(() {});
    } catch (e) {
      debugPrint("Error fetching learning content: $e");

      setState(() {
        playlistData = Future.value([]);
      });
    }
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
        objectType: primaryCategory ?? (isObjectNull ? null : subType),
        clickId: clickId);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return tabs.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                        left: 16.0, right: 16, top: 16, bottom: 8)
                    .r,
                child: TitleWidget(
                    title: widget.exploreContent['strips'][0]['title'] ?? ""),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22).r,
                child: TabBar(
                  onTap: (value) {
                    fetchPlaylistData(
                        tabs[value]['request']['playlistRead']['type']);
                    _generateInteractTelemetryData(
                      telemetryData[value],
                      subType: TelemetrySubType.exploreLearningContent,
                    );
                  },
                  tabAlignment: TabAlignment.start,
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.darkBlue,
                        width: 2.0,
                      ),
                    ),
                  ),
                  indicatorColor: AppColors.darkBlue,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8).r,
                  unselectedLabelColor: AppColors.greys60,
                  labelColor: AppColors.darkBlue,
                  labelStyle: GoogleFonts.lato(
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: GoogleFonts.lato(
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.normal,
                  ),
                  tabs: tabs.map((e) => Tab(text: e['label'])).toList(),
                ),
              ),
              SizedBox(height: 16.w),
              SizedBox(
                height: 320.w,
                child: _buildCourseTab(),
              ),
            ],
          )
        : SizedBox();
  }

  Widget _buildCourseTab() {
    return FutureBuilder<List<Course>>(
      future: playlistData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0).r,
            child: CourseCardSkeletonPage(),
          );
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final shuffledCourses = snapshot.data!..shuffle();
          return CourseCardStrip(
            courses: shuffledCourses,
            telemetryPageIdentifier:
                TelemetryPageIdentifier.nationalLearningWeekUri,
            telemetrySubType: TelemetrySubType.exploreLearningContent,
            telemetryEnv: TelemetryEnv.nationalLearningWeek,
          );
        }
        return Center(
            child: Text(AppLocalizations.of(context)!.mNoResourcesFound));
      },
    );
  }
}
