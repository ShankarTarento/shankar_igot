import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/models/_models/connection_request_model.dart.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../constants/index.dart';
import '../../../../respositories/index.dart';
import '../../../../util/telemetry_repository.dart';
import '../../../widgets/index.dart';

class NetworkRequestPage extends StatefulWidget {
  final parentAction;
  const NetworkRequestPage({Key? key, this.parentAction}) : super(key: key);

  @override
  _NetworkRequestPageState createState() => _NetworkRequestPageState();
}

class _NetworkRequestPageState extends State<NetworkRequestPage> {
  String? userId;
  String? userSessionId;
  String? messageIdentifier;
  String? departmentId;
  int _start = 0;
  List? allEventsData;
  String? deviceIdentifier;
  var telemetryEventData;

  @override
  void initState() {
    super.initState();
    // _getConnectionRequest(context);
    _getPymk(context);
    if (_start == 0) {
      allEventsData = [];
      _generateTelemetryData();
    }
    // _startTimer();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.networkHomePageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.networkHomePageUri,
        env: TelemetryEnv.network);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  void dispose() async {
    super.dispose();
  }

  /// Get connection request response
  Future<ConnectionRequest?> _getConnectionRequest(context) async {
    try {
      return await Provider.of<NetworkRespository>(context, listen: false)
          .getCrList();
    } catch (err) {
      throw err;
    }
  }

  // Future<dynamic> _getFromMyMDO(context) async {
  //   try {
  //     dynamic _networks = [];
  //     _networks = await Provider.of<NetworkRespository>(context, listen: false)
  //         .getAllUsersFromMDO();

  //     return _networks;
  //   } catch (err) {
  //     return err;
  //   }
  // }

  /// Get PYMK response
  Future _getPymk(context) async {
    try {
      return Provider.of<NetworkRespository>(context, listen: false)
          .getPymkList();
    } catch (err) {
      return err;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        children: [
          FutureBuilder<ConnectionRequest?>(
            future: _getConnectionRequest(context),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Container(
                  decoration: BoxDecoration(
                      color: AppColors.appBarBackground,
                      borderRadius: BorderRadius.circular(12).r),
                  margin: EdgeInsets.only(top: 16).r,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(15.0, 16.0, 15.0, 0.0).r,
                        child: Text(
                            AppLocalizations.of(context)!.mStaticRecentRequests,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp)),
                      ),
                      Wrap(
                        children: [
                          ConnectionRequests(
                            snapshot.data,
                            false,
                            isFromHome: true,
                            isFromProfile: true,
                            parentAction: widget.parentAction,
                          )
                        ],
                      ),
                      Visibility(
                        visible: snapshot.data!.data.length > 0,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            FadeRoute(
                                page: NetworkHubV2(
                              initialIndex: 1,
                            )),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(24).r,
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)!.mLearnShowAll,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    fontSize: 16.sp,
                                    letterSpacing: 0.12.w,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return PageLoader(
                  bottom: 150.w,
                  top: 16.w,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
