import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/services/_services/profile_service.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/button_widget_v2.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WithdrawRequestPopup extends StatelessWidget {
  final BuildContext parentContext;
  final String text;
  final List<dynamic> inReviewFields;
  final bool isWithdrawTransferRequest;
  final ValueChanged<bool>? successWithdrawCallback;
  const WithdrawRequestPopup(
      {Key? key,
      required this.parentContext,
      required this.text,
      required this.inReviewFields,
      this.isWithdrawTransferRequest = false,
      this.successWithdrawCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.only(left: 16, right: 16).r,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0).r),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12).r),
          padding: EdgeInsets.all(24).r,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.orangeTourText, width: 4.w),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0).r,
                  child: Center(
                      child: Text('!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              fontSize: 32.sp,
                              color: AppColors.orangeTourText,
                              fontWeight: FontWeight.bold))),
                ),
              ),
              SizedBox(height: 16.w),
              Text(
                  isWithdrawTransferRequest
                      ? AppLocalizations.of(parentContext)!
                          .mProfileWithdrawTransferPopupDetailsText
                      : AppLocalizations.of(parentContext)!
                          .mProfileWithdrawPopupDetailsText,
                  style: GoogleFonts.lato(color: AppColors.darkBlue)),
              SizedBox(height: 8.w),
              inReviewFields.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        inReviewFields
                                .where((element) => element.name != null)
                                .isNotEmpty
                            ? _requestedFieldItem(
                                context: context,
                                fieldName: AppLocalizations.of(parentContext)!
                                    .mProfileOrganisation,
                                fieldValue: inReviewFields
                                    .where((element) => element.name != null)
                                    .first
                                    .name)
                            : SizedBox(),
                        inReviewFields
                                .where((element) => element.group != null)
                                .isNotEmpty
                            ? _requestedFieldItem(
                                context: context,
                                fieldName: AppLocalizations.of(parentContext)!
                                    .mStaticGroup,
                                fieldValue: inReviewFields
                                    .where((element) => element.group != null)
                                    .first
                                    .group)
                            : SizedBox(),
                        inReviewFields
                                .where((element) => element.designation != null)
                                .isNotEmpty
                            ? _requestedFieldItem(
                                context: context,
                                fieldName: AppLocalizations.of(parentContext)!
                                    .mStaticDesignation,
                                fieldValue: inReviewFields
                                    .where((element) =>
                                        element.designation != null)
                                    .first
                                    .designation)
                            : SizedBox()
                      ],
                    )
                  : SizedBox(),
              SizedBox(height: 16.w),
              Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      fontSize: 16.sp, color: AppColors.darkBlue),
                ),
              ),
              SizedBox(height: 16.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonWidgetV2(
                    text: AppLocalizations.of(parentContext)!.mStaticNo,
                    textColor: AppColors.darkBlue,
                    borderColor: AppColors.darkBlue,
                    bgColor: Colors.transparent,
                    borderRadius: 57.r,
                    padding: EdgeInsets.fromLTRB(32, 8, 32, 8).r,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 10.w),
                  ButtonWidgetV2(
                    text: AppLocalizations.of(parentContext)!.mStaticYes,
                    textColor: AppColors.appBarBackground,
                    bgColor: AppColors.darkBlue,
                    borderRadius: 57.r,
                    padding: EdgeInsets.fromLTRB(32, 8, 32, 8).r,
                    onTap: () async => await _withDrawPrimaryDetails(context),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _requestedFieldItem(
      {required String fieldName,
      required String fieldValue,
      required BuildContext context}) {
    return Wrap(
      children: [
        Text('$fieldName: ',
            style: GoogleFonts.lato(color: AppColors.darkBlue)),
        Text(fieldValue,
            style: GoogleFonts.lato(
                color: AppColors.darkBlue, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _withDrawPrimaryDetails(BuildContext ctx) async {
    ProfileService profileService = ProfileService();
    try {
      for (var i = 0; i < inReviewFields.length; i++) {
        final field = inReviewFields[i];
        if (field.name == null || isWithdrawTransferRequest) {
          await profileService.withdrawProfileField(
            wfId: field.wfId ?? '',
          );
        }
      }
      Helper.showSnackBarMessage(
          context: parentContext,
          text:
              AppLocalizations.of(parentContext)!.mProfileWithdrawalRequestSent,
          bgColor: AppColors.positiveLight);
      Navigator.of(ctx).pop();
      // To get the In review fields which is SENT FOR APPROVAL
      await Provider.of<ProfileRepository>(parentContext, listen: false)
          .getInReviewFields(forceUpdate: true);
      if (successWithdrawCallback != null) {
        successWithdrawCallback!(true);
      }
    } catch (e) {
      Navigator.of(ctx).pop();
      Helper.showSnackBarMessage(
          context: parentContext,
          text:
              AppLocalizations.of(parentContext)!.mStaticSomethingWrongTryLater,
          bgColor: AppColors.negativeLight);
    }
  }
}
