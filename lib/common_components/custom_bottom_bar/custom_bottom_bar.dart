import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/custom_bottom_bar/models/bottom_bar_model.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';

class CustomBottomBar extends StatefulWidget {
  final List<BottomBarModel> bottomBarItems;
  final Function(String route)? onTap;
  final int currentIndex;

  const CustomBottomBar({
    super.key,
    required this.bottomBarItems,
    required this.currentIndex,
    this.onTap,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.bottomBarItems.length, vsync: this);
    _tabController.index = widget.currentIndex;
  }

  @override
  void didUpdateWidget(CustomBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _tabController.index) {
      _tabController.animateTo(widget.currentIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 65.w,
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          if (widget.onTap != null) {
            widget.onTap!(widget.bottomBarItems[index].route);
          }
        },
        indicator: BoxDecoration(
          color: AppColors.darkBlue.withValues(alpha: 0.1),
          border: Border(
            top: BorderSide(
              color: AppColors.darkBlue,
              width: 2.0.w,
            ),
          ),
        ),
        indicatorColor: Colors.transparent,
        labelPadding: EdgeInsets.only(top: 0.0).w,
        unselectedLabelColor: AppColors.greys60,
        labelColor: AppColors.darkBlue,
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
            ),
        unselectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
            ),
        tabs: widget.bottomBarItems.map((item) => item.widget).toList(),
      ),
    );
  }
}
