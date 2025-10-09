
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'localization/_langs/english_lang.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/img/Login_background.svg',
          // alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
        Center(
            child: Container(
          child: Image(
            image: AssetImage('assets/img/karmayogi_bharat.png'),
            height: 0.45.sw,
          ),
        )),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20).r,
          alignment: Alignment.bottomCenter,
          child: Text(
            EnglishLang.publicCopyRightText,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
