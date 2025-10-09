import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DescriptionWebView extends StatefulWidget {
  final String data;
  const DescriptionWebView({Key? key, required this.data}) : super(key: key);

  @override
  _DescriptionWebViewState createState() => _DescriptionWebViewState();
}

class _DescriptionWebViewState extends State<DescriptionWebView> {
  double _webViewHeight = 50.0;
  late WebViewController _controller;

  bool _isContentLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        Colors.transparent,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _updateHeight();
          },
          onPageFinished: (String url) {
            if (!_isContentLoaded) {
              _isContentLoaded = true;
              _updateHeight();
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            Helper.doLaunchUrl(url: request.url);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(Uri.dataFromString(
        """
          <html lang='en'>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            
          </head>
          <body>
            ${widget.data}
          </body>
          </html>
          """,
        mimeType: 'text/html',
      ).toString()));
  }

  void _updateHeight() {
    if (_isContentLoaded) {
      _controller
          .runJavaScriptReturningResult('document.body.scrollHeight;')
          .then((result) {
        double height = double.tryParse(result.toString()) ?? 500.0;
        if (height != _webViewHeight) {
          setState(() {
            _webViewHeight = height;
          });
        }
      }).catchError((error) {
        debugPrint('Error getting height===============: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        height: Platform.isIOS ? null : _webViewHeight,
        child: Platform.isIOS
            ? HtmlWidget(
                widget.data,
              )
            : WebViewWidget(
                controller: _controller,
              ));
  }
}
