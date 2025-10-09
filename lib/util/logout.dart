import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/rounded_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../respositories/_respositories/login_respository.dart';

class Logout extends StatelessWidget {
  final BuildContext contextMain;
  const Logout({Key? key, required this.contextMain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 20).r,
          width: double.infinity.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.only(bottom: 20).r,
                  height: 6.w,
                  width: 0.25.sw,
                  decoration: BoxDecoration(
                    color: AppColors.grey16,
                    borderRadius: BorderRadius.all(Radius.circular(16)).r,
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 15).r,
                  child: Text(
                    AppLocalizations.of(context)!.mSettingDoYouWantToLogout,
                    style: GoogleFonts.montserrat(
                        decoration: TextDecoration.none,
                        color: AppColors.greys87,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500),
                  )),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(true);
                  doLogout(contextMain);
                },
                child: RoundedButton(
                    buttonLabel:
                        AppLocalizations.of(context)!.mSettingYeslogout,
                    bgColor: AppColors.appBarBackground,
                    textColor: AppColors.darkBlue),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12).r,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(true),
                  child: RoundedButton(
                    buttonLabel:
                        AppLocalizations.of(context)!.mCommonNoTakeMeBack,
                    bgColor: AppColors.darkBlue,
                    textColor: AppColors.appBarBackground,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> doLogout(context) async {
    await Provider.of<LoginRespository>(context, listen: false)
        .doLogout(contextMain);
  }
}
