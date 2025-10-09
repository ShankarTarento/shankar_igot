import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/content_strips/carousel_card/carousel_course_card.dart';
import 'package:karmayogi_mobile/common_components/content_strips/course_strip_widget/course_strip_widget.dart';
import 'package:karmayogi_mobile/common_components/information_card/information_card.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/common_components/models/information_card_model.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/designation_card/designation_card.dart';
import 'package:karmayogi_mobile/home_screen_components/enrollment_popup/enrollment_popup.dart';
import 'package:karmayogi_mobile/home_screen_components/home_live_events_strip/home_live_events_strip.dart';
import 'package:karmayogi_mobile/home_screen_components/hubs_strip/hubs_strip.dart';
import 'package:karmayogi_mobile/home_screen_components/karma_program_strip/karma_program_strip.dart';
import 'package:karmayogi_mobile/home_screen_components/mdo_channels/mdo_channels.dart';
import 'package:karmayogi_mobile/home_screen_components/models/hub_item_model.dart';
import 'package:karmayogi_mobile/home_screen_components/models/learn_tab_model.dart';
import 'package:karmayogi_mobile/home_screen_components/models/my_space_model.dart';
import 'package:karmayogi_mobile/home_screen_components/my_activity_card/my_activity_card.dart';
import 'package:karmayogi_mobile/home_screen_components/my_space_tab/my_space_tab.dart';
import 'package:karmayogi_mobile/home_screen_components/tab_course_Strip_widget/tab_course_strip_widget.dart';
import 'package:karmayogi_mobile/models/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/login_respository.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/home_page/scheduled_assesment/scheduled_assesment_strip.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/home_page/upcoming_course_schedule.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/learning_week_card/learning_week_card.dart';
import 'package:karmayogi_mobile/ui/widgets/_banner/banner_view_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/alert_display_card.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/home_learner_tip_strip.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/home_network_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/home_theme_data_strip.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/home_top_provider_strip.dart';
import 'package:karmayogi_mobile/ui/widgets/_network/follow_us_social_media.dart';
import 'package:karmayogi_mobile/ui/widgets/_tips_for_learning/data_models/tips_model.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreenComponents extends StatefulWidget {
  const HomeScreenComponents({super.key});

  @override
  State<HomeScreenComponents> createState() => _HomeScreenComponentsState();
}

class _HomeScreenComponentsState extends State<HomeScreenComponents> {
  List<Widget> widgets = [];

  void didChangeDependencies() {
    super.didChangeDependencies();
    constructHomeComponents();
  }

