import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../constants/index.dart';

class PDFStructureWidget extends StatefulWidget {
  const PDFStructureWidget({
    super.key,
    required this.resourcename,
    required this.player,
  });

  final String resourcename;
  final Widget player;

  @override
  State<PDFStructureWidget> createState() => _PDFStructureWidgetState();
}

class _PDFStructureWidgetState extends State<PDFStructureWidget> {
  @override
  void dispose() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });
    super.dispose();
  }

  ValueNotifier<bool> _isLandscape = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                backgroundColor: AppColors.appBarBackground,
                pinned: false,
                automaticallyImplyLeading: false,
                flexibleSpace: Row(
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.close,
                          color: AppColors.greys60,
                        ),
                        onPressed: () {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            SystemChrome.setPreferredOrientations([
                              DeviceOrientation.portraitUp,
                              DeviceOrientation.portraitDown,
                            ]);
                          });
                          Future.delayed(Duration(milliseconds: 200),
                              () => Navigator.of(context).pop());
                        }),
                    SizedBox(
                      width: 0.75.sw,
                      child: ValueListenableBuilder<bool>(
                          valueListenable: _isLandscape,
                          builder: (context, value, _) {
                            return Text(
                              widget.resourcename,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                  color: AppColors.greys87,
                                  fontSize: value ? 8.sp : 14.0.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.25),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: OrientationBuilder(builder: (context, orientation) {
            _updateOrientation(orientation);
            return Center(
              child: widget.player,
            );
          }),
        ),
      ),
    );
  }

  void _updateOrientation(Orientation orientation) {
    if ((orientation == Orientation.landscape && !_isLandscape.value) ||
        (orientation == Orientation.portrait && _isLandscape.value)) {
      _isLandscape.value = orientation == Orientation.landscape;
    }
  }
}
