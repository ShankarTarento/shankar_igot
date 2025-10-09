import 'package:flutter/material.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/landing_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UpdatePassword extends StatefulWidget {
  final String? initialUrl;

  const UpdatePassword({Key? key, this.initialUrl}) : super(key: key);
  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.greys)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // You can use this to update a loading indicator if needed
          },
          onPageStarted: (String url) {
            // Handle page load start
          },
          onPageFinished: (String url) {
            // Handle page load finish
          },
          onWebResourceError: (WebResourceError error) {
            // Handle web resource errors
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.contains(ApiUrl.baseUrl + ApiUrl.loginShortUrl)) {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LandingPage(
                    isFromUpdateScreen: true,
                  ),
                ),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
