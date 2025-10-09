import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/public_profile_dashboard.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/utils/profile_constants.dart';
import '../../../../util/telemetry_repository.dart';
import './../../../../constants/index.dart';

class NetworkProfile extends StatefulWidget {
  static const route = AppUrl.networkProfilePage;
  final profileId;
  final UserConnectionStatus connectionStatus;

  const NetworkProfile({
    Key? key,
    this.profileId,
    required this.connectionStatus,
  }) : super(key: key);

  @override
  _NetworkProfileState createState() => _NetworkProfileState();
}

class _NetworkProfileState extends State<NetworkProfile>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _generateTelemetryData();
  }

  void _generateTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.userProfilePageId,
        telemetryType: TelemetryType.page,
        pageUri: TelemetryPageIdentifier.userProfilePageUri
            .replaceAll(":userId", widget.profileId),
        env: TelemetryEnv.network);
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PublicProfileDashboard(
      type: ProfileConstants.networkUser,
      userId: widget.profileId,
    );
  }
}
