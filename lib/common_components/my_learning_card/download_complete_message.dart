import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_file_plus/open_file_plus.dart';

class DownloadCompleteMessage extends StatelessWidget {
  final String filePath;
  final BuildContext parentContext;

  const DownloadCompleteMessage({
    super.key,
    required this.filePath,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  padding: EdgeInsets.all(20).r,
                  width: double.infinity.w,
                  height: filePath != '' ? 190.0.w : 140.w,
                  color: AppColors.appBarBackground,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 15).r,
                          child: Text(
                            AppLocalizations.of(parentContext)!
                                .mStaticFileDownloadingCompleted,
                            style: GoogleFonts.montserrat(
                                decoration: TextDecoration.none,
                                color: AppColors.greys87,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400),
                          )),
                      filePath != ''
                          ? Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 10).r,
                                child: GestureDetector(
                                  onTap: () => _openFile(filePath),
                                  child: roundedButton(
                                    AppLocalizations.of(parentContext)!
                                        .mStaticOpen,
                                    AppColors.darkBlue,
                                    AppColors.appBarBackground,
                                  ),
                                ),
                              ),
                            )
                          : Center(),
                      // Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 15).r,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: roundedButton(
                              AppLocalizations.of(parentContext)!.mCommonClose,
                              AppColors.appBarBackground,
                              AppColors.customBlue),
                        ),
                      ),
                    ],
                  ),
                )))
      ],
    );
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = Container(
      padding: EdgeInsets.all(10).r,
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(4.0)).r,
        border: bgColor == AppColors.appBarBackground
            ? Border.all(color: AppColors.grey40)
            : Border.all(color: bgColor),
      ),
      child: Text(
        buttonLabel,
        style: GoogleFonts.montserrat(
            decoration: TextDecoration.none,
            color: textColor,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500),
      ),
    );
    return loginBtn;
  }

  Future<dynamic> _openFile(filePath) async {
    await OpenFile.open(filePath);
  }
}
