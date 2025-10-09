import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/common_components/image_widget/image_widget.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/recommended_user.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/network/network_profile.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class NetworkCard extends StatefulWidget {
  final RecommendedUser user;
  final double? height;
  final double? width;
  final double? contentHeight;
  final double? radius;
  final String? telemetrySubType;

  const NetworkCard({
    super.key,
    required this.user,
    this.height,
    this.width,
    this.radius,
    this.contentHeight,
    this.telemetrySubType,
  });

  @override
  State<NetworkCard> createState() => _NetworkCardState();
}

class _NetworkCardState extends State<NetworkCard> {
  UserConnectionStatus _connectionStatus = UserConnectionStatus.Connect;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double cardHeight = widget.height ?? 190.w;
    final double cardWidth = widget.width ?? 175.w;
    final double avatarSize = widget.radius ?? 74.w;

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            FadeRoute(
                page: NetworkProfile(
              profileId: widget.user.id,
              connectionStatus: UserConnectionStatus.Approved,
            )));
        _generateInteractTelemetryData(
          clickId: TelemetryClickId.profileCard,
          userId: widget.user.id,
          pageId: TelemetryPageIdentifier.network + "${widget.user.id}",
        );
      },
      child: SizedBox(
        height: cardHeight,
        width: cardWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 36.w,
              child: _buildCardContent(context, cardWidth),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(child: _buildProfileAvatar(avatarSize)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, double cardWidth) {
    return Container(
      height: widget.contentHeight ?? 155.w,
      width: cardWidth,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: AppColors.grey24, width: 1.w),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(height: 35.w),
          Text(
            widget.user.personalDetails?.firstname ?? "",
            style: TextStyle(
              fontSize: 14.w,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          _buildMentorBadge(),
          if (widget.user.professionalDetails != null &&
              widget.user.professionalDetails!.isNotEmpty &&
              widget.user.professionalDetails!.first.designation != null)
            Text(
              widget.user.professionalDetails!.first.designation!,
              style: TextStyle(
                fontSize: 12.w,
                color: AppColors.greys60,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          SizedBox(height: 4.w),
          _buildConnectionButton(),
          SizedBox(height: 6.w),
        ],
      ),
    );
  }

  Widget _buildMentorBadge() {
    return widget.user.verifiedKarmayogi != null || widget.user.role != null
        ? Column(
            children: [
              SizedBox(height: 3.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.user.verifiedKarmayogi != null &&
                          widget.user.verifiedKarmayogi!
                      ? CircleAvatar(
                          radius: 8.w,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.check,
                            size: 12.w,
                            color: Colors.white,
                          ),
                        )
                      : SizedBox(),
                  SizedBox(width: 3.w),
                  widget.user.role != null &&
                          widget.user.role!.contains("MENTOR")
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.darkBlue,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.mProfileMentor,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
              SizedBox(height: 3.w),
            ],
          )
        : SizedBox.shrink();
  }

  Widget _buildConnectionButton() {
    switch (_connectionStatus) {
      case UserConnectionStatus.Pending:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.appBarBackground,
            border: Border.all(color: AppColors.grey40, width: 1.w),
            borderRadius: BorderRadius.circular(40.w),
          ),
          child: Text(
            Helper.capitalizeEachWordFirstCharacter(
              AppLocalizations.of(context)!.mStaticConnectionRequestSent,
            ),
            style: GoogleFonts.lato(fontSize: 12.sp, color: AppColors.grey40),
          ),
        );

      case UserConnectionStatus.Connect:
      default:
        return SizedBox(
          height: 35.w,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createConnectionRequest,
            style: ElevatedButton.styleFrom(
              maximumSize: Size(120.w, 40.w),
              backgroundColor: AppColors.darkBlue.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.w),
                side: BorderSide(color: AppColors.darkBlue, width: 1.w),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 16.w,
                    width: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.darkBlue),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        color: AppColors.darkBlue,
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        AppLocalizations.of(context)!.mHomeConnect,
                        style: TextStyle(
                          fontSize: 14.w,
                          color: AppColors.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        );
    }
  }

  Widget _buildProfileAvatar(double avatarSize) {
    final bool hasImage = widget.user.profileImageUrl?.isNotEmpty ?? false;

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: ImageWidget(
          imageUrl: widget.user.profileImageUrl!,
          height: avatarSize,
          width: avatarSize,
          radius: 50.r,
        ),
      );
    }

    final bgColor =
        AppColors.networkBg[Random().nextInt(AppColors.networkBg.length)];

    return Container(
      height: avatarSize,
      width: avatarSize,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        Helper.getInitialsNew(widget.user.personalDetails?.firstname ?? ""),
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _createConnectionRequest() async {
    setState(() {
      _isLoading = true;
    });

    final String status = await NetworkHubRepository().createConnectionRequest(
      connectionId: widget.user.userId,
      userNameTo: widget.user.personalDetails?.firstname ?? "",
      userDepartmentTo: widget.user.employmentDetails?.departmentName ?? "",
    );

    if (status == "Successful") {
      setState(() {
        _connectionStatus = UserConnectionStatus.Pending;
      });

      Helper.showSnackBarMessage(
        context: context,
        text: AppLocalizations.of(context)!.mConnectionRequestSentSuccessfully,
        bgColor: AppColors.darkBlue,
      );

      _generateInteractTelemetryData(
        userId: widget.user.userId,
        clickId: TelemetryClickId.profileCOnnect,
        subtype: widget.telemetrySubType ??
            TelemetrySubType.networkHubPeopleYouMayKnow,
      );
    } else {
      Helper.showSnackBarMessage(
        context: context,
        text: AppLocalizations.of(context)!.mStaticSomethingWrongTryLater,
        bgColor: AppColors.redBgShade,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _generateInteractTelemetryData(
      {required String userId,
      required String clickId,
      String? pageId,
      String? subtype}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        pageIdentifier: pageId ?? TelemetryPageIdentifier.networkHomePageId,
        contentId: userId,
        clickId: clickId,
        subType: subtype,
        env: TelemetryEnv.network);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