  void constructHomeComponents() async {
    widgets = [];
    Map<String, dynamic>? response = AppConfiguration.homeConfigData ??
        await AppConfiguration().getHomeConfig();

    if (response == null) {
      return;
    }

    bool enableThemeOverride = response['themeData']?['enabled'] ?? false;

    try {

      response['data'].forEach((e) async {
        if (e['enabled'] == false) {
          return;
        }

        BoxDecoration decoration = _buildBoxDecoration(
          e: e,
          formResponse: response,
          enableThemeOverride: enableThemeOverride,
        );

        String widgetType = e['type'].toString();

        switch (widgetType) {
          case WidgetConstants.notMyUser:
            widgets.add(buildNotMyUserWidget(decoration));
            break;
          case WidgetConstants.userDataError:
            widgets.add(buildUserDataErrorWidget(decoration));
            break;
          case WidgetConstants.updateDesignation:
            widgets.add(buildUpdateDesignationWidget(decoration, e));
            break;
          case WidgetConstants.hubs:
            widgets.addAll(buildHubsWidget(decoration, e));
            break;
          case WidgetConstants.homeLiveEventsStrip:
            widgets.add(buildHomeLiveEventsStripWidget(decoration));
            break;
          case WidgetConstants.homeThemeDataStrip:
            widgets.add(buildHomeThemeDataStripWidget(
                decoration, response, enableThemeOverride));
            break;
          case WidgetConstants.informationCard:
            widgets.add(buildInformationCardWidget(decoration, e));
            break;
          case WidgetConstants.courseStrip:
            widgets.add(buildCourseStripWidget(decoration, e));
            break;
          case WidgetConstants.tab:
            widgets.add(buildTabCourseStripWidget(decoration, e));
            break;
          case WidgetConstants.mySpace:
            widgets.add(buildMySpaceTabWidget(decoration, e));
            break;
          case WidgetConstants.karmaPrograms:
            widgets.add(buildKarmaProgramsStripWidget(decoration, e));
            break;
          case WidgetConstants.mdoChannels:
            widgets.add(buildMdoChannelsStripWidget(decoration, e));
            break;
          case WidgetConstants.myActivityCard:
            widgets.add(buildMyActivityCardWidget(decoration));
            break;
          case WidgetConstants.carouselStrip:
            widgets.add(buildCarouselStripWidget(decoration, e));
            break;
          case WidgetConstants.networkHub:
            widgets.add(buildNetworkHubWidget(decoration));
            break;
          case WidgetConstants.topProviderStrip:
            widgets.add(buildTopProviderStripWidget(decoration));
            break;
          case WidgetConstants.socialMedia:
            widgets.add(buildSocialMediaWidget(decoration));
            break;
          case WidgetConstants.banner:
            widgets.add(buildBannerWidget(decoration));
            break;
          case WidgetConstants.scheduledAssesment:
            widgets.add(buildScheduledAssesmentWidget(decoration));
            break;
          case WidgetConstants.learningWeek:
            widgets.add(buildLearningWeekWidget(decoration, e));
            break;
          case WidgetConstants.learnerTips:
            widgets.add(buildLearnerTipsWidget(decoration, e));
            break;
          case WidgetConstants.homeBlendedProgramAttendance:
            widgets.add(buildHomeBlendedProgramAttendanceWidget(decoration));
            break;
          default:
            debugPrint('Unknown widget type: $widgetType');
        }
      });
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("----------------$e");
    }
  }

