import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartech_appinbox/model/smt_appinbox_model.dart';

class GIFNotificationView extends StatelessWidget {
  final SMTAppInboxMessage inbox;
  const GIFNotificationView({Key? key, required this.inbox}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          inbox.mediaUrl != ""
              ? Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width - 26,
                    child: CachedNetworkImage(
                      fit: BoxFit.fill,
                      placeholder: (context, url) => Center(
                        child: CupertinoActivityIndicator(),
                      ),
                      imageUrl: inbox.mediaUrl.toString(),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
