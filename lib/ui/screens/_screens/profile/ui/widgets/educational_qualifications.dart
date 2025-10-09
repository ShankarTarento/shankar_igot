import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/edit_educational_details.dart';

import '../../../../../../constants/index.dart';
import '../../../../../skeleton/index.dart';
import '../../../../../widgets/index.dart';
import '../../model/education_qualification_item_model.dart';
import '../../view_model/profile_education_qualification_view_model.dart';
import 'header_with_icon.dart';

class EducationalQualifications extends StatefulWidget {
  const EducationalQualifications({
    super.key,
    this.educationList = const [],
    this.showAll = false,
    this.count = 0,
    this.isMyProfile = false,
    this.isDataUpdated = false,
    this.userId,
    required this.updateCallback,
    this.modalUpdateCallback,
  });

  final List<EducationalQualificationItem> educationList;
  final bool showAll;
  final int count;
  final bool isMyProfile;
  final bool isDataUpdated;
  final String? userId;
  final VoidCallback updateCallback;
  final VoidCallback? modalUpdateCallback;

  @override
  State<EducationalQualifications> createState() =>
      _EducationalQualificationsState();
}

class _EducationalQualificationsState extends State<EducationalQualifications> {
  Future<List<EducationalQualificationItem>>? futureEducationList;

  @override
  void initState() {
    super.initState();
    _initializeEducationList();
  }

  @override
  void didUpdateWidget(EducationalQualifications oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!widget.showAll && oldWidget.educationList != widget.educationList) {
      futureEducationList = Future.value(widget.educationList);
    } else if (widget.showAll && widget.isDataUpdated) {
      _fetchData();
    }
  }

  void _initializeEducationList() {
    if (widget.showAll) {
      _fetchData();
    } else {
      futureEducationList = Future.value(widget.educationList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.isMyProfile) ? _profileView() : _otherProfileView();
  }

  Widget _otherProfileView() {
    return (widget.educationList.isNotEmpty)
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
          if (!widget.showAll) _buildHeader(context),
          SizedBox(height: 16.w),
          _buildEducationList(),
          if (_shouldDisplayShowAll) ...[
            _buildGradientLine(),
            _buildShowAllButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return HeaderWithIcon(
      title: AppLocalizations.of(context)!.mProfileEducationQualification,
      showClose: widget.showAll,
      hideIcon: !widget.isMyProfile,
      onAddCallback: () => _handleAddEducation(context),
    );
  }

  void _handleAddEducation(BuildContext context) {
    if (widget.showAll) {
      Navigator.of(context).pop();
    } else {
      _showEditEducationBottomSheet(context);
    }
  }

  Widget _buildEducationList() {
    return Flexible(
      child: FutureBuilder<List<EducationalQualificationItem>>(
        future: futureEducationList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final qualificationList = snapshot.data ?? [];

          if (qualificationList.isEmpty) {
            return CachedNetworkImage(
                width: 100.w,
                height: 80.w,
                fit: BoxFit.contain,
                imageUrl:
                    ApiUrl.baseUrl + '/assets/mobile_app/assets/empty.gif',
                placeholder: (context, url) => ContainerSkeleton(
                      width: 100.w,
                      height: 80.w,
                    ),
                errorWidget: (context, url, error) => Container(
                    width: 100.w,
                    height: 80.w,
                    color: AppColors.appBarBackground));
          }

          return ListView.builder(
            itemCount: qualificationList.length,
            shrinkWrap: true,
            physics: widget.showAll
                ? const ClampingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final qualification = qualificationList[index];
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 0.45.sw,
                          child: Text(
                            qualification.degree,
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: AppColors.greys,
                                    ),
                          ),
                        ),
                        if (widget.isMyProfile)
                          InkWell(
                            onTap: () => _showEditEducationBottomSheet(
                              context,
                              qualification: qualification,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(left: 24, bottom: 8).r,
                              child: Icon(
                                Icons.edit,
                                size: 16.sp,
                                color: AppColors.darkBlue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '${qualification.fieldOfStudy}, ${qualification.institutionName}',
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: AppColors.greys,
                          ),
                    ),
                    SizedBox(height: 8.w),
                    Text(
                      '${qualification.startYear} - ${qualification.endYear}',
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: AppColors.greys60,
                          ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGradientLine() {
    return Padding(
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
    );
  }

  Widget _buildShowAllButton(BuildContext context) {
    return InkWell(
      onTap: () => _showAllEducationsModal(context),
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

  void _showEditEducationBottomSheet(
    BuildContext context, {
    EducationalQualificationItem? qualification,
  }) {
    showModalBottomSheet(
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
      builder: (context) => SafeArea(
        child: Container(
          height: 0.85.sh,
          padding: widget.showAll
              ? EdgeInsets.zero
              : const EdgeInsets.only(bottom: 40).r,
          child: qualification != null
              ? EditEducationalDetails(
                  degree: qualification.degree,
                  fieldOfStudy: qualification.fieldOfStudy,
                  instituteName: qualification.institutionName,
                  startYear: qualification.startYear,
                  endYear: qualification.endYear,
                  uuid: qualification.uuid,
                  updateCallback: widget.updateCallback,
                  isUpdate: true,
                )
              : EditEducationalDetails(updateCallback: widget.updateCallback),
        ),
      ),
    );
  }

  Future<void> _showAllEducationsModal(BuildContext context) async {
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
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Container(
            height: 0.9.sh,
            padding: const EdgeInsets.only(top: 32).r,
            child: Scaffold(
              backgroundColor: AppColors.appBarBackground,
              body: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0).r,
                    color: AppColors.appBarBackground,
                    child: HeaderWithIcon(
                        title: AppLocalizations.of(context)!
                            .mProfileEducationQualification,
                        showClose: true,
                        hideIcon: !widget.isMyProfile,
                        onAddCallback: () => Navigator.of(context).pop()),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: EducationalQualifications(
                        updateCallback: () =>
                            setModalState(() => isDataUpdated = true),
                        modalUpdateCallback: () =>
                            setModalState(() => isDataUpdated = false),
                        showAll: true,
                        isMyProfile: widget.isMyProfile,
                        userId: widget.userId,
                        educationList: widget.educationList,
                        count: widget.count,
                        isDataUpdated: isDataUpdated,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) => widget.updateCallback());
  }

  bool get _shouldDisplayShowAll =>
      !widget.showAll && widget.educationList.length < widget.count;

  Future<void> _fetchData() async {
    final educationList = await EducationQualificationViewModel()
        .getExtendedEducationHistory(widget.userId);

    if (mounted) {
      setState(() {
        futureEducationList = Future.value(educationList);
      });
    }

    if (widget.isDataUpdated && widget.modalUpdateCallback != null) {
      widget.modalUpdateCallback!();
    }
  }
}
