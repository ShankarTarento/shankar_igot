import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_helper/network_helper.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/confirmation_popup.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/user_connection_request.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class NetworkRequestReceived extends StatefulWidget {
  final NetworkUser user;
  final UserConnectionStatus connectionStatus;

  const NetworkRequestReceived({
    super.key,
    required this.user,
    required this.connectionStatus,
  });

  @override
  State<NetworkRequestReceived> createState() => _NetworkRequestReceivedState();
}

class _NetworkRequestReceivedState extends State<NetworkRequestReceived> {
  final NetworkHubRepository _networkHubRepository = NetworkHubRepository();
  late UserConnectionStatus _connectionStatus;

  @override
  void initState() {
    super.initState();
    _connectionStatus = widget.connectionStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.user.createdAt != null)
          Padding(
            padding: const EdgeInsets.only(right: 6.0).r,
            child: Text(
              NetworkHubHelper.getRequestCreatedTime(
                createdAt: widget.user.createdAt!,
              ),
              style: GoogleFonts.lato(
                color: AppColors.greys60,
                fontSize: 12.sp,
              ),
            ),
          ),
        SizedBox(height: 8.h),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (_connectionStatus) {
      case UserConnectionStatus.Received:
        return Row(
          children: [
            _actionButton(
              icon: Icons.close,
              color: AppColors.greys60,
              borderColor: AppColors.greys60,
              onTap: () {
                _showWithdrawConfirmationDialog();

                _generateInteractTelemetryData(
                  userId: widget.user.userId,
                  clickId: TelemetryClickId.ignoreRequest,
                );
              },
            ),
            SizedBox(width: 6.w),
            _actionButton(
              icon: Icons.check,
              color: Colors.white,
              backgroundColor: AppColors.darkBlue,
              onTap: () {
                _updateStatus(UserConnectionStatus.Approved);
                _generateInteractTelemetryData(
                  userId: widget.user.userId,
                  clickId: TelemetryClickId.acceptRequest,
                );
              },
            ),
          ],
        );

      case UserConnectionStatus.Approved:
        return _statusText(
          AppLocalizations.of(context)!.mAccepted,
        );

      case UserConnectionStatus.Rejected:
        return _statusText(AppLocalizations.of(context)!.mIgnored);

      default:
        return SizedBox.shrink();
    }
  }

  Widget _statusText(String text) {
    return Text(
      text,
      style: GoogleFonts.lato(
        color: AppColors.greys60,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          border: Border.all(
            color: borderColor ?? Colors.transparent,
            width: 1.w,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24.sp),
      ),
    );
  }

  Future<void> _updateStatus(UserConnectionStatus newStatus) async {
    final result = await _networkHubRepository.updateConnectionStatus(
      connectionDepartmentTo: widget.user.departmentName,
      connectionIdTo: widget.user.userId,
      userNameTo: widget.user.fullName,
      status: newStatus.name,
    );

    if (result == NetworkConstants.successful) {
      setState(() {
        _connectionStatus = _mapToUserConnectionStatus(newStatus);
      });
      _showSnackBar(newStatus);
    } else {
      _showSnackBar(null);
    }
  }

  UserConnectionStatus _mapToUserConnectionStatus(UserConnectionStatus status) {
    switch (status) {
      case UserConnectionStatus.Approved:
        return UserConnectionStatus.Approved;
      case UserConnectionStatus.Rejected:
        return UserConnectionStatus.Rejected;
      default:
        return _connectionStatus;
    }
  }

  void _showSnackBar(UserConnectionStatus? status) {
    String message;
    Color bgColor = AppColors.darkBlue;

    switch (status) {
      case UserConnectionStatus.Approved:
        message =
            AppLocalizations.of(context)!.mNetworkConnectionRequestAccepted;
        break;
      case UserConnectionStatus.Rejected:
        message =
            AppLocalizations.of(context)!.mStaticConnectionRequestRejected;
        break;
      default:
        message = AppLocalizations.of(context)!.mStaticSomethingWrongTryLater;
        bgColor = AppColors.redBgShade;
    }

    Helper.showSnackBarMessage(
      context: context,
      text: message,
      bgColor: bgColor,
    );
  }

  void _showWithdrawConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        parentContext: context,
        message: AppLocalizations.of(context)!.mRequestRejectedMessage,
        onConfirm: () async {
          await _updateStatus(UserConnectionStatus.Rejected);
          Navigator.of(dialogContext).pop();
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
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
