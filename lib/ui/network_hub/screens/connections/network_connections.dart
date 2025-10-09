import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/constants/network_constants.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/network_tab_model.dart';
import 'package:karmayogi_mobile/ui/network_hub/models/user_connection_request.dart';
import 'package:karmayogi_mobile/ui/network_hub/network_hub_repository/network_hub_repository.dart';
import 'package:karmayogi_mobile/ui/network_hub/screens/connections/widgets/network_recommendation_tab.dart';
import 'package:karmayogi_mobile/ui/network_hub/screens/connections/widgets/stickyTabbardelegate.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/custom_network_card/custom_network_card.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/custom_network_card/widgets/custom_network_card_skeleton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/ui/network_hub/widgets/empty_state.dart';

class NetworkConnections extends StatefulWidget {
  final int? tabIndex;
  final Function(int index)? onTabChanged;

  const NetworkConnections({super.key, this.tabIndex, this.onTabChanged});

  @override
  State<NetworkConnections> createState() => _NetworkConnectionsState();
}

class _NetworkConnectionsState extends State<NetworkConnections>
    with SingleTickerProviderStateMixin {
  final _networkHubRepository = NetworkHubRepository();

  final ValueNotifier<bool> _isTabLoading = ValueNotifier(true);
  final ValueNotifier<bool> _tabsInitialized = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingMore = ValueNotifier(false);

  final ScrollController _scrollController = ScrollController();

  TabController? _tabController;
  List<NetworkTabModel> _tabItems = [];
  List<NetworkUser> _users = [];
  int _selectedIndex = -1;

  bool _hasMore = true;
  int _offset = 0;
  final int _pageSize = 30;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeTabs();
  }

  Future<void> _initializeTabs() async {
    final counts = await _networkHubRepository.getConnectionsCount();
    _tabItems = getConnectionTabsV2(context: context, values: counts);

    _tabController = TabController(
      length: _tabItems.length,
      vsync: this,
      initialIndex: widget.tabIndex ?? 0,
    )..addListener(_onTabChanged);

    _selectedIndex = _tabController!.index;
    _tabsInitialized.value = true;

    await _fetchInitialUsers();
    _isTabLoading.value = false;

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore.value &&
          _hasMore) {
        _loadMoreUsers();
      }
    });
  }

  void _onTabChanged() async {
    if (_tabController!.index == _selectedIndex) return;

    _isTabLoading.value = true;
    _selectedIndex = _tabController!.index;

    if (widget.onTabChanged != null) {
      widget.onTabChanged!(_selectedIndex);
    }

    final counts = await _networkHubRepository.getConnectionsCount();
    _tabItems = getConnectionTabsV2(context: context, values: counts);

    await _fetchInitialUsers();

    _isTabLoading.value = false;
  }

  Future<void> _fetchInitialUsers() async {
    _offset = 0;
    _hasMore = true;
    _users = [];

    await _loadMoreUsers(initial: true);
  }

  Future<void> _loadMoreUsers({bool initial = false}) async {
    _isLoadingMore.value = true;

    final status = _tabItems[_tabController?.index ?? 0].id;
    final newUsers =
        await _getUsersByStatus(status, offset: _offset, size: _pageSize);

    if (mounted) {
      setState(() {
        _users.addAll(newUsers);
        _offset += _pageSize;
        _hasMore = newUsers.length == _pageSize;
      });
    }

    _isLoadingMore.value = false;
  }

  Future<List<NetworkUser>> _getUsersByStatus(UserConnectionStatus status,
      {required int offset, required int size}) {
    switch (status) {
      case UserConnectionStatus.Pending:
        return _networkHubRepository.getRequestedConnections(
            offset: offset, size: size);
      case UserConnectionStatus.Approved:
        return _networkHubRepository.getMyConnections(
            offset: offset, size: size);
      case UserConnectionStatus.Received:
        return _networkHubRepository.getConnectionRequests(
            offset: offset, size: size);
      case UserConnectionStatus.BlockedOutgoing:
        return _networkHubRepository.getBlockedUsers(
            offset: offset, size: size);
      default:
        return Future.value([]);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _isTabLoading.dispose();
    _tabsInitialized.dispose();
    _scrollController.dispose();
    _isLoadingMore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _tabsInitialized,
      builder: (context, initialized, _) {
        if (!initialized) {
          return _buildSkeletonLoader();
        }

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildTabHeader(),
            _buildContent(),
          ],
        );
      },
    );
  }

  Widget _buildTabHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyTabBarDelegate(
        child: Container(
          color: AppColors.whiteGradientOne,
          child: NetworkRecommendationTab(
            tabItems: _tabItems,
            tabController: _tabController!,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(12).r,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isTabLoading,
          builder: (context, isLoading, _) {
            if (isLoading) return _buildSkeletonLoader();

            if (_users.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                ..._buildUserList(_users),
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoadingMore,
                  builder: (_, loading, __) {
                    if (loading) return _buildSkeletonLoader();
                    return const SizedBox.shrink();
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildUserList(List<NetworkUser> users) {
    final status = _tabItems[_tabController?.index ?? 0].id;

    return List.generate(users.length * 2 - 1, (index) {
      if (index.isEven) {
        final user = users[index ~/ 2];
        return CustomNetworkCard(cardState: status, user: user);
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12).r,
          child: Divider(height: 10.h, color: AppColors.grey24),
        );
      }
    });
  }

  Widget _buildEmptyState() {
    final status = _tabItems[_tabController?.index ?? 0].id;
    final localization = AppLocalizations.of(context)!;

    String message = localization.mMsgNoConnectionFound;

    switch (status) {
      case UserConnectionStatus.Received:
        message = localization.mStaticNoConnectionRequestsText;
      case UserConnectionStatus.Pending:
        message = localization.mNoRequestSent;

      case UserConnectionStatus.Approved:
        message = localization.mEmptyConnectionsStateMessage;
      default:
        message = localization.mMsgNoConnectionFound;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50).r,
      child: Center(child: EmptyConnectionState(message: message)),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (_, __) => const CustomNetworkCardSkeleton(),
      separatorBuilder: (_, __) =>
          Divider(height: 16.h, color: AppColors.grey24),
    );
  }
}
