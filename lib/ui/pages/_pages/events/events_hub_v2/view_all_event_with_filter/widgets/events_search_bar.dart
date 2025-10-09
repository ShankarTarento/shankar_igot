import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:karmayogi_mobile/util/helper.dart';

class EventsSearchBar extends StatefulWidget {
  final Function(String value) onFieldSubmitted;
  final String? searchQuery;
  final bool showButton;
  const EventsSearchBar(
      {super.key,
      required this.onFieldSubmitted,
      this.showButton = false,
      this.searchQuery});

  @override
  _EventsSearchBarState createState() => _EventsSearchBarState();
}

class _EventsSearchBarState extends State<EventsSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.searchQuery ?? "";
    super.initState();
  }

  @override
  void didUpdateWidget(covariant EventsSearchBar oldWidget) {
    if (oldWidget.searchQuery != widget.searchQuery) {
      _controller.text = widget.searchQuery ?? "";
      FocusScope.of(context).unfocus();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 40.w,
          width: widget.showButton ? 0.765.sw : 0.9.sw,
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.black40,
                size: 20.sp,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.grey40,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        _controller.clear();
                      },
                    )
                  : null,
              contentPadding: EdgeInsets.only(top: 4, left: 16).r,
              fillColor: AppColors.appBarBackground,
              filled: true,
              hintText: Helper.capitalizeEachWordFirstCharacter(
                  AppLocalizations.of(context)!.mSearchEvent),
              hintStyle: TextStyle(fontSize: 14.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0).r,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0).r,
                borderSide: BorderSide(color: AppColors.grey24, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: BorderSide(color: AppColors.darkBlue, width: 1.0),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
            onFieldSubmitted: (value) {
              widget.onFieldSubmitted(value);
              if (!widget.showButton) _controller.clear();
            },
          ),
        ),
        Spacer(),
        widget.showButton
            ? InkWell(
                onTap: () {
                  widget.onFieldSubmitted(_controller.text);
                  FocusScope.of(context).unfocus();
                },
                child: CircleAvatar(
                  radius: 23.r,
                  backgroundColor: AppColors.darkBlue,
                  child: Icon(
                    Icons.arrow_forward,
                    color: AppColors.appBarBackground,
                  ),
                ),
              )
            : SizedBox()
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
