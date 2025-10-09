import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartech_appinbox/model/smt_appinbox_model.dart';

import '../utils/utils.dart';
import '../utils/video_player.dart';

class SMTVideoNotificationView extends StatefulWidget {
  final SMTAppInboxMessage inbox;
  const SMTVideoNotificationView({Key? key, required this.inbox})
      : super(key: key);

  @override
  State<SMTVideoNotificationView> createState() =>
      _SMTVideoNotificationViewState();
}

class _SMTVideoNotificationViewState extends State<SMTVideoNotificationView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              widget.inbox.publishedDate!.getTimeAndDayCount(),
              style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.greyColorText,
                  fontWeight: FontWeight.w400),
            ),
          ),
          SizedBox(
            height: 8.w,
          ),
          htmlText(widget.inbox.title),
          if (widget.inbox.subtitle.toString() != "")
            htmlText(widget.inbox.subtitle),
          htmlText(widget.inbox.body),
          SizedBox(
            height: 8.w,
          ),
          InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return VideoPlayerDialog(
                      videoUrl: widget.inbox.mediaUrl,
                    );
                  });
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: AppColor.greyColorText.withValues(alpha: 0.3),
              ),
              height: MediaQuery.of(context).size.height / 5,
              child: Icon(
                Icons.play_circle_outline_outlined,
                size: 66.w,
              ),
            ),
          )
        ],
      ),
    );
  }
}
