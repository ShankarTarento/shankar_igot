import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:igot_ui_components/ui/components/microsite_image_view.dart';
import 'package:smartech_appinbox/model/smt_appinbox_model.dart';
import 'package:url_launcher/url_launcher.dart';


class SMTImageNotificationView extends StatefulWidget {
  final SMTAppInboxMessage inbox;
  const SMTImageNotificationView({Key? key, required this.inbox})
      : super(key: key);

  @override
  State<SMTImageNotificationView> createState() =>
      _SMTImageNotificationViewState();
}

class _SMTImageNotificationViewState extends State<SMTImageNotificationView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16).r,
          child: Center(
            child: MicroSiteImageView(
              imgUrl: widget.inbox.mediaUrl != "" ? widget.inbox.mediaUrl.toString() : '',
              height: 260.w,
              width: double.maxFinite,
              fit: BoxFit.fill,
            ),
          ),
        ),
        widget.inbox.actionButton.length > 0
            ? Container(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          color: Color.fromRGBO(247, 247, 247, 1),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.inbox.actionButton.map((e) {
              return Expanded(
                  child: Center(
                      child: e.aTyp == 1
                          ? InkWell(
                        onTap: () async {
                          if (e.actionDeeplink.contains("http")) {
                            print("navigate to browser with url");
                            final Uri _url =
                            Uri.parse(e.actionDeeplink);
                            if (!await launchUrl(_url))
                              throw 'Could not launch $_url';
                          }
                        },
                        child: Text(
                          e.actionName.toString(),
                          style: TextStyle(
                              color:
                              Color.fromRGBO(75, 79, 81, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                          : e.aTyp == 2
                          ? InkWell(
                        onTap: () async {
                          print("navigation called");
                          Clipboard.setData(ClipboardData(
                              text: e.configCtxt))
                              .then((result) {
                            final snackBar = SnackBar(
                              content: Text('Copied'),
                              duration:
                              Duration(milliseconds: 500),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                                snackBar); // -> show a notification
                          });
                          if (e.actionDeeplink
                              .contains("http")) {
                            print(
                                "navigate to browser with url");
                            final Uri _url =
                            Uri.parse(e.actionDeeplink);
                            if (!await launchUrl(_url))
                              throw 'Could not launch $_url';
                            // await FlutterWebBrowser.openWebPage(url: e.actionDeeplink);
                          } else if (e.actionDeeplink.contains(
                              "smartechflutter://profile")) {
                            // NavigationUtilities.pushRoute(UpdateProfile.route);
                          }
                        },
                        child: Text(
                          e.actionName.toString(),
                          style: TextStyle(
                              color: Color.fromRGBO(
                                  75, 79, 81, 1),
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                          : SizedBox(
                        height: 0,
                      )));
            }).toList(),
          ),
        )
            : SizedBox(
          height: 0,
        ),
      ],
    );
  }
}
