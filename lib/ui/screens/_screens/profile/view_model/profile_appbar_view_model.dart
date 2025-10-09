import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/index.dart';
import '../../../../../respositories/index.dart';
import '../../../../../util/index.dart';
import '../../../../../util/logout.dart';
import '../ui/widgets/profile_transfer_request_popup.dart';
import '../ui/widgets/withdraw_request_popup.dart';
import '../model/profile_field_status_model.dart';

class ProfileAppbarViewModel {
  static final ProfileAppbarViewModel _instance =
      ProfileAppbarViewModel._internal();
  factory ProfileAppbarViewModel() {
    return _instance;
  }
  ProfileAppbarViewModel._internal();

  Future<void> doTransferRequest(
      {required BuildContext context,
      bool isDesignationMasterEnabled = false}) async {
    showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext ctx) {
              return ProfileTransferRequestPopup(
                  parentContext: context,
                  isDesignationMasterEnabled: isDesignationMasterEnabled);
            })
        .then((value) async =>
            await Provider.of<ProfileRepository>(context, listen: false)
                .getInReviewFields(forceUpdate: true));
  }

  Future<void> doWithdrawRequest(
      {required BuildContext context,
      bool isDesignationMasterEnabled = false,
      bool isWithdrawTransferRequest = false,
      required List<ProfileFieldStatusModel> fieldStatusList}) async {
    isWithdrawTransferRequest
        ? showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext ctx) {
                  return WithdrawRequestPopup(
                    text: AppLocalizations.of(context)!
                        .mProfileWithdrawTransferRequestConfirm,
                    isWithdrawTransferRequest: true,
                    inReviewFields: fieldStatusList,
                    parentContext: context,
                  );
                })
            .then((value) async =>
                await Provider.of<ProfileRepository>(context, listen: false)
                    .getInReviewFields(forceUpdate: true))
        : Helper.showSnackBarMessage(
            context: context,
            text: AppLocalizations.of(context)!
                .mProfileMessageBeforeTransferRequest,
            bgColor: AppColors.greys87);
  }

  Future<void> doSignOut(BuildContext contextMain) {
    return showModalBottomSheet(
        isScrollControlled: true,
        // useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8).r),
          side: BorderSide(
            color: AppColors.grey08,
          ),
        ),
        context: contextMain,
        builder: (context) => Logout(
              contextMain: contextMain,
            ));
  }
}
