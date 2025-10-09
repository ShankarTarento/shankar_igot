import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../../constants/_constants/color_constants.dart';

class AddDiscussionWidget extends StatefulWidget {
  final String text;
  final Widget? startingIcon;
  final String hintText;
  final bool isReply;
  final bool readOnly;
  final String replyText;
  final Function callback;

  AddDiscussionWidget(
      {this.text = '',
      this.startingIcon,
      required this.hintText,
      this.isReply = false,
      this.readOnly = false,
      this.replyText = '',
      required this.callback});
  @override
  _AddDiscussionWidgetState createState() => _AddDiscussionWidgetState();
}

class _AddDiscussionWidgetState extends State<AddDiscussionWidget> {
  onTapCallback() async {
    FocusScope.of(context).unfocus();
    widget.callback();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: (widget.isReply)
              ? AppColors.replyBackgroundColor
              : AppColors.appBarBackground,
          borderRadius: BorderRadius.all(Radius.circular(12).r),
        ),
        child: Column(
          children: [
            if (widget.replyText != '') _replyToView(),
            _addDiscussionWidget(),
          ],
        ));
  }

  Widget _replyToView() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(left: 16, right: 16, top: 16).r,
      child: Text(
        widget.replyText,
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _addDiscussionWidget() {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16).r,
      child: Row(
        children: [
          if (widget.startingIcon != null) widget.startingIcon ?? SizedBox(),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!widget.readOnly) onTapCallback();
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8).r,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16).r,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey08),
                    borderRadius:
                        BorderRadius.all(const Radius.circular(50.0).r),
                    color: widget.readOnly
                        ? AppColors.grey04
                        : AppColors.appBarBackground),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Text(
                      widget.hintText,
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey40,
                                fontSize: 12.sp,
                              ),
                      overflow: TextOverflow.ellipsis,
                    )),
                    Container(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 2, right: 2).r,
                            child: Icon(
                              Icons.sentiment_satisfied_outlined,
                              size: 24.w,
                              color: AppColors.primaryOne,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, right: 4).r,
                            child: Icon(
                              Icons.perm_media,
                              size: 24.w,
                              color: Color.fromRGBO(132, 88, 255, 1),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          if ((!widget.isReply) && (!widget.readOnly))
            _actionButton(!widget.readOnly),
        ],
      ),
    );
  }

  Widget _actionButton(bool isEnabled) {
    return ElevatedButton(
        onPressed: () async {},
        child: Container(
            width: 28.w,
            alignment: Alignment.center,
            child: Icon(
              Icons.send_rounded,
              size: 24.w,
              color: AppColors.appBarBackground,
            )),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.darkBlue : AppColors.grey16,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(63).r,
          ),
        ));
  }
}
