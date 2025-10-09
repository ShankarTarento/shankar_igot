import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../constants/index.dart';
import '../../../../../skeleton/index.dart';

class SearchableBottomSheetContent extends StatefulWidget {
  final List<String> items;
  final Function(String) onItemSelected;
  final String? defaultItem;
  final Future<List<String>> Function(String)? onFetchMore;
  final bool hasMore;
  final String initialQuery;
  final BuildContext? parentContext;

  const SearchableBottomSheetContent(
      {required this.items,
      required this.onItemSelected,
      this.defaultItem,
      this.onFetchMore,
      required this.hasMore,
      required this.initialQuery,
      this.parentContext});

  @override
  State<SearchableBottomSheetContent> createState() =>
      SearchableBottomSheetContentState();
}

class SearchableBottomSheetContentState
    extends State<SearchableBottomSheetContent> {
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final ValueNotifier<List<String>> _filteredItems;

  List<String> _allItems = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _allItems = List.from(widget.items);
    _hasMore = widget.hasMore;
    _currentQuery = widget.initialQuery;

    _filteredItems = ValueNotifier(_getProcessedItems(_allItems));

    if (widget.onFetchMore != null) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _filteredItems.dispose();
    super.dispose();
  }

  List<String> _getProcessedItems(List<String> items) {
    if (widget.defaultItem?.isNotEmpty == true) {
      final itemsWithoutDefault =
          items.where((item) => item != widget.defaultItem).toList();
      return [...itemsWithoutDefault, widget.defaultItem!];
    }
    return items;
  }

  Future<void> _onScroll() async {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        _hasMore &&
        !_isLoading &&
        widget.onFetchMore != null) {
      await _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    setState(() => _isLoading = true);

    try {
      final newItems = await widget.onFetchMore!(_currentQuery);

      if (newItems.isEmpty) {
        _hasMore = false;
      } else {
        _allItems.addAll(newItems);
        _filteredItems.value = _getProcessedItems(_allItems);
      }
    } catch (e) {
      // Handle error appropriately
      _hasMore = false;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onSearchChanged(String value) async {
    _currentQuery = value;

    if (widget.onFetchMore != null) {
      setState(() => _isLoading = true);

      try {
        final newItems = await widget.onFetchMore!(value);
        _allItems = newItems;
        _hasMore = newItems.isNotEmpty;
        _filteredItems.value = _getProcessedItems(_allItems);
      } catch (e) {
        // Handle error appropriately
        _hasMore = false;
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      _performLocalSearch(value);
    }
  }

  void _performLocalSearch(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = widget.items
        .where((item) => item.toLowerCase().contains(lowerQuery))
        .toList();

    _filteredItems.value = _getProcessedItems(filtered);
  }

  bool get _shouldShowSearch =>
      _allItems.length > 10 || widget.onFetchMore != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.7.sh,
      padding: const EdgeInsets.all(16).r,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_shouldShowSearch) ...[
            _buildSearchField(),
            SizedBox(height: 8.w),
          ],
          Flexible(child: _buildItemsList()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText:
            AppLocalizations.of(widget.parentContext ?? context)!.mStaticSearch,
        hintStyle: Theme.of(context).textTheme.labelLarge,
        prefixIcon: Icon(Icons.search, color: AppColors.darkBlue),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(63).r,
          borderSide: BorderSide(color: AppColors.darkBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(63).r,
          borderSide: BorderSide(color: AppColors.darkBlue),
        ),
      ),
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(color: AppColors.greys),
      onChanged: _onSearchChanged,
    );
  }

  Widget _buildItemsList() {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _filteredItems,
      builder: (context, filtered, _) {
        if (filtered.isEmpty && !_isLoading) {
          return Center(
              child: CachedNetworkImage(
                  width: 120.w,
                  height: 100.w,
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
                      color: AppColors.appBarBackground)));
        }

        return ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: filtered.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loader at the bottom if loading
            if (index == filtered.length && _isLoading) {
              return Padding(
                padding: EdgeInsets.all(16.0).r,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
              title: Text(filtered[index]),
              onTap: () {
                widget.onItemSelected(filtered[index]);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
