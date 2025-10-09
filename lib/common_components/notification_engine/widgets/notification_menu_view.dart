import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/constants/notification_constants.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/helper/notification_helper.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_model.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_stats.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/repositories/notification_repository.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/screens/all_notification_screen/all_notification_screen.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/widgets/notification_card.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/widgets/notification_menu_view_skeleton.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';

class NotificationMenuView extends StatefulWidget {
  const NotificationMenuView({super.key});

  @override
  State<NotificationMenuView> createState() => _NotificationMenuViewState();
}

class _NotificationMenuViewState extends State<NotificationMenuView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final NotificationRepository _repository = NotificationRepository();

  final ValueNotifier<List<NotificationSubtypeStats>> _tabItems =
      ValueNotifier<List<NotificationSubtypeStats>>([]);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(true);
  Future<List<NotificationModel>>? _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotificationsData();
  }

  Future<void> _loadNotificationsData() async {
    _isLoadingNotifier.value = true;
    try {
      await _repository.getNotificationCount();
      final stats = await NotificationRepository.notificationsStats;

      if (stats.any((item) => item.id == NotificationConstants.all)) {
        final allItem =
            stats.firstWhere((item) => item.id == NotificationConstants.all);
        _tabItems.value.add(allItem);
        _notificationsFuture = _repository.getNotifications(page: 0, size: 5);
      }
      if (stats.any((item) => item.id == NotificationConstants.alert)) {
        final alertItem =
            stats.firstWhere((item) => item.id == NotificationConstants.alert);
        _tabItems.value.add(alertItem);
      }

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeTabController();
        });
      }
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  void _handleTabChange() {
    if (_tabController!.indexIsChanging) {
      try {
        _notificationsFuture = _repository.getNotifications(
            page: 0,
            size: 5,
            subtype: _tabItems.value[_tabController!.index].id ==
                    NotificationConstants.all
                ? null
                : _tabItems.value[_tabController!.index].id);
        setState(() {});
      } catch (e) {
        debugPrint("Error refreshing notifications: $e");
      }
    }
  }

  void _initializeTabController() {
    if (!mounted) return;

    _tabController = TabController(length: _tabItems.value.length, vsync: this);
    _tabController!.addListener(_handleTabChange);

    setState(() {});
  }

  @override
  void dispose() {
    _tabController?.dispose();

    _isLoadingNotifier.dispose();
    super.dispose();
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.mNotifications,
      style: TextStyle(
          fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.greys),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      width: 1.sw,
      padding: EdgeInsets.only(top: 4.h, left: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.w, color: AppColors.grey08),
        ),
      ),
      child: TabBar(
        controller: _tabController!,
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.darkBlue,
              width: 2.0.w,
            ),
          ),
        ),
        indicatorColor: AppColors.appBarBackground,
        unselectedLabelColor: AppColors.greys60,
        labelColor: AppColors.greys87,
        labelStyle: GoogleFonts.lato(
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.lato(
          fontSize: 14.0.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.greys60,
        ),
        tabs: _tabItems.value.map((item) => Tab(text: item.name)).toList(),
      ),
    );
  }

  Widget _buildNotificationList(
      {required List<NotificationModel> notifications}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0).r,
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (_, index) {
          return InkWell(
              onTap: () {
                if (!notifications[index].read) {
                  _markNotificationAsRead(
                      notificationId: notifications[index].notificationId);
                }
                _generateInteractTelemetryData(
                    clickId: notifications[index].notificationId);
                NotificationHelper.handleNotificationNavigation(
                    context: context, notification: notifications[index]);
              },
              child: NotificationCard(notificationModel: notifications[index]));
        },
      ),
    );
  }

  Widget _buildShowAllButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          FadeRoute(page: AllNotificationScreen()),
        );
      },
      child: Container(
        height: 40.w,
        width: double.infinity,
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.mNetworkShowAll,
            style: GoogleFonts.lato(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null || _tabItems.value.isEmpty) {
      return NotificationMenuViewSkeleton();
    }

    return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 12.h),
            _buildTabBar(context),
            FutureBuilder<List<NotificationModel>>(
                future: _notificationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0).r,
                      child: ListView.builder(
                          itemCount: 4,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0).r,
                              child: ContainerSkeleton(
                                height: 91.w,
                                width: double.infinity,
                              ),
                            );
                          }),
                    );
                  }
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return Column(
                      children: [
                        SizedBox(
                            height: 0.42.sh,
                            child: _buildNotificationList(
                                notifications: snapshot.data!)),
                        _buildShowAllButton(context),
                      ],
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(top: 0.20.sh),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.mNoNotificationsFound,
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          color: AppColors.greys87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
          ],
        ));
  }

  void _markNotificationAsRead({required String notificationId}) async {
    try {
      await _repository.markNotificationAsRead(
        type: NotificationConstants.individual,
        notificationIds: [notificationId],
      );

      if (mounted) {
        setState(() {
          _notificationsFuture = _notificationsFuture?.then((notifications) {
            return notifications.map((notification) {
              if (notification.notificationId == notificationId) {
                return notification.copyWith(read: true);
              }
              return notification;
            }).toList();
          });
        });
      }
    } catch (error) {
      debugPrint("Error marking notification as read: $error");
    }
  }

  void _generateInteractTelemetryData({required String clickId}) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
        contentId: clickId,
        pageIdentifier: TelemetryPageIdentifier.homePageId,
        subType: TelemetrySubType.notificationEngine,
        clickId: clickId,
        env: TelemetryEnv.home);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
