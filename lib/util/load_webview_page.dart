import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoadWebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const LoadWebViewPage({Key? key, required this.url, required this.title})
      : super(key: key);

  @override
  State<LoadWebViewPage> createState() => _LoadWebViewPageState();
}

class _LoadWebViewPageState extends State<LoadWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Scaffold(
                  appBar: AppBar(
                    titleSpacing: 0,
                    centerTitle: false,
                    title: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontFamily: GoogleFonts.montserrat().fontFamily,
                          ),
                    ),
                  ),
                  body: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Error loading URL',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Error code: ${error.errorCode}\nDescription: ${error.description}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(
                                  fontFamily:
                                      GoogleFonts.montserrat().fontFamily,
                                  fontSize: 12.sp,
                                ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0.w),
        child: AppBar(
          titleSpacing: 0,
          centerTitle: false,
          toolbarHeight: 70.w,
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.black87,
                size: 35.w,
              )),
          title: Text(widget.title,
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 20.sp,
                  color: AppColors.greys)),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
