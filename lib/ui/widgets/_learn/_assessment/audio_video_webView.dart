import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../pages/index.dart';

class AudioVideoWebView extends StatefulWidget {
  final String htmlText;
  final bool isAudio;
  final bool isVideo;

  const AudioVideoWebView(
      {super.key,
      required this.htmlText,
      this.isAudio = false,
      this.isVideo = false});
  @override
  State<AudioVideoWebView> createState() => _AudioVideoWebViewState();
}

class _AudioVideoWebViewState extends State<AudioVideoWebView> {
  double _webViewHeight = 0.1.sw;
  WebViewController? webViewController;
  bool _isContentLoaded = false;

  @override
  void initState() {
    super.initState();
    initializeController();
  }

  @override
  void didUpdateWidget(AudioVideoWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.htmlText != widget.htmlText) {
      stopAllMedia();
      webViewController!.clearCache();
      setState(() {
        _webViewHeight = 0.1.sw;
        _isContentLoaded = false;
        initializeController();
      });
    }
  }

  @override
  void dispose() {
    stopAllMedia();
    webViewController!.clearCache();
    super.dispose();
  }

  void initializeController() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(Uri.dataFromString(
        '''<html lang='en'>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
          </head>
          <body>
        ${widget.htmlText}
          </body>
          </html>''',
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ).toString()));
  }

  void _updateHeight() {
    if (_isContentLoaded) {
      webViewController!
          .runJavaScriptReturningResult('document.body.scrollHeight;')
          .then((result) {
        double height = double.tryParse(result.toString()) ?? 500.0;
        if (height != _webViewHeight) {
          setState(() {
            _webViewHeight = height;
          });
        }
      }).catchError((error) {
        print('Error getting height===============: $error');
      });
    }
  }

  void stopAllMedia() {
    final stopAllMediaJS = '''
     var mediaElements = document.querySelectorAll('audio, video');
     mediaElements.forEach(function(media) {
        media.pause();
        media.removeAttribute('src'); 
        media.load(); 
     });
  ''';

    webViewController!.runJavaScript(stopAllMediaJS);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TocServices>(builder: (context, tocServices, _) {
      if (!tocServices.isWebWiewPersist) {
        stopAllMedia();
        webViewController!.clearCache();
        Provider.of<TocServices>(context).setWebView();
        initializeController();
      }
      final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
        Factory(() => EagerGestureRecognizer())
      };
      return Container(
        height: _webViewHeight,
        width: 1.0.sw,
        alignment: Alignment.bottomLeft,
        child: WebViewWidget(
            controller: webViewController!
              ..setNavigationDelegate(
                NavigationDelegate(
                  onPageStarted: (url) async {
                    double videoWidth = 0.8.sw;
                    webViewController!.runJavaScript('''
                          document.querySelector("video").setAttribute("width", "$videoWidth");
                        ''');
                    _updateHeight();
                  },
                  onPageFinished: (url) {
                    if (!_isContentLoaded) {
                      _isContentLoaded = true;
                      _updateHeight();
                    }
                  },
                ),
              ),
            gestureRecognizers: gestureRecognizers),
      );
    });
  }
}
