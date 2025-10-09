import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/confirmation_popup.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/repository/public_profile_dashboard_repository.dart';
import 'package:karmayogi_mobile/ui/skeleton/index.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_widgets/pills_button_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';

class ConnectionStatusButton extends StatefulWidget {
  final String userId;
  final String name;
  final String department;

  const ConnectionStatusButton({
    super.key,
    required this.userId,
    required this.name,
    required this.department,
  });

  @override
  State<ConnectionStatusButton> createState() => _ConnectionStatusButtonState();
}

class _ConnectionStatusButtonState extends State<ConnectionStatusButton> {
  final ValueNotifier<bool> _isConnecting = ValueNotifier(false);
  final NetworkHubRepository _networkHubRepository = NetworkHubRepository();

  @override
  Widget build(BuildContext context) {
    return Consumer<PublicProfileDashboardRepository>(
      builder: (context, provider, child) {
        final status = provider.userConnectionStatus;
        return _buildConnectionButton(status);
      },
    );
  }

  Widget _buildConnectionButton(UserConnectionStatus? status) {
    if (status == null) {
      return ContainerSkeleton(
        height: 40.h,
        width: 1.sw,
        radius: 50.r,
      );
    }
    switch (status) {
      case UserConnectionStatus.Connect:
      case UserConnectionStatus.UnBlock:
      case UserConnectionStatus.Withdrawn:
      case UserConnectionStatus.Approved:
      case UserConnectionStatus.BlockedOutgoing:
      case UserConnectionStatus.Rejected:
        return _buildPillsButton(status);
      case UserConnectionStatus.Pending:
        return _buildStaticPillsButton(
          status: status,
          color: Colors.white,
          borderColor: AppColors.greys60,
          textColor: AppColors.greys60,
        );
      case UserConnectionStatus.Received:
        return _buildActionButtons();
      case UserConnectionStatus.BlockedIncoming:
        return SizedBox.shrink();
      default:
        return SizedBox();
    }
  }

