import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:igot_ui_components/ui/widgets/container_skeleton/container_skeleton.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/constants/notification_constants.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_model.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/models/notification_stats.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/repositories/notification_repository.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/screens/all_notification_screen/widgets/notification_list.dart';
import 'package:karmayogi_mobile/common_components/notification_engine/screens/all_notification_screen/widgets/notification_tab.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/index.dart';

class AllNotificationScreen extends StatefulWidget {
  const AllNotificationScreen({super.key});

  @override
  State<AllNotificationScreen> createState() => _AllNotificationScreenState();
}

class _AllNotificationScreenState extends State<AllNotificationScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final NotificationRepository _repository = NotificationRepository();
  List<NotificationSubtypeStats> _tabItems =
      NotificationRepository.notificationsStats;
  List<NotificationModel> _notifications = [];
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  String? _currentSubtype;
  int notificationCount = 15;
  final ValueNotifier<bool> showMarkAllAsRead = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    checkShowMarkAllAsRead();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _tabController = TabController(length: _tabItems.length, vsync: this);
        _tabController?.addListener(_handleTabChange);
      });
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    super.dispose();
  }

  void checkShowMarkAllAsRead() {
    _tabItems;
    showMarkAllAsRead.value = _tabItems.any((item) => item.unread > 0);
    debugPrint("Show Mark All As Read: ${showMarkAllAsRead.value}");
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMoreNotifications();
    }
  }

  void _handleTabChange() {
    if (_tabController!.indexIsChanging) {
      try {
        _refreshNotifications(subtype: _tabItems[_tabController!.index].id);
      } catch (e) {
        debugPrint("Error refreshing notifications: $e");
      }
    }
  }

  void _refreshNotifications({String? subtype}) {
    setState(() {
      _currentPage = 0;
      _notifications.clear();
      _hasMore = true;
      _currentSubtype = subtype;
    });
    _loadNotifications(subtype: subtype);
  }

  void _loadMoreNotifications() {
    _loadNotifications(subtype: _currentSubtype);
  }

  void _loadNotifications({String? subtype}) {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    _repository
        .getNotifications(
            page: _currentPage,
            size: notificationCount,
            subtype:
                _tabItems[_tabController!.index].id == NotificationConstants.all
                    ? null
                    : _tabItems[_tabController!.index].id)
        .then((newNotifications) {
      if (mounted) {
        setState(() {
          _notifications.addAll(newNotifications);
          _isLoadingMore = false;
          _hasMore = newNotifications.length == notificationCount;
          if (_hasMore) _currentPage++;
        });
      }
    }).catchError((error) {
      debugPrint("Error loading notifications: $error");
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  void _markNotificationAsRead({required String notificationId}) {
    _repository.markNotificationAsRead(
      type: NotificationConstants.individual,
      notificationIds: [notificationId],
    ).then((_) {
      if (mounted) {
        setState(() {
          final index = _notifications.indexWhere(
              (notification) => notification.notificationId == notificationId);

          if (index != -1) {
            _notifications[index] = _notifications[index].copyWith(read: true);
          }
        });
      }
    }).catchError((error) {
      debugPrint("Error marking notification as read: $error");
    });
  }

  void _markAllNotificationsAsRead() {
    _repository
        .markNotificationAsRead(
      type: "all",
    )
        .then((_) {
      if (mounted) {
        setState(() {
          _notifications = _notifications
              .map((notification) => notification.copyWith(read: true))
              .toList();
          showMarkAllAsRead.value = false;
        });
      }
      Helper.showSnackBarMessage(
          bgColor: AppColors.darkBlue,
          context: context,
          text: AppLocalizations.of(context)!.mMarkedAllAsRead);
    }).catchError((error) {
      debugPrint("Error marking all notifications as read: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_tabController == null || _tabItems.isEmpty) {
      return Scaffold(
          appBar: _buildAppBar(l10n),
          body: Center(
              child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.builder(
                itemCount: 7,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0).r,
                    child: ContainerSkeleton(
                      height: 65.w,
                      width: double.infinity,
                    ),
                  );
                }),
          )));
    }

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: _buildAppBar(l10n),
      body: Column(
        children: [
          if (_tabController != null)
            NotificationTab(
              tabController: _tabController!,
              tabItems: _tabItems,
            ),
          SizedBox(height: 16.h),
          Expanded(
            child: NotificationList(
              hasMore: _hasMore,
              isLoadingMore: _isLoadingMore,
              markNotificationAsRead: (id) {
                _markNotificationAsRead(notificationId: id);
              },
              notifications: _notifications,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      elevation: 0,
      title: Text(
        l10n.mNotifications,
        style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.w700),
      ),
      centerTitle: false,
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: showMarkAllAsRead,
          builder: (context, value, child) {
            return value
                ? Center(
                    child: TextButton(
                      onPressed: () {
                        _markAllNotificationsAsRead();
                      },
                      child: Text(
                        l10n.mMarkAllAsRead,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
        SizedBox(width: 16.w)
      ],
    );
  }
}
