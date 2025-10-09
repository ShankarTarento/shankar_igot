import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/user_connection_request.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/custom_network_card/widgets/network_blocked_state.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/custom_network_card/widgets/network_card_details.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/custom_network_card/widgets/network_connected_state.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/custom_network_card/widgets/network_request_received.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/custom_network_card/widgets/network_request_sent.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/network/network_profile.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class CustomNetworkCard extends StatefulWidget {
  final NetworkUser user;
  final UserConnectionStatus cardState;
  const CustomNetworkCard(
      {super.key, required this.cardState, required this.user});

  @override
  State<CustomNetworkCard> createState() => _CustomNetworkCardState();
}

class _CustomNetworkCardState extends State<CustomNetworkCard> {
  UserConnectionStatus? _connectionStatus;

  @override
  void initState() {
    _connectionStatus = widget.cardState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            FadeRoute(
                page: NetworkProfile(
              profileId: widget.user.userId,
              connectionStatus: UserConnectionStatus.Approved,
            )));
        _generateInteractTelemetryData();
      },
      child: Container(
        width: 1.sw,
        padding: EdgeInsets.all(8).r,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            CustomNetworkCardDetails(
              user: widget.user,
            ),
            SizedBox(width: 10.w),
            _buildTrailingButtons(context, state: _connectionStatus!),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingButtons(BuildContext context,
      {required UserConnectionStatus state}) {
    switch (state) {
      case UserConnectionStatus.Received:
        return NetworkRequestReceived(
          connectionStatus: UserConnectionStatus.Received,
          user: widget.user,
        );
      case UserConnectionStatus.Pending:
        return NetworkRequestSent(
          connectionStatus: UserConnectionStatus.Pending,
          user: widget.user,
        );
      case UserConnectionStatus.Approved:
        return NetworkConnectedState(
          user: widget.user,
          userConnectionStatus: UserConnectionStatus.Approved,
        );

      case UserConnectionStatus.BlockedOutgoing:
        return NetworkBlockedState(
          connectionStatus: UserConnectionStatus.BlockedOutgoing,
          user: widget.user,
        );
      default:
        return SizedBox.shrink();
    }
  }

  void _generateInteractTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier:
            TelemetryPageIdentifier.network + '${widget.user.userId}',
        contentId: widget.user.userId,
        clickId: TelemetryClickId.profileCard,
        env: TelemetryEnv.network);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
