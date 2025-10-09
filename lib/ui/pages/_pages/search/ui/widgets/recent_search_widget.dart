import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../constants/index.dart';
import '../../../../../../util/index.dart';
import '../../models/recent_search_model.dart';
import '../../repository/search_repository.dart';

class RecentSearchWidget extends StatefulWidget {
  final Function(String) updateSearchText;
  const RecentSearchWidget({super.key, required this.updateSearchText});

  @override
  State<RecentSearchWidget> createState() => _RecentSearchWidgetState();
}

class _RecentSearchWidgetState extends State<RecentSearchWidget> {
  List<RecentSearchModel> _allRecentSearches = [];
  int _visibleCount = 5;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentSearches();
  }

  Future<void> _fetchRecentSearches() async {
    final results = await SearchRepository().getRecentSearch();
    setState(() {
      _allRecentSearches = results;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    await SearchRepository().deleteRecentSearch();
    setState(() {
      _allRecentSearches.clear();
    });
  }

  Future<void> _deleteItem(RecentSearchModel item) async {
    if (item.timestamp != null) {
      await SearchRepository().deleteRecentSearchWithTimeStamp(item.timestamp!);
      await _fetchRecentSearches();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _allRecentSearches.isEmpty) return const SizedBox.shrink();

    final visibleItems = _allRecentSearches.take(_visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.mSearchRecentSearches,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColors.grey36_65)),
              GestureDetector(
                  onTap: _clearAll,
                  child: Text(AppLocalizations.of(context)!.mStaticClearAll,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.darkBlue))),
            ],
          ),
        ),
        ...visibleItems.map((item) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8).r,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0, right: 8).r,
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.blue54, AppColors.blue49],
                              ).createShader(bounds);
                            },
                            child: Icon(Icons.search,
                                color: AppColors.appBarBackground, size: 14.sp),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _generateInteractTelemetryData(item.searchQuery);
                            widget.updateSearchText(item.searchQuery);
                          },
                          child: SizedBox(
                            width: 0.7.sw,
                            child: Text(item.searchQuery,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(color: AppColors.grey36_1)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 20.sp, color: AppColors.greys60),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () async {
                      await _deleteItem(item);
                      if (_visibleCount < _allRecentSearches.length) {
                        setState(() {
                          _visibleCount =
                              (_visibleCount < _allRecentSearches.length)
                                  ? _visibleCount + 1
                                  : _allRecentSearches.length;
                        });
                      }
                    },
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _generateInteractTelemetryData(String searchQuery) async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getInteractTelemetryEvent(
      pageIdentifier: TelemetryPageIdentifier.globalSearchPageId,
      subType: TelemetrySubType.searchHistory,
      env: TelemetryEnv.home,
      clickId: TelemetryClickId.search,
      contentId: '',
      pageUri:
          '${TelemetryPageIdentifier.globalSearchPageId}?q=${searchQuery}',
    );
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