  Widget _buildPillsButton(UserConnectionStatus status) {
    final isApproved = status == UserConnectionStatus.Approved;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8).w,
      child: PillsButtonWidget(
        title: _getButtonTitle(status),
        onTap: () => _handleButtonTap(status),
        decoration: BoxDecoration(
          color: isApproved ? Colors.white : const Color(0xFFE8EDF5),
          border: Border.all(color: AppColors.darkBlue),
          borderRadius: BorderRadius.circular(50.0).r,
        ),
        textColor: AppColors.darkBlue,
        textFontSize: 14.sp,
        isLoading: _isConnecting,
        isLightTheme: !isApproved,
        prefix: _getButtonIcon(status),
      ),
    );
  }

  Widget _buildStaticPillsButton({
    required UserConnectionStatus status,
    required Color color,
    Color? borderColor,
    required Color textColor,
  }) {
    return PillsButtonWidget(
      title: _getButtonTitle(status),
      onTap: () {},
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50.0).r,
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      textColor: textColor,
      textFontSize: 14.sp,
      isLoading: _isConnecting,
      isLightTheme: false,
      prefix: _getButtonIcon(status),
    );
  }

  Widget _getButtonIcon(UserConnectionStatus status) {
    switch (status) {
      case UserConnectionStatus.Connect:
      case UserConnectionStatus.Withdrawn:
      case UserConnectionStatus.Rejected:
        return Icon(Icons.person_add_alt_1_rounded,
            color: AppColors.darkBlue, size: 16.sp);
      case UserConnectionStatus.Pending:
        return Icon(Icons.watch_later_outlined,
            color: AppColors.grey84, size: 16.sp);
      case UserConnectionStatus.Approved:
        return SvgPicture.asset(
          "assets/img/person_connected.svg",
          height: 16.sp,
          width: 16.sp,
          colorFilter:
              const ColorFilter.mode(AppColors.darkBlue, BlendMode.srcIn),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _getButtonTitle(UserConnectionStatus status) {
    final loc = AppLocalizations.of(context)!;

    return switch (status) {
      UserConnectionStatus.Connect => loc.mStaticConnect,
      UserConnectionStatus.Pending => loc.mStaticConnectionRequestSent,
      UserConnectionStatus.Approved => loc.mStaticConnected,
      UserConnectionStatus.BlockedOutgoing => loc.mUnblock,
      UserConnectionStatus.Withdrawn ||
      UserConnectionStatus.UnBlock =>
        loc.mStaticConnect,
      _ => loc.mStaticConnect,
    };
  }

  Future<void> _handleButtonTap(UserConnectionStatus status) async {
    switch (status) {
      case UserConnectionStatus.Connect:
      case UserConnectionStatus.Withdrawn:
      case UserConnectionStatus.UnBlock:
      case UserConnectionStatus.Rejected:
        await _createConnectionRequest();
        break;
      case UserConnectionStatus.BlockedOutgoing:
        _showConfirmationDialog(
            message: AppLocalizations.of(context)!.mUnblockConfirmationMessage,
            onConfirm: () async {
              await _updateConnectionStatus(UserConnectionStatus.UnBlocked);
            });

        break;

      default:
        break;
    }
  }

  Widget _buildActionButtons() {
    return _isConnecting.value
        ? CircularProgressIndicator()
        : Row(
            children: [
              _buildActionButton(
                label: AppLocalizations.of(context)!.mIgnore,
                status: UserConnectionStatus.Rejected,
                textColor: AppColors.darkBlue,
                backgroundColor: Colors.white,
              ),
              SizedBox(width: 16.w),
              _buildActionButton(
                label: AppLocalizations.of(context)!.mAccept,
                status: UserConnectionStatus.Approved,
                textColor: Colors.white,
                backgroundColor: AppColors.darkBlue,
              ),
            ],
          );
  }

  Widget _buildActionButton({
    required String label,
    required UserConnectionStatus status,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return PillsButtonWidget(
      horizontalPadding: 24,
      title: label,
      onTap: () => _updateConnectionStatus(status),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50.0).r,
        border: Border.all(color: AppColors.darkBlue),
      ),
      textColor: textColor,
      textFontSize: 14.sp,
      isLoading: _isConnecting,
      isLightTheme: false,
    );
  }

  Future<void> _createConnectionRequest() async {
    _isConnecting.value = true;
    try {
      final result = await _networkHubRepository.createConnectionRequest(
        connectionId: widget.userId,
        userNameTo: widget.name,
        userDepartmentTo: widget.department,
      );

      if (result == NetworkConstants.successful) {
        _showSnackBar(
            AppLocalizations.of(context)!.mConnectionRequestSentSuccessfully);
        _updateProviderStatus(UserConnectionStatus.Pending);
        _generateInteractTelemetryData(
            userId: widget.userId, clickId: TelemetryClickId.profileCOnnect);
      }
    } finally {
      _isConnecting.value = false;
    }
  }

  Future<void> _updateConnectionStatus(UserConnectionStatus status) async {
    _isConnecting.value = true;
    try {
      final result = await _networkHubRepository.updateConnectionStatus(
        connectionDepartmentTo: widget.department,
        connectionIdTo: widget.userId,
        userNameTo: widget.name,
        status: status.name,
      );

      if (result == NetworkConstants.successful) {
        _showSnackBar(_getSuccessMessage(status));
        _updateProviderStatus(status);
        _generateInteractTelemetryData(
            userId: widget.userId,
            clickId: status == UserConnectionStatus.Approved
                ? TelemetryClickId.acceptRequest
                : TelemetryClickId.ignoreRequest);
      } else {
        _showSnackBar(
            AppLocalizations.of(context)!.mStaticSomethingWrongTryLater,
            isError: true);
      }
    } finally {
      _isConnecting.value = false;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    Helper.showSnackBarMessage(
      context: context,
      text: message,
      bgColor: isError ? Colors.red : AppColors.darkBlue,
    );
  }

  String _getSuccessMessage(UserConnectionStatus status) {
    final loc = AppLocalizations.of(context)!;

    return switch (status) {
      UserConnectionStatus.Approved => loc.mNetworkConnectionRequestAccepted,
      UserConnectionStatus.Rejected => loc.mStaticConnectionRequestRejected,
      UserConnectionStatus.UnBlocked => loc.mBlockedSuccessfully,
      _ => loc.mBlockedSuccessfully,
    };
  }

  void _updateProviderStatus(UserConnectionStatus status) {
    Provider.of<PublicProfileDashboardRepository>(context, listen: false)
        .updateConnectionStatus(status);
  }

  void _showConfirmationDialog(
      {required String message, required Function() onConfirm}) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        parentContext: context,
        message: message,
        onConfirm: () async {
          Navigator.of(dialogContext).pop();

          await onConfirm();
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
        pageIdentifier: TelemetryPageIdentifier.network + '$userId',
        contentId: userId,
        clickId: clickId,
        env: TelemetryEnv.network);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
