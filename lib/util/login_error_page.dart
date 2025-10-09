import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:karmayogi_mobile/signup.dart';
import 'package:karmayogi_mobile/ui/widgets/_signup/contact_us.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/index.dart';

class LoginErrorPage extends StatelessWidget {
  final String? errorText;
  final isHtmlErrorPage;
  const LoginErrorPage({Key? key, this.errorText, this.isHtmlErrorPage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60).r,
              child: Container(
                width: 0.75.sw,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 16).r,
                      child: Image.asset(
                          'assets/img/Karmayogi_bharat_logo_horizontal.png'),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 48).r,
                          child: !isHtmlErrorPage
                              ? Text(
                                  errorText != null
                                      ? errorText!
                                      : AppLocalizations.of(context)!
                                          .mStaticSomethingWrong,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.negativeLight,
                                  ))
                              : HtmlWidget(
                                  errorText!,
                                  textStyle:
                                      TextStyle(color: AppColors.negativeLight),
                                ),
                        ),
                        TextButton(
                            onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ContactUs(),
                                  ),
                                ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0).r,
                              child: Text(
                                AppLocalizations.of(context)!.mStaticContactUs,
                                style: TextStyle(
                                    color: AppColors.primaryThree,
                                    fontSize: 16.sp),
                              ),
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 135.w,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16).r,
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryThree,
                    minimumSize: const Size.fromHeight(40), // NEW
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppUrl.loginPage);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.mStaticClickHereToLogin,
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  height: 4.w,
                ),
                TextButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appBarBackground,
                    minimumSize: const Size.fromHeight(40), // NEW
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                  child: Text(
                    AppLocalizations.of(context)!.mStaticSignUp,
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primaryThree,
                        fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
