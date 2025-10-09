import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_discussion_hub/screens/community_view/_models/user_community_model.dart';

class CommunityDropdown extends StatefulWidget {
  final List<UserCommunityIdData>? items;
  final String? selectedItem;
  final ValueChanged<String>? parentAction;
  final String? defaultText;
  final String? defaultValue;

  CommunityDropdown({
    Key? key,
    this.items,
    this.selectedItem,
    this.parentAction,
    this.defaultText,
    this.defaultValue,
  }) : super(key: key);

  @override
  CommunityDropdownState createState() => CommunityDropdownState();
}

class CommunityDropdownState extends State<CommunityDropdown> {
  late String? dropdownValue;
  late List<UserCommunityIdData> dropdownItems;

  @override
  void initState() {
    super.initState();
    dropdownItems = widget.items ?? [];
    if (widget.defaultText != null && widget.defaultValue != null) {
      dropdownItems.insert(0, UserCommunityIdData(communityId: widget.defaultValue, communityName: widget.defaultText));
    }
    initializeDropdown();
  }

  void initializeDropdown() {
    setState(() {
      dropdownValue = widget.selectedItem?.isNotEmpty ?? false
          ? widget.selectedItem
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_drop_down_outlined),
      iconSize: 24.w,
      elevation: 16,
      style: TextStyle(color: AppColors.greys87, overflow: TextOverflow.ellipsis),
      underline: Container(
        color: AppColors.lightGrey,
      ),
      selectedItemBuilder: (BuildContext context) {
        return dropdownItems.map<Widget>((UserCommunityIdData item) {
          return Container(
            width: 0.77.sw,
            child: Row(
              children: [
                SizedBox(
                  width: 0.75.sw,
                  child: HtmlWidget(
                    item.communityName ?? '',
                    textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: (widget.defaultValue != null) ? (item.communityId == widget.defaultValue) ? AppColors.disabledGrey : AppColors.disabledTextGrey : AppColors.disabledTextGrey
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      onChanged: (String? newValue) {
        if (newValue != null && newValue.isNotEmpty) {
          setState(() {
            dropdownValue = newValue;
            widget.parentAction?.call(newValue);
          });
        }
      },
      items: dropdownItems.map<DropdownMenuItem<String>>((UserCommunityIdData item) {
        return DropdownMenuItem<String>(
          value: item.communityId,
          child: HtmlWidget(
            item.communityName ?? '',
            textStyle: TextStyle(
                color: (widget.defaultValue != null) ? (item.communityId == widget.defaultValue) ? AppColors.disabledGrey : AppColors.disabledTextGrey : AppColors.disabledTextGrey
            ),
          ),
        );
      }).toList(),
    );
  }
}
