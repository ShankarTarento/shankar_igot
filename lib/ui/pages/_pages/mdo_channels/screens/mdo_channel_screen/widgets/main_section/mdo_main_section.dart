import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/state_learning_week.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/ati_cti_microsite_data_model.dart';
import 'package:provider/provider.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../../../util/telemetry_repository.dart';
import '../../../../../../../skeleton/widgets/container_skeleton.dart';
import '../../../../model/mdo_announcement_section_data_model.dart';
import '../../../../model/mdo_cbp_section_data_model.dart';
import '../../../../model/mdo_main_section_data_model.dart';
import '../../../key_announcements/key_announcement_screen.dart';
import '../../../key_announcements/widgets/key_announcement_widget.dart';
import '../cbp_section/mdo_cbplans.dart';
import 'content/mdo_content_view.dart';
import 'core_areas/mdo_competency_strength_view.dart';

class MdoMainSection extends StatefulWidget {
  final GlobalKey? containerKey;
  final String providerName;
  final String orgId;
  final ColumnData columnData;
  final Map<String, dynamic>? stateLearningWeekConfig;

  MdoMainSection({
    this.containerKey,
    required this.providerName,
    required this.orgId,
    required this.columnData,
    this.stateLearningWeekConfig,
    Key? key,
  }) : super(key: key);

  @override
  _MdoMainSectionState createState() {
    return _MdoMainSectionState();
  }
}

class _MdoMainSectionState extends State<MdoMainSection>
    with SingleTickerProviderStateMixin {
  Future<MdoMainSectionDataModel>? mdoMainSectionDataModelFuture;
  Future<List<AnnouncementListItemData>>? announcementListDataDataFuture;
  int selectedTabIndex = 0;
  @override
  void initState() {
    super.initState();
    getMainSectionData();
    getAnnouncementData();
  }

  Future<void> getMainSectionData() async {
    var responseData = widget.columnData.data;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        mdoMainSectionDataModelFuture =
            Future.value(MdoMainSectionDataModel.fromJson(responseData));
      });
    });
  }

  Future<void> getAnnouncementData() async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getAnnouncementData(orgId: widget.orgId);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        announcementListDataDataFuture =
            Future<List<AnnouncementListItemData>>.value(
          responseData
              .map<AnnouncementListItemData>(
                  (data) => AnnouncementListItemData.fromJson(data))
              .toList(),
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return Container(
      key: widget.containerKey,
      child: FutureBuilder(
        future: mdoMainSectionDataModelFuture,
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            MdoMainSectionDataModel channelMainSectionDataModel = snapshot.data;
            return Container(
              child: Column(
                children: [
                  widget.stateLearningWeekConfig != null &&
                          channelMainSectionDataModel
                                  .stateLearningWeekSection !=
                              null
                      ? StateLearningWeek(
                          slwConfig: widget.stateLearningWeekConfig!,
                          mdoOrgId: widget.orgId,
                          slwData: channelMainSectionDataModel
                              .stateLearningWeekSection!)
                      : SizedBox.shrink(),
                  _cbPlanView(channelMainSectionDataModel.cbpPlanSection),
                  if (!channelMainSectionDataModel
                      .announcementSection.isDisabled)
                    _announcementView(
                        channelMainSectionDataModel.announcementSection),
                  channelMainSectionDataModel.tabSection.isDisabled
                      ? SizedBox.shrink()
                      : _channelTabView(
                          tabSection: channelMainSectionDataModel.tabSection),
                  channelMainSectionDataModel.tabSection.isDisabled
                      ? SizedBox.shrink()
                      : _channelTabItemView(
                          tabSection: channelMainSectionDataModel.tabSection),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _cbPlanView(MdoCBPSectionDataModel cbpPlanSection) {
    return (cbpPlanSection.data != null)
        ? MdoCBPlans(orgId: widget.orgId, cbpPlanSection: cbpPlanSection)
        : SizedBox.shrink();
  }

  Widget _announcementView(
      MdoAnnouncementSectionDataModel announcementSection) {
    return FutureBuilder(
      future: announcementListDataDataFuture,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          List<AnnouncementListItemData> announcementList = snapshot.data ?? [];
          return ((announcementList).length > 0)
              ? KeyAnnouncementView(
                  height: 30.w,
                  width: 268.w,
                  title: announcementSection.data?.title ??
                      AppLocalizations.of(context)!.mMdoChannelKeyAnnouncements,
                  iconUrl: announcementSection.data?.mobileIcon ?? '',
                  showPrefixIcon: true,
                  showPostfixIcon: true,
                  onTap: () {
                    _showKeyAnnouncementsBottomSheet(
                        announcementSection, announcementList);
                  },
                )
              : SizedBox.shrink();
        } else {
          return Container(
              width: double.maxFinite,
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 4, right: 4).w,
              child: ContainerSkeleton(
                width: 220.w,
                height: 38.w,
                radius: 18.w,
              ));
        }
      },
    );
  }

  Widget _channelTabView({required TabSectionData tabSection}) {
    return Container(
      height: 36.w,
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(top: 16, left: 16, right: 16).w,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.w,
            color: AppColors.grey08,
          ),
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: (tabSection.tabs).length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            setState(() {
              selectedTabIndex = index;
              _generateInteractTelemetryData(
                  contentId: (selectedTabIndex == 0)
                      ? TelemetryIdentifier.contentTab
                      : TelemetryIdentifier.coreAreaTab,
                  subType: TelemetrySubType.mdoChannel);
            });
          },
          child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 12).w,
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 16).w,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: selectedTabIndex == index ? 1.w : 0.w,
                    color: selectedTabIndex == index
                        ? AppColors.darkBlue
                        : AppColors.grey08,
                  ),
                ),
              ),
              child: Text(
                '${tabSection.tabs[index].name[0].toUpperCase()}${tabSection.tabs[index].name.substring(1)}',
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: selectedTabIndex == index
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: selectedTabIndex == index
                      ? AppColors.greys87
                      : AppColors.greys60,
                ),
              )),
        ),
      ),
    );
  }

  Widget _channelTabItemView({required TabSectionData tabSection}) {
    return Stack(
      children: [
        Offstage(
          offstage: (selectedTabIndex != 0),
          child: TickerMode(
            enabled: (selectedTabIndex == 0),
            child: MdoContentView(
                orgId: widget.orgId, contentTab: tabSection.contentTab),
          ),
        ),
        Offstage(
          offstage: (selectedTabIndex == 0),
          child: TickerMode(
            enabled: (selectedTabIndex != 0),
            child: MdoCompetencyStrengthView(
              orgId: widget.orgId,
            ),
          ),
        ),
      ],
    );
  }

  void _showKeyAnnouncementsBottomSheet(
      MdoAnnouncementSectionDataModel announcementSection,
      List<AnnouncementListItemData> announcementList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.grey04.withValues(alpha: 0.36),
      builder: (BuildContext context) {
        return Container(
            child: KeyAnnouncementScreen(
                data: announcementSection.data,
                announcementList: announcementList));
      },
    );
  }

  void _generateInteractTelemetryData(
      {required String contentId,
      required String subType,
      String clickId = ''}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.browseByMdoChannelPageId,
        contentId: contentId,
        subType: subType,
        clickId: clickId,
        env: TelemetryEnv.learn);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
