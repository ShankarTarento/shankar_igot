import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart'
    as storage_const;
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/env/env.dart';
import 'package:karmayogi_mobile/landing_page.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';
import '../localization/_langs/english_lang.dart';
import 'package:device_info_plus/device_info_plus.dart';

class InAppWebViewPage extends StatefulWidget {
  final String url;
  final BuildContext parentContext;
  final bool isSurvey;
  const InAppWebViewPage(
      {Key? key,
      required this.url,
      required this.parentContext,
      this.isSurvey = false})
      : super(key: key);

  @override
  State<InAppWebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<InAppWebViewPage> {
  InAppWebViewController? _appWebViewController;
  late InAppWebViewSettings options;
  String? _authToken;
  bool setLocalStorage = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserToken();
    if (widget.isSurvey) {
      _generateImpressionTelemetryData();
    }
    options = InAppWebViewSettings(
      useShouldOverrideUrlLoading: true,
      useOnDownloadStart: true,
      mediaPlaybackRequiresUserGesture: false,
      useHybridComposition: true,
      supportMultipleWindows: true,
      allowsInlineMediaPlayback: true,
      transparentBackground: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.appBarBackground,
        appBar: AppBar(
          title: widget.isSurvey
              ? Text(
                  EnglishLang.karmayogiSurvey,
                  style: GoogleFonts.lato(
                      fontSize: 18.sp, fontWeight: FontWeight.w700),
                )
              : SizedBox(),
          automaticallyImplyLeading: true,
          foregroundColor: AppColors.greys87,
          backgroundColor: AppColors.appBarBackground,
          leading: InkWell(
              onTap: () => Navigator.of(widget.parentContext).pop(),
              child: BackButton(color: AppColors.greys60)),
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                  url: WebUri(_getUrl()), headers: _getHeadersToLoadLink()),
              initialSettings: options,

              onWebViewCreated:
                  (InAppWebViewController webViewController) async {
                _appWebViewController = webViewController;

                await _registerJavaScriptHandlers();
              },

              onDownloadStartRequest: (controller, downloadStartRequest) async {
                try {
                  final url = downloadStartRequest.url.toString();

                  // Handle blob URLs differently
                  if (url.startsWith('blob:')) {
                    await _handleBlobDownload(controller, downloadStartRequest);
                  } else {
                    // Handle regular HTTP/HTTPS downloads
                    await _handleRegularDownload(downloadStartRequest);
                  }
                } catch (e) {
                  debugPrint('Error handling download: $e');
                  // Show error to user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Download failed: $e')),
                  );
                }
              },

              onLoadStart: (controller, url) async {
                if (Platform.isAndroid && !setLocalStorage) {
                  await _setLocalStorageItems();
                }
              },

              shouldOverrideUrlLoading: (controller, navigationAction) async {
                // You can access the URL like this
                final url = navigationAction.request.url.toString();
                // log("Loading URL shouldOverrideUrlLoading: $url");

                if (Platform.isAndroid &&
                    url.toString().startsWith('intent://')) {
                  await Helper.doLaunchUrl(
                      url: 'https://${url.toString().split('intent://').last}',
                      mode: LaunchMode.externalApplication);
                  // This one means prevent navigation
                  return NavigationActionPolicy.CANCEL;
                }

                // Handle blob URLs - let them load but they'll be handled by onDownloadStartRequest
                if (url.toString().startsWith('blob:')) {
                  // Allow blob URLs to load so onDownloadStartRequest can handle them
                  return NavigationActionPolicy.ALLOW;
                }

                // Handle direct file downloads (CSV, PDF, etc.)
                if (_isDirectDownloadUrl(url)) {
                  await Helper.doLaunchUrl(
                      url: url, mode: LaunchMode.externalApplication);
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },

              onProgressChanged: (controller, progress) async {
                _isLoading = await controller.isLoading();
                setState(() {});
              },

              onLoadStop: (controller, url) async {
                if (Platform.isIOS && !setLocalStorage) {
                  await _setLocalStorageItems();
                }

                // Optional: Re-register handlers after page load for extra reliability
                // This helps with timing issues on some devices/platforms
                await _registerJavaScriptHandlers();
              },

              onConsoleMessage: (controller, consoleMessage) {
                // log('Console message: ${consoleMessage.message}');
              },

              // Handle WebView errors
              onReceivedError: (controller, request, error) async {
                debugPrint('WebView Error: ${error.description}');
              },

              // Handle HTTP errors
              onReceivedHttpError: (controller, request, errorResponse) async {
                debugPrint('HTTP Error: ${errorResponse.statusCode}');
              },
            ),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
          ],
        ));
  }

  Future<void> _handleBlobDownload(InAppWebViewController controller,
      DownloadStartRequest downloadStartRequest) async {
    try {
      final suggestedFilename =
          downloadStartRequest.suggestedFilename ?? 'download';
      final mimeType = downloadStartRequest.mimeType ?? '';

      debugPrint('Handling blob download: $suggestedFilename');

      // JavaScript to convert blob to base64
      final jsCode = '''
      (function() {
        try {
          fetch('${downloadStartRequest.url}')
            .then(response => response.blob())
            .then(blob => {
              const reader = new FileReader();
              reader.onloadend = function() {
                const base64data = reader.result.split(',')[1];
                window.flutter_inappwebview.callHandler('BlobDownloadHandler', {
                  filename: '$suggestedFilename',
                  mimeType: '$mimeType',
                  data: base64data
                });
              };
              reader.readAsDataURL(blob);
            })
            .catch(error => {
              console.error('Error fetching blob:', error);
              window.flutter_inappwebview.callHandler('BlobDownloadHandler', {
                error: error.message
              });
            });
        } catch (error) {
          console.error('Error in blob download:', error);
          window.flutter_inappwebview.callHandler('BlobDownloadHandler', {
            error: error.message
          });
        }
      })();
    ''';

      // Register handler for blob download result
      controller.addJavaScriptHandler(
        handlerName: 'BlobDownloadHandler',
        callback: (args) async {
          final data = args[0];
          if (data['error'] != null) {
            debugPrint('Blob download error: ${data['error']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Download failed: ${data['error']}')),
            );
            return;
          }

          final filename = data['filename'] ?? 'download';
          final base64Data = data['data'];
          final fileType = _getFileTypeFromMimeType(data['mimeType'] ?? '');

          await downloadFileToDownloads(base64Data, filename, fileType, true);

          // Remove the handler after use
          await controller.removeJavaScriptHandler(
              handlerName: 'BlobDownloadHandler');
        },
      );

      // Execute the JavaScript
      await controller.evaluateJavascript(source: jsCode);
    } catch (e) {
      debugPrint('Error in blob download: $e');
      throw e;
    }
  }

  String _getFileTypeFromMimeType(String mimeType) {
    switch (mimeType.toLowerCase()) {
      case 'text/csv':
      case 'application/csv':
        return 'csv';
      case 'application/pdf':
        return 'pdf';
      case 'application/vnd.ms-excel':
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        return 'xlsx';
      case 'application/msword':
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return 'docx';
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'text/plain':
        return 'txt';
      case 'application/json':
        return 'json';
      default:
        return 'txt';
    }
  }

  bool _isDirectDownloadUrl(String url) {
    final downloadExtensions = [
      '.pdf',
      '.csv',
      '.xlsx',
      '.xls',
      '.docx',
      '.doc',
      '.zip',
      '.rar',
      '.txt',
      '.json',
      '.xml'
    ];

    final lowerUrl = url.toLowerCase();
    return downloadExtensions.any((ext) => lowerUrl.contains(ext));
  }

  Future<void> _handleRegularDownload(
      DownloadStartRequest downloadStartRequest) async {
    try {
      final url = downloadStartRequest.url.toString();
      final suggestedFilename =
          downloadStartRequest.suggestedFilename ?? 'download';

      debugPrint('Handling regular download: $suggestedFilename from $url');

      // Or launch external browser/downloader
      await Helper.doLaunchUrl(
        url: url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error in regular download: $e');
      throw e;
    }
  }

  Future<void> _registerJavaScriptHandlers() async {
    if (_appWebViewController == null) return;

    try {
      await _appWebViewController!
          .removeJavaScriptHandler(handlerName: 'FlutterChannel');
    } catch (e) {
      debugPrint('Handler removal failed (expected on first registration): $e');
    }

    // Register the main FlutterChannel handler
    _appWebViewController!.addJavaScriptHandler(
      handlerName: 'FlutterChannel',
      callback: (args) async {
        try {
          if (args.isEmpty) {
            debugPrint('FlutterChannel called with no arguments');
            return;
          }

          final data = args[0];
          if (data == null) {
            debugPrint('FlutterChannel called with null data');
            return;
          }

          final content = data['url'];
          final title = data['title'];
          final type = data['type'];

          debugPrint('FlutterChannel called with type: $type');

          switch (type) {
            case 'share':
              if (content != null && title != null) {
                await downloadAndSharePdf(content, title);
              } else {
                debugPrint('Share action missing required parameters');
              }
              break;

            case 'download':
              if (content != null && title != null) {
                final isBase64 = data['isBase64'] ?? false;
                final fileType = data['fileType'] ?? 'pdf';
                await downloadFileToDownloads(
                    content, title, fileType, isBase64);
              } else {
                debugPrint('Download action missing required parameters');
              }
              break;

            default:
              debugPrint('Unknown FlutterChannel action: $type');
          }
        } catch (e) {
          debugPrint('Error in FlutterChannel handler: $e');
        }
      },
    );
  }

  Future<void> _setLocalStorageItems() async {
    await _appWebViewController?.evaluateJavascript(source: '''
      localStorage.setItem('API-KEY','${ApiUrl.apiKey}');
      localStorage.setItem('USER-TOKEN','$_authToken');
      const headerObj = {
        'Authorization': 'bearer ${ApiUrl.apiKey}',
        'x-authenticated-user-token': '$_authToken'
      };
      localStorage.setItem('headers', JSON.stringify(headerObj));
      localStorage.setItem('baseUrl','${ApiUrl.baseUrl}/api');
    ''');
    setLocalStorage = true;
  }

  Future<String> _getUserToken() async {
    final storage = FlutterSecureStorage();
    _authToken = await storage.read(key: storage_const.Storage.authToken);
    if (_authToken == null || JwtDecoder.isExpired(_authToken!)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LandingPage(),
        ),
      );
    } else {
      storage.delete(key: storage_const.Storage.deepLinkPayload);
    }
    return _authToken!;
  }

  _getHeadersToLoadLink() {
    Map<String, String> headers = {
      'Authorization': 'bearer ${ApiUrl.apiKey}',
      'x-authenticated-user-token': '$_authToken'
    };
    return headers;
  }

  String _getUrl() {
    if (widget.isSurvey) {
      return '${Env.portalBaseUrl}/mligot/mlsurvey/${widget.url.split('/').last}';
    } else {
      return widget.url;
    }
  }

  Future<void> downloadFileToDownloads(
      String content, String filename, String fileType, bool isBase64) async {
    try {
      // Request permission if Android
      if (Platform.isAndroid && !await _requestStoragePermission()) {
        throw Exception("Storage permission not granted.");
      }

      // Sanitize filename
      if (filename.length > 100) {
        filename = filename.substring(0, 100);
      }
      // Determine directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          downloadDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        downloadDir = await getApplicationDocumentsDirectory();
      } else {
        throw UnsupportedError("Unsupported platform");
      }

      final path = '${downloadDir!.path}/$filename.$fileType';
      final file = File(path);
      if (isBase64) {
        try {
          final base64Str = content.split(',').last;
          final bytes = base64Decode(base64Str);
          await file.writeAsBytes(bytes);
        } catch (e) {
          throw Exception("Invalid base64 content.");
        }
      } else {
        if (content.startsWith('http')) {
          final response = await get(Uri.parse(content));
          if (response.statusCode != 200) {
            throw Exception("HTTP request failed (${response.statusCode})");
          }
          await file.writeAsBytes(response.bodyBytes);
        } else {
          await file.writeAsString(content);
        }
      }

      debugPrint("File saved at: $path");

      final result = await OpenFile.open(path);
      debugPrint("File open result: ${result.message}");
    } catch (e, stacktrace) {
      debugPrint("Download error: $e");
      debugPrint("Stacktrace: $stacktrace");
    }
  }

  Future<bool> _requestStoragePermission() async {
    Permission _permision = Permission.storage;

    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        _permision = Permission.photos;
      }
    }
    return await Helper.requestPermission(_permision);
  }

  Future<void> downloadAndSharePdf(String url, String filename) async {
    try {
      final response = await get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception("Download failed");

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/$filename.pdf';
      final file = File(path)..writeAsBytesSync(response.bodyBytes);

      final xFile =
          XFile(file.path, name: "$filename.pdf", mimeType: 'application/pdf');
      await SharePlus.instance.share(
        ShareParams(files: [xFile], text: "Sharing PDF: $filename"),
      );
    } catch (e) {
      debugPrint("Download/share error: $e");
    }
  }

  void _generateImpressionTelemetryData() async {
    var telemetryRepository = TelemetryRepository();
    Map eventData = telemetryRepository.getImpressionTelemetryEvent(
        pageIdentifier: TelemetryPageIdentifier.surveyPageId,
        telemetryType: TelemetryType.viewer,
        pageUri: TelemetryPageIdentifier.surveyPageUri
            .replaceAll(':surveyId', widget.url.split('/').last.toString()),
        env: TelemetryEnv.kbSurvey);
    await telemetryRepository.insertEvent(eventData: eventData);
  }
}
