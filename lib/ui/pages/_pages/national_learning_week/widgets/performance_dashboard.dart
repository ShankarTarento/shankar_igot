import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PerformanceDashboard extends StatefulWidget {
  final String url;
  const PerformanceDashboard({super.key, required this.url});

  @override
  State<PerformanceDashboard> createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard> {
  double _webViewHeight = 800.0;
  bool _isScrollingWebView = false;

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
    return Stack(
      children: [
        Container(
          width: 1.sw,
          height: _webViewHeight,
          margin: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 8).r,
          child: GestureDetector(
            onVerticalDragStart: (details) {
              _isScrollingWebView = true;
            },
            onVerticalDragUpdate: (details) {
              if (_isScrollingWebView) {
                Scrollable.of(context).position.moveTo(
                    Scrollable.of(context).position.pixels - details.delta.dy);
              }
            },
            onVerticalDragEnd: (details) {
              _isScrollingWebView = false;
            },
            child: Container(
                height: _webViewHeight.w,
                child: InAppWebView(
                  gestureRecognizers: Set()
                    ..add(Factory<VerticalDragGestureRecognizer>(
                        () => VerticalDragGestureRecognizer())),
                  initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                  // onLoadStop: (controller, url) async {
                  //   final contentHeight = await controller.evaluateJavascript(
                  //       source: "document.body.scrollHeight;");
                  // setState(() {
                  //   _webViewHeight =
                  //       ((double.tryParse(contentHeight.toString()) ??
                  //                   500.0) -
                  //               930)
                  //           .w;
                  // });
                  // },
                )),
          ),
        ),
      ],
    );
  }
}
