import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_models/support_section_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/main_section/mdo_main_section.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/state_learning_week/widgets/slw_support_section.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/widgets/top_section/mdo_top_section_view.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/microsites/model/ati_cti_microsite_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/national_learning_week_description.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/national_learning_week/widgets/performance_dashboard.dart';
import 'package:provider/provider.dart';
import '../../../../../../localization/_langs/english_lang.dart';
import '../../../../../../respositories/_respositories/learn_repository.dart';
import '../../../../../../util/telemetry_repository.dart';
import 'mdo_channel_screen_skeleton.dart';
import 'widgets/top_learner/mdo_top_learner.dart';

class MdoChannelScreen extends StatefulWidget {
  final String channelName;
  final String orgId;
  final String? telemetryPageIdentifier;

  MdoChannelScreen(
      {required this.channelName,
      required this.orgId,
      this.telemetryPageIdentifier});

  @override
  _MdoChannelScreenState createState() {
    return _MdoChannelScreenState();
  }
}

class _MdoChannelScreenState extends State<MdoChannelScreen>
    with SingleTickerProviderStateMixin {
  ScrollController? _mdoChannelScrollController;
  Future<AtiCtiMicroSitesDataModel>? mdoChannelFuture;

  List<SectionListModel> mdoChannelSortedData = [];
  List<Widget> mdoChannelWidgets = [];
  Map<String, dynamic>? slwConfig;
  String? userId;
  String? userSessionId;
  String? messageIdentifier;
  String? departmentId;
  String? deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    _mdoChannelScrollController = ScrollController();
    getMdoChannelFormData();
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: widget.telemetryPageIdentifier ??
            TelemetryPageIdentifier.mdoChannelUri,
        telemetryType: TelemetryType.page,
        pageUri: widget.telemetryPageIdentifier ??
            TelemetryPageIdentifier.mdoChannelUri,
        env: EnglishLang.learn,
        subType: TelemetrySubType.mdoChannel);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  Future<void> getMdoChannelFormData() async {
    var responseData =
        await Provider.of<LearnRepository>(context, listen: false)
            .getMdoChannelFormData(orgId: widget.orgId);
    slwConfig = responseData['stateLearningWeekConfig'];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        mdoChannelFuture =
            Future.value(AtiCtiMicroSitesDataModel.fromJson(responseData));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _mdoChannelScrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: mdoChannelFuture,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MdoChannelScreenSkeleton(appBarWidget: _appBar());
        }
        if (snapshot.hasData && snapshot.data != null) {
          List<SectionListModel> mdoChannelDataList =
              snapshot.data.sectionList ?? [];
          mdoChannelSortedData = mdoChannelDataList
              .where((item) => item.enabled ?? false)
              .toList();
          mdoChannelSortedData.sort((a, b) => a.order!.compareTo(b.order!));
          sortLayouts(mdoChannelSortedData);
          return Scaffold(
            backgroundColor: AppColors.whiteGradientOne,
            appBar: _appBar(),
            body: (mdoChannelWidgets.isNotEmpty) ? _buildLayout() : Container(),
          );
        } else {
          return MdoChannelScreenSkeleton(appBarWidget: _appBar());
        }
      },
    );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 24.sp, color: AppColors.greys60),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        controller: _mdoChannelScrollController,
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              child: Column(children: mdoChannelWidgets),
            ),
          ],
        ),
      ),
    );
  }

  void sortLayouts(List<SectionListModel> _microSiteSortedData) {
    mdoChannelWidgets = [];
    _microSiteSortedData.forEach((element) {
      switch (element.key) {
        case 'sectionTopBanner':
          if (element.column.isNotEmpty)
            return mdoChannelWidgets.add(MdoTopSectionView(
                providerName: widget.channelName,
                orgId: widget.orgId,
                slwConfig: slwConfig,
                columnData: element.column[0]));
          break;

        case 'sectionTopLearners':
          if (element.column.isNotEmpty)
            return mdoChannelWidgets.add(MdoTopLearner(
                providerName: widget.channelName,
                slwConfig: slwConfig,
                orgId: widget.orgId,
                columnData: element.column[0]));
          break;
        case 'sectionMain':
          if (element.column.isNotEmpty)
            return mdoChannelWidgets.add(MdoMainSection(
                stateLearningWeekConfig: slwConfig,
                providerName: widget.channelName,
                orgId: widget.orgId,
                columnData: element.column[0]));
          break;
        case 'sectionLookerpro':
          try {
            if (element.column.isNotEmpty && element.enabled == true) {
              return mdoChannelWidgets.add(FutureBuilder(
                  future: Future.delayed(Duration(seconds: 1)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox();
                    }
                    return handleLookerDashboard(element.column[0].data);
                  }));
            }
          } catch (e) {
            debugPrint(",,,,,,,,,,,,,,,,,$e");
          }
          break;
        case 'sectionSupport':
          try {
            if (element.column.isNotEmpty && element.enabled == true) {
              SupportSectionModel? supportSectionModel;
              try {
                supportSectionModel =
                    SupportSectionModel.fromMap(element.column[0].data);
              } catch (e) {
                debugPrint("$e");
              }
              return mdoChannelWidgets.add(SlwSupportSection(
                element: element,
                supportSectionModel: supportSectionModel,
              ));
            }
          } catch (e) {
            debugPrint(",,,,,,,,,,,,,,,,,$e");
          }
          break;
        default:
          return mdoChannelWidgets.add(SizedBox.shrink());
      }
    });
  }

  Widget handleLookerDashboard(Map<String, dynamic> lookerData) {
    List<Widget> microSiteWidgets = [];

    if (lookerData['header'] != null) {
      microSiteWidgets.add(
        NationalLearningWeekDescription(
          title: lookerData['header']['headerText'] ?? "",
          description: lookerData['header']['description'] ?? "",
        ),
      );
    }

    microSiteWidgets.add(
      PerformanceDashboard(
        url: lookerData['lookerProMobileUrl'] != null
            ? lookerData['lookerProMobileUrl'] ?? ""
            : "",
      ),
    );

    return Column(
      children: microSiteWidgets,
    );
  }
}
