import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/user_connection_request.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/confirmation_popup.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class NetworkRequestSent extends StatefulWidget {
  final NetworkUser user;
  final UserConnectionStatus connectionStatus;

  const NetworkRequestSent({
    super.key,
    required this.user,
    required this.connectionStatus,
  });

  @override
  State<NetworkRequestSent> createState() => _NetworkRequestSentState();
}

class _NetworkRequestSentState extends State<NetworkRequestSent> {
  final NetworkHubRepository _networkHubRepository = NetworkHubRepository();
  late UserConnectionStatus _connectionStatus;

  @override
  void initState() {
    super.initState();
    _connectionStatus = widget.connectionStatus;
  }

  @override
  Widget build(BuildContext context) {
    return _buildActionWidget();
  }

  Widget _buildActionWidget() {
    switch (_connectionStatus) {
      case UserConnectionStatus.Pending:
        return _buildWithdrawButton();

      case UserConnectionStatus.Withdrawn:
        return _buildStatusLabel(AppLocalizations.of(context)!.mWithdrawn);

      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildWithdrawButton() {
    return TextButton(
      onPressed: () => _showWithdrawConfirmationDialog(),
      child: Text(
        AppLocalizations.of(context)!.mWithdraw,
        style: GoogleFonts.lato(
          color: AppColors.darkBlue,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildStatusLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.lato(
        color: AppColors.greys60,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _showWithdrawConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        parentContext: context,
        message: AppLocalizations.of(context)!.mWithdrawConnectionRequest,
        onConfirm: () async {
          _withdrawRequest(dialogContext);
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  Future<void> _withdrawRequest(BuildContext dialogContext) async {
    final result = await _networkHubRepository.updateConnectionStatus(
      connectionDepartmentTo: widget.user.departmentName,
      connectionIdTo: widget.user.userId,
      userNameTo: widget.user.fullName,
      status: UserConnectionStatus.Withdrawn.name,
    );

    if (result == NetworkConstants.successful) {
      setState(() {
        _connectionStatus = UserConnectionStatus.Withdrawn;
      });
    }

    Navigator.of(dialogContext).pop();
    if (result == NetworkConstants.successful) {
      Helper.showSnackBarMessage(
        context: context,
        text: AppLocalizations.of(context)!.mRequestWithdrawnSuccessfully,
        bgColor: AppColors.darkBlue,
      );
      _generateInteractTelemetryData(
        userId: widget.user.userId,
        clickId: TelemetryClickId.connectWithdraw,
      );
    } else {
      Helper.showSnackBarMessage(
        context: context,
        text: AppLocalizations.of(context)!.mStaticSomethingWrongTryLater,
        bgColor: Colors.red,
      );
    }
  }

  void _generateInteractTelemetryData(
      {required String userId, required String clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.networkHomePageId,
        contentId: userId,
        clickId: clickId,
        subType: TelemetrySubType.networkHubConnectionsRequests,
        env: TelemetryEnv.network);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
