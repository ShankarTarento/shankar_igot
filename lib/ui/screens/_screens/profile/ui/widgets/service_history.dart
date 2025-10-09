import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/edit_service_history.dart';

import '../../../../../../constants/index.dart';
import '../../../../../../util/index.dart';
import '../../../../../skeleton/index.dart';
import '../../../../../widgets/index.dart';
import '../../model/service_history_model.dart';
import '../../view_model/profile_service_history_view_model.dart';
import 'header_with_icon.dart';

class ServiceHistory extends StatefulWidget {
  final List<ServiceHistoryModel> serviceList;
  final bool showAll;
  final int count;
  final bool isMyProfile;
  final bool isDataUpdated;
  final String? userId;
  final VoidCallback updateCallback;
  final VoidCallback? modalUpdateCallback;

  const ServiceHistory({
    super.key,
    this.serviceList = const [],
    this.showAll = false,
    this.count = 0,
    this.isMyProfile = false,
    this.isDataUpdated = false,
    this.userId,
    required this.updateCallback,
    this.modalUpdateCallback,
  });

  @override
  State<ServiceHistory> createState() => _ServiceHistoryState();
}

class _ServiceHistoryState extends State<ServiceHistory> {
  Future<List<ServiceHistoryModel>>? _futureServiceList;
  List<ServiceHistoryModel> _serviceList = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(ServiceHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.showAll && oldWidget.serviceList != widget.serviceList) {
      _futureServiceList = Future.value(widget.serviceList);
    } else if (widget.showAll && widget.isDataUpdated) {
      _fetchData();
    }
  }

  void _initializeData() {
    if (widget.showAll) {
      _fetchData();
    } else {
      _futureServiceList = Future.value(widget.serviceList);
    }
  }

  Future<void> _fetchData() async {
    try {
      _serviceList = await ProfileServiceHistoryViewModel()
          .getExtendedServiceHistory(widget.userId);
      if (!_serviceList.any((item) =>
          widget.serviceList.first.orgName == item.orgName &&
          widget.serviceList.first.designation == item.designation)) {
        _serviceList.insert(0, widget.serviceList.first);
      }
      if (mounted) {
        setState(() {
          _futureServiceList = Future.value(_serviceList);
        });
      }
      if (widget.isDataUpdated && widget.modalUpdateCallback != null) {
        widget.modalUpdateCallback!();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _futureServiceList = Future.error(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.isMyProfile) ? _profileView() : _otherProfileView();
  }

  Widget _otherProfileView() {
    return (widget.serviceList.isNotEmpty) ? _profileView() : SizedBox.shrink();
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
          _buildServiceList(),
          if (_shouldShowViewAll) ...[
            _buildGradientDivider(),
            _buildShowAllButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return HeaderWithIcon(
      title: AppLocalizations.of(context)!.mProfileServiceHistory,
      showClose: widget.showAll,
      hideIcon: !widget.isMyProfile,
      onAddCallback: () => _handleHeaderAction(context),
    );
  }

  void _handleHeaderAction(BuildContext context) {
    if (widget.showAll) {
      Navigator.of(context).pop();
    } else {
      _showEditServiceModal(context);
    }
  }

  Widget _buildServiceList() {
    return FutureBuilder<List<ServiceHistoryModel>>(
      future: _futureServiceList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        _serviceList = snapshot.data ?? [];

        if (_serviceList.isEmpty) {
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
                  width: 100.w,
                  height: 80.w,
                  color: AppColors.appBarBackground));
        }

        return ListView.separated(
          itemCount: _serviceList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => SizedBox(height: 8.h),
          itemBuilder: (context, index) => _buildServiceItem(context, index),
        );
      },
    );
  }

  Widget _buildServiceItem(BuildContext context, int index) {
    final service = _serviceList[index];

    return Container(
      padding: EdgeInsets.all(8).r,
      decoration: BoxDecoration(
        color: AppColors.replyBackgroundColor,
        border: Border.all(color: AppColors.grey04),
        borderRadius: BorderRadius.circular(8).r,
      ),
      child: Row(
        children: [
          service.orgLogo.isEmpty
              ? _buildServiceIcon()
              : CachedNetworkImage(
                  width: 70.w,
                  height: 50.w,
                  fit: BoxFit.fill,
                  // color: AppColors.greys87,
                  imageUrl: Helper.convertToPortalUrl(service.orgLogo),
                  placeholder: (context, url) => ContainerSkeleton(
                        width: 70.w,
                        height: 50.w,
                      ),
                  errorWidget: (context, url, error) => Container(
                        width: 70.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: AppColors.darkBlue.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(4).r,
                        ),
                        child: Icon(
                          Icons.apartment,
                          size: 24.sp,
                          color: AppColors.darkBlue,
                        ),
                      )),
          SizedBox(width: 8.w),
          Expanded(child: _buildServiceDetails(context, service, index)),
        ],
      ),
    );
  }

  Widget _buildServiceIcon() {
    return Container(
      width: 70.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: AppColors.darkBlue.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(4).r,
      ),
      child: Icon(
        Icons.apartment,
        size: 24.sp,
        color: AppColors.darkBlue,
      ),
    );
  }

  Widget _buildServiceDetails(
      BuildContext context, ServiceHistoryModel service, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                service.designation,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.greys,
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.isMyProfile) _buildEditButton(context, service),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          ProfileServiceHistoryViewModel().buildOrgLocation(service),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.greys,
              ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        SizedBox(height: 8.h),
        Text(
          ProfileServiceHistoryViewModel().formatDuration(service, context),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.greys60,
              ),
        ),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, ServiceHistoryModel service) {
    return InkWell(
      onTap: () => _showEditServiceModal(context, service: service),
      borderRadius: BorderRadius.circular(20).r,
      child: Padding(
        padding: EdgeInsets.all(8).r,
        child: Icon(
          Icons.edit,
          size: 16.sp,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }

  Widget _buildGradientDivider() {
    return Padding(
      padding: EdgeInsets.only(top: 16.0, left: 80, right: 80).r,
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

  Widget _buildShowAllButton() {
    return InkWell(
      onTap: () => _showFullServiceHistoryModal(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16).r,
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.of(context)!.mCommonShowAll,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }

  bool get _shouldShowViewAll =>
      !widget.showAll && (widget.serviceList.length < widget.count);

  void _showEditServiceModal(BuildContext context,
      {ServiceHistoryModel? service}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appBarBackground,
      isScrollControlled: true,
      shape: _getModalShape(),
      builder: (context) => _buildEditServiceModal(context, service),
    ).then((_) => widget.updateCallback());
  }

  Widget _buildEditServiceModal(
      BuildContext context, ServiceHistoryModel? service) {
    return SafeArea(
      child: Container(
        height: 0.85.sh,
        padding: EdgeInsets.only(bottom: widget.showAll ? 0 : 40).r,
        child: EditServiceHistory(
          orgName: service?.orgName,
          designation: service?.designation,
          state: service?.orgState,
          district: service?.orgDistrict,
          isUpdate: service?.uuid.isNotEmpty ?? false,
          startDate: service?.startDate ?? '',
          endDate: service?.endDate ?? '',
          updateCallback: widget.updateCallback,
          uuid: service?.uuid,
          currentlyWorking: service?.currentlyWorking == 'true',
          description: service?.description,
          orgLogo: service?.orgLogo,
        ),
      ),
    );
  }

  void _showFullServiceHistoryModal() async {
    bool isDataUpdated = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.appBarBackground,
      isScrollControlled: true,
      shape: _getModalShape(),
      builder: (context) => _buildFullServiceHistoryModal(isDataUpdated),
    );

    // Refresh data after modal closes
    _refreshData();
  }

  Widget _buildFullServiceHistoryModal(bool isDataUpdated) {
    return StatefulBuilder(
      builder: (context, setModalState) => SafeArea(
        child: Container(
          height: 0.9.sh,
          padding: EdgeInsets.only(top: 32).r,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0).r,
                  color: AppColors.appBarBackground,
                  child: HeaderWithIcon(
                    title: AppLocalizations.of(context)!.mProfileServiceHistory,
                    showClose: true,
                    hideIcon: !widget.isMyProfile,
                    onAddCallback: () => Navigator.of(context).pop(),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: ServiceHistory(
                      updateCallback: () =>
                          setModalState(() => isDataUpdated = true),
                      modalUpdateCallback: () =>
                          setModalState(() => isDataUpdated = false),
                      showAll: true,
                      isMyProfile: widget.isMyProfile,
                      userId: widget.userId,
                      serviceList: widget.serviceList,
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
    );
  }

  RoundedRectangleBorder _getModalShape() {
    return RoundedRectangleBorder(
      side: BorderSide(color: AppColors.grey08),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ).r,
    );
  }

  void _refreshData() {
    if (mounted) {
      setState(() {
        _serviceList = widget.serviceList;
        _futureServiceList = Future.value(_serviceList);
      });
    }
  }
}