  BoxDecoration _buildBoxDecoration({
    required dynamic e,
    required Map<String, dynamic> formResponse,
    required bool enableThemeOverride,
  }) {
    if (formResponse['themeData'] != null) {
      List<Color> themeColors =
          (formResponse['themeData']['backgroundColors'] as List?)
                  ?.map((e) => Color(int.parse(e)))
                  .toList() ??
              [];
      var color = int.tryParse(e['backgroundColor']);
      return BoxDecoration(
        color: color != null ? Color(color) : AppColors.whiteGradientOne,
        gradient:
            enableThemeOverride && themeColors.isNotEmpty && e['enableTheme']
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: themeColors)
                : null,
      );
    } else {
      return BoxDecoration(
        color: AppColors.whiteGradientOne,
      );
    }
  }

  Widget buildNotMyUserWidget(BoxDecoration decoration) {
    try {
      return Consumer<ProfileRepository>(builder: (BuildContext context,
          ProfileRepository profileRepository, Widget? child) {
        if (profileRepository.profileDetails != null &&
            profileRepository.profileDetails!.profileStatus ==
                UserProfileStatus.notMyUser) {
          return Container(
            decoration: decoration,
            child: AlertDisplayCard(
                message: AppLocalizations.of(context)!.mNotMyUserTimeAlertMsg),
          );
        } else
          return SizedBox.shrink();
      });
    } catch (e) {
      debugPrint('Error in NotMyUserWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildUserDataErrorWidget(BoxDecoration decoration) {
    try {
      return Consumer<ProfileRepository>(builder: (BuildContext context,
          ProfileRepository profileRepository, Widget? child) {
        if ((profileRepository.profileDetails == null) &&
            (profileRepository.isLoading)) return const SizedBox.shrink();
        return (profileRepository.profileDetails == null)
            ? Container(
                decoration: decoration,
                child: AlertDisplayCard(
                    message: AppLocalizations.of(context)!.mStaticUserDataError,
                    enableAlertIcon: false,
                    showActionButton: true,
                    buttonTitle: AppLocalizations.of(context)!.mSettingSignOut,
                    buttonCallback: () {
                      _generateInteractTelemetryData(
                          TelemetryConstants.signout);
                      _doLogout(context);
                    }),
              )
            : SizedBox.shrink();
      });
    } catch (e) {
      debugPrint('Error in UserDataErrorWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildUpdateDesignationWidget(BoxDecoration decoration, dynamic e) {
    try {
      return Container(
        width: 1.sw,
        padding: EdgeInsets.all(16).r,
        decoration: decoration,
        child: DesignationCard(designationCardData: e),
      );
    } catch (e) {
      debugPrint('Error in UpdateDesignationWidget: $e');
      return SizedBox.shrink();
    }
  }

  List<Widget> buildHubsWidget(BoxDecoration decoration, dynamic e) {
    try {
      List<HubItemModel> hubItems = [];

      var data = e['data'];

      if (data is List) {
        for (var element in data) {
          if (element is Map<String, dynamic>) {
            hubItems.add(HubItemModel.fromJson(element));
          }
        }
      }

      return [
        LayoutBuilder(builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            color: AppColors.appBarBackground,
            child: HubsStrip(
              hubItems: hubItems,
            ),
          );
        }),
        EnrollmentPopup(),
      ];
    } catch (e) {
      debugPrint('Error in HubsWidget: $e');
      return [];
    }
  }

  Widget buildHomeLiveEventsStripWidget(BoxDecoration decoration) {
    try {
      return Container(
        decoration: decoration,
        child: HomeLiveEventsStrip(),
      );
    } catch (e) {
      debugPrint('Error in HomeLiveEventsStripWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildHomeThemeDataStripWidget(BoxDecoration decoration,
      Map<String, dynamic> formResponse, bool enableThemeOverride) {
    try {
      OverlayThemeModel overlayThemeModel =
          OverlayThemeModel.fromJson(formResponse['themeData']);
      return Container(
        decoration: decoration,
        child: HomeThemeDataStrip(
          overlayThemeUpdatesData: overlayThemeModel,
          showOverlayThemeUpdates: enableThemeOverride,
        ),
      );
    } catch (e) {
      debugPrint('Error in HomeThemeDataStripWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildInformationCardWidget(BoxDecoration decoration, dynamic e) {
    try {
      return Container(
        decoration: decoration,
        child: InformationCard(
          informationCardModel: InformationCardModel.fromJson(e['data']),
        ),
      );
    } catch (e) {
      debugPrint('Error in InformationCardWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildCourseStripWidget(BoxDecoration decoration, dynamic e) {
    try {
      return Container(
        decoration: decoration,
        child: CourseStripWidget(
          courseStripData: ContentStripModel.fromMap(e),
        ),
      );
    } catch (e) {
      debugPrint('Error in CourseStripWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildTabCourseStripWidget(BoxDecoration decoration, dynamic e) {
    try {
      return Container(
        decoration: decoration,
        child: TabCourseStripWidget(
          tabData: LearnTabModel.fromJson(e),
        ),
      );
    } catch (e) {
      debugPrint('Error in TabCourseStripWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildMySpaceTabWidget(BoxDecoration decoration, dynamic e) {
    try {
      return Container(
        decoration: decoration,
        child: MySpaceTab(
          tabData: MySpaceModel.fromJson(e),
        ),
      );
    } catch (e) {
      debugPrint('Error in MySpaceTabWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildKarmaProgramsStripWidget(BoxDecoration decoration, dynamic e) {
    try {
      return Container(
        decoration: decoration,
        child: KarmaProgramsStrip(
          stripData: ContentStripModel.fromMap(e),
        ),
      );
    } catch (e) {
      debugPrint('Error in KarmaProgramsStripWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildMdoChannelsStripWidget(BoxDecoration decoration, dynamic e) {
    try {
      return Container(
        decoration: decoration,
        child: MdoChannelsStripWidget(
          stripData: ContentStripModel.fromMap(e),
        ),
      );
    } catch (e) {
      debugPrint('Error in MdoChannelsStripWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildMyActivityCardWidget(BoxDecoration decoration) {
    try {
      return Container(
        decoration: decoration,
        child: MyActivityCard(),
      );
    } catch (e) {
      debugPrint('Error in MyActivityCardWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildCarouselStripWidget(BoxDecoration decoration, dynamic e) {
    try {
      return Container(
        decoration: decoration,
        child: CarouselCourseCard(
          stripData: ContentStripModel.fromMap(e),
        ),
      );
    } catch (e) {
      debugPrint('Error in CarouselStripWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildNetworkHubWidget(BoxDecoration decoration) {
    try {
      return Container(
        decoration: decoration,
        child: HomeNetworkWidget(
          generateShowAllTelemetry: () {
            HomeTelemetryService.generateInteractTelemetryData(
                TelemetryIdentifier.showAll,
                subType: TelemetrySubType.suggestedConnections,
                isObjectNull: true);
          },
        ),
      );
    } catch (e) {
      debugPrint('Error in NetworkHubWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildTopProviderStripWidget(BoxDecoration decoration) {
    try {
      return Container(
        decoration: decoration,
        child: HomeTopProviderStrip(),
      );
    } catch (e) {
      debugPrint('Error in TopProviderStripWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildSocialMediaWidget(BoxDecoration decoration) {
    try {
      return Container(
        decoration: decoration,
        child: FollowUsOnSocialMedia(),
      );
    } catch (e) {
      debugPrint('Error in SocialMediaWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildBannerWidget(BoxDecoration decoration) {
    try {
      return Container(
        decoration: decoration,
        child: BannerViewWidget(),
      );
    } catch (e) {
      debugPrint('Error in BannerWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildScheduledAssesmentWidget(BoxDecoration decoration) {
    try {
      return Container(
        decoration: decoration,
        child: ScheduledAssesmentStrip(),
      );
    } catch (e) {
      debugPrint('Error in ScheduledAssesmentWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildLearningWeekWidget(BoxDecoration decoration, Map e) {
    try {
      List dataList = e['data'];
      return Container(
        decoration: decoration,
        child: LearningWeekCard(configData: dataList),
      );
    } catch (e) {
      debugPrint('Error in lLearningWeekWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildLearnerTipsWidget(BoxDecoration decoration, dynamic e) {
    try {
      List<TipsModel> tips = [];

      var data = e['data'];

      if (data is List) {
        for (var element in data) {
          if (element is Map<String, dynamic>) {
            tips.add(TipsModel.fromJson(element));
          }
        }
      }
      return Container(
        decoration: decoration,
        child: HomeLearnerTipStrip(
          generateShowAllTelemetry: () {
            HomeTelemetryService.generateInteractTelemetryData(
                TelemetryIdentifier.showAll,
                subType: TelemetrySubType.tipsForLearner,
                isObjectNull: true);
          },
          tips: tips,
        ),
      );
    } catch (e) {
      debugPrint('Error in LearnerTipsWidget: $e');
      return SizedBox.shrink();
    }
  }

  Widget buildHomeBlendedProgramAttendanceWidget(BoxDecoration decoration) {
    try {
      return Container(
        decoration: decoration,
        child: UpcomingCourseSchedule(
          callBack: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('Error in HomeBlendedProgramAttendanceWidget: $e');
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: widgets));
  }

  Future<void> _doLogout(context) async {
    await Provider.of<LoginRespository>(context, listen: false)
        .doLogout(context);
  }

  void _generateInteractTelemetryData(String contentId) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: TelemetrySubType.profile.toLowerCase(),
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
