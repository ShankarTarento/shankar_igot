import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../constants/index.dart';
import '../../../services/_services/registration_service.dart';
import '../../../util/app_navigator_observer.dart';
import '../index.dart';
import '../language_dropdown.dart';

class SelfRegisterAppbar extends StatefulWidget {
  @override
  State<SelfRegisterAppbar> createState() => _SelfRegisterAppbarState();
}

class _SelfRegisterAppbarState extends State<SelfRegisterAppbar> {
  String karmayogiLogo = '';

  @override
  void initState() {
    super.initState();
    fetchAsset();
  }

  Future<void> fetchAsset() async {
    karmayogiLogo = await RegistrationService().getKarmayogiLogo();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: AppColors.greys,
      automaticallyImplyLeading: false,
      toolbarHeight: 70.w,
      elevation: 0,
      backgroundColor: AppColors.appBarBackground,
      leading: IconButton(
          onPressed: () {
            final previousRoute =
                AppNavigatorObserver.instance.getLastRouteName();
            if (previousRoute == '/') {
              Navigator.pushReplacementNamed(context, AppUrl.onboardingScreen);
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.black87,
            size: 35,
          )),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),
          SvgPicture.asset(
            "assets/img/Karmayogi_bharat_logo_horizontal.svg",
            height: 40.w,
            width: 88.w,
          ),
          Spacer(),
          Row(
            children: [
              LanguageDropdown(
                isHomePage: true,
              ),
              HelpWidget(),
            ],
          )
        ],
      ),
    );
  }
}
