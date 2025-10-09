import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path/path.dart' as path;

class DocumentWebView extends StatefulWidget {
  final String title;
  final String fileUrl;

  const DocumentWebView({
    Key? key,
    required this.title,
    required this.fileUrl,
  }) : super(key: key);

  @override
  State<DocumentWebView> createState() => _DocumentWebViewState();
}

class _DocumentWebViewState extends State<DocumentWebView> {
  late final WebViewController _controller;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final fileType = path.extension(widget.fileUrl).toLowerCase();
    final encodedUrl = Uri.encodeFull(widget.fileUrl);
    String viewerUrl;

    if (fileType == '.txt') {
      viewerUrl = widget.fileUrl;
    } else {
      viewerUrl = 'https://docs.google.com/gview?embedded=true&url=$encodedUrl';
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.appBarBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            if (fileType == '.txt') {
              _injectTextStyling();
            }
            _injectColors();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false;
              errorMessage = 'Error loading document: ${error.description}';
            });
            _controller.loadRequest(Uri.parse(widget.fileUrl));
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));
  }

  Future<void> _injectTextStyling() async {
    await _controller.runJavaScript('''
      document.body.style.padding = '20px';
      document.body.style.fontSize = '18px';
      document.body.style.fontFamily = 'Arial, sans-serif';
      document.body.style.lineHeight = '1.6';
      document.body.style.whiteSpace = 'pre-wrap';
      document.body.style.backgroundColor = '#ffffff';
      document.body.style.color = '#000000';
    ''');
  }

  Future<void> _injectColors() async {
    await _controller.runJavaScript('''
      document.body.style.backgroundColor = '#ffffff';
      document.body.style.color = '#000000';
      document.documentElement.style.backgroundColor = '#ffffff';
      document.documentElement.style.color = '#000000';
      
      // For Google Docs viewer
      if (document.getElementsByClassName('drive-viewer-paginated-scrollable').length > 0) {
        document.getElementsByClassName('drive-viewer-paginated-scrollable')[0].style.backgroundColor = '#ffffff';
      }
      
      // Apply black color to all text elements
      var textElements = document.querySelectorAll('p, span, div, h1, h2, h3, h4, h5, h6');
      textElements.forEach(function(element) {
        element.style.color = '#000000';
      });
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: AppColors.greys),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.greys),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.appBarBackground,
      ),
      body: Container(
        color: AppColors.appBarBackground,
        child: Stack(
          children: [
            if (errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0).r,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.mandatoryRed),
                      ),
                      SizedBox(height: 16.w),
                      ElevatedButton(
                        onPressed: _initializeWebView,
                        child: Text(
                          'Try Again',
                          style: TextStyle(color: AppColors.greys),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              WebViewWidget(controller: _controller),
            if (isLoading)
              Container(
                color: AppColors.appBarBackground,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
