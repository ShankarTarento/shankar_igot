import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../util/date_time_helper.dart';
import '../../../../../../util/index.dart';
import '../../../../../skeleton/index.dart';
import '../../../../../widgets/index.dart';
import '../../model/achievement_item_model.dart';
import '../../view_model/profile_achievement_view_model.dart';
import '../pages/edit_achievement.dart';
import 'header_with_icon.dart';
import 'view_more_text_widget.dart';

class Achievements extends StatefulWidget {
  final List<AchievementItem> achievementList;
  final bool showAll;
  final int count;
  final bool isMyProfile;
  final bool isDataUpdated;
  final String? userId;
  final VoidCallback updateCallback;
  final VoidCallback? modalUpdateCallback;

  const Achievements(
      {super.key,
      this.achievementList = const [],
      this.showAll = false,
      this.count = 0,
      this.isMyProfile = false,
      this.isDataUpdated = false,
      this.userId,
      required this.updateCallback,
      this.modalUpdateCallback});

  @override
  State<Achievements> createState() => _AchievementsState();
}

class _AchievementsState extends State<Achievements> {
  Future<List<AchievementItem>>? futureAchievementList;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(Achievements oldWidget) {
    super.didUpdateWidget(oldWidget);
    _handleDataUpdate(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return (widget.isMyProfile) ? _profileView() : _otherProfileView();
  }

  Widget _otherProfileView() {
    return (widget.achievementList.isNotEmpty)
        ? _profileView()
        : SizedBox.shrink();
  }

  Widget _profileView() {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 4, right: 16, bottom: 16).r,
      color: AppColors.appBarBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.showAll) _buildHeader(),
          _buildAchievementsList(),
          if (_shouldShowViewAll()) _buildShowAllSection(),
        ],
      ),
    );
  }

  void _initializeData() {
    futureAchievementList =
        widget.showAll ? null : Future.value(widget.achievementList);

    if (widget.showAll) {
      _fetchData();
    }
  }

  void _handleDataUpdate(Achievements oldWidget) {
    if (!widget.showAll &&
        oldWidget.achievementList != widget.achievementList) {
      futureAchievementList = Future.value(widget.achievementList);
      if (mounted) setState(() {});
    } else if (widget.showAll && widget.isDataUpdated) {
      _fetchData();
    }
  }

  Widget _buildHeader() {
    return HeaderWithIcon(
      title: AppLocalizations.of(context)!.mProfileAchievements,
      hideIcon: !widget.isMyProfile,
      onAddCallback: () => _showEditBottomSheet(),
    );
  }

  Widget _buildAchievementsList() {
    return FutureBuilder<List<AchievementItem>>(
      future: futureAchievementList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final achievementsList = snapshot.data ?? [];

        if (achievementsList.isEmpty) {
          return _buildEmptyState();
        }

        return _buildAchievementsListView(achievementsList);
      },
    );
  }

  Widget _buildEmptyState() {
    return CachedNetworkImage(
        width: 100.w,
        height: 80.w,
        fit: BoxFit.contain,
        imageUrl: ApiUrl.baseUrl + '/assets/mobile_app/assets/empty.gif',
        placeholder: (context, url) => ContainerSkeleton(
              width: 100.w,
              height: 80.w,
            ),
        errorWidget: (context, url, error) => Container(
            width: 100.w, height: 80.w, color: AppColors.appBarBackground));
  }

  Widget _buildAchievementsListView(List<AchievementItem> achievements) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0).r,
      child: ListView.builder(
        itemCount: achievements.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) =>
            _buildAchievementCard(achievements[index]),
      ),
    );
  }

  Widget _buildAchievementCard(AchievementItem achievement) {
    return Container(
      padding: EdgeInsets.all(8).r,
      margin: EdgeInsets.only(bottom: 8).r,
      decoration: BoxDecoration(
        color: AppColors.replyBackgroundColor,
        border: Border.all(color: AppColors.grey04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(achievement),
          SizedBox(height: 8.w),
          _buildIssuedDate(achievement),
          _buildDescription(achievement),
          _buildDocumentSection(achievement),
        ],
      ),
    );
  }

  Widget _buildCardHeader(AchievementItem achievement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 0.45.sw,
          child: Text(
            achievement.title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.greys,
                ),
          ),
        ),
        if (widget.isMyProfile) _buildEditButton(achievement),
      ],
    );
  }

  Widget _buildEditButton(AchievementItem achievement) {
    return Padding(
      padding: EdgeInsets.only(left: 24, bottom: 8).r,
      child: InkWell(
        onTap: () => _showEditBottomSheet(achievement: achievement),
        child: Icon(
          Icons.edit,
          size: 16.sp,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }

  Widget _buildIssuedDate(AchievementItem achievement) {
    if (achievement.issuedDate.isEmpty) return const SizedBox.shrink();

    return Text(
      DateTimeHelper.getDateTimeInFormat(
        achievement.issuedDate,
        desiredDateFormat: IntentType.achievementDateFormat,
      ),
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: AppColors.greys60,
          ),
    );
  }

  Widget _buildDescription(AchievementItem achievement) {
    return ViewMoreTextWidget(text: achievement.description, maxline: 2);
  }

  Widget _buildDocumentSection(AchievementItem achievement) {
    if (achievement.documentUrl.isNotEmpty) {
      return _buildExternalDocumentButton(achievement.documentUrl);
    }

    if (achievement.uploadedDocumentUrl.isNotEmpty) {
      return _buildUploadedDocumentView(achievement);
    }

    return const SizedBox.shrink();
  }

  Widget _buildExternalDocumentButton(String documentUrl) {
    return IntrinsicWidth(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0).r,
        child: ElevatedButton(
          onPressed: () => Helper.doLaunchUrl(
            url: documentUrl,
            mode: LaunchMode.externalApplication,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blackLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(63).r,
            ),
          ),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context)!.mProfileViewCertification,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.link,
                color: AppColors.darkBlue,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedDocumentView(AchievementItem achievement) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0).r,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey08),
        borderRadius: BorderRadius.all(Radius.circular(6).r),
        color: AppColors.appBarBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 16).r,
            child: Row(
              children: [
                _buildImageWidget(url: achievement.uploadedDocumentUrl),
                SizedBox(width: 8.w),
                SizedBox(
                  width: 0.5.sw,
                  child: Text(
                    achievement.uploadedFileName,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: AppColors.deepBlue,
                        ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showImageOverlay(achievement.uploadedDocumentUrl),
            padding: EdgeInsets.only(left: 24).r,
            icon: Icon(
              Icons.remove_red_eye,
              color: AppColors.darkBlue,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowAllSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 80, right: 80).r,
          child: GradientLine(
            colors: [
              AppColors.appBarBackground.withValues(alpha: 0),
              AppColors.orangeTourText,
              AppColors.orangeTourText,
              AppColors.appBarBackground.withValues(alpha: 0),
            ],
            opacity: 1,
          ),
        ),
        _buildShowAllButton(),
      ],
    );
  }

  Widget _buildShowAllButton() {
    return InkWell(
      onTap: _showFullAchievementsModal,
      child: Container(
        width: 1.0.sw,
        padding: EdgeInsets.symmetric(vertical: 16).r,
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.of(context)!.mCommonShowAll,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }

  Widget _buildImageWidget({
    required String url,
    double? height,
    double? width,
  }) {
    return CachedNetworkImage(
      fit: BoxFit.fill,
      height: height ?? 40.w,
      width: width ?? 50.w,
      imageUrl: Helper.convertPortalImageUrl(url),
      placeholder: (context, url) => ContainerSkeleton(
        height: height ?? 40.w,
        width: width ?? 50.w,
        radius: 4,
      ),
      errorWidget: (context, url, error) => Image.asset(
        'assets/img/image_placeholder.jpg',
        height: height ?? 40.w,
        width: width ?? 50.w,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  bool _shouldShowViewAll() {
    return !widget.showAll && widget.achievementList.length < widget.count;
  }

  void _showEditBottomSheet({AchievementItem? achievement}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.appBarBackground,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.grey08),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ).r),
      builder: (context) {
        return SafeArea(
          child: Container(
            height: 0.85.sh,
            padding: widget.showAll
                ? EdgeInsets.zero
                : const EdgeInsets.only(bottom: 40).r,
            child: AchievementEdit(
              title: achievement?.title,
              description: achievement?.description,
              issueDate: achievement?.issuedDate,
              issueOrg: achievement?.issuedOrganisation,
              showAll: widget.showAll,
              url: achievement?.documentUrl,
              documentUrl: achievement?.uploadedDocumentUrl,
              documentName: achievement?.uploadedFileName,
              uuid: achievement?.uuid,
              isUpdate: achievement != null,
              updateCallback: widget.updateCallback,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFullAchievementsModal() async {
    bool isDataUpdated = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appBarBackground,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.grey08),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ).r,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                height: 0.9.sh,
                padding: const EdgeInsets.only(top: 32).r,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
                        color: AppColors.appBarBackground,
                        child: HeaderWithIcon(
                          title: AppLocalizations.of(context)!
                              .mProfileAchievements,
                          showClose: true,
                          hideIcon: !widget.isMyProfile,
                          onAddCallback: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Achievements(
                              updateCallback: () {
                                setModalState(() {
                                  isDataUpdated = true;
                                });
                              },
                              modalUpdateCallback: () {
                                setModalState(() {
                                  isDataUpdated = false;
                                });
                              },
                              showAll: true,
                              isMyProfile: widget.isMyProfile,
                              userId: widget.userId,
                              achievementList: widget.achievementList,
                              count: widget.count,
                              isDataUpdated: isDataUpdated),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) => widget.updateCallback());
  }

  Future<void> _fetchData() async {
    final achievementList = await ProfileAchievementViewModel()
        .getExtendedAchievements(widget.userId);

    if (mounted) {
      setState(() {
        futureAchievementList = Future.value(achievementList);
      });
    }
    if (widget.isDataUpdated && widget.modalUpdateCallback != null) {
      widget.modalUpdateCallback!();
    }
  }

  void _showImageOverlay(String imageUrl) {
    showDialog(
      context: context,
      barrierColor: AppColors.greys.withValues(alpha: 0.6),
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Hero(
              tag: imageUrl,
              child: InteractiveViewer(
                child: _buildImageWidget(
                  url: imageUrl,
                  height: 0.25.sh,
                  width: 0.8.sw,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
