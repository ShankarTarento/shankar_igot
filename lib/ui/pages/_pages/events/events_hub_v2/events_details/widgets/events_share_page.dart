import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventsSharePage extends StatefulWidget {
  final String eventId;
  const EventsSharePage({super.key, required this.eventId});

  @override
  State<EventsSharePage> createState() => _EventsSharePageState();
}

class _EventsSharePageState extends State<EventsSharePage> {
  TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    _textEditingController.text =
        "${ApiUrl.baseUrl}/app/event-hub/home/${widget.eventId}";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.only(top: 26.0).r,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 16).r,
                child: Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 36.w,
                        width: 36.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey40,
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppColors.whiteGradientOne,
                          size: 16.sp,
                        ),
                      ),
                    )),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(left: 16).r,
                child: Image(
                  image: AssetImage('assets/img/karmasahayogi.png'),
                  height: 160.w,
                ),
              ),
              Container(
                color: AppColors.appBarBackground,
                height: 250.w,
                padding: EdgeInsets.all(16).r,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 16.w,
                    ),
                    Text(
                      AppLocalizations.of(context)!.mContentSharePageHeading,
                      style: GoogleFonts.lato(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 16.w,
                    ),
                    TextFormField(
                      readOnly: true,
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0).r,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0).r,
                          borderSide:
                              BorderSide(color: AppColors.greys87, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              BorderSide(color: AppColors.greys87, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16.w,
                    ),
                    Row(
                      children: [
                        Spacer(),
                        SizedBox(
                          width: 130.w,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.darkBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30).r,
                              ),
                            ),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                  text:
                                      "${ApiUrl.baseUrl}/app/event-hub/home/${widget.eventId}"));

                              _showSnackBar(
                                  AppLocalizations.of(context)!
                                      .mContentSharePageLinkCopied,
                                  AppColors.darkBlue);
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.copy,
                                    color: AppColors.appBarBackground,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(AppLocalizations.of(context)!.mCopy,
                                      style: GoogleFonts.lato(
                                        color: AppColors.appBarBackground,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                      )),
                                ]),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        child: Container(
          width: 1.sw,
          padding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0).r,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(3.0).r,
          ),
          child: Text(
            message,
            style: GoogleFonts.lato(
                color: AppColors.appBarBackground,
                fontSize: 13.sp,
                decoration: TextDecoration.none),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
