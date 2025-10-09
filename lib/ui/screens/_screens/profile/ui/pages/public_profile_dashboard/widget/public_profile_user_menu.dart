import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/confirmation_popup.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/repository/public_profile_dashboard_repository.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PublicProfileUserMenu extends StatefulWidget {
  final String userId;
  final String departmentName;
  final String fullName;

  const PublicProfileUserMenu({
    super.key,
    required this.userId,
    required this.departmentName,
    required this.fullName,
  });

  @override
  State<PublicProfileUserMenu> createState() => _PublicProfileUserMenuState();
}

class _PublicProfileUserMenuState extends State<PublicProfileUserMenu> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PublicProfileDashboardRepository>(
        builder: (context, provider, child) {
      UserConnectionStatus userConnectionStatus =
          provider.userConnectionStatus ?? UserConnectionStatus.Connect;
      return PopupMenuButton<UserConnectionStatus>(
        icon: const Icon(Icons.more_vert, color: Colors.black),
        onSelected: _onMenuSelected,
        itemBuilder: (BuildContext context) =>
            getMenuItems(userConnectionStatus),
      );
    });
  }

  List<PopupMenuItem<UserConnectionStatus>> getMenuItems(
      UserConnectionStatus status) {
    switch (status) {
      case UserConnectionStatus.Connect:
        return [
          PopupMenuItem<UserConnectionStatus>(
            value: UserConnectionStatus.BlockedOutgoing,
            child: Text(AppLocalizations.of(context)!.mBlock),
          ),
          PopupMenuItem<UserConnectionStatus>(
            value: UserConnectionStatus.CopyProfileLink,
            child: Text(AppLocalizations.of(context)!.mCopyProfileLink),
          ),
        ];
      case UserConnectionStatus.Pending:
        return [
          PopupMenuItem<UserConnectionStatus>(
              value: UserConnectionStatus.Withdrawn,
              child: Text(
                AppLocalizations.of(context)!.mWithdraw,
              )),
          PopupMenuItem<UserConnectionStatus>(
            value: UserConnectionStatus.CopyProfileLink,
            child: Text(AppLocalizations.of(context)!.mCopyProfileLink),
          ),
        ];
      case UserConnectionStatus.Approved:
        return [
          PopupMenuItem<UserConnectionStatus>(
            value: UserConnectionStatus.Removed,
            child: Text(AppLocalizations.of(context)!.mRemoveConnection),
          ),
          PopupMenuItem<UserConnectionStatus>(
            value: UserConnectionStatus.BlockedOutgoing,
            child: Text(AppLocalizations.of(context)!.mBlock),
          ),
          PopupMenuItem<UserConnectionStatus>(
            value: UserConnectionStatus.CopyProfileLink,
            child: Text(AppLocalizations.of(context)!.mCopyProfileLink),
          ),
        ];
      case UserConnectionStatus.BlockedOutgoing:
        return [
          PopupMenuItem<UserConnectionStatus>(
            value: UserConnectionStatus.CopyProfileLink,
            child: Text(AppLocalizations.of(context)!.mCopyProfileLink),
          ),
        ];
      default:
        return [
          PopupMenuItem<UserConnectionStatus>(
            value: UserConnectionStatus.CopyProfileLink,
            child: Text(AppLocalizations.of(context)!.mCopyProfileLink),
          )
        ];
    }
  }

  void _onMenuSelected(UserConnectionStatus value) {
    switch (value) {
      case UserConnectionStatus.BlockedOutgoing:
        _showConfirmationDialog(
            message: AppLocalizations.of(context)!.mBlockUserMessage,
            newStatus: UserConnectionStatus.BlockedOutgoing,
            onConfirm: () async {
              await blockUser();
            });
        break;
      case UserConnectionStatus.Withdrawn:
        _showConfirmationDialog(
            message:
                AppLocalizations.of(context)!.mProfileWithdrawRequestConfirm,
            newStatus: UserConnectionStatus.Withdrawn,
            onConfirm: () async {
              await _updateStatus(UserConnectionStatus.Withdrawn);
              _generateInteractTelemetryData(
                  userId: widget.userId,
                  clickId: TelemetryClickId.connectWithdraw);
            });
        break;
      case UserConnectionStatus.Removed:
        _showConfirmationDialog(
            message: AppLocalizations.of(context)!
                .mRemoveConnectionConfirmationMessage,
            newStatus: UserConnectionStatus.Removed,
            onConfirm: () async {
              await _updateStatus(UserConnectionStatus.Removed);
              _generateInteractTelemetryData(
                  userId: widget.userId,
                  clickId: TelemetryClickId.profileRemove);
            });
        break;
      case UserConnectionStatus.CopyProfileLink:
        copyProfileLink();
        break;
      default:
        break;
    }
  }

  Future<void> copyProfileLink() async {
    await Clipboard.setData(ClipboardData(
        text: '${ApiUrl.baseUrl}/app/person-profile/${widget.userId}'));
    Helper.showSnackBarMessage(
        context: context,
        text: AppLocalizations.of(context)!.mContentSharePageLinkCopied,
        bgColor: AppColors.darkBlue);
  }

  void _showConfirmationDialog(
      {required UserConnectionStatus newStatus,
      required String message,
      required Function() onConfirm}) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        parentContext: context,
        message: message,
        onConfirm: () async {
          await onConfirm();
          Navigator.of(dialogContext).pop();
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  Future<void> _updateStatus(UserConnectionStatus newStatus) async {
    final result = await NetworkHubRepository().updateConnectionStatus(
      connectionDepartmentTo: widget.departmentName,
      connectionIdTo: widget.userId,
      userNameTo: widget.fullName,
      status: newStatus.name,
    );

    if (result == NetworkConstants.successful) {
      UserConnectionStatus status =
          PublicProfileDashboardRepository.mapStatusToUserConnectionStatus(
              newStatus.name);
      Provider.of<PublicProfileDashboardRepository>(context, listen: false)
          .updateConnectionStatus(status);

      _showSnackBar(newStatus);
    } else {
      _showSnackBar(null);
    }
  }

  Future<void> blockUser() async {
    final result = await NetworkHubRepository().blockUser(
      connectionId: widget.userId,
      userNameTo: widget.fullName,
      userDepartmentTo: widget.departmentName,
    );

    if (result == NetworkConstants.successful) {
      Provider.of<PublicProfileDashboardRepository>(context, listen: false)
          .updateConnectionStatus(UserConnectionStatus.BlockedOutgoing);

      _showSnackBar(UserConnectionStatus.BlockedOutgoing);
      _generateInteractTelemetryData(
          userId: widget.userId, clickId: TelemetryClickId.profileBlock);
    } else {
      _showSnackBar(null);
    }
  }

  void _showSnackBar(UserConnectionStatus? status) {
    String message;
    Color bgColor = AppColors.darkBlue;

    switch (status) {
      case UserConnectionStatus.BlockedOutgoing:
        message = AppLocalizations.of(context)!.mConnectionBlocked;
        break;
      case UserConnectionStatus.Removed:
        message = AppLocalizations.of(context)!.mConnectionRemoved;
        break;
      case UserConnectionStatus.Withdrawn:
        message = AppLocalizations.of(context)!.mRequestWithdrawnSuccessfully;
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
