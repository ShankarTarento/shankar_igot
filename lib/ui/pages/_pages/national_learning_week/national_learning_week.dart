import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/learn_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/ati_cti_microsite_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/national_learning_week_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/course_section/explore_learning_content/explore_learning_content.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/course_section/mandatory_section.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/explore_events/explore_events_strip.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/highlights_of_the_week/highlights_of_the_week.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/key_highlights.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/national_learning_week_description.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/national_learning_week_top_section.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/performance_dashboard.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/speaker_of_the_day/speaker_of_the_day.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/week_progress/week_progress.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';
import 'widgets/mdo_leaderboard/mdo_leaderboard.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NationalLearningWeek extends StatefulWidget {
  final String startDate;
  final String endDate;
  const NationalLearningWeek(
      {Key? key, required this.startDate, required this.endDate})
      : super(key: key);

  @override
  _NationalLearningWeekState createState() => _NationalLearningWeekState();
}

class _NationalLearningWeekState extends State<NationalLearningWeek> {
  List<SectionListModel> _microSiteSortedData = [];
  List<Widget> _microSiteWidgets = [];

  late Future<AtiCtiMicroSitesFormDataModel> nationalLearningWeek;

  @override
  void initState() {
    super.initState();
    nationalLearningWeek = fetchNationalWeekData();
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.nationalLearningWeekUri,
        telemetryType: TelemetryType.app,
        pageUri: TelemetryPageIdentifier.nationalLearningWeekUri,
        env: TelemetryEnv.nationalLearningWeek);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<AtiCtiMicroSitesFormDataModel> fetchNationalWeekData() async {
    try {
      var responseData =
          await Provider.of<LearnRepository>(context, listen: false)
              .getMicroSiteFormData(
                  orgId: '123456789',
                  type: 'National Learning Week',
                  subtype: 'microsite');

      return AtiCtiMicroSitesFormDataModel.fromJson(responseData);
    } catch (error) {
      throw Exception('Failed to load micro site data $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        leading: BackButton(color: AppColors.greys87),
        title: Padding(
          padding: const EdgeInsets.only(left: 10).r,
          child: Text(
            AppLocalizations.of(context)!.mNationalLearningWeek,
            style: GoogleFonts.montserrat(
              color: AppColors.greys87,
              fontSize: 16.0.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: FutureBuilder<AtiCtiMicroSitesFormDataModel>(
        future: nationalLearningWeek,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: NationalLearningWeekSkeleton());
          } else if (snapshot.hasData) {
            _processMicroSiteData(snapshot.data!);
            return SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _microSiteWidgets),
            );
          } else {
            return Center(
                child: Text(AppLocalizations.of(context)!.mMsgNoDataFound));
          }
        },
      ),
    );
  }

  void _processMicroSiteData(AtiCtiMicroSitesFormDataModel data) {
    List<SectionListModel> microSiteDataList = data.data?.sectionList ?? [];
    _microSiteSortedData =
        microSiteDataList.where((item) => item.enabled == true).toList();
    _microSiteSortedData.sort((a, b) => a.order?.compareTo(b.order ?? 0) ?? 0);
    _sortLayouts(_microSiteSortedData);
  }

  void _sortLayouts(List<SectionListModel> sortedData) {
    _microSiteWidgets = [];

    for (var element in sortedData) {
      switch (element.key) {
        case 'sectionTopBanner':
          _handleSectionTopBanner(element);
          break;
        case 'sectionContent':
          _handleContentSection(element);
          break;
        // case 'mandatorySection':
        //   handleMandatorySection(element);
        // case 'exploreLearningContent':
        //   if (element.enabled != null && element.enabled!) {
        //     _microSiteWidgets.add(ExploreLearningContent(
        //       exploreContent: element,
        //     ));
        //   }
        //   break;
        case 'eventsSection':
          _microSiteWidgets.add(ExploreEventsStrip(
            startDate: widget.startDate,
            endDate: widget.endDate,
          ));
          break;
        case 'sectionlooker':
          _performanceDashboard(element);
          break;
        default:
          _microSiteWidgets.add(SizedBox.shrink());
      }
    }
    // moveExploreEventsStripToEnd();
  }

  void _handleSectionTopBanner(SectionListModel element) {
    if (element.column.isNotEmpty) {
      var data = element.column[0].data;

      if (data['sliderData'] != null) {
        _microSiteWidgets.add(
          NationalLearningWeekTopSection(
            columnData: element.column[0],
          ),
        );
      }

      if (data['keyHighlights'] != null) {
        _microSiteWidgets.add(
          KeyHighlights(
            highlights: data['keyHighlights']['content'] ?? [],
          ),
        );
      }

      _microSiteWidgets.add(
        NationalLearningWeekDescription(
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrlMobile'],
        ),
      );
    }
  }

  void _handleContentSection(SectionListModel element) {
    if (element.column.isNotEmpty) {
      var data = element.column[0].data;
      var leftContent = data['leftContent'];
      var rightContent = data['rightContent'];

      if (leftContent != null &&
          leftContent['data']['weekHighlights'] != null) {
        var weekHighlightsData = leftContent['data']['weekHighlights']['data'];
        if (weekHighlightsData != null) {
          _microSiteWidgets.addAll([
            HighlightsOfTheWeek(highlightsData: weekHighlightsData),
            SizedBox(height: 24),
          ]);
        }
      }

      if (rightContent != null) {
        var rightContentData = rightContent['data'];

        if (rightContentData != null) {
          if (rightContentData['myprogress'] != null) {
            var myprogressData = rightContentData['myprogress']['data'];
            if (myprogressData != null) {
              _microSiteWidgets.addAll([
                WeekProgress(
                  title: myprogressData['title'],
                  infoText: myprogressData['infoText'],
                ),
                SizedBox(
                  height: 24,
                )
              ]);
            }
          }

          if (rightContentData['speakerOftheDay'] != null) {
            var speakerData = rightContentData['speakerOftheDay']['data'];
            if (speakerData != null) {
              _microSiteWidgets.addAll([
                SpeakerOfTheDay(speakerData: speakerData),
                SizedBox(height: 24),
              ]);
            }
          }

          if (rightContentData['mdoLeaderboard'] != null) {
            var mdoLeaderboardData = rightContentData['mdoLeaderboard']['data'];
            if (mdoLeaderboardData != null) {
              _microSiteWidgets.addAll([
                MdoLeaderboard(
                  title: mdoLeaderboardData['title'],
                  infoText: mdoLeaderboardData['infoText'],
                ),
                SizedBox(height: 24),
              ]);
            }
          }
        }
      }
    }
    _handleMandatorySection(element);
    _handleExploreLearningContent(element);
    _handleEventsSection(element);
  }

  _handleMandatorySection(SectionListModel element) {
    if (element.column.isNotEmpty) {
      var data = element.column[0].data;
      var leftContent = data['leftContent'];
      if (leftContent != null &&
          leftContent['data']['mandatoryCourse'] != null &&
          leftContent['data']['mandatoryCourse']['enabled']) {
        _microSiteWidgets.add(
          MandatorySection(
            title: leftContent['data']?['mandatoryCourse']?['column']?[0]
                    ?['data']?['strips']?[0]?['title'] ??
                'Indian Knowledge Systems',
          ),
        );
      }
    }
  }

  _handleExploreLearningContent(SectionListModel element) {
    if (element.column.isNotEmpty) {
      var data = element.column[0].data;
      var leftContent = data['leftContent'];
      if (leftContent != null &&
          leftContent['data']['exploreLearningContent'] != null &&
          leftContent['data']['exploreLearningContent']['enabled']) {
        _microSiteWidgets.add(ExploreLearningContent(
          exploreContent: leftContent['data']['exploreLearningContent'],
        ));
      }
    }
  }

  _handleEventsSection(SectionListModel element) {
    if (element.column.isNotEmpty) {
      var data = element.column[0].data;
      var leftContent = data['leftContent'];
      if (leftContent != null &&
          leftContent['data']['events'] != null &&
          leftContent['data']['events']['enabled']) {
        _microSiteWidgets.add(
          ExploreEventsStrip(
            startDate: widget.startDate,
            endDate: widget.endDate,
          ),
        );
      }
    }
  }

  void moveExploreEventsStripToEnd() {
    final index =
        _microSiteWidgets.indexWhere((widget) => widget is ExploreEventsStrip);
    if (index != -1) {
      final widgetToMove = _microSiteWidgets.removeAt(index);
      _microSiteWidgets.add(widgetToMove);
    }
  }

  void _performanceDashboard(SectionListModel element) {
    if ((element.enabled ?? false) && element.column.isNotEmpty) {
      var data = element.column[0].data;
      if (data['lookerProMobileUrl'] != null) {
        if (data['header'] != null) {
          _microSiteWidgets.add(
            NationalLearningWeekDescription(
              title: data['header']['headerText'] ?? "",
              description: data['header']['description'] ?? "",
            ),
          );
        }
        _microSiteWidgets.add(
          PerformanceDashboard(
            url: data['lookerProMobileUrl'] ?? "",
          ),
        );
      }
    }
  }
}
