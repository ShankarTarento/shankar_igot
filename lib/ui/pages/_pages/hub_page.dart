import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/common_components/constants/widget_constants.dart';
import 'package:karmayogi_mobile/home_screen_components/hubs_strip/widgets/explore_hub_items.dart';
import 'package:karmayogi_mobile/home_screen_components/models/hub_item_model.dart';
import 'package:karmayogi_mobile/ui/widgets/_network/follow_us_social_media.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/in_app_webview_page.dart';
import 'package:provider/provider.dart';
import '../../screens/_screens/profile/model/profile_model.dart';
import '../../../respositories/_respositories/profile_repository.dart';
import '../../../util/telemetry_repository.dart';
import './../../../ui/screens/index.dart';
import '../../../constants/index.dart';
import '../../widgets/index.dart';
import './../../../util/faderoute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HubPage extends StatefulWidget {
  final int? tabIndex;

  const HubPage({Key? key, this.tabIndex}) : super(key: key);
  @override
  State<HubPage> createState() => _HubPageState();
}

class _HubPageState extends State<HubPage> {
  Profile? _profileData;
  String? userId;
  String? userSessionId;
  String? messageIdentifier;
  String? departmentId;
  List? allEventsData;
  bool? dataSent;
  String? deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    if (widget.tabIndex == 1) {
      _generateImpressionTelemetryData();
      _profileData =
          Provider.of<ProfileRepository>(context, listen: false).profileDetails;
    }
  }

  void _generateImpressionTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        telemetryType: TelemetryType.app,
        pageUri: TelemetryPageIdentifier.homePageUri,
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  void _generateInteractTelemetryData(
      {required String contentId, required String subType}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        contentId: contentId,
        subType: subType,
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        color: AppColors.whiteGradientOne,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: SectionHeading(AppLocalizations.of(context)!.mCommonHubs),
            ),
            AnimationLimiter(
              child: Column(
                children: buildHubsWidget(),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              child:
                  SectionHeading(AppLocalizations.of(context)!.mStaticDoMore),
            ),
            doMoreWidgets(),
            Container(
              alignment: Alignment.topLeft,
              child: SectionHeading(
                  AppLocalizations.of(context)!.mStaticComingSoon),
            ),
            comingSoonWidgets(),
            FollowUsOnSocialMedia(),
          ],
        ),
      ),
    );
  }

  Widget doMoreWidgets() {
    final doMoreList = DO_MORE(context: context)
        .where((hub) => !(hub.enabled ?? true) ? false : !(_profileData!.roles!
        .contains(Roles.mentor.toUpperCase()) && hub.externalUrl != null))
        .toList();

    return AnimationLimiter(
      child: Column(
        children: List.generate(
          doMoreList.length,
              (i) {
            final hub = doMoreList[i];
            return AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: InkWell(
                    onTap: () {
                      _generateInteractTelemetryData(
                        contentId: hub.telemetryId!,
                        subType: TelemetrySubType.hubMenu,
                      );
                      if (hub.comingSoon!) {
                        Navigator.push(
                          context,
                          FadeRoute(page: ComingSoonScreen()),
                        );
                      } else if (hub.externalUrl != null) {
                        Navigator.push(
                          context,
                          FadeRoute(
                            page: InAppWebViewPage(
                              parentContext: context,
                              url: hub.externalUrl!,
                            ),
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, hub.url!);
                      }
                    },
                    child: HubItem(
                      hub.id,
                      hub.title,
                      hub.description,
                      hub.icon as IconData,
                      hub.iconColor,
                      hub.comingSoon!,
                      hub.url!,
                      hub.svgIcon!,
                      hub.svg!,
                      isDoMore: true,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  Widget comingSoonWidgets() {
    final comingSoonList = COMING_SOON(context: context);

    return AnimationLimiter(
      child: Column(
        children: List.generate(
          comingSoonList.length,
              (i) {
            final hub = comingSoonList[i];
            return AnimationConfiguration.staggeredList(
              position: i,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: InkWell(
                    onTap: () {
                      if (!hub.comingSoon!) {
                        Navigator.pushNamed(context, hub.url!);
                      }
                    },
                    child: HubItem(
                      hub.id,
                      hub.title,
                      hub.description,
                      hub.icon as IconData,
                      hub.iconColor,
                      hub.comingSoon!,
                      hub.url!,
                      hub.svgIcon!,
                      hub.svg!,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }


  List<Widget> buildHubsWidget() {
    final List<Widget> hubWidgets = [];

    try {
      final homeConfig = AppConfiguration.homeConfigData;
      if (homeConfig == null) return [];

      final data = homeConfig['data'];
      if (data is! List) return [];

      final hubsItem = data.cast<Map<String, dynamic>?>().firstWhere(
            (item) => item?['type'] == WidgetConstants.hubs,
        orElse: () => null,
      );

      final hubData = hubsItem?['data'];
      if (hubData is! List) return [];

      final hubItems = hubData
          .whereType<Map<String, dynamic>>()
          .map(HubItemModel.fromJson)
          .toList();

      for (int i = 0; i < hubItems.length; i++) {
        hubWidgets.add(
          AnimationConfiguration.staggeredList(
            position: i,
            duration: const Duration(milliseconds: 475),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: ExploreHubItems(hubItem: hubItems[i]),
              ),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in buildHubsWidget: $e');
    }

    return hubWidgets;
  }


}
