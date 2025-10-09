import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/models/_models/option_item_model.dart';

import '../../../../../../constants/index.dart';
import '../../../../../skeleton/index.dart';

class OptionBottomSheetContent extends StatefulWidget {
  final List<OptionItemModel> items;
  final double? height;
  final Function(OptionItemModel) onItemSelected;

  const OptionBottomSheetContent({
    required this.items,
    this.height,
    required this.onItemSelected,
    super.key,
  });

  @override
  State<OptionBottomSheetContent> createState() =>
      _OptionBottomSheetContentState();
}

class _OptionBottomSheetContentState extends State<OptionBottomSheetContent> {
  late final ScrollController _scrollController;
  late final ValueNotifier<List<OptionItemModel>> _filteredItems;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _filteredItems =
        ValueNotifier<List<OptionItemModel>>(List.from(widget.items));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _filteredItems.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 0.2.sh,
      child: Padding(
        padding: const EdgeInsets.all(16).r,
        child: _buildItemsList(),
      ),
    );
  }

  Widget _buildItemsList() {
    return ValueListenableBuilder<List<OptionItemModel>>(
      valueListenable: _filteredItems,
      builder: (context, filtered, _) {
        if (filtered.isEmpty) {
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
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            if (index == filtered.length) {
              return Padding(
                padding: const EdgeInsets.all(16).r,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final item = filtered[index];
            return ListTile(
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              contentPadding: EdgeInsets.zero,
              title: Text(
                item.level,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.greys60,
                      fontWeight: FontWeight.w400,
                    ),
              ),
              onTap: () {
                widget.onItemSelected(item);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
