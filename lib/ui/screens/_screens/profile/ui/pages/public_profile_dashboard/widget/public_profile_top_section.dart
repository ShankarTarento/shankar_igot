import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/repository/public_profile_dashboard_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/widget/connection_status_button.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/public_profile_dashboard/widget/public_profile_user_menu.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/edit_profile_icon.dart';
import 'package:karmayogi_mobile/util/app_config.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/in_app_webview_page.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/view_model/profile_top_section_view_model.dart';
import 'package:provider/provider.dart';

class PublicProfileTopSection extends StatefulWidget {
  final String? userId;
  final String name;
  final String userName;
  final String state;
  final String district;
  final String? profileImageUrl;
  final String? designation;
  final String? department;
  final List<String> roles;
  final bool isMyProfile;
  final String? profileStatus;

  const PublicProfileTopSection({
    super.key,
    required this.userId,
    required this.name,
    required this.userName,
    required this.state,
    required this.district,
    this.profileImageUrl,
    this.designation,
    this.department,
    this.roles = const [],
    this.isMyProfile = true,
    this.profileStatus,
  });

  @override
  State<PublicProfileTopSection> createState() =>
      _PublicProfileTopSectionState();
}

class _PublicProfileTopSectionState extends State<PublicProfileTopSection> {
  late String name;
  late String state;
  late String district;
  late String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _updateFieldsFromWidget();
    Provider.of<PublicProfileDashboardRepository>(context, listen: false)
        .getUserRelationshipStatus(widget.userId ?? "");
  }

  @override
  void didUpdateWidget(covariant PublicProfileTopSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateFieldsFromWidget();
  }

  void _updateFieldsFromWidget() {
    name = widget.name;
    state = widget.state;
    district = widget.district;
    profileImageUrl = widget.profileImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appBarBackground,
      padding: EdgeInsets.only(top: 16, left: 16, right: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditProfileIcon(
              parentContext: context,
              profileImageUrl: profileImageUrl ?? '',
              firstName: name,
              isMyProfile: widget.isMyProfile),
          Row(
            children: [
              Expanded(flex: 8, child: _buildUserDetails(context)),
              const Spacer(),
              PublicProfileUserMenu(
                userId: widget.userId ?? "",
                departmentName: widget.department ?? "",
                fullName: widget.name,
              )
            ],
          ),
          SizedBox(height: 8.w),
          ConnectionStatusButton(
            userId: widget.userId ?? "",
            department: widget.department ?? "",
            name: name,
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails(BuildContext context) {
    final showMentorButton = AppConfiguration.mentorshipEnabled &&
        widget.roles.contains(Roles.mentor.toUpperCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameRow(context),
        SizedBox(height: 4.w),
        _buildText(
          context,
          ProfileTopSectionViewModel().formatDesignationAndDepartment(
            designation: widget.designation ?? '',
            department: widget.department ?? '',
          ),
        ),
        SizedBox(height: 4.w),
        if (state.isNotEmpty || district.isNotEmpty)
          _buildText(
            context,
            '$state${state.isNotEmpty && district.isNotEmpty ? ', ' : ''}$district',
          ),
        if (showMentorButton) _buildMentorButton(context),
      ],
    );
  }

  Widget _buildNameRow(BuildContext context) {
    return SizedBox(
      width: 0.67.sw,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              Helper.capitalizeFirstLetter(name).trim(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: AppColors.deepBlue),
            ),
          ),
          if (widget.profileStatus == UserProfileStatus.verified)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0).r,
              child: Icon(
                Icons.check_circle,
                size: 20.sp,
                color: AppColors.positiveLight,
              ),
            ),
          if (widget.userName.isNotEmpty)
            Expanded(
              child: Text(
                ' (${widget.userName})',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: AppColors.greys60),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildText(BuildContext context, String text) {
    return SizedBox(
      width: 0.65.sw,
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelMedium!
            .copyWith(color: AppColors.greys60),
      ),
    );
  }

  Widget _buildMentorButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          FadeRoute(
            page: InAppWebViewPage(
              parentContext: context,
              url: ApiUrl.mentorshipUrl,
            ),
          ),
        );
        _generateInteractTelemetryData();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkBlue,
        minimumSize: Size(0, 25.w),
      ),
      child: Text(
        AppLocalizations.of(context)!.mProfileViewMyMentorProfile,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }

  void _generateInteractTelemetryData() async {
    final telemetryRepository = TelemetryRepository();
    final eventData = telemetryRepository.getInteractTelemetryEvent(
      pageIdentifier: TelemetryPageIdentifier.userProfilePageId,
      contentId: widget.userId ?? '',
      subType: TelemetrySubType.click,
      env: TelemetryEnv.network,
      objectType: TelemetryObjectType.user,
    );
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
