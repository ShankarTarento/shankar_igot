import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:smartech_appinbox/model/smt_appinbox_model.dart';


class SMTNotificationItemView extends StatefulWidget {
  final SMTAppInboxMessage inbox;
  final Widget? child;
  const SMTNotificationItemView({Key? key, required this.inbox, this.child})
      : super(key: key);

  @override
  State<SMTNotificationItemView> createState() =>
      _SMTImageNotificationViewState();
}

class _SMTImageNotificationViewState extends State<SMTNotificationItemView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12).r,
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.inbox.publishedDate!.getTimeAndDayCount(),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.grey40,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.w),
                  HtmlWidget(
                    widget.inbox.title,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.greys87,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (widget.inbox.subtitle.toString() != "")
                    HtmlWidget(
                      widget.inbox.subtitle,
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.grey40,
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 8).r,
                    child: HtmlWidget(
                      widget.inbox.body,
                      textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.grey40,
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.w),
                ],
              ),
            ),
            (widget.child != null) ? widget.child! : Container(),
            SizedBox(height: 16.w),
          ],
        ),
      ),
    );
  }
}
