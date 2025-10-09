import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/common_components/models/content_strip_model.dart';
import 'package:karmayogi_mobile/home_screen_components/mdo_channels/mdo_channel_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/model/mdo_channel_data_model.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/all_channel/browse_by_all_channel.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/all_channel/widgets/channel_list_item_widget.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/all_channel/widgets/mdo_channel_strip_widget_skeleton.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/mdo_channels/screens/mdo_channel_screen/mdo_channel_screen.dart';
import 'package:karmayogi_mobile/ui/widgets/title_widget/title_widget.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import '../../../../../../../constants/_constants/telemetry_constants.dart';
import '../../../../../../../util/faderoute.dart';

class MdoChannelsStripWidget extends StatefulWidget {
  final ContentStripModel stripData;
  MdoChannelsStripWidget({Key? key, required this.stripData}) : super(key: key);

  @override
  _MdoChannelStripWidgetState createState() {
    return new _MdoChannelStripWidgetState();
  }
}

class _MdoChannelStripWidgetState extends State<MdoChannelsStripWidget>
    with WidgetsBindingObserver {
  Future<List<MdoChannelDataModel>>? _channelResponseDataFuture;
  var telemetryEventData;
  int maxChanelToDisplay = 8;
  String orgBookmarkId = '';

  @override
  void initState() {
    super.initState();

    _channelResponseDataFuture = _getListOfChannels();
  }

  Future<List<MdoChannelDataModel>> _getListOfChannels() async {
    Map<String, dynamic>? data = AppConfiguration.homeConfigData;
    orgBookmarkId = Helper.getid(data?['mdoChannelMobile']);
    List<MdoChannelDataModel> responseData =
        await MdoChannelRepository.getMdoChannelRepository(
            apiUrl: widget.stripData.apiUrl + orgBookmarkId);

    responseData.removeWhere((element) => element.channel == null);
    return responseData;
  }

  @override
  Widget build(BuildContext context) {
    return _buildLayout();
  }

  Widget _buildLayout() {
    return FutureBuilder(
      future: _channelResponseDataFuture,
      builder: (context, AsyncSnapshot<List<MdoChannelDataModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0).r,
            child: MdoChannelStripWidgetSkeleton(),
          );
        }
        if (snapshot.data != null && snapshot.data!.isNotEmpty) {
          List<MdoChannelDataModel> channelList = snapshot.data ?? [];
          return channelList.isNotEmpty
              ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 8).r,
                      child: TitleWidget(
                        title: widget.stripData.title!.getText(context),
                        showAllCallBack: () {
                          // HomeTelemetryService.generateInteractTelemetryData(
                          //   TelemetryIdentifier.showAll,
                          //   subType: TelemetrySubType.mdoChannel,
                          // );
                          Navigator.push(
                            context,
                            FadeRoute(
                                page: BrowseByAllChannel(
                                    orgBookmarkId: orgBookmarkId)),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: 160.w,
                      margin: EdgeInsets.only(top: 16, bottom: 32).w,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: (channelList.length < maxChanelToDisplay
                              ? channelList.length
                              : maxChanelToDisplay),
                          itemBuilder: (context, index) {
                            return AnimationConfiguration.staggeredList(
                                position: index,
                                child: SlideAnimation(
                                  child: FadeInAnimation(
                                      child: Container(
                                    width: 0.7.sw,
                                    margin: EdgeInsets.only(left: 16).r,
                                    child: ChannelListItemWidget(
                                        onTap: () {
                                          HomeTelemetryService
                                              .generateInteractTelemetryData(
                                            TelemetryIdentifier.cardContent,
                                            clickId:
                                                channelList[index].rootOrgId ??
                                                    '',
                                            subType:
                                                TelemetrySubType.mdoChannel,
                                          );
                                          return Navigator.push(
                                            context,
                                            FadeRoute(
                                                page: MdoChannelScreen(
                                              channelName:
                                                  channelList[index].channel ??
                                                      '',
                                              orgId: channelList[index]
                                                      .rootOrgId ??
                                                  '',
                                            )),
                                          );
                                        },
                                        cardData: channelList[index]),
                                  )),
                                ));
                          }),
                    ),
                  ],
                )
              : SizedBox();
        } else {
          return SizedBox();
        }
      },
    );
  }
}
