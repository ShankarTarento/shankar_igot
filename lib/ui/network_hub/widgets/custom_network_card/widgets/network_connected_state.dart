import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/user_connection_request.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/confirmation_popup.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NetworkConnectedState extends StatefulWidget {
  final UserConnectionStatus userConnectionStatus;
  final NetworkUser user;

  const NetworkConnectedState({
    super.key,
    required this.userConnectionStatus,
    required this.user,
  });

  @override
  State<NetworkConnectedState> createState() => _NetworkConnectedStateState();
}

class _NetworkConnectedStateState extends State<NetworkConnectedState> {
  final _repository = NetworkHubRepository();
  late UserConnectionStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.userConnectionStatus;
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      UserConnectionStatus.Approved => _buildPopupMenuButton(),
      UserConnectionStatus.Removed =>
        _buildStatusText(AppLocalizations.of(context)!.mRemoved),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildPopupMenuButton() {
    return PopupMenuButton<UserConnectionStatus>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.darkBlue),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      useRootNavigator: true,
      onSelected: (value) {
        switch (value) {
          case UserConnectionStatus.CopyProfileLink:
            Helper.showSnackBarMessage(
                context: context,
                text: AppLocalizations.of(context)!.mContentSharePageLinkCopied,
                bgColor: AppColors.darkBlue);
            copyProfileLink();
            break;
          case UserConnectionStatus.Removed:
            _showWithdrawConfirmationDialog(
              newStatus: UserConnectionStatus.Removed,
              message: AppLocalizations.of(context)!
                  .mRemoveConnectionConfirmationMessage,
            );

            break;

          default:
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: UserConnectionStatus.CopyProfileLink,
          child: _buildMenuItem(AppLocalizations.of(context)!.mCopyProfileLink),
        ),
        PopupMenuItem(
          value: UserConnectionStatus.Removed,
          child:
              _buildMenuItem(AppLocalizations.of(context)!.mRemoveConnection),
        ),
      ],
    );
  }

  Widget _buildStatusText(String text) => Text(
        text,
        style: GoogleFonts.lato(
          color: AppColors.greys60,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _buildMenuItem(String text) => Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.grey84,
        ),
        textAlign: TextAlign.center,
      );
  void _showWithdrawConfirmationDialog({
    required UserConnectionStatus newStatus,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        parentContext: context,
        message: message,
        onConfirm: () async {
          Navigator.of(dialogContext).pop();

          await _updateStatus(newStatus);
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  Future<void> _updateStatus(UserConnectionStatus newStatus) async {
    final result = await _repository.updateConnectionStatus(
      connectionDepartmentTo: widget.user.departmentName,
      connectionIdTo: widget.user.userId,
      userNameTo: widget.user.fullName,
      status: newStatus.name,
    );

    if (result == NetworkConstants.successful) {
      setState(() => _status = newStatus);
      _showSnackBar(success: true, status: newStatus);
    } else {
      _showSnackBar(success: false);
    }
  }

  void _showSnackBar({required bool success, UserConnectionStatus? status}) {
    final localizations = AppLocalizations.of(context)!;
    final text = success && status == UserConnectionStatus.Removed
        ? localizations.mConnectionRemoved
        : localizations.mStaticSomethingWrongTryLater;
    final color = success ? AppColors.darkBlue : AppColors.redBgShade;

    Helper.showSnackBarMessage(
      context: context,
      text: text,
      bgColor: color,
    );
  }

  Future<void> copyProfileLink() async {
    await Clipboard.setData(ClipboardData(
        text: '${ApiUrl.baseUrl}/app/person-profile/${widget.user.userId}'));
  }
}
