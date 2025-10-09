import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/respositories/index.dart';
import 'package:karmayogi_mobile/util/date_time_helper.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/_constants/color_constants.dart';
import '../../model/profile_model.dart';
import '../../../../../widgets/_common/button_widget_v2.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FieldApprovalStatus extends StatefulWidget {
  final bool isSurvey;
  final Profile? profileDetails;
  const FieldApprovalStatus(
      {Key? key, this.isSurvey = false, this.profileDetails})
      : super(key: key);

  @override
  State<FieldApprovalStatus> createState() => _FieldApprovalStatusState();
}

class _FieldApprovalStatusState extends State<FieldApprovalStatus> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileRepository>(builder: (BuildContext context,
        ProfileRepository profileRepository, Widget? child) {
      dynamic inReviewGroupFields =
          profileRepository.inReview.where((element) => element.group != null);
      dynamic inReviewDesignationFields = profileRepository.inReview
          .where((element) => element.designation != null);
      dynamic rejectedGroupFields = profileRepository.rejectedFields
          .where((element) => element.group != null);
      dynamic rejectedDesignationFields = profileRepository.rejectedFields
          .where((element) => element.designation != null);
      final _profileDetails =
          widget.profileDetails ?? profileRepository.profileDetails;
      String? groupFieldValue = inReviewGroupFields.isNotEmpty
          ? inReviewGroupFields.first.group
          : (rejectedGroupFields.isNotEmpty
              ? rejectedGroupFields.first.group
              : _profileDetails?.group);
      String? designationFieldValue = inReviewDesignationFields.isNotEmpty
          ? inReviewDesignationFields.first.designation
          : (rejectedDesignationFields.isNotEmpty
              ? rejectedDesignationFields.first.designation
              : _profileDetails?.designation);
      bool showRejectedGroup = true;
      bool showRejectedDesignation = true;
      if (_profileDetails?.profileStatusUpdatedOn != null) {
        DateTime profileStatusUpdatedOn =
            DateTimeHelper.getDateTimeFormatFromDateString(
                _profileDetails?.profileStatusUpdatedOn);
        if (rejectedGroupFields.isNotEmpty) {
          DateTime rejectedTime = DateTime.fromMillisecondsSinceEpoch(
              rejectedGroupFields.first.lastUpdatedOn);
          if (rejectedTime.isBefore(profileStatusUpdatedOn)) {
            // don't show rejected field
            showRejectedGroup = false;
          }
        }
        if (rejectedDesignationFields.isNotEmpty) {
          DateTime rejectedTime = DateTime.fromMillisecondsSinceEpoch(
              rejectedDesignationFields.first.lastUpdatedOn);
          if (rejectedTime.isBefore(profileStatusUpdatedOn)) {
            // don't show rejected field
            showRejectedDesignation = false;
          }
        }
      }
      return (inReviewDesignationFields.isNotEmpty ||
                  inReviewGroupFields.isNotEmpty) ||
              ((rejectedDesignationFields.isNotEmpty &&
                      showRejectedDesignation) ||
                  (rejectedGroupFields.isNotEmpty && showRejectedGroup))
          ? Container(
              margin: const EdgeInsets.only(top: 8).r,
              padding: EdgeInsets.all(16).r,
              decoration: BoxDecoration(
                  color: AppColors.grey04,
                  borderRadius: BorderRadius.circular(16).r),
              child: Column(
                children: [
                  Container(
                    padding: widget.isSurvey
                        ? EdgeInsets.all(6).r
                        : EdgeInsets.all(0),
                    decoration: widget.isSurvey
                        ? BoxDecoration(
                            border: Border.all(color: AppColors.grey08),
                            color: AppColors.appBarBackground,
                            borderRadius: BorderRadius.circular(3).r)
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.mProfileApprovalStatus,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        SizedBox(height: 12.w),
                        _getApprovalField(
                            fieldName:
                                AppLocalizations.of(context)!.mStaticGroup,
                            fieldValue: groupFieldValue ?? "",
                            isPending: inReviewGroupFields.isNotEmpty,
                            isRejected: rejectedGroupFields.isNotEmpty &&
                                showRejectedGroup,
                            reason: rejectedGroupFields.isNotEmpty
                                ? rejectedGroupFields.first.comment
                                : ''),
                        Visibility(
                            visible: (groupFieldValue != null &&
                                    groupFieldValue.isNotEmpty &&
                                    designationFieldValue != null &&
                                    designationFieldValue.isNotEmpty) &&
                                ((inReviewDesignationFields.isNotEmpty ||
                                        rejectedDesignationFields.isNotEmpty) &&
                                    (inReviewGroupFields.isNotEmpty ||
                                        rejectedGroupFields.isNotEmpty)),
                            child:
                                Divider(color: AppColors.grey16, height: 24)),
                        _getApprovalField(
                            fieldName: AppLocalizations.of(context)!
                                .mStaticDesignation,
                            fieldValue: designationFieldValue ?? "",
                            isPending: inReviewDesignationFields.isNotEmpty,
                            isRejected: rejectedDesignationFields.isNotEmpty &&
                                showRejectedDesignation,
                            reason: rejectedDesignationFields.isNotEmpty
                                ? rejectedDesignationFields.first.comment
                                : ''),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : SizedBox();
    });
  }

  Widget _getApprovalField(
      {required String fieldName,
      required String fieldValue,
      required String reason,
      bool isRejected = false,
      bool isPending = false}) {
    return isRejected || isPending
        ? Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fieldName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                        SizedBox(height: 4.w),
                        Text(fieldValue,
                            style: GoogleFonts.lato(
                                fontSize: 16.sp, fontWeight: FontWeight.w400))
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 0.5.sw,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 8).r,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4).r,
                              color: isPending
                                  ? AppColors.orangeTourText
                                  : isRejected
                                      ? AppColors.negativeLight
                                      : AppColors.positiveLight),
                          padding: EdgeInsets.all(6).r,
                          child: Text(
                            isPending
                                ? AppLocalizations.of(context)!.mProfilePending
                                : isRejected
                                    ? AppLocalizations.of(context)!
                                        .mProfileRejected
                                    : AppLocalizations.of(context)!
                                        .mProfileApproved,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        isPending
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 16, right: 16)
                                        .r,
                                child: Text('-'),
                              )
                            : InkWell(
                                onTap: () => _showReason(reason),
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .mProfileViewReason,
                                    style: GoogleFonts.lato(
                                        shadows: [
                                          Shadow(
                                              color: AppColors.darkBlue,
                                              offset: Offset(0, -3))
                                        ],
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.darkBlue,
                                        fontSize: 14.sp,
                                        color: Colors.transparent,
                                        fontWeight: FontWeight.w400)),
                              )
                      ],
                    ),
                  )
                ],
              ),
            ],
          )
        : SizedBox();
  }

  _showReason(String? reason) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return Dialog(
            insetPadding: EdgeInsets.only(left: 16, right: 16).r,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0).r),
            child: SingleChildScrollView(
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(12).r),
                padding: EdgeInsets.all(24).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.question_answer,
                      color: AppColors.orangeTourText,
                      size: 50.sp,
                    ),
                    SizedBox(height: 16.w),
                    Center(
                      child: Text(
                        reason != null && reason.isNotEmpty
                            ? reason
                            : AppLocalizations.of(context)!.mProfileNoComments,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(fontSize: 14.sp),
                      ),
                    ),
                    SizedBox(height: 16.w),
                    SizedBox(
                      width: 0.25.sw,
                      child: ButtonWidgetV2(
                        text: AppLocalizations.of(context)!.mStaticOk,
                        textColor: AppColors.appBarBackground,
                        bgColor: AppColors.darkBlue,
                        borderRadius: 4.r,
                        padding: EdgeInsets.fromLTRB(32, 8, 32, 8).r,
                        onTap: () => Navigator.of(ctx).pop(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
