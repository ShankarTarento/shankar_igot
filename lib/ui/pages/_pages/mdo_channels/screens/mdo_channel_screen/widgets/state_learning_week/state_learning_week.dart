import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/model/mdo_main_section_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_course_strip.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_explore_events_strip.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_explore_learning_content.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_highlights_of_the_week.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_key_highlights.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_mdo_leaderboard/slw_mdo_leaderboard.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_speaker_of_the_day.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_week_progress.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';

class StateLearningWeek extends StatefulWidget {
  final StateLearningWeekModel slwData;
  final String mdoOrgId;
  final Map<String, dynamic> slwConfig;
  const StateLearningWeek(
      {super.key,
      required this.slwData,
      required this.mdoOrgId,
      required this.slwConfig});

  @override
  State<StateLearningWeek> createState() => _StateLearningWeekState();
}

class _StateLearningWeekState extends State<StateLearningWeek> {
  List<Widget> _microSiteWidgets = [];

  @override
  void initState() {
    _sortLayouts(widget.slwData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _microSiteWidgets,
    );
  }

  void _sortLayouts(StateLearningWeekModel sortedData) {
    _microSiteWidgets = [];

    try {
      // Check for Key Highlights
      if (sortedData.keyHighlights != null &&
          sortedData.keyHighlights!["enabled"]) {
        _microSiteWidgets.add(
          SlwKeyHighlights(
            highlights: sortedData.keyHighlights?['content'] ?? [],
          ),
        );
      }

      if (sortedData.weekHighlights != null &&
          sortedData.weekHighlights!["enabled"]) {
        _microSiteWidgets.addAll([
          SlwHighlightsOfTheWeek(
            highlightsData: sortedData.weekHighlights?['data'],
          ),
          SizedBox(height: 24.w),
        ]);
      }

      if (sortedData.speakerOfTheDay != null &&
          sortedData.speakerOfTheDay!["enabled"]) {
        _microSiteWidgets.addAll([
          SlwSpeakerOfTheDay(speakerData: sortedData.speakerOfTheDay?['data']),
          SizedBox(height: 24.w),
        ]);
      }

      if (sortedData.myProgress != null && sortedData.myProgress!["enabled"]) {
        _microSiteWidgets.addAll([
          SlwWeekProgress(
            title: sortedData.myProgress?['data']?['title'] ?? "",
            infoText: sortedData.myProgress?['data']?['infoText'] ?? "",
          ),
          SizedBox(height: 24.w),
        ]);
      }

      if (sortedData.mdoLeaderboard != null &&
          sortedData.mdoLeaderboard!["enabled"]) {
        _microSiteWidgets.addAll([
          SlwMdoLeaderboard(
            leaderboardData: sortedData.mdoLeaderboard!,
            mdoOrgId: widget.mdoOrgId,
            title: sortedData.mdoLeaderboard?['data']?['title'] ?? "",
            infoText: sortedData.mdoLeaderboard?['data']?['infoText'] ?? "",
          ),
          SizedBox(height: 24.w),
        ]);
      }

      if (sortedData.mandatoryCourse != null &&
          sortedData.mandatoryCourse?['enabled'] == true) {
        try {
          _microSiteWidgets.add(
            SlwCourseStrip(
              mdoOrgId: widget.mdoOrgId,
              type: sortedData.mandatoryCourse?['column']?[0]?['data']
                      ?['strips']?[0]?['request']?['playlistRead']?['type'] ??
                  "",
              title: sortedData.mandatoryCourse?['column'][0]['data']['strips']
                      ?[0]?['title'] ??
                  'Trending Courses',
            ),
          );
        } catch (e) {
          debugPrint('Error while adding SlwCourseStrip: $e');
        }
      }

      if (sortedData.exploreLearningContent != null &&
          sortedData.exploreLearningContent?['enabled'] == true) {
        _microSiteWidgets.add(
          SlwExploreLearningContent(
            exploreContent: sortedData.exploreLearningContent!,
            mdoId: widget.mdoOrgId,
          ),
        );
      }

      if (sortedData.events != null) {
        try {
          String startDate = DateTimeHelper.convertDateFormat(
              widget.slwConfig['startDate'],
              inputFormat: IntentType.dateFormat,
              desiredFormat: IntentType.dateFormat4);
          String endDate = DateTimeHelper.convertDateFormat(widget.slwConfig['endDate'],
              inputFormat: IntentType.dateFormat,
              desiredFormat: IntentType.dateFormat4);

          if (sortedData.events?['enabled'] == true) {
            _microSiteWidgets.add(
              SlwExploreEventsStrip(
                startDate: startDate,
                endDate: endDate,
                exploreEventsData: sortedData.events!,
              ),
            );
          }
        } catch (e) {
          debugPrint("Error in SlwExploreEventsStrip $e");
        }
      }

      if (_microSiteWidgets.isEmpty) {
        _microSiteWidgets.add(SizedBox.shrink());
      }
    } catch (e) {
      debugPrint("Error during layout sorting: $e");
    }
  }
}
